import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../database/app_database.dart';
import '../../../shared/repositories/db_provider.dart';
import '../auth/auth_http_client.dart';
import 'r2_media_service.dart';
import 'sync_service.dart';

part 'media_upload_queue_service.g.dart';

@riverpod
MediaUploadQueueService mediaUploadQueueService(Ref ref) =>
    MediaUploadQueueService(ref);

/// R2 미디어 업로드 큐 서비스
/// 로컬 미디어 파일을 백그라운드에서 R2로 업로드하고,
/// 완료 시 memories/nodes 테이블의 R2 키를 업데이트
class MediaUploadQueueService {
  MediaUploadQueueService(this._ref);
  final Ref _ref;

  static const _uuid = Uuid();

  /// 최대 동시 업로드 수
  static const int _maxConcurrentUploads = 3;

  /// 최대 재시도 횟수
  static const int _maxRetryCount = 5;

  /// 현재 진행 중인 업로드 수
  int _activeUploads = 0;

  /// 큐 처리 중 여부
  bool _isProcessing = false;

  // ── 큐 추가 ──────────────────────────────────────────────────────────────

  /// 미디어 파일을 업로드 큐에 추가
  /// [memoryId]: 기억 관련 업로드 시 (사진/음성/영상/썸네일)
  /// [nodeId]: 노드 프로필 사진 업로드 시
  Future<String> enqueue({
    String? memoryId,
    String? nodeId,
    required String localPath,
    required String category, // photo / voice / video / thumbnail
    required String contentType, // MIME type
  }) async {
    assert(
      memoryId != null || nodeId != null,
      'memoryId 또는 nodeId 중 하나는 필수',
    );

    final db = _ref.read(appDatabaseProvider);
    final id = _uuid.v4();

    // 파일 크기 확인
    final file = File(localPath);
    final fileSizeBytes = await file.length();

    await db.enqueueMediaUpload(
      MediaUploadQueueTableCompanion.insert(
        id: id,
        memoryId: Value(memoryId),
        nodeId: Value(nodeId),
        localPath: localPath,
        category: category,
        contentType: contentType,
        fileSizeBytes: fileSizeBytes,
        status: const Value('pending'),
        createdAt: Value(DateTime.now()),
      ),
    );

    debugPrint('[MediaUploadQueue] enqueued: $id ($category, ${fileSizeBytes}B)');
    return id;
  }

  // ── 큐 처리 ──────────────────────────────────────────────────────────────

  /// 대기 중인 업로드 항목 처리
  /// 최대 [_maxConcurrentUploads]개 동시 업로드
  Future<void> processQueue() async {
    if (_isProcessing) return;
    _isProcessing = true;

    try {
      final db = _ref.read(appDatabaseProvider);

      // pending + 재시도 가능한 failed 항목 조회
      final pendingItems = await db.getPendingMediaUploads(
        limit: _maxConcurrentUploads * 2,
      );
      final retryItems = await db.getRetryableMediaUploads(
        maxRetry: _maxRetryCount,
        limit: _maxConcurrentUploads,
      );

      final allItems = [...pendingItems, ...retryItems];
      if (allItems.isEmpty) {
        debugPrint('[MediaUploadQueue] 큐 비어있음 — 처리할 항목 없음');
        return;
      }

      debugPrint('[MediaUploadQueue] 처리 시작: ${allItems.length}개 항목');

      // 동시 업로드 제한을 두고 병렬 처리
      final futures = <Future<void>>[];
      for (final item in allItems) {
        if (_activeUploads >= _maxConcurrentUploads) {
          // 하나가 끝날 때까지 대기
          if (futures.isNotEmpty) {
            await Future.any(futures);
          }
        }
        final future = _processItem(item);
        futures.add(future);
      }

      // 모든 업로드 완료 대기
      await Future.wait(futures);

      debugPrint('[MediaUploadQueue] 처리 완료');

      // 업로드 완료 후 클라우드 동기화 트리거
      // (import cycle 방지: lazy read로 접근)
      try {
        // FamilySyncNotifier를 직접 import하면 순환 참조가 되므로
        // SyncService를 통해 동기화 트리거
        final syncService = _ref.read(syncServiceProvider);
        await syncService.sync();
        debugPrint('[MediaUploadQueue] 동기화 트리거 완료');
      } catch (e) {
        debugPrint('[MediaUploadQueue] 동기화 트리거 오류 (무시): $e');
      }
    } catch (e) {
      debugPrint('[MediaUploadQueue] processQueue 오류: $e');
    } finally {
      _isProcessing = false;
    }
  }

