import 'dart:io';
import '../backup/backup_format.dart';
import 'cloud_backup_provider.dart';

/// iOS iCloud Drive 백업 구현
/// TODO Phase 2: icloud_storage 패키지 API 연동
class ICloudBackup implements CloudBackupProvider {
  // iCloud 컨테이너 ID — Info.plist의 NSUbiquitousContainers와 일치해야 함
  // static const String _containerId = 'iCloud.com.relink';

  @override
  Future<bool> isAvailable() async {
    if (!Platform.isIOS) return false;
    // TODO Phase 2: iCloud 가용성 확인
    return false;
  }

  @override
  Future<void> upload(File rlinkFile) async {
    // TODO Phase 2: iCloud Drive 업로드
    // ICloudStorage.upload(containerId, filePath, destinationRelativePath)
    throw UnimplementedError('iCloud 업로드는 Phase 2에서 구현됩니다.');
  }

  @override
  Future<List<BackupInfo>> listBackups() async {
    // TODO Phase 2: iCloud 파일 목록 조회
    return [];
  }

  @override
  Future<File> download(String filename) async {
    // TODO Phase 2: iCloud Drive 다운로드
    throw UnimplementedError('iCloud 다운로드는 Phase 2에서 구현됩니다.');
  }

  @override
  Future<void> pruneOldBackups({int keepCount = 5}) async {
    // TODO Phase 2
  }
}
