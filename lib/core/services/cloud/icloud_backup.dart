import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:icloud_storage/icloud_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../backup/backup_format.dart';
import 'cloud_backup_provider.dart';

/// iOS iCloud Drive 백업 구현
/// iCloud 컨테이너 ID: iCloud.com.relink.app
///
/// 사전 조건 (Xcode에서 설정):
///   Runner → Signing & Capabilities → + Capability → iCloud → Documents 체크
///   Containers: iCloud.com.relink.app 추가
class ICloudBackup implements CloudBackupProvider {
  static const String _containerId = 'iCloud.com.relink.app';

  @override
  Future<bool> isAvailable() async {
    if (!Platform.isIOS) return false;
    try {
      await ICloudStorage.gather(containerId: _containerId);
      return true;
    } catch (e) {
      debugPrint('[ICloudBackup] isAvailable 실패: $e');
      return false;
    }
  }

  @override
  Future<void> upload(File rlinkFile) async {
    final filename = p.basename(rlinkFile.path);
    await ICloudStorage.upload(
      containerId: _containerId,
      filePath: rlinkFile.path,
      destinationRelativePath: filename,
    );
  }

  @override
  Future<List<BackupInfo>> listBackups() async {
    if (!Platform.isIOS) return [];
    try {
      final files = await ICloudStorage.gather(containerId: _containerId);
      return files
          .where((f) => f.relativePath.endsWith('.rlink'))
          .map((f) => BackupInfo(
                filename: Uri.decodeComponent(p.basename(f.relativePath)),
                createdAt: f.creationDate,
                sizeBytes: f.sizeInBytes,
                nodeCount: 0,
                memoryCount: 0,
                source: 'icloud',
              ))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      debugPrint('[ICloudBackup] listBackups 실패: $e');
      return [];
    }
  }

  @override
  Future<File> download(String filename) async {
    final decodedFilename = Uri.decodeComponent(filename);
    final tmpDir = await getTemporaryDirectory();
    final localPath = p.join(tmpDir.path, decodedFilename);

    // 기존 파일 삭제 (이전 다운로드 잔여물 방지)
    final existing = File(localPath);
    if (await existing.exists()) {
      await existing.delete();
    }

    debugPrint('[ICloudBackup] 다운로드 시작: $decodedFilename → $localPath');

    // Completer로 다운로드 완료를 정확히 감지
    final completer = Completer<void>();
    StreamSubscription<double>? progressSub;

    try {
      await ICloudStorage.download(
        containerId: _containerId,
        relativePath: decodedFilename,
        destinationFilePath: localPath,
        onProgress: (stream) {
          progressSub = stream.listen(
            (progress) {
              debugPrint('[ICloudBackup] 다운로드 진행: ${(progress * 100).toStringAsFixed(0)}%');
              if (progress >= 1.0 && !completer.isCompleted) {
                completer.complete();
              }
            },
            onError: (e) {
              if (!completer.isCompleted) {
                completer.completeError(e);
              }
            },
            onDone: () {
              if (!completer.isCompleted) {
                completer.complete();
              }
            },
          );
        },
      );

      // onProgress 콜백이 호출되지 않는 경우 폴백 (이미 로컬에 있는 파일)
      final file = File(localPath);
      if (await file.exists() && await file.length() > 0) {
        if (!completer.isCompleted) completer.complete();
      }

      // 최대 60초 대기 (대용량 백업 대비)
      await completer.future.timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          debugPrint('[ICloudBackup] 다운로드 타임아웃 (60초)');
        },
      );
    } finally {
      await progressSub?.cancel();
    }

    final file = File(localPath);
    if (!await file.exists() || await file.length() == 0) {
      throw Exception('iCloud에서 파일 다운로드에 실패했습니다. 네트워크를 확인해주세요.');
    }

    debugPrint('[ICloudBackup] 다운로드 완료: ${await file.length()} bytes');
    return file;
  }

  @override
  Future<void> pruneOldBackups({int keepCount = 5}) async {
    final all = await listBackups();
    if (all.length <= keepCount) return;

    for (final backup in all.skip(keepCount)) {
      try {
        await ICloudStorage.delete(
          containerId: _containerId,
          relativePath: backup.filename,
        );
      } catch (e) {
        debugPrint('[ICloudBackup] 오래된 백업 삭제 실패: ${backup.filename} — $e');
      }
    }
  }
}
