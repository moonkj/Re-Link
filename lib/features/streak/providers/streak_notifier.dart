import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../shared/models/user_plan.dart';
import '../../../shared/repositories/settings_repository.dart';

part 'streak_notifier.g.dart';

/// 스트릭 상태 모델
@immutable
class StreakState {
  const StreakState({
    this.count = 0,
    this.lastDate,
    this.freezeRemaining = 0,
    this.isTodayRecorded = false,
  });

  final int count;
  final DateTime? lastDate;
  final int freezeRemaining;
  final bool isTodayRecorded;

  StreakState copyWith({
    int? count,
    DateTime? lastDate,
    int? freezeRemaining,
    bool? isTodayRecorded,
  }) =>
      StreakState(
        count: count ?? this.count,
        lastDate: lastDate ?? this.lastDate,
        freezeRemaining: freezeRemaining ?? this.freezeRemaining,
        isTodayRecorded: isTodayRecorded ?? this.isTodayRecorded,
      );

  /// 마일스톤 달성 여부 (7, 30, 100, 365)
  static const List<int> milestones = [7, 30, 100, 365];

  /// 현재 카운트가 마일스톤인지 확인
  bool get isMilestone => milestones.contains(count);

  /// 마일스톤 이모지
  String get milestoneEmoji => switch (count) {
        7 => '\u2B50',   // ⭐
        30 => '\uD83C\uDF1F',  // 🌟
        100 => '\uD83D\uDCAB', // 💫
        365 => '\uD83C\uDFC6', // 🏆
        _ => '',
      };

  /// 마일스톤 메시지
  String get milestoneMessage => switch (count) {
        7 => '일주일 연속 기록! 좋은 습관의 시작이에요.',
        30 => '한 달 연속! 가족 기억이 풍성해지고 있어요.',
        100 => '100일 달성! 대단한 꾸준함이에요.',
        365 => '1년 연속! 가족 기억의 마스터입니다.',
        _ => '',
      };
}

/// 기억 스트릭 노티파이어
@riverpod
class StreakNotifier extends _$StreakNotifier {
  @override
  Future<StreakState> build() async {
    final repo = ref.read(settingsRepositoryProvider);
    final count = await repo.getStreakCount();
    final lastDate = await repo.getStreakLastDate();
    final freezeCount = await repo.getStreakFreezeCount();

    final now = DateTime.now();
    final today = DateUtils.dateOnly(now);
    final isTodayRecorded =
        lastDate != null && DateUtils.isSameDay(lastDate, today);

    return StreakState(
      count: count,
      lastDate: lastDate,
      freezeRemaining: freezeCount,
      isTodayRecorded: isTodayRecorded,
    );
  }

  SettingsRepository get _repo => ref.read(settingsRepositoryProvider);

  /// 앱 포그라운드 진입 시 호출 — 스트릭 상태 확인
  Future<void> checkStreak() async {
    final current = state.valueOrNull;
    if (current == null) return;

    final now = DateTime.now();
    final today = DateUtils.dateOnly(now);
    final lastDate = current.lastDate;

    // lastDate가 없으면 첫 사용 — 스트릭 0 유지
    if (lastDate == null) return;

    final lastDay = DateUtils.dateOnly(lastDate);

    // 같은 날: 스트릭 유지, isTodayRecorded = true
    if (DateUtils.isSameDay(lastDay, today)) {
      if (!current.isTodayRecorded) {
        state = AsyncData(current.copyWith(isTodayRecorded: true));
      }
      return;
    }

    // 어제: 스트릭 유지 (다음 기록 시 증가)
    final yesterday = today.subtract(const Duration(days: 1));
    if (DateUtils.isSameDay(lastDay, yesterday)) {
      state = AsyncData(current.copyWith(isTodayRecorded: false));
      return;
    }

    // 2일 이상 지남: 프리즈 사용 또는 스트릭 초기화
    final daysDiff = today.difference(lastDay).inDays;
    final missedDays = daysDiff - 1; // 어제까지는 이미 기록됨

    if (current.freezeRemaining >= missedDays && missedDays > 0) {
      // 프리즈로 커버 가능
      final newFreeze = current.freezeRemaining - missedDays;
      await _repo.setStreakFreezeCount(newFreeze);
      state = AsyncData(current.copyWith(
        freezeRemaining: newFreeze,
        isTodayRecorded: false,
      ));
    } else {
      // 스트릭 리셋
      await _repo.setStreakCount(0);
      state = AsyncData(StreakState(
        count: 0,
        lastDate: current.lastDate,
        freezeRemaining: current.freezeRemaining,
        isTodayRecorded: false,
      ));
    }
  }

  /// 기억/온도 저장 시 호출 — 스트릭 기록
  /// 마일스톤 달성 시 true 반환
  Future<bool> recordActivity() async {
    final current = state.valueOrNull;
    if (current == null) return false;

    // 이미 오늘 기록됨 → no-op
    if (current.isTodayRecorded) return false;

    final now = DateTime.now();
    final today = DateUtils.dateOnly(now);
    final newCount = current.count + 1;

    // 프리즈 월별 리셋 체크
    await _checkFreezeMonthlyReset();

    await _repo.setStreakCount(newCount);
    await _repo.setStreakLastDate(today);

    final newState = current.copyWith(
      count: newCount,
      lastDate: today,
      isTodayRecorded: true,
    );
    state = AsyncData(newState);

    return StreakState.milestones.contains(newCount);
  }

  /// 프리즈 사용 (수동)
  Future<bool> useFreeze() async {
    final current = state.valueOrNull;
    if (current == null) return false;
    if (current.freezeRemaining <= 0) return false;

    final newFreeze = current.freezeRemaining - 1;
    await _repo.setStreakFreezeCount(newFreeze);
    state = AsyncData(current.copyWith(freezeRemaining: newFreeze));
    return true;
  }

  /// 프리즈 월별 리셋 — 매월 1일에 플랜별 프리즈 개수 재충전
  Future<void> _checkFreezeMonthlyReset() async {
    final now = DateTime.now();
    final currentMonth =
        '${now.year}-${now.month.toString().padLeft(2, '0')}';
    final usedMonth = await _repo.getStreakFreezeUsedMonth();

    if (usedMonth != currentMonth) {
      // 새 달 진입 → 프리즈 리셋
      final plan = await _repo.getUserPlan();
      final freezeLimit = _freezeLimitForPlan(plan);
      await _repo.setStreakFreezeCount(freezeLimit);
      await _repo.setStreakFreezeUsedMonth(currentMonth);

      final current = state.valueOrNull;
      if (current != null) {
        state = AsyncData(current.copyWith(freezeRemaining: freezeLimit));
      }
    }
  }

  /// 플랜별 프리즈 제한
  static int _freezeLimitForPlan(UserPlan plan) => switch (plan) {
        UserPlan.free => 0,
        UserPlan.basic => 3,
        UserPlan.premium => 99, // 사실상 무제한
      };
}
