import 'package:flutter_test/flutter_test.dart';
import 'package:re_link/core/utils/lunar_calendar.dart';

void main() {
  // ═══════════════════════════════════════════════════════════════════════════
  // 1. lunarToSolar 변환
  // ═══════════════════════════════════════════════════════════════════════════
  group('lunarToSolar 변환', () {
    test('음력 2025.1.1 → 양력 2025-01-29 (설날)', () {
      final result = LunarCalendar.lunarToSolar(2025, 1, 1);
      expect(result, isNotNull);
      expect(result, DateTime(2025, 1, 29));
    });

    test('음력 2024.1.1 → 양력 2024-02-10', () {
      final result = LunarCalendar.lunarToSolar(2024, 1, 1);
      expect(result, isNotNull);
      expect(result, DateTime(2024, 2, 10));
    });

    test('음력 2026.1.1 → 양력 2026-02-17', () {
      final result = LunarCalendar.lunarToSolar(2026, 1, 1);
      expect(result, isNotNull);
      expect(result, DateTime(2026, 2, 17));
    });

    test('음력 2025.1.15 (정월대보름) 변환', () {
      // 2025년 음력 1월은 29일: baseDate(1/29) + 14일 = 2/12
      final result = LunarCalendar.lunarToSolar(2025, 1, 15);
      expect(result, isNotNull);
      expect(result, DateTime(2025, 2, 12));
    });

    test('유효하지 않은 일수 (음력 1월이 29일인데 30일 요청) → null', () {
      // 2025년 음력 1월은 29일
      final result = LunarCalendar.lunarToSolar(2025, 1, 30);
      expect(result, isNull);
    });

    test('유효하지 않은 월 (0월 또는 13월) → null', () {
      expect(LunarCalendar.lunarToSolar(2025, 0, 1), isNull);
      expect(LunarCalendar.lunarToSolar(2025, 13, 1), isNull);
    });

    test('유효하지 않은 일 (0일) → null', () {
      expect(LunarCalendar.lunarToSolar(2025, 1, 0), isNull);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // 2. solarToLunar 변환
  // ═══════════════════════════════════════════════════════════════════════════
  group('solarToLunar 변환', () {
    test('양력 2025-01-29 (설날) → 음력 2025.1.1', () {
      final result = LunarCalendar.solarToLunar(DateTime(2025, 1, 29));
      expect(result, isNotNull);
      expect(result!.year, 2025);
      expect(result.month, 1);
      expect(result.day, 1);
      expect(result.isLeapMonth, isFalse);
    });

    test('양력 2026-02-17 → 음력 2026.1.1', () {
      final result = LunarCalendar.solarToLunar(DateTime(2026, 2, 17));
      expect(result, isNotNull);
      expect(result!.year, 2026);
      expect(result.month, 1);
      expect(result.day, 1);
      expect(result.isLeapMonth, isFalse);
    });

    test('양력 2024-02-10 → 음력 2024.1.1', () {
      final result = LunarCalendar.solarToLunar(DateTime(2024, 2, 10));
      expect(result, isNotNull);
      expect(result!.year, 2024);
      expect(result.month, 1);
      expect(result.day, 1);
    });

    test('lunarToSolar → solarToLunar 왕복 변환', () {
      // 음력 2025.3.15 → 양력 → 다시 음력
      final solar = LunarCalendar.lunarToSolar(2025, 3, 15);
      expect(solar, isNotNull);

      final lunar = LunarCalendar.solarToLunar(solar!);
      expect(lunar, isNotNull);
      expect(lunar!.year, 2025);
      expect(lunar.month, 3);
      expect(lunar.day, 15);
      expect(lunar.isLeapMonth, isFalse);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // 3. 2026년 설날 변환 검증
  // ═══════════════════════════════════════════════════════════════════════════
  group('2026년 설날 검증', () {
    test('음력 2026.1.1 = 양력 2026-02-17', () {
      final solar = LunarCalendar.lunarToSolar(2026, 1, 1);
      expect(solar, DateTime(2026, 2, 17));
    });

    test('양력 2026-02-17 = 음력 2026.1.1', () {
      final lunar = LunarCalendar.solarToLunar(DateTime(2026, 2, 17));
      expect(lunar, isNotNull);
      expect(lunar!.year, 2026);
      expect(lunar.month, 1);
      expect(lunar.day, 1);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // 4. 윤달 처리
  // ═══════════════════════════════════════════════════════════════════════════
  group('윤달 처리', () {
    test('2025년에는 윤6월이 있다', () {
      expect(LunarCalendar.leapMonthOf(2025), 6);
    });

    test('2026년에는 윤달이 없다', () {
      expect(LunarCalendar.leapMonthOf(2026), 0);
    });

    test('2028년에는 윤5월이 있다', () {
      expect(LunarCalendar.leapMonthOf(2028), 5);
    });

    test('2025년 윤6월 변환 — isLeapMonth=true', () {
      final solar = LunarCalendar.lunarToSolar(2025, 6, 1, isLeapMonth: true);
      expect(solar, isNotNull);
      // 윤6월 1일은 6월 이후에 삽입되므로 일반 6월보다 뒤에 온다
      final regularSixth = LunarCalendar.lunarToSolar(2025, 6, 1);
      expect(solar!.isAfter(regularSixth!), isTrue);
    });

    test('윤달이 없는 해에 윤달 요청 → null', () {
      // 2026년에는 윤달 없음
      final result = LunarCalendar.lunarToSolar(2026, 6, 1, isLeapMonth: true);
      expect(result, isNull);
    });

    test('윤달이 있지만 다른 월의 윤달 요청 → null', () {
      // 2025년 윤6월인데 윤3월 요청
      final result = LunarCalendar.lunarToSolar(2025, 3, 1, isLeapMonth: true);
      expect(result, isNull);
    });

    test('윤6월 → 양력 → 다시 음력 왕복 변환', () {
      final solar = LunarCalendar.lunarToSolar(2025, 6, 15, isLeapMonth: true);
      expect(solar, isNotNull);

      final lunar = LunarCalendar.solarToLunar(solar!);
      expect(lunar, isNotNull);
      expect(lunar!.year, 2025);
      expect(lunar.month, 6);
      expect(lunar.day, 15);
      expect(lunar.isLeapMonth, isTrue);
    });

    test('daysInLunarMonth — 윤달 일수 조회', () {
      // 2025년 윤6월 일수
      final days =
          LunarCalendar.daysInLunarMonth(2025, 6, isLeapMonth: true);
      expect(days, isNotNull);
      expect(days == 29 || days == 30, isTrue);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // 5. 범위 밖 연도 처리
  // ═══════════════════════════════════════════════════════════════════════════
  group('범위 밖 연도 처리', () {
    test('2023년 (범위 밖 — 최소 2024) → null', () {
      final result = LunarCalendar.lunarToSolar(2023, 1, 1);
      expect(result, isNull);
    });

    test('2036년 (범위 밖 — 최대 2035) → null', () {
      final result = LunarCalendar.lunarToSolar(2036, 1, 1);
      expect(result, isNull);
    });

    test('solarToLunar — 범위 밖 양력 날짜 → null', () {
      // 2024년 음력 1월 1일 = 2024.2.10 이전 날짜
      final result = LunarCalendar.solarToLunar(DateTime(2023, 1, 1));
      expect(result, isNull);
    });

    test('leapMonthOf — 범위 밖이면 0', () {
      expect(LunarCalendar.leapMonthOf(2023), 0);
      expect(LunarCalendar.leapMonthOf(2036), 0);
    });

    test('daysInLunarMonth — 범위 밖이면 null', () {
      expect(LunarCalendar.daysInLunarMonth(2023, 1), isNull);
      expect(LunarCalendar.daysInLunarMonth(2036, 1), isNull);
    });

    test('minYear / maxYear 상수 검증', () {
      expect(LunarCalendar.minYear, 2024);
      expect(LunarCalendar.maxYear, 2035);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // 6. nextAnniversary (음력 기일)
  // ═══════════════════════════════════════════════════════════════════════════
  group('nextAnniversary', () {
    test('음력 기일의 다음 양력 날짜를 반환한다', () {
      final result = LunarCalendar.nextAnniversary(
        lunarMonth: 1,
        lunarDay: 15,
      );
      // 결과가 null이 아니고 오늘 이후여야 한다
      expect(result, isNotNull);
      final today = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
      );
      expect(result!.isAfter(today) || result.isAtSameMomentAs(today), isTrue);
    });

    test('변환 불가능한 음력 날짜 → null', () {
      // 모든 지원 연도에서 13월 1일은 존재하지 않음
      final result = LunarCalendar.nextAnniversary(
        lunarMonth: 13,
        lunarDay: 1,
      );
      expect(result, isNull);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // 7. nextSolarAnniversary (양력 기일)
  // ═══════════════════════════════════════════════════════════════════════════
  group('nextSolarAnniversary', () {
    test('올해 날짜가 아직 지나지 않았으면 올해 반환', () {
      // 12월 31일은 항상 아직 지나지 않았거나 오늘
      final result = LunarCalendar.nextSolarAnniversary(
        month: 12,
        day: 31,
      );
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final dec31 = DateTime(now.year, 12, 31);

      if (!dec31.isBefore(today)) {
        expect(result.year, now.year);
      } else {
        expect(result.year, now.year + 1);
      }
      expect(result.month, 12);
      expect(result.day, 31);
    });

    test('올해 날짜가 이미 지났으면 내년 반환', () {
      // 1월 1일은 (1월 2일 이후라면) 이미 지남
      final result = LunarCalendar.nextSolarAnniversary(
        month: 1,
        day: 1,
      );
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final jan1 = DateTime(now.year, 1, 1);

      if (jan1.isBefore(today)) {
        expect(result.year, now.year + 1);
      } else {
        expect(result.year, now.year);
      }
      expect(result.month, 1);
      expect(result.day, 1);
    });

    test('반환값은 오늘 이후 (또는 오늘)이다', () {
      final result = LunarCalendar.nextSolarAnniversary(
        month: 6,
        day: 15,
      );
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      expect(
        result.isAfter(today) || result.isAtSameMomentAs(today),
        isTrue,
      );
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // 8. LunarDate 모델
  // ═══════════════════════════════════════════════════════════════════════════
  group('LunarDate 모델', () {
    test('toString() 형식 검증 — 일반월', () {
      const ld = LunarDate(year: 2025, month: 8, day: 15);
      expect(ld.toString(), '음력 2025.8.15');
    });

    test('toString() 형식 검증 — 윤달', () {
      const ld = LunarDate(year: 2025, month: 6, day: 1, isLeapMonth: true);
      expect(ld.toString(), '음력 2025.6(윤).1');
    });

    test('toKorean() 형식 검증 — 일반월', () {
      const ld = LunarDate(year: 2025, month: 8, day: 15);
      expect(ld.toKorean(), '8월 15일');
    });

    test('toKorean() 형식 검증 — 윤달', () {
      const ld = LunarDate(year: 2025, month: 6, day: 1, isLeapMonth: true);
      expect(ld.toKorean(), '윤6월 1일');
    });

    test('isLeapMonth 기본값은 false', () {
      const ld = LunarDate(year: 2025, month: 3, day: 10);
      expect(ld.isLeapMonth, isFalse);
    });
  });
}
