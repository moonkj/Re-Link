import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../database/app_database.dart';
import '../../../shared/repositories/db_provider.dart';
import '../../../shared/repositories/settings_repository.dart';
import '../auth/auth_http_client.dart';

part 'sync_service.g.dart';

@riverpod
SyncService syncService(Ref ref) => SyncService(ref);

/// 클라우드 동기화 오케스트레이터
/// - Pull: 서버에서 변경 사항 받아오기
/// - Push: 로컬 SyncQueue 항목들을 서버로 전송
class SyncService {
  SyncService(this._ref);
  final Ref _ref;

  bool _isSyncing = false;

  /// 전체 동기화 (Pull → Push)
  Future<SyncResult> sync() async {
    if (_isSyncing) return const SyncResult(pulled: 0, pushed: 0);
    _isSyncing = true;
    try {
      final pulled = await _pull();
      final pushed = await _push();
      // lastSyncAt 업데이트
      await _ref.read(settingsRepositoryProvider).setLastSyncAt(DateTime.now());
      return SyncResult(pulled: pulled, pushed: pushed);
    } finally {
      _isSyncing = false;
    }
  }

  /// 서버에서 변경 사항 가져오기
  /// GET /sync/pull?since=<lastSyncAt_ms>
  Future<int> _pull() async {
    final settingsRepo = _ref.read(settingsRepositoryProvider);
    final db = _ref.read(appDatabaseProvider);
    final httpClient = _ref.read(authHttpClientProvider);

    // 1. lastSyncAt 조회 → ms (null이면 0)
    final lastSyncAt = await settingsRepo.getLastSyncAt();
    final sinceMs = lastSyncAt?.millisecondsSinceEpoch ?? 0;

    // 2. GET /sync/pull?since=<ms>
    final response = await httpClient.get('/sync/pull?since=$sinceMs');
    if (response.statusCode != 200) return 0;

    // 3. 응답 파싱
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final nodes = (body['nodes'] as List<dynamic>?) ?? [];
    final edges = (body['edges'] as List<dynamic>?) ?? [];
    final memories = (body['memories'] as List<dynamic>?) ?? [];

    int count = 0;

    // 4a. 노드 처리
    for (final raw in nodes) {
      final item = raw as Map<String, dynamic>;
      final id = item['id'] as String;
      if ((item['is_deleted'] as int? ?? 0) == 1) {
        await db.deleteNode(id);
      } else {
        final birthMs = item['birth_date'] as int?;
        final deathMs = item['death_date'] as int?;
        final updatedMs = item['updated_at'] as int?;
        await db.upsertNode(NodesTableCompanion(
          id: Value(id),
          name: Value(item['name'] as String),
          nickname: Value(item['nickname'] as String?),
          bio: Value(item['bio'] as String?),
          r2PhotoKey: Value(item['r2_photo_key'] as String?),
          birthDate: Value(birthMs != null
              ? DateTime.fromMillisecondsSinceEpoch(birthMs)
              : null),
          deathDate: Value(deathMs != null
              ? DateTime.fromMillisecondsSinceEpoch(deathMs)
              : null),
          isGhost: Value((item['is_ghost'] as int? ?? 0) == 1),
          temperature: Value(item['temperature'] as int? ?? 2),
          positionX: Value((item['position_x'] as num?)?.toDouble() ?? 0.0),
          positionY: Value((item['position_y'] as num?)?.toDouble() ?? 0.0),
          tagsJson: Value(item['tags_json'] as String? ?? '[]'),
          updatedAt: Value(updatedMs != null
              ? DateTime.fromMillisecondsSinceEpoch(updatedMs)
              : DateTime.now()),
        ));
      }
      count++;
    }

    // 4b. 엣지 처리
    for (final raw in edges) {
      final item = raw as Map<String, dynamic>;
      final id = item['id'] as String;
      if ((item['is_deleted'] as int? ?? 0) == 1) {
        await db.deleteEdge(id);
      } else {
        await db.upsertEdge(NodeEdgesTableCompanion(
          id: Value(id),
          fromNodeId: Value(item['from_node_id'] as String),
          toNodeId: Value(item['to_node_id'] as String),
          relation: Value(item['relation'] as String),
        ));
      }
      count++;
    }

    // 4c. 기억 처리
    for (final raw in memories) {
      final item = raw as Map<String, dynamic>;
      final id = item['id'] as String;
      if ((item['is_deleted'] as int? ?? 0) == 1) {
        await db.deleteMemory(id);
      } else {
        final dateTakenMs = item['date_taken'] as int?;
        await db.upsertMemory(MemoriesTableCompanion(
          id: Value(id),
          nodeId: Value(item['node_id'] as String),
          type: Value(item['type'] as String),
          title: Value(item['title'] as String?),
          description: Value(item['description'] as String?),
          r2FileKey: Value(item['r2_file_key'] as String?),
          r2ThumbnailKey: Value(item['r2_thumbnail_key'] as String?),
          durationSeconds: Value(item['duration_seconds'] as int?),
          dateTaken: Value(dateTakenMs != null
              ? DateTime.fromMillisecondsSinceEpoch(dateTakenMs)
              : null),
          tagsJson: Value(item['tags_json'] as String? ?? '[]'),
          isPrivate: Value((item['is_private'] as int? ?? 0) == 1),
        ));
      }
      count++;
    }

    return count;
  }

