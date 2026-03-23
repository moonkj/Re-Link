import 'dart:io';
import 'dart:convert';
import 'package:archive/archive_io.dart';
import 'package:crypto/crypto.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../database/app_database.dart';
import '../media/media_service.dart';
import 'backup_format.dart';
import '../../../shared/repositories/db_provider.dart';
import '../../../shared/repositories/settings_repository.dart';
import '../../../shared/repositories/node_repository.dart';

part 'backup_service.g.dart';

@riverpod
BackupService backupService(Ref ref) => BackupService(
      db: ref.watch(appDatabaseProvider),
      media: ref.watch(mediaServiceProvider),
      settings: ref.watch(settingsRepositoryProvider),
      nodeRepo: ref.watch(nodeRepositoryProvider),
    );

class BackupService {
  BackupService({
    required this.db,
    required this.media,
    required this.settings,
    required this.nodeRepo,
  });

  final AppDatabase db;
  final MediaService media;
  final SettingsRepository settings;
  final NodeRepository nodeRepo;

  // ── 백업 생성 ─────────────────────────────────────────────────────────────

  /// DB + 미디어 → .rlink ZIP 파일 생성 → 로컬 임시 경로 반환
  ///
  /// [versioned]가 true이면 버전 번호가 포함된 파일명을 사용하고
  /// 버전 히스토리에 기록한다 (패밀리플러스 전용).
  Future<File> createBackup({bool versioned = false}) async {
    final now = DateTime.now();
    final tmpDir = await getTemporaryDirectory();

    // 버전 관리 백업인 경우 버전 번호 포함 파일명
    final int? backupVersion;
    final String filename;
    if (versioned) {
      backupVersion = await settings.getNextBackupVersion();
      filename = BackupManifest.generateVersionedFilename(now, backupVersion);
    } else {
      backupVersion = null;
      filename = BackupManifest.generateFilename(now);
    }
    final outPath = p.join(tmpDir.path, filename);

    // 통계
    final stats = await db.getStats();
    final nodeCount = stats['nodes'] ?? 0;
    final memoryCount = stats['memories'] ?? 0;
    final info = await PackageInfo.fromPlatform();

    // DB 파일 경로
    final dbPath = await getDatabasePath();

    // 미디어 디렉토리
    final mediaDir = await media.mediaRootDir;

    // ZIP 생성
    final encoder = ZipFileEncoder();
    encoder.create(outPath);

    // DB 추가
    if (await File(dbPath).exists()) {
      encoder.addFile(File(dbPath), 'relink.db');
    }

    // 미디어 파일 추가
    if (await mediaDir.exists()) {
      await encoder.addDirectory(mediaDir, includeDirName: true);
    }

    // 내 노드 ID + 초대 코드 가져오기
    final myNodeId = await settings.getMyNodeId();
    final inviteCode = await settings.getInviteCode();

    // manifest 추가 (크기는 나중에)
    final manifestTmp = File(p.join(tmpDir.path, 'manifest_tmp.json'));
    final manifest = BackupManifest(
      version: BackupManifest.currentVersion,
      createdAt: now,
      appVersion: '${info.version}+${info.buildNumber}',
      nodeCount: nodeCount,
      memoryCount: memoryCount,
      totalBytes: 0, // ZIP 완료 후 업데이트
      senderNodeId: myNodeId,
      inviteCode: inviteCode,
    );
    await manifestTmp.writeAsString(manifest.toJsonString());
    encoder.addFile(manifestTmp, 'manifest.json');

    encoder.close();

    // 체크섬
    final bytes = await File(outPath).readAsBytes();
    final checksum = sha256.convert(bytes).toString();
    final finalManifest = BackupManifest(
      version: manifest.version,
      createdAt: manifest.createdAt,
      appVersion: manifest.appVersion,
      nodeCount: manifest.nodeCount,
      memoryCount: manifest.memoryCount,
      totalBytes: bytes.length,
      checksum: checksum,
      senderNodeId: manifest.senderNodeId,
      inviteCode: manifest.inviteCode,
    );
    // manifest를 체크섬 포함해서 다시 덮어쓰기 (별도 파일에 저장)
    final checksumFile = File(p.join(tmpDir.path, '$filename.meta'));
    await checksumFile.writeAsString(jsonEncode(finalManifest.toJson()));

    // 마지막 백업 시각 기록
    await settings.setLastBackupAt(now);

    // 버전 관리 백업인 경우 히스토리에 추가
    if (versioned && backupVersion != null) {
      await settings.addBackupVersion(BackupVersionEntry(
        version: backupVersion,
        date: now.toIso8601String(),
        fileName: filename,
        sizeBytes: bytes.length,
      ));
    }

    return File(outPath);
  }

