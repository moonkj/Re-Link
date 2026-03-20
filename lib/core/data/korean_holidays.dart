import 'package:flutter/material.dart';

/// 한국 공휴일/기념일 타입
enum HolidayType { seollal, chuseok, memorial, birthday }

/// 한국 전통 공휴일/기념일 데이터
///
/// 음력 기반 명절은 2024-2030년 양력 날짜를 미리 계산하여 포함.
/// 외부 패키지 의존 없이 정적 테이블로 관리.
@immutable
class KoreanHoliday {
  final String id;
  final String name;
  final HolidayType type;
  final String emoji;
  final Color themeColor;
  final String message;

  /// 양력 기준 날짜 목록 (음력 명절은 연도별 미리 계산된 값)
  final List<DateTime> dates;

  const KoreanHoliday({
    required this.id,
    required this.name,
    required this.type,
    required this.emoji,
    required this.themeColor,
    required this.message,
    required this.dates,
  });
}

/// 전체 한국 명절/기념일 목록
///
/// DateTime은 const가 아니므로 final 리스트로 선언.
/// 앱 실행 중 변경되지 않는 정적 데이터.
final List<KoreanHoliday> koreanHolidays = [
  // ── 설날 (음력 1월 1일) ─────────────────────────────────────────────────
  KoreanHoliday(
    id: 'seollal',
    name: '설날',
    type: HolidayType.seollal,
    emoji: '\uD83C\uDF8A', // 🎊
    themeColor: const Color(0xFFE53935),
    message: '새해 복 많이 받으세요',
    dates: [
      DateTime(2024, 2, 10),
      DateTime(2025, 1, 29),
      DateTime(2026, 2, 17),
      DateTime(2027, 2, 6),
      DateTime(2028, 1, 26),
      DateTime(2029, 2, 13),
      DateTime(2030, 2, 3),
    ],
  ),

  // ── 추석 (음력 8월 15일) ────────────────────────────────────────────────
  KoreanHoliday(
    id: 'chuseok',
    name: '추석',
    type: HolidayType.chuseok,
    emoji: '\uD83C\uDF15', // 🌕
    themeColor: const Color(0xFFFF8F00),
    message: '풍요로운 한가위 보내세요',
    dates: [
      DateTime(2024, 9, 17),
      DateTime(2025, 10, 6),
      DateTime(2026, 9, 25),
      DateTime(2027, 9, 15),
      DateTime(2028, 10, 3),
      DateTime(2029, 9, 22),
      DateTime(2030, 9, 12),
    ],
  ),

  // ── 어버이날 (양력 5월 8일 고정) ────────────────────────────────────────
  KoreanHoliday(
    id: 'parents_day',
    name: '어버이날',
    type: HolidayType.memorial,
    emoji: '\uD83C\uDF39', // 🌹
    themeColor: const Color(0xFFE91E63),
    message: '감사한 마음을 전하세요',
    dates: [
      DateTime(2024, 5, 8),
      DateTime(2025, 5, 8),
      DateTime(2026, 5, 8),
      DateTime(2027, 5, 8),
      DateTime(2028, 5, 8),
      DateTime(2029, 5, 8),
      DateTime(2030, 5, 8),
    ],
  ),

  // ── 어린이날 (양력 5월 5일 고정) ────────────────────────────────────────
  KoreanHoliday(
    id: 'children_day',
    name: '어린이날',
    type: HolidayType.birthday,
    emoji: '\uD83C\uDF88', // 🎈
    themeColor: const Color(0xFF4CAF50),
    message: '아이들에게 사랑을 전하세요',
    dates: [
      DateTime(2024, 5, 5),
      DateTime(2025, 5, 5),
      DateTime(2026, 5, 5),
      DateTime(2027, 5, 5),
      DateTime(2028, 5, 5),
      DateTime(2029, 5, 5),
      DateTime(2030, 5, 5),
    ],
  ),

  // ── 한글날 (양력 10월 9일 고정) ─────────────────────────────────────────
  KoreanHoliday(
    id: 'hangul_day',
    name: '한글날',
    type: HolidayType.memorial,
    emoji: '\uD83D\uDCD6', // 📖
    themeColor: const Color(0xFF1565C0),
    message: '한글의 아름다움을 기억합니다',
    dates: [
      DateTime(2024, 10, 9),
      DateTime(2025, 10, 9),
      DateTime(2026, 10, 9),
      DateTime(2027, 10, 9),
      DateTime(2028, 10, 9),
      DateTime(2029, 10, 9),
      DateTime(2030, 10, 9),
    ],
  ),
];

/// 오늘이 명절/기념일인지 확인
KoreanHoliday? getTodayHoliday() {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  for (final holiday in koreanHolidays) {
    for (final date in holiday.dates) {
      if (date.year == today.year &&
          date.month == today.month &&
          date.day == today.day) {
        return holiday;
      }
    }
  }
  return null;
}

/// 다가오는 명절/기념일 확인 (withinDays일 이내)
///
/// 오늘 당일은 제외 (getTodayHoliday로 별도 처리).
/// 가장 가까운 명절 하나를 반환.
({KoreanHoliday holiday, int daysUntil})? getUpcomingHoliday({
  int withinDays = 7,
}) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  KoreanHoliday? closest;
  int closestDays = withinDays + 1;

  for (final holiday in koreanHolidays) {
    for (final date in holiday.dates) {
      final holidayDate = DateTime(date.year, date.month, date.day);
      final diff = holidayDate.difference(today).inDays;
      // 1 ~ withinDays 범위 (오늘 제외, 미래만)
      if (diff >= 1 && diff <= withinDays && diff < closestDays) {
        closest = holiday;
        closestDays = diff;
      }
    }
  }

  if (closest == null) return null;
  return (holiday: closest, daysUntil: closestDays);
}