  /// 로컬 SyncQueue 항목들을 서버로 전송
  /// POST /sync/push (배치 50개)
  Future<int> _push() async {
    final db = _ref.read(appDatabaseProvider);
    final settingsRepo = _ref.read(settingsRepositoryProvider);
    final httpClient = _ref.read(authHttpClientProvider);

    // 1. 미전송 항목 조회
    final pending = await db.getPendingSyncItems(limit: 50);
    if (pending.isEmpty) return 0;

    // 2. 기기 ID 조회
    final deviceId = await settingsRepo.getDeviceId() ?? 'unknown';

    // 3. 항목 매핑
    final typeMap = {
      'nodes': 'node',
      'node_edges': 'edge',
      'memories': 'memory',
    };

    final items = <Map<String, dynamic>>[];
    for (final entry in pending) {
      final type = typeMap[entry.targetTable] ?? entry.targetTable;
      final data = jsonDecode(entry.payloadJson) as Map<String, dynamic>;

      // R2 키가 있는 항목만 포함 — 업로드 미완료 미디어는 제외
      if (type == 'memory') {
        // memory payload에 R2 키 포함 (업로드 완료된 것만)
        final memoryId = data['id'] as String?;
        if (memoryId != null) {
          final memRow = await db.getMemory(memoryId);
          if (memRow != null) {
            data['r2_file_key'] = memRow.r2FileKey;
            data['r2_thumbnail_key'] = memRow.r2ThumbnailKey;
          }
        }
      } else if (type == 'node') {
        // node payload에 R2 프로필 사진 키 포함
        final nodeId = data['id'] as String?;
        if (nodeId != null) {
          final nodeRow = await db.getNode(nodeId);
          if (nodeRow != null) {
            data['r2_photo_key'] = nodeRow.r2PhotoKey;
          }
        }
      }

      items.add({'type': type, 'data': data});
    }

    // 4. POST /sync/push
    try {
      final response = await httpClient.post(
        '/sync/push',
        body: {'device_id': deviceId, 'items': items},
      );

      // 5. 성공 시 완료 표시
      if (response.statusCode == 200) {
        final ids = pending.map((e) => e.id).toList();
        await db.markSyncedItems(ids);
        return ids.length;
      } else {
        // 실패 시 재시도 카운트 증가
        for (final entry in pending) {
          await db.incrementRetryCount(entry.id);
        }
        return 0;
      }
    } catch (_) {
      // 네트워크 오류 등 예외 시 재시도 카운트 증가
      for (final entry in pending) {
        await db.incrementRetryCount(entry.id);
      }
      return 0;
    }
  }

  /// 변경 사항을 SyncQueue에 추가
  Future<void> enqueue({
    required String targetTable,
    required String recordId,
    required String operation,    // 'upsert' | 'delete'
    required Map<String, dynamic> payload,
  }) async {
    final db = _ref.read(appDatabaseProvider);
    await db.enqueueSyncItem(
      targetTable: targetTable,
      recordId: recordId,
      operation: operation,
      payloadJson: jsonEncode(payload),
    );
  }

  /// 완료된 동기화 항목 정리
  Future<void> cleanUp() async {
    final db = _ref.read(appDatabaseProvider);
    await db.cleanSyncedItems();
  }
}

class SyncResult {
  const SyncResult({required this.pulled, required this.pushed});
  final int pulled;
  final int pushed;
}
