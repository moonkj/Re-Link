import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../shared/repositories/db_provider.dart';
import '../../../shared/repositories/settings_repository.dart';

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
  /// 패밀리 플랜이 아니면 즉시 반환
  Future<int> _pull() async {
    // TODO: AuthHttpClient 사용하여 구현
    // 1. lastSyncAt 조회
    // 2. GET /sync/pull?since=<ms>
    // 3. 응답 파싱 후 Drift upsert
    // 4. 처리된 항목 수 반환
    return 0;
  }

  /// 로컬 SyncQueue 항목들을 서버로 전송
  /// POST /sync/push (배치 50개)
  Future<int> _push() async {
    final db = _ref.read(appDatabaseProvider);
    int totalPushed = 0;

    final pending = await db.getPendingSyncItems(limit: 50);
    if (pending.isEmpty) return 0;

    // TODO: AuthHttpClient 사용하여 실제 서버 전송 구현
    // 현재는 스텁: 성공 시 markSyncedItems, 실패 시 incrementRetryCount
    // try {
    //   final ids = pending.map((e) => e.id).toList();
    //   await _authHttpClient.post('/sync/push', body: pending.map((e) => e.toJson()).toList());
    //   await db.markSyncedItems(ids);
    //   totalPushed += ids.length;
    // } catch (e) {
    //   for (final entry in pending) {
    //     await db.incrementRetryCount(entry.id);
    //   }
    // }

    return totalPushed;
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
