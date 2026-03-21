import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'r2_media_service.g.dart';

@riverpod
R2MediaService r2MediaService(Ref ref) => R2MediaService(ref);

/// Cloudflare R2 미디어 파일 업/다운로드
/// 패밀리 / 패밀리플러스 플랜 전용
class R2MediaService {
  R2MediaService(this._ref);
  final Ref _ref;

  /// 로컬 파일을 R2에 업로드
  /// 반환: R2 file key (예: 'media/photos/uuid.webp'), 실패 시 null
  Future<String?> uploadFile({
    required String localPath,
    required String contentType,    // 'image/webp', 'audio/mp4', 'video/mp4'
    required String folder,         // 'photos', 'voice', 'videos'
  }) async {
    // TODO: AuthHttpClient 사용하여 구현
    // 1. POST /media/upload-url → presigned URL + fileKey 획득
    // 2. PUT presignedUrl, body: File(localPath).readAsBytesSync()
    // 3. 성공 시 fileKey 반환
    return null;
  }

  /// R2에서 로컬에 다운로드
  /// 반환: 저장된 로컬 경로, 실패 시 null
  Future<String?> downloadFile({
    required String fileKey,
    required String localPath,
  }) async {
    // TODO: AuthHttpClient 사용하여 구현
    // 1. GET /media/:fileKey/download-url → presigned URL 획득
    // 2. GET presignedUrl → 바이트 수신
    // 3. File(localPath).writeAsBytes(bytes)
    // 4. 성공 시 localPath 반환
    return null;
  }

  /// R2에서 파일 삭제
  Future<bool> deleteFile({required String fileKey}) async {
    // TODO: AuthHttpClient 사용하여 구현
    // DELETE /media/:fileKey
    return false;
  }
}
