import 'dart:io';
import 'dart:developer' as dev;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../backup/backup_format.dart';
import 'cloud_backup_provider.dart';

/// Android Google Drive 백업 구현
/// 앱 전용 폴더(appDataFolder) 사용 — 사용자 Drive에 보이지 않음
class GoogleDriveBackup implements CloudBackupProvider {
  static const String _tag = 'GoogleDriveBackup';

  static final _googleSignIn = GoogleSignIn(
    scopes: [drive.DriveApi.driveAppdataScope],
  );

  drive.DriveApi? _driveApi;

  /// 인증된 DriveApi 인스턴스를 반환한다.
  /// 로그인 상태가 아니면 silent sign-in을 시도한다.
  /// 토큰 만료 시 재인증을 위해 매번 새 auth headers를 사용한다.
  Future<drive.DriveApi?> _getApi() async {
    try {
      final account =
          _googleSignIn.currentUser ?? await _googleSignIn.signInSilently();
      if (account == null) {
        dev.log('[$_tag] Google 계정 로그인 필요', name: _tag);
        return null;
      }
      // 매번 새 authHeaders를 가져와서 토큰 만료 문제 방지
      final authHeaders = await account.authHeaders;
      if (authHeaders.isEmpty) {
        dev.log('[$_tag] authHeaders가 비어있음 — 재인증 필요', name: _tag);
        _driveApi = null;
        return null;
      }
      final client = _GoogleAuthClient(authHeaders);
      _driveApi = drive.DriveApi(client);
      return _driveApi;
    } catch (e, st) {
      dev.log('[$_tag] API 초기화 실패: $e', name: _tag, error: e, stackTrace: st);
      _driveApi = null;
      return null;
    }
  }

  @override
  Future<bool> isAvailable() async {
    if (!Platform.isAndroid) return false;
    try {
      final api = await _getApi();
      final available = api != null;
      dev.log('[$_tag] isAvailable: $available', name: _tag);
      return available;
    } catch (e, st) {
      dev.log('[$_tag] isAvailable 실패: $e', name: _tag, error: e, stackTrace: st);
      return false;
    }
  }

  /// 사용자에게 Google 로그인 대화상자를 표시한다.
  /// 로그인 성공 시 true를 반환한다.
  Future<bool> signIn() async {
    try {
      final account = await _googleSignIn.signIn();
      final success = account != null;
      dev.log('[$_tag] signIn: $success', name: _tag);
      return success;
    } catch (e, st) {
      dev.log('[$_tag] signIn 실패: $e', name: _tag, error: e, stackTrace: st);
      return false;
    }
  }

