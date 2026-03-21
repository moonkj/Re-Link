import 'dart:ui' show Color;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../shared/models/family_event_model.dart';
import '../../../shared/repositories/family_event_repository.dart';

part 'family_event_notifier.g.dart';

/// 가족 일정 상태 관리 프로바이더
@riverpod
class FamilyEventNotifier extends _$FamilyEventNotifier {
  @override
  Future<List<FamilyEventModel>> build() async {
    final repo = ref.watch(familyEventRepositoryProvider);
    final events = await repo.getAll();

    // 다음 일정 날짜 기준 정렬
    events.sort((a, b) => a.daysUntil.compareTo(b.daysUntil));
    return events;
  }

  /// 일정 추가
  Future<void> addEvent({
    required String title,
    String? description,
    required DateTime eventDate,
    bool isYearly = false,
    int colorValue = 0xFF8B5CF6,
    String? nodeId,
  }) async {
    final repo = ref.read(familyEventRepositoryProvider);
    await repo.create(
      title: title,
      description: description,
      eventDate: eventDate,
      isYearly: isYearly,
      color: Color(colorValue),
      nodeId: nodeId,
    );
    ref.invalidateSelf();
  }

  /// 일정 삭제
  Future<void> deleteEvent(String id) async {
    final repo = ref.read(familyEventRepositoryProvider);
    await repo.delete(id);
    ref.invalidateSelf();
  }

  /// 일정 수정
  Future<void> updateEvent(FamilyEventModel event) async {
    final repo = ref.read(familyEventRepositoryProvider);
    await repo.update(event);
    ref.invalidateSelf();
  }

  /// 새로고침
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => build());
  }
}
