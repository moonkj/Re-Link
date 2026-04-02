import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../auth/auth_http_client.dart';
import '../../errors/app_error.dart';
import '../../../shared/models/user_plan.dart';
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
  /// 클라우드 쿼터 초과 시 StorageError 발생 (#14)
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

      // 클라우드 저장소 쿼터 체크 (#14)
      await _checkCloudQuota(bytes.length);
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
          // 서버에 업로드 완료 확인 (스토리지 용량 추적)
          try {
            await authClient.post('/media/confirm-upload', body: {
              'file_key': fileKey,
              'file_size_bytes': bytes.length,
            });
          } catch (_) {
            // confirm 실패해도 파일은 이미 R2에 올라감
          }
          return fileKey;
        }
        return null;
      } finally {
        plainClient.close();
      }
    } on StorageError {
      rethrow; // 클라우드 쿼터 초과 에러는 상위로 전파
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

  /// 클라우드 저장소 쿼터 체크 (#14)
  /// 업로드 전 현재 사용량 + 파일 크기가 플랜 한도 이내인지 확인
  Future<void> _checkCloudQuota(int fileSizeBytes) async {
    try {
      final settings = _ref.read(settingsRepositoryProvider);
      final plan = await settings.getUserPlan();

      if (!plan.hasCloud) {
        throw const StorageError('클라우드 저장소는 패밀리 플랜 이상에서 사용 가능합니다.');
      }

      final limitBytes = plan.cloudStorageGB * 1024 * 1024 * 1024; // GB → bytes
      final currentUsage = await getCloudUsageBytes();

      if (currentUsage + fileSizeBytes > limitBytes) {
        final usedGB = (currentUsage / (1024 * 1024 * 1024)).toStringAsFixed(1);
        final limitGB = plan.cloudStorageGB;
        throw StorageError(
          '클라우드 저장 공간이 부족합니다. ($usedGB GB / $limitGB GB 사용 중)\n'
          '플랜을 업그레이드하거나 불필요한 파일을 삭제해 주세요.',
        );
      }
    } on StorageError {
      rethrow;
    } catch (e) {
      // 쿼터 체크 실패 시에도 업로드는 허용 (서버에서 최종 거부 가능)
      debugPrint('[R2MediaService] 쿼터 체크 오류 (업로드 계속): $e');
    }
  }

  /// 현재 클라우드 사용량 조회 (bytes)
  Future<int> getCloudUsageBytes() async {
    try {
      final authClient = _ref.read(authHttpClientProvider);
      final response = await authClient.get('/media/usage');

      if (response.statusCode == 200) {
        final data =
            jsonDecode(response.body) as Map<String, dynamic>;
        final result = data['data'] as Map<String, dynamic>?;
        return result?['total_bytes'] as int? ?? 0;
      }
      return 0;
    } catch (e) {
      debugPrint('[R2MediaService] 사용량 조회 오류: $e');
      return 0;
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
