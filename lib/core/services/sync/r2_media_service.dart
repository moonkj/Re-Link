import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../auth/auth_http_client.dart';
import '../../../shared/repositories/settings_repository.dart';

part 'r2_media_service.g.dart';

@riverpod
R2MediaService r2MediaService(Ref ref) => R2MediaService(ref);

/// Cloudflare R2 미디어 파일 업/다운로드
/// 패밀리 / 패밀리플러스 플랜 전용
class R2MediaService {
  R2MediaService(this._ref);
  final Ref _ref;

  /// 로컬 파일을 R2에 업로드
  /// 반환: R2 file key (예: 'groupId/userId/photos/uuid.webp'), 실패 시 null
  Future<String?> uploadFile({
    required String localPath,
    required String contentType,
    required String folder,
  }) async {
    try {
      final settings = _ref.read(settingsRepositoryProvider);
      final userId = await settings.getAuthUserId();
      final groupId = await settings.getFamilyGroupId();

      if (userId == null || userId.isEmpty || groupId == null || groupId.isEmpty) {
        return null;
      }

      final bytes = await File(localPath).readAsBytes();
      final ext = localPath.split('.').last;
      final uuid = const Uuid().v4();
      final fileKey = '$groupId/$userId/$folder/$uuid.$ext';

      final authClient = _ref.read(authHttpClientProvider);
      final uploadUrlResponse = await authClient.post(
        '/media/upload-url',
        body: {
          'file_key': fileKey,
          'content_type': contentType,
          'category': folder,
          'file_size_bytes': bytes.length,
        },
      );

      if (uploadUrlResponse.statusCode != 200) return null;

      final responseData =
          (jsonDecode(uploadUrlResponse.body) as Map<String, dynamic>)['data']
              as Map<String, dynamic>;
      final uploadUrl = responseData['upload_url'] as String?;

      if (uploadUrl == null) return null;

      final plainClient = http.Client();
      try {
        final putResponse = await plainClient.put(
          Uri.parse(uploadUrl),
          headers: {'Content-Type': contentType},
          body: bytes,
        );

        if (putResponse.statusCode == 200 || putResponse.statusCode == 204) {
          return fileKey;
        }
        return null;
      } finally {
        plainClient.close();
      }
    } catch (_) {
      return null;
    }
  }

  /// R2에서 로컬에 다운로드
  /// 반환: 저장된 로컬 경로, 실패 시 null
  Future<String?> downloadFile({
    required String fileKey,
    required String localPath,
  }) async {
    try {
      final authClient = _ref.read(authHttpClientProvider);
      final downloadUrlResponse =
          await authClient.get('/media/${Uri.encodeComponent(fileKey)}/download-url');

      if (downloadUrlResponse.statusCode != 200) return null;

      final responseData =
          (jsonDecode(downloadUrlResponse.body) as Map<String, dynamic>)['data']
              as Map<String, dynamic>;
      final downloadUrl = responseData['download_url'] as String?;

      if (downloadUrl == null) return null;

      final plainClient = http.Client();
      try {
        final getResponse = await plainClient.get(Uri.parse(downloadUrl));

        if (getResponse.statusCode != 200) return null;

        await File(localPath).writeAsBytes(getResponse.bodyBytes);
        return localPath;
      } finally {
        plainClient.close();
      }
    } catch (_) {
      return null;
    }
  }

  /// R2에서 파일 삭제
  Future<bool> deleteFile({required String fileKey}) async {
    try {
      final authClient = _ref.read(authHttpClientProvider);
      final response =
          await authClient.delete('/media/${Uri.encodeComponent(fileKey)}');
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
