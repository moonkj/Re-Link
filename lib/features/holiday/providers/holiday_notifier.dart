import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/data/korean_holidays.dart';
import '../../../core/database/tables/settings_table.dart';
import '../../../shared/repositories/settings_repository.dart';

part 'holiday_notifier.g.dart';

/// 명절/기념일 배너 상태
@immutable
class HolidayState {
  const HolidayState({
    this.todayHoliday,
    this.upcomingHoliday,
    this.daysUntil = 0,
    this.isDismissed = false,
  });

  /// 오늘이 명절인 경우
  final KoreanHoliday? todayHoliday;

  /// 다가오는 명절 (7일 이내)
  final KoreanHoliday? upcomingHoliday;

  /// 다가오는 명절까지 남은 일수
  final int daysUntil;

  /// 오늘 이미 배너를 닫았는지
  final bool isDismissed;

  /// 표시할 명절이 있는지 (오늘 또는 다가오는)
  bool get hasHoliday =>
      !isDismissed && (todayHoliday != null || upcomingHoliday != null);

  /// 현재 활성 명절 (오늘 우선)
  KoreanHoliday? get activeHoliday => todayHoliday ?? upcomingHoliday;

  HolidayState copyWith({
    KoreanHoliday? todayHoliday,
    KoreanHoliday? upcomingHoliday,
    int? daysUntil,
    bool? isDismissed,
  }) {
    return HolidayState(
      todayHoliday: todayHoliday ?? this.todayHoliday,
      upcomingHoliday: upcomingHoliday ?? this.upcomingHoliday,
      daysUntil: daysUntil ?? this.daysUntil,
      isDismissed: isDismissed ?? this.isDismissed,
    );
  }
}

/// 명절/기념일 감지 Notifier
///
/// - 오늘 명절이면 축하 메시지 표시
/// - 7일 이내 명절이면 D-day 카운트다운 표시
/// - dismiss 시 해당 명절 ID + 날짜를 settings에 저장하여 같은 기간 재표시 방지
@riverpod
class HolidayNotifier extends _$HolidayNotifier {
  @override
  Future<HolidayState> build() async {
    try {
      final todayHoliday = getTodayHoliday();
      final upcomingResult = getUpcomingHoliday(withinDays: 7);

      // dismiss 상태 확인
      final repo = ref.read(settingsRepositoryProvider);
      final dismissedKey =
          await repo.get(SettingsKey.holidayBannerDismissed);
      final today = _todayString();

      // 현재 활성 명절의 ID 확인
      final activeId = todayHoliday?.id ?? upcomingResult?.holiday.id;

      // dismiss 키 형식: "holiday_id:YYYY-MM-DD"
      final isDismissed =
          activeId != null && dismissedKey == '$activeId:$today';

      return HolidayState(
        todayHoliday: todayHoliday,
        upcomingHoliday: upcomingResult?.holiday,
        daysUntil: upcomingResult?.daysUntil ?? 0,
        isDismissed: isDismissed,
      );
    } catch (e) {
      // DB 미완료 등 초기화 실패 시 숨김 (블랙 스크린 방지)
      return const HolidayState(isDismissed: true);
    }
  }

  /// 배너 닫기 — 해당 명절 ID + 오늘 날짜 저장
  Future<void> dismiss() async {
    final current = state.valueOrNull;
    if (current == null) return;

    final activeId = current.activeHoliday?.id;
    if (activeId == null) return;

    final repo = ref.read(settingsRepositoryProvider);
    final today = _todayString();
    await repo.set(SettingsKey.holidayBannerDismissed, '$activeId:$today');

    state = AsyncData(current.copyWith(isDismissed: true));
  }

  String _todayString() {
    final now = DateTime.now();
    final y = now.year.toString().padLeft(4, '0');
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