  /// Google 계정 로그아웃
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      _driveApi = null;
      dev.log('[$_tag] signOut 완료', name: _tag);
    } catch (e, st) {
      dev.log('[$_tag] signOut 실패: $e', name: _tag, error: e, stackTrace: st);
    }
  }

  @override
  Future<void> upload(File rlinkFile) async {
    final api = await _getApi();
    if (api == null) throw Exception('Google 계정 연결이 필요합니다.');

    final filename = p.basename(rlinkFile.path);
    final fileSize = await rlinkFile.length();

    dev.log('[$_tag] 업로드 시작: $filename ($fileSize bytes)', name: _tag);

    final meta = drive.File()
      ..name = filename
      ..parents = ['appDataFolder'];

    try {
      final result = await api.files.create(
        meta,
        uploadMedia: drive.Media(rlinkFile.openRead(), fileSize),
      );
      dev.log(
        '[$_tag] 업로드 완료: ${result.name} (id: ${result.id})',
        name: _tag,
      );
    } catch (e, st) {
      dev.log('[$_tag] 업로드 실패: $filename — $e', name: _tag, error: e, stackTrace: st);
      throw Exception('Google Drive 업로드 실패: $e');
    }
  }

  @override
  Future<List<BackupInfo>> listBackups() async {
    final api = await _getApi();
    if (api == null) {
      dev.log('[$_tag] listBackups: API 없음 — 빈 목록 반환', name: _tag);
      return [];
    }

    try {
      final result = await api.files.list(
        spaces: 'appDataFolder',
        q: "name contains '.rlink'",
        orderBy: 'createdTime desc',
        $fields: 'files(id,name,size,createdTime)',
      );

      final files = result.files ?? [];
      dev.log('[$_tag] listBackups: ${files.length}개 백업 발견', name: _tag);

      return files.map((f) {
        return BackupInfo(
          filename: f.name ?? '',
          createdAt: f.createdTime ?? DateTime.now(),
          sizeBytes: int.tryParse(f.size ?? '0') ?? 0,
          nodeCount: 0,
          memoryCount: 0,
          source: 'google',
        );
      }).toList();
    } catch (e, st) {
      dev.log('[$_tag] listBackups 실패: $e', name: _tag, error: e, stackTrace: st);
      return [];
    }
  }

  @override
  Future<File> download(String filename) async {
    final api = await _getApi();
    if (api == null) throw Exception('Google 계정 연결이 필요합니다.');

    dev.log('[$_tag] 다운로드 시작: $filename', name: _tag);

    try {
      // 1) 파일명으로 파일 ID 조회
      final result = await api.files.list(
        spaces: 'appDataFolder',
        q: "name = '$filename'",
        $fields: 'files(id,name)',
      );
      final fileId = result.files?.firstOrNull?.id;
      if (fileId == null) {
        throw Exception('백업 파일을 찾을 수 없습니다: $filename');
      }

      // 2) 파일 다운로드 (Media 스트림)
      final media = await api.files.get(
        fileId,
        downloadOptions: drive.DownloadOptions.fullMedia,
      ) as drive.Media;

      // 3) 스트림을 로컬 임시 파일로 저장
      final tmpDir = await getTemporaryDirectory();
      final localPath = p.join(tmpDir.path, filename);
      final localFile = File(localPath);
      final sink = localFile.openWrite();

      await for (final chunk in media.stream) {
        sink.add(chunk);
      }
      await sink.flush();
      await sink.close();

      final downloadedSize = await localFile.length();
      dev.log(
        '[$_tag] 다운로드 완료: $filename ($downloadedSize bytes)',
        name: _tag,
      );

      return localFile;
    } catch (e, st) {
      dev.log('[$_tag] 다운로드 실패: $filename — $e', name: _tag, error: e, stackTrace: st);
      if (e is Exception) rethrow;
      throw Exception('Google Drive 다운로드 실패: $e');
    }
  }

  /// 지정한 파일명의 백업을 Google Drive에서 삭제한다.
  Future<void> deleteBackup(String filename) async {
    final api = await _getApi();
    if (api == null) throw Exception('Google 계정 연결이 필요합니다.');

    dev.log('[$_tag] 삭제 시작: $filename', name: _tag);

    try {
      final result = await api.files.list(
        spaces: 'appDataFolder',
        q: "name = '$filename'",
        $fields: 'files(id,name)',
      );
      final fileId = result.files?.firstOrNull?.id;
      if (fileId == null) {
        dev.log('[$_tag] 삭제 대상 없음: $filename', name: _tag);
        return;
      }

      await api.files.delete(fileId);
      dev.log('[$_tag] 삭제 완료: $filename (id: $fileId)', name: _tag);
    } catch (e, st) {
      dev.log('[$_tag] 삭제 실패: $filename — $e', name: _tag, error: e, stackTrace: st);
      throw Exception('Google Drive 삭제 실패: $e');
    }
  }

  @override
  Future<void> pruneOldBackups({int keepCount = 5}) async {
    final api = await _getApi();
    if (api == null) {
      dev.log('[$_tag] pruneOldBackups: API 없음 — 건너뜀', name: _tag);
      return;
    }

    try {
      final result = await api.files.list(
        spaces: 'appDataFolder',
        q: "name contains '.rlink'",
        orderBy: 'createdTime desc',
        $fields: 'files(id,name,createdTime)',
      );

      final files = result.files ?? [];
      if (files.length <= keepCount) {
        dev.log(
          '[$_tag] pruneOldBackups: ${files.length}개 <= $keepCount — 정리 불필요',
          name: _tag,
        );
        return;
      }

      final toDelete = files.skip(keepCount).toList();
      dev.log(
        '[$_tag] pruneOldBackups: ${toDelete.length}개 오래된 백업 삭제 예정',
        name: _tag,
      );

      for (final f in toDelete) {
        if (f.id != null) {
          try {
            await api.files.delete(f.id!);
            dev.log(
              '[$_tag] pruneOldBackups 삭제: ${f.name} (id: ${f.id})',
              name: _tag,
            );
          } catch (e) {
            // 개별 파일 삭제 실패는 무시 — 다음 기회에 정리
            dev.log(
              '[$_tag] pruneOldBackups 삭제 실패: ${f.name} — $e',
              name: _tag,
            );
          }
        }
      }
    } catch (e, st) {
      dev.log(
        '[$_tag] pruneOldBackups 실패: $e',
        name: _tag,
        error: e,
        stackTrace: st,
      );
    }
  }
}

/// Google 인증 헤더를 포함하는 HTTP 클라이언트.
/// [GoogleSignInAccount.authHeaders]에서 가져온 헤더를 모든 요청에 추가한다.
class _GoogleAuthClient extends http.BaseClient {
  _GoogleAuthClient(this._headers);

  final Map<String, String> _headers;
  final http.Client _inner = http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _inner.send(request);
  }

  @override
  void close() {
    _inner.close();
    super.close();
  }
}
