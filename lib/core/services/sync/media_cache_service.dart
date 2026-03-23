import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../utils/path_utils.dart';
import 'r2_media_service.dart';

part 'media_cache_service.g.dart';

@riverpod
MediaCacheService mediaCacheService(Ref ref) => MediaCacheService(
      r2Media: ref.read(r2MediaServiceProvider),
    );

/// R2 미디어 파일 다운로드 캐시 서비스
///
/// 로컬 파일이 있으면 그대로 반환하고,
/// 없으면 R2에서 다운로드하여 로컬 캐시 디렉토리에 저장합니다.
/// 패밀리 플랜 사용자가 다른 기기에서 동기화된 데이터를 볼 때 사용됩니다.
class MediaCacheService {
  MediaCacheService({required this.r2Media});
  final R2MediaService r2Media;

  /// 미디어 파일 경로 해석
  ///
  /// 1. 로컬 파일이 존재하면 해당 절대 경로를 반환
  /// 2. R2 키가 있으면 다운로드 후 캐시 경로를 반환
  /// 3. 둘 다 없으면 null 반환
  ///
  /// [localPath]: DB에 저장된 로컬 파일 경로 (상대/절대)
  /// [r2FileKey]: R2 클라우드 파일 키 (예: 'groupId/userId/photos/uuid.webp')
  /// [category]: 파일 카테고리 (photo/voice/video/thumbnail)
  Future<String?> resolveMediaPath({
    String? localPath,
    String? r2FileKey,
    required String category,
  }) async {
    // 1. 로컬 파일 존재 확인
    if (localPath != null && localPath.isNotEmpty) {
      final resolved = PathUtils.toAbsolute(localPath);
      if (resolved != null && await File(resolved).exists()) {
        return resolved;
      }
    }

    // 2. R2 키가 있으면 다운로드
    if (r2FileKey != null && r2FileKey.isNotEmpty) {
      final downloaded = await _downloadAndCache(r2FileKey, category);
      return downloaded;
    }

    return null;
  }

  /// 썸네일 경로 해석 (resolveMediaPath와 동일한 로직, 편의 메서드)
  Future<String?> resolveThumbnailPath({
    String? localPath,
    String? r2ThumbnailKey,
  }) =>
      resolveMediaPath(
        localPath: localPath,
        r2FileKey: r2ThumbnailKey,
        category: 'thumbnail',
      );

  /// R2에서 다운로드하여 로컬 캐시에 저장
  ///
  /// 캐시 경로: Documents/media/cache/{category}/{filename}
  /// 이미 캐시에 있으면 다운로드를 건너뜁니다.
  Future<String?> _downloadAndCache(String r2FileKey, String category) async {
    try {
      final cacheDir = await _getCacheDir(category);
      final filename = _extractFilename(r2FileKey);
      final localPath = p.join(cacheDir.path, filename);

      // 이미 캐시에 존재하면 즉시 반환
      if (await File(localPath).exists()) {
        debugPrint('[MediaCache] 캐시 히트: $filename');
        return localPath;
      }

      // R2에서 다운로드
      debugPrint('[MediaCache] R2 다운로드 시작: $r2FileKey');
      final result = await r2Media.downloadFile(
        fileKey: r2FileKey,
        localPath: localPath,
      );

      if (result != null) {
        debugPrint('[MediaCache] 다운로드 완료: $filename');
        return result;
      }

      debugPrint('[MediaCache] 다운로드 실패: $r2FileKey');
      return null;
    } catch (e) {
      debugPrint('[MediaCache] 다운로드/캐시 오류: $e');
      return null;
    }
  }

  /// 카테고리별 캐시 디렉토리 생성 및 반환
  Future<Directory> _getCacheDir(String category) async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(base.path, 'media', 'cache', category));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// R2 키에서 파일명 추출
  /// 예: 'groupId/userId/photos/uuid.webp' → 'uuid.webp'
  String _extractFilename(String r2FileKey) {
    return r2FileKey.split('/').last;
  }

  // ── 캐시 관리 ────────────────────────────────────────────────────────────

  /// 전체 미디어 캐시 크기 (bytes)
  Future<int> getCacheSizeBytes() async {
    final base = await getApplicationDocumentsDirectory();
    final cacheRoot = Directory(p.join(base.path, 'media', 'cache'));
    if (!await cacheRoot.exists()) return 0;

    int totalBytes = 0;
    await for (final entity in cacheRoot.list(recursive: true)) {
      if (entity is File) {
        totalBytes += await entity.length();
      }
    }
    return totalBytes;
  }

  /// 전체 미디어 캐시 삭제
  Future<void> clearCache() async {
    final base = await getApplicationDocumentsDirectory();
    final cacheRoot = Directory(p.join(base.path, 'media', 'cache'));
    if (await cacheRoot.exists()) {
      await cacheRoot.delete(recursive: true);
      debugPrint('[MediaCache] 캐시 전체 삭제 완료');
    }
  }

  /// 특정 카테고리 캐시 삭제
  Future<void> clearCategoryCache(String category) async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(base.path, 'media', 'cache', category));
    if (await dir.exists()) {
      await dir.delete(recursive: true);
      debugPrint('[MediaCache] $category 캐시 삭제 완료');
    }
  }
}
