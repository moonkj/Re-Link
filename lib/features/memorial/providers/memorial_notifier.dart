import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/database/app_database.dart';
import '../../../core/services/notification/notification_service.dart';
import '../../../shared/repositories/db_provider.dart';
import '../../../shared/repositories/memorial_repository.dart';

part 'memorial_notifier.g.dart';

/// 노드별 추모 메시지 스트림
@riverpod
Stream<List<MemorialMessagesTableData>> memorialMessagesForNode(
  Ref ref,
  String nodeId,
) =>
    ref.watch(memorialRepositoryProvider).watchForNode(nodeId);

/// 기일 알림 초기 스케줄 — 앱 시작 시 1회 호출
///
/// 수동 정의 (build_runner 재실행 불필요)
final memorialAnniversarySchedulerProvider = FutureProvider<void>((ref) async {
  try {
    final db = ref.read(appDatabaseProvider);
    final svc = ref.read(notificationServiceProvider);
    final allNodes = await db.getAllNodes();

    for (final node in allNodes) {
      if (node.deathDate == null) continue;

      final death = node.deathDate!;
      final name = node.nickname ?? node.name;

      svc.scheduleYearly(
        id: NotificationId.memorialAnnivBase.forItem(node.id),
        title: '기일 알림',
        body: '오늘은 $name님의 기일입니다.',
        month: death.month,
        day: death.day,
        hour: 9,
        minute: 0,
        channelId: 're_link_event',
        payload: 'memorial_anniv:${node.id}',
      );
    }
  } catch (e) {
    debugPrint('[MemorialAnniversaryScheduler] 기일 알림 스케줄 실패: $e');
  }
});

/// 추모 메시지 CRUD 오퍼레이션
@riverpod
class MemorialNotifier extends _$MemorialNotifier {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  MemorialRepository get _repo => ref.read(memorialRepositoryProvider);

  /// 추모 메시지 작성
  Future<String?> addMessage({
    required String nodeId,
    required String message,
    String? authorName,
  }) async {
    state = const AsyncLoading();
    try {
      final id = await _repo.create(
        nodeId: nodeId,
        message: message,
        authorName: authorName,
      );
      state = const AsyncData(null);
      return id;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }

  /// 추모 메시지 삭제
  Future<void> deleteMessage(String id) async {
    state = const AsyncLoading();
    try {
      await _repo.delete(id);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