  // ── 백업 복원 ─────────────────────────────────────────────────────────────

  /// .rlink 파일 → DB + 미디어 복원
  ///
  /// 복원 후 앱을 재시작해야 DB가 올바르게 재연결됩니다.
  /// [restoreCompleted]가 true인 상태에서 호출 측이 앱 재시작을 안내해야 합니다.
  bool restoreCompleted = false;

  Future<BackupManifest> restoreBackup(File rlinkFile) async {
    // 파일 존재 확인
    if (!await rlinkFile.exists()) {
      throw Exception('백업 파일이 존재하지 않습니다: ${rlinkFile.path}');
    }

    // 파일 크기 확인 (비어있는 파일 거부)
    final fileLength = await rlinkFile.length();
    if (fileLength == 0) {
      throw Exception('백업 파일이 비어있습니다.');
    }

    final tmpDir = await getTemporaryDirectory();
    final extractDir = Directory(p.join(tmpDir.path, 'restore_${DateTime.now().millisecondsSinceEpoch}'));
    await extractDir.create(recursive: true);

    try {
      // ZIP 해제
      final bytes = await rlinkFile.readAsBytes();
      final Archive archive;
      try {
        archive = ZipDecoder().decodeBytes(bytes);
      } catch (e) {
        throw Exception('유효하지 않은 백업 파일입니다. ZIP 형식이 아닙니다: $e');
      }
      await extractArchiveToDisk(archive, extractDir.path);

      // manifest 읽기
      final manifestFile = File(p.join(extractDir.path, 'manifest.json'));
      if (!await manifestFile.exists()) {
        throw Exception('유효하지 않은 백업 파일입니다. manifest.json이 없습니다.');
      }
      final manifest = BackupManifest.fromJson(
          jsonDecode(await manifestFile.readAsString()) as Map<String, dynamic>);

      // DB 복원
      final dbPath = await getDatabasePath();
      final backupDb = File(p.join(extractDir.path, 'relink.db'));
      if (await backupDb.exists()) {
        // DB를 닫고 파일을 덮어씀
        await db.close();
        await backupDb.copy(dbPath);
        restoreCompleted = true;
        // 중요: DB가 닫힌 상태이므로, 앱 재시작이 필요함.
        // Riverpod의 appDatabaseProvider를 invalidate해야 새 연결이 생성됨.
      } else {
        throw Exception('백업 파일에 데이터베이스(relink.db)가 포함되어 있지 않습니다.');
      }

      // 미디어 복원
      final backupMedia = Directory(p.join(extractDir.path, 'media'));
      if (await backupMedia.exists()) {
        final mediaDir = await media.mediaRootDir;
        await _copyDirectory(backupMedia, mediaDir);
      }

      return manifest;
    } finally {
      // 임시 디렉토리 정리 (성공이든 실패든)
      try {
        if (await extractDir.exists()) {
          await extractDir.delete(recursive: true);
        }
      } catch (_) {
        // 정리 실패는 무시
      }
    }
  }

  // ── 로컬 백업 목록 ────────────────────────────────────────────────────────

  Future<List<File>> getLocalBackups() async {
    final tmpDir = await getTemporaryDirectory();
    final files = tmpDir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.rlink'))
        .toList()
      ..sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));
    return files;
  }

  // ── 유틸리티 ──────────────────────────────────────────────────────────────

  Future<void> _copyDirectory(Directory src, Directory dst) async {
    if (!await dst.exists()) await dst.create(recursive: true);
    await for (final entity in src.list(recursive: false)) {
      final target = p.join(dst.path, p.basename(entity.path));
      if (entity is File) {
        await entity.copy(target);
      } else if (entity is Directory) {
        await _copyDirectory(entity, Directory(target));
      }
    }
  }
}
