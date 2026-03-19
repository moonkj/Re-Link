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
  Future<File> createBackup() async {
    final now = DateTime.now();
    final tmpDir = await getTemporaryDirectory();
    final filename = BackupManifest.generateFilename(now);
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

    // manifest 추가 (크기는 나중에)
    final manifestTmp = File(p.join(tmpDir.path, 'manifest_tmp.json'));
    final manifest = BackupManifest(
      version: BackupManifest.currentVersion,
      createdAt: now,
      appVersion: '${info.version}+${info.buildNumber}',
      nodeCount: nodeCount,
      memoryCount: memoryCount,
      totalBytes: 0, // ZIP 완료 후 업데이트
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
    );
    // manifest를 체크섬 포함해서 다시 덮어쓰기 (별도 파일에 저장)
    final checksumFile = File(p.join(tmpDir.path, '$filename.meta'));
    await checksumFile.writeAsString(jsonEncode(finalManifest.toJson()));

    // 마지막 백업 시각 기록
    await settings.setLastBackupAt(now);

    return File(outPath);
  }

  // ── 백업 복원 ─────────────────────────────────────────────────────────────

  /// .rlink 파일 → DB + 미디어 복원
  Future<BackupManifest> restoreBackup(File rlinkFile) async {
    final tmpDir = await getTemporaryDirectory();
    final extractDir = Directory(p.join(tmpDir.path, 'restore_${DateTime.now().millisecondsSinceEpoch}'));
    await extractDir.create(recursive: true);

    // ZIP 해제
    final bytes = await rlinkFile.readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);
    await extractArchiveToDisk(archive, extractDir.path);

    // manifest 읽기
    final manifestFile = File(p.join(extractDir.path, 'manifest.json'));
    if (!await manifestFile.exists()) throw Exception('유효하지 않은 백업 파일입니다.');
    final manifest = BackupManifest.fromJson(
        jsonDecode(await manifestFile.readAsString()) as Map<String, dynamic>);

    // DB 복원
    final dbPath = await getDatabasePath();
    final backupDb = File(p.join(extractDir.path, 'relink.db'));
    if (await backupDb.exists()) {
      await db.close();
      await backupDb.copy(dbPath);
      // DB 재연결은 앱 재시작 시 자동으로 됨
    }

    // 미디어 복원
    final backupMedia = Directory(p.join(extractDir.path, 'media'));
    if (await backupMedia.exists()) {
      final mediaDir = await media.mediaRootDir;
      await _copyDirectory(backupMedia, mediaDir);
    }

    // 임시 디렉토리 정리
    await extractDir.delete(recursive: true);

    return manifest;
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
