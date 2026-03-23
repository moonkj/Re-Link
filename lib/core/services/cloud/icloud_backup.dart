import 'dart:io';
import 'package:icloud_storage/icloud_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../backup/backup_format.dart';
import 'cloud_backup_provider.dart';

/// iOS iCloud Drive 백업 구현
/// iCloud 컨테이너 ID: iCloud.com.relink
///
/// 사전 조건 (Xcode에서 설정):
///   Runner → Signing & Capabilities → + Capability → iCloud → Documents 체크
///   Containers: iCloud.com.relink 추가
class ICloudBackup implements CloudBackupProvider {
  static const String _containerId = 'iCloud.com.relink.app';

  @override
  Future<bool> isAvailable() async {
    if (!Platform.isIOS) return false;
    try {
      await ICloudStorage.gather(containerId: _containerId);
      return true;
    } catch (_) {
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
                filename: p.basename(f.relativePath),
                createdAt: f.creationDate,
                sizeBytes: f.sizeInBytes,
                nodeCount: 0,
                memoryCount: 0,
                source: 'icloud',
              ))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (_) {
      return [];
    }
  }

  @override
  Future<File> download(String filename) async {
    final tmpDir = await getTemporaryDirectory();
    final localPath = p.join(tmpDir.path, filename);

    // 기존 파일 삭제 (이전 다운로드 잔여물 방지)
    final existing = File(localPath);
    if (await existing.exists()) {
      await existing.delete();
    }

    await ICloudStorage.download(
      containerId: _containerId,
      relativePath: filename,
      destinationFilePath: localPath,
    );

    // 다운로드 완료 대기 (iCloud는 비동기 다운로드)
    final file = File(localPath);
    for (int i = 0; i < 30; i++) {
      if (await file.exists() && await file.length() > 0) {
        return file;
      }
      await Future.delayed(const Duration(seconds: 1));
    }

    if (!await file.exists() || await file.length() == 0) {
      throw Exception('iCloud에서 파일 다운로드에 실패했습니다. 네트워크를 확인해주세요.');
    }

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
      } catch (_) {
        // 삭제 실패 무시 — 다음 기회에 정리
      }
    }
  }
}
