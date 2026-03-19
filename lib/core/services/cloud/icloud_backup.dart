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
  static const String _containerId = 'iCloud.com.relink';

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

    await ICloudStorage.download(
      containerId: _containerId,
      relativePath: filename,
      destinationFilePath: localPath,
    );

    return File(localPath);
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