  /// 개별 항목 업로드 처리
  Future<void> _processItem(MediaUploadQueueEntry item) async {
    _activeUploads++;
    final db = _ref.read(appDatabaseProvider);

    try {
      // 로컬 파일 존재 확인
      final file = File(item.localPath);
      if (!await file.exists()) {
        debugPrint('[MediaUploadQueue] 파일 없음: ${item.localPath}');
        await db.updateMediaUploadStatus(item.id, status: 'failed');
        return;
      }

      // uploading 상태로 변경
      await db.updateMediaUploadStatus(item.id, status: 'uploading');

      // R2 업로드 실행
      final r2Service = _ref.read(r2MediaServiceProvider);
      final r2FileKey = await r2Service.uploadFile(
        localPath: item.localPath,
        contentType: item.contentType,
        folder: _categoryToFolder(item.category),
      );

      if (r2FileKey != null) {
        // 업로드 성공
        final now = DateTime.now();
        await db.updateMediaUploadStatus(
          item.id,
          status: 'completed',
          r2FileKey: r2FileKey,
          completedAt: now,
        );

        // memories / nodes 테이블에 R2 키 반영
        await _updateR2Key(item, r2FileKey);

        // Workers에 업로드 완료 알림 (storage 사용량 업데이트)
        await _confirmUpload(
          r2FileKey: r2FileKey,
          category: item.category,
          fileSizeBytes: item.fileSizeBytes,
        );

        debugPrint('[MediaUploadQueue] 업로드 성공: ${item.id} → $r2FileKey');
      } else {
        // 업로드 실패 — 재시도 카운트 증가
        await db.incrementMediaUploadRetry(item.id);
        debugPrint(
          '[MediaUploadQueue] 업로드 실패: ${item.id} '
          '(retry: ${item.retryCount + 1}/$_maxRetryCount)',
        );
      }
    } catch (e) {
      debugPrint('[MediaUploadQueue] 항목 처리 오류: ${item.id} — $e');
      await db.incrementMediaUploadRetry(item.id);
    } finally {
      _activeUploads--;
    }
  }

  /// Workers에 업로드 완료 확인 요청
  /// POST /media/confirm-upload
  /// storage 사용량을 서버에서 트래킹하기 위해 호출
  Future<void> _confirmUpload({
    required String r2FileKey,
    required String category,
    required int fileSizeBytes,
  }) async {
    try {
      final authClient = _ref.read(authHttpClientProvider);
      final response = await authClient.post(
        '/media/confirm-upload',
        body: {
          'file_key': r2FileKey,
          'category': category,
          'file_size_bytes': fileSizeBytes,
        },
      );
      if (response.statusCode == 200) {
        debugPrint('[MediaUploadQueue] confirm-upload 성공: $r2FileKey');
      } else {
        debugPrint(
          '[MediaUploadQueue] confirm-upload 실패: '
          '${response.statusCode} — $r2FileKey',
        );
      }
    } catch (e) {
      // confirm-upload 실패는 치명적이지 않음 — 서버에서 별도 정산 가능
      debugPrint('[MediaUploadQueue] confirm-upload 오류 (무시): $e');
    }
  }

  /// 업로드 성공 후 memories/nodes 테이블에 R2 키 반영
  Future<void> _updateR2Key(
      MediaUploadQueueEntry item, String r2FileKey) async {
    final db = _ref.read(appDatabaseProvider);

    if (item.memoryId != null) {
      // memory의 R2 키 업데이트
      final companion = switch (item.category) {
        'thumbnail' => MemoriesTableCompanion(
            r2ThumbnailKey: Value(r2FileKey),
          ),
        _ => MemoriesTableCompanion(
            r2FileKey: Value(r2FileKey),
          ),
      };
      await (db.update(db.memoriesTable)
            ..where((t) => t.id.equals(item.memoryId!)))
          .write(companion);
    }

    if (item.nodeId != null) {
      // node의 R2 프로필 사진 키 업데이트
      await (db.update(db.nodesTable)
            ..where((t) => t.id.equals(item.nodeId!)))
          .write(NodesTableCompanion(r2PhotoKey: Value(r2FileKey)));
    }
  }

  /// category → R2 폴더 매핑
  String _categoryToFolder(String category) => switch (category) {
        'photo' => 'photos',
        'voice' => 'voices',
        'video' => 'videos',
        'thumbnail' => 'thumbnails',
        _ => 'misc',
      };

  // ── 상태 조회 ────────────────────────────────────────────────────────────

  /// 업로드 큐 상태별 카운트 반환
  /// { 'pending': 3, 'uploading': 1, 'completed': 10, 'failed': 0 }
  Future<Map<String, int>> getQueueStatus() async {
    final db = _ref.read(appDatabaseProvider);
    return db.getMediaUploadQueueStatus();
  }

  /// 특정 memory의 업로드 상태 조회
  Future<List<MediaUploadQueueEntry>> getByMemoryId(String memoryId) async {
    final db = _ref.read(appDatabaseProvider);
    return db.getMediaUploadsByMemoryId(memoryId);
  }

  /// 특정 node의 업로드 상태 조회
  Future<List<MediaUploadQueueEntry>> getByNodeId(String nodeId) async {
    final db = _ref.read(appDatabaseProvider);
    return db.getMediaUploadsByNodeId(nodeId);
  }

  // ── 정리 ──────────────────────────────────────────────────────────────────

  /// 완료된 업로드 항목 정리
  Future<void> cleanCompleted() async {
    final db = _ref.read(appDatabaseProvider);
    await db.cleanCompletedMediaUploads();
    debugPrint('[MediaUploadQueue] 완료 항목 정리됨');
  }
}
