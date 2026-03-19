import 'dart:io';
import '../backup/backup_format.dart';

/// 클라우드 백업 공통 인터페이스
abstract class CloudBackupProvider {
  /// 클라우드에 .rlink 파일 업로드
  Future<void> upload(File rlinkFile);

  /// 클라우드에서 백업 목록 조회
  Future<List<BackupInfo>> listBackups();

  /// 클라우드에서 파일 다운로드 → 로컬 File 반환
  Future<File> download(String filename);

  /// 오래된 백업 삭제 (최대 5개 유지)
  Future<void> pruneOldBackups({int keepCount = 5});

  /// 사용 가능 여부 (로그인 여부, 권한 등)
  Future<bool> isAvailable();
}
