import 'dart:io';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../backup/backup_format.dart';
import 'cloud_backup_provider.dart';

/// Android Google Drive 백업 구현
/// 앱 전용 폴더(appDataFolder) 사용 — 사용자 Drive에 보이지 않음
/// TODO Phase 2: 전체 구현
class GoogleDriveBackup implements CloudBackupProvider {
  static final _googleSignIn = GoogleSignIn(
    scopes: [drive.DriveApi.driveAppdataScope],
  );

  drive.DriveApi? _driveApi;

  Future<drive.DriveApi?> _getApi() async {
    if (_driveApi != null) return _driveApi;
    try {
      final account =
          _googleSignIn.currentUser ?? await _googleSignIn.signInSilently();
      if (account == null) return null;
      final auth = await account.authentication;
      final client = _AuthClient(auth.accessToken ?? '');
      _driveApi = drive.DriveApi(client);
      return _driveApi;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> isAvailable() async {
    if (!Platform.isAndroid) return false;
    try {
      final api = await _getApi();
      return api != null;
    } catch (_) {
      return false;
    }
  }

  Future<bool> signIn() async {
    try {
      final account = await _googleSignIn.signIn();
      return account != null;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> upload(File rlinkFile) async {
    final api = await _getApi();
    if (api == null) throw Exception('Google 계정 연결이 필요합니다.');

    final filename = p.basename(rlinkFile.path);
    final fileSize = await rlinkFile.length();

    final meta = drive.File()
      ..name = filename
      ..parents = ['appDataFolder'];

    await api.files.create(
      meta,
      uploadMedia: drive.Media(rlinkFile.openRead(), fileSize),
    );
  }

  @override
  Future<List<BackupInfo>> listBackups() async {
    final api = await _getApi();
    if (api == null) return [];

    try {
      // TODO Phase 2: $fields 파라미터는 googleapis 버전에 따라 다름
      final result = await api.files.list(
        spaces: 'appDataFolder',
        q: "name contains '.rlink'",
        orderBy: 'createdTime desc',
      );

      return (result.files ?? []).map((f) {
        return BackupInfo(
          filename: f.name ?? '',
          createdAt: f.createdTime ?? DateTime.now(),
          sizeBytes: int.tryParse(f.size ?? '0') ?? 0,
          nodeCount: 0,
          memoryCount: 0,
          source: 'google',
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<File> download(String filename) async {
    final api = await _getApi();
    if (api == null) throw Exception('Google 계정 연결이 필요합니다.');

    final result = await api.files.list(
      spaces: 'appDataFolder',
      q: "name = '$filename'",
    );
    final fileId = result.files?.firstOrNull?.id;
    if (fileId == null) throw Exception('백업 파일을 찾을 수 없습니다: $filename');

    final media = await api.files.get(
      fileId,
      downloadOptions: drive.DownloadOptions.fullMedia,
    ) as drive.Media;

    final tmpDir = await getTemporaryDirectory();
    final localPath = p.join(tmpDir.path, filename);
    final out = File(localPath).openWrite();
    await media.stream.pipe(out);
    await out.close();

    return File(localPath);
  }

  @override
  Future<void> pruneOldBackups({int keepCount = 5}) async {
    final api = await _getApi();
    if (api == null) return;

    final result = await api.files.list(
      spaces: 'appDataFolder',
      q: "name contains '.rlink'",
      orderBy: 'createdTime desc',
    );

    final files = result.files ?? [];
    if (files.length <= keepCount) return;
    for (final f in files.skip(keepCount)) {
      if (f.id != null) {
        await api.files.delete(f.id!);
      }
    }
  }
}

class _AuthClient extends http.BaseClient {
  _AuthClient(this._accessToken);
  final String _accessToken;
  final _inner = http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers['Authorization'] = 'Bearer $_accessToken';
    return _inner.send(request);
  }
}
