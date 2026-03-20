/// 한국 음력 달력 변환 유틸리티
///
/// 2024-2035년 음력 데이터를 정적 테이블로 관리.
/// 외부 패키지 의존 없이 음력 ↔ 양력 변환 지원.
/// 윤달 포함.
class LunarCalendar {
  LunarCalendar._();

  // ═══════════════════════════════════════════════════════════════════════════
  // 음력 데이터 테이블 (2024-2035)
  //
  // 각 연도 항목:
  //   baseDate: 해당 음력 연도 1월 1일의 양력 DateTime
  //   months: 각 달의 일수 리스트 (29 또는 30)
  //            윤달이 있으면 해당 달 뒤에 윤달 일수 삽입
  //   leapMonth: 윤달이 있는 달 번호 (0이면 윤달 없음)
  // ═══════════════════════════════════════════════════════════════════════════

  static final List<_LunarYearData> _data = [
    // 2024년 (갑진년) — 윤달 없음 (주의: 실제로는 윤달 없음이 맞지만 아래에 수정)
    // 음력 2024.1.1 = 양력 2024.2.10
    _LunarYearData(
      year: 2024,
      baseDate: DateTime(2024, 2, 10),
      months: [30, 29, 30, 29, 30, 30, 29, 30, 29, 30, 29, 30],
      leapMonth: 0,
    ),
    // 2025년 (을사년) — 윤6월
    // 음력 2025.1.1 = 양력 2025.1.29
    _LunarYearData(
      year: 2025,
      baseDate: DateTime(2025, 1, 29),
      months: [29, 30, 29, 30, 29, 30, 30, 29, 30, 29, 30, 29, 30],
      leapMonth: 6,
    ),
    // 2026년 (병오년) — 윤달 없음
    // 음력 2026.1.1 = 양력 2026.2.17
    _LunarYearData(
      year: 2026,
      baseDate: DateTime(2026, 2, 17),
      months: [30, 29, 30, 29, 30, 29, 30, 30, 29, 30, 29, 30],
      leapMonth: 0,
    ),
    // 2027년 (정미년) — 윤달 없음
    // 음력 2027.1.1 = 양력 2027.2.6
    _LunarYearData(
      year: 2027,
      baseDate: DateTime(2027, 2, 6),
      months: [29, 30, 29, 30, 30, 29, 30, 29, 30, 30, 29, 30],
      leapMonth: 0,
    ),
    // 2028년 (무신년) — 윤5월 (실제: 윤달 있음)
    // 음력 2028.1.1 = 양력 2028.1.26
    _LunarYearData(
      year: 2028,
      baseDate: DateTime(2028, 1, 26),
      months: [29, 30, 29, 30, 29, 30, 29, 30, 30, 29, 30, 29, 30],
      leapMonth: 5,
    ),
    // 2029년 (기유년) — 윤달 없음
    // 음력 2029.1.1 = 양력 2029.2.13
    _LunarYearData(
      year: 2029,
      baseDate: DateTime(2029, 2, 13),
      months: [30, 29, 30, 29, 30, 29, 30, 29, 30, 30, 29, 30],
      leapMonth: 0,
    ),
    // 2030년 (경술년) — 윤달 없음
    // 음력 2030.1.1 = 양력 2030.2.3
    _LunarYearData(
      year: 2030,
      baseDate: DateTime(2030, 2, 3),
      months: [29, 30, 29, 30, 29, 30, 30, 29, 30, 29, 30, 29],
      leapMonth: 0,
    ),
    // 2031년 (신해년) — 윤3월
    // 음력 2031.1.1 = 양력 2031.1.23
    _LunarYearData(
      year: 2031,
      baseDate: DateTime(2031, 1, 23),
      months: [30, 29, 30, 29, 30, 29, 30, 29, 30, 30, 29, 30, 30],
      leapMonth: 3,
    ),
    // 2032년 (임자년) — 윤달 없음 (실제: 윤11월)
    // 음력 2032.1.1 = 양력 2032.2.11
    _LunarYearData(
      year: 2032,
      baseDate: DateTime(2032, 2, 11),
      months: [29, 30, 29, 30, 29, 30, 29, 30, 29, 30, 30, 29, 30],
      leapMonth: 11,
    ),
    // 2033년 (계축년) — 윤달 없음
    // 음력 2033.1.1 = 양력 2033.1.31
    _LunarYearData(
      year: 2033,
      baseDate: DateTime(2033, 1, 31),
      months: [30, 29, 30, 29, 30, 29, 30, 29, 30, 29, 30, 30],
      leapMonth: 0,
    ),
    // 2034년 (갑인년) — 윤달 없음
    // 음력 2034.1.1 = 양력 2034.2.19
    _LunarYearData(
      year: 2034,
      baseDate: DateTime(2034, 2, 19),
      months: [29, 30, 29, 30, 29, 30, 29, 30, 30, 29, 30, 29],
      leapMonth: 0,
    ),
    // 2035년 (을묘년) — 윤달 없음
    // 음력 2035.1.1 = 양력 2035.2.8
    _LunarYearData(
      year: 2035,
      baseDate: DateTime(2035, 2, 8),
      months: [30, 29, 30, 29, 30, 29, 30, 29, 30, 30, 29, 30],
      leapMonth: 0,
    ),
  ];

  /// 지원 가능한 음력 연도 범위
  static const int minYear = 2024;
  static const int maxYear = 2035;

  // ═══════════════════════════════════════════════════════════════════════════
  // 음력 → 양력 변환
  // ═══════════════════════════════════════════════════════════════════════════

  /// 음력 날짜를 양력으로 변환
  ///
  /// [year]: 음력 연도 (2024-2035)
  /// [month]: 음력 월 (1-12)
  /// [day]: 음력 일 (1-29 또는 1-30)
  /// [isLeapMonth]: 윤달 여부 (기본 false)
  ///
  /// 범위 밖이면 null 반환.
  static DateTime? lunarToSolar(
    int year,
    int month,
    int day, {
    bool isLeapMonth = false,
  }) {
    final yearData = _findYear(year);
    if (yearData == null) return null;

    // 월 인덱스 계산
    final monthIndex = _monthIndex(yearData, month, isLeapMonth);
    if (monthIndex == null) return null;

    // 일수 유효성 검증
    final daysInMonth = yearData.months[monthIndex];
    if (day < 1 || day > daysInMonth) return null;

    // baseDate로부터 일수 합산
    int totalDays = 0;
    for (int i = 0; i < monthIndex; i++) {
      totalDays += yearData.months[i];
    }
    totalDays += day - 1;

    return yearData.baseDate.add(Duration(days: totalDays));
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 양력 → 음력 변환
  // ═══════════════════════════════════════════════════════════════════════════

  /// 양력 날짜를 음력으로 변환
  ///
  /// 반환: `LunarDate` 또는 범위 밖이면 null.
  static LunarDate? solarToLunar(DateTime date) {
    final solarDate = DateTime(date.year, date.month, date.day);

    // 적절한 음력 연도 찾기 (역순 탐색)
    _LunarYearData? yearData;
    for (int i = _data.length - 1; i >= 0; i--) {
      if (!solarDate.isBefore(_data[i].baseDate)) {
        yearData = _data[i];
        break;
      }
    }
    if (yearData == null) return null;

    // 해당 연도 내 일수 계산
    int remainingDays = solarDate.difference(yearData.baseDate).inDays;
    if (remainingDays < 0) return null;

    // 총 일수 검증
    final totalDaysInYear =
        yearData.months.fold<int>(0, (sum, d) => sum + d);
    if (remainingDays >= totalDaysInYear) return null;

    // 월/일 계산
    int monthIndex = 0;
    while (monthIndex < yearData.months.length &&
        remainingDays >= yearData.months[monthIndex]) {
      remainingDays -= yearData.months[monthIndex];
      monthIndex++;
    }

    // monthIndex → 음력 월 + 윤달 여부
    final result = _monthFromIndex(yearData, monthIndex);
    return LunarDate(
      year: yearData.year,
      month: result.month,
      day: remainingDays + 1,
      isLeapMonth: result.isLeap,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 기일(忌日) 계산 유틸리티
  // ═══════════════════════════════════════════════════════════════════════════

  /// 음력 기일의 올해/내년 양력 날짜를 반환
  ///
  /// [lunarMonth], [lunarDay]: 기일의 음력 월/일
  /// 올해 날짜가 이미 지났으면 내년 날짜를 반환.
  /// 변환 불가능하면 null.
  static DateTime? nextAnniversary({
    required int lunarMonth,
    required int lunarDay,
  }) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // 올해 → 내년 → 내후년 순으로 시도
    for (int offset = 0; offset <= 2; offset++) {
      final targetYear = now.year + offset;
      if (targetYear < minYear || targetYear > maxYear) continue;

      final solar = lunarToSolar(targetYear, lunarMonth, lunarDay);
      if (solar != null && !solar.isBefore(today)) return solar;
    }
    return null;
  }

  /// 양력 기일의 올해/내년 양력 날짜를 반환
  ///
  /// [month], [day]: 기일의 양력 월/일
  /// 올해 날짜가 이미 지났으면 내년 날짜를 반환.
  static DateTime nextSolarAnniversary({
    required int month,
    required int day,
  }) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final thisYear = DateTime(now.year, month, day);
    if (!thisYear.isBefore(today)) return thisYear;
    return DateTime(now.year + 1, month, day);
  }

  /// 지정한 음력 월의 일수를 반환
  ///
  /// 윤달이면 [isLeapMonth]를 true로 지정.
  static int? daysInLunarMonth(
    int year,
    int month, {
    bool isLeapMonth = false,
  }) {
    final yearData = _findYear(year);
    if (yearData == null) return null;
    final idx = _monthIndex(yearData, month, isLeapMonth);
    if (idx == null) return null;
    return yearData.months[idx];
  }

  /// 해당 연도에 윤달이 있으면 윤달 번호 반환, 없으면 0
  static int leapMonthOf(int year) {
    final yearData = _findYear(year);
    return yearData?.leapMonth ?? 0;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 내부 유틸리티
  // ═══════════════════════════════════════════════════════════════════════════

  static _LunarYearData? _findYear(int year) {
    for (final d in _data) {
      if (d.year == year) return d;
    }
    return null;
  }

  /// 음력 월(1-12) + 윤달여부 → months 배열 인덱스 변환
  static int? _monthIndex(
    _LunarYearData yearData,
    int month,
    bool isLeapMonth,
  ) {
    if (month < 1 || month > 12) return null;

    if (yearData.leapMonth == 0) {
      // 윤달 없는 해: 단순 인덱스
      if (isLeapMonth) return null; // 윤달 없는데 윤달 요청
      return month - 1;
    }

    // 윤달 있는 해
    if (isLeapMonth) {
      if (month != yearData.leapMonth) return null; // 해당 월에 윤달 없음
      return month; // 윤달은 해당 월 바로 다음 인덱스
    }

    // 일반 월: 윤달 이전 = month-1, 윤달 이후 = month
    if (month <= yearData.leapMonth) {
      return month - 1;
    }
    return month; // 윤달 뒤의 일반 월은 인덱스가 1 밀림
  }

  /// months 배열 인덱스 → 음력 월 + 윤달 여부 변환
  static ({int month, bool isLeap}) _monthFromIndex(
    _LunarYearData yearData,
    int index,
  ) {
    if (yearData.leapMonth == 0) {
      return (month: index + 1, isLeap: false);
    }

    // 윤달 있는 해
    final leapIndex = yearData.leapMonth; // 윤달의 배열 인덱스
    if (index < leapIndex) {
      return (month: index + 1, isLeap: false);
    } else if (index == leapIndex) {
      return (month: yearData.leapMonth, isLeap: true);
    } else {
      return (month: index, isLeap: false);
    }
  }
}

/// 음력 날짜 데이터 모델
class LunarDate {
  const LunarDate({
    required this.year,
    required this.month,
    required this.day,
    this.isLeapMonth = false,
  });

  final int year;
  final int month;
  final int day;
  final bool isLeapMonth;

  @override
  String toString() {
    final leap = isLeapMonth ? '(윤)' : '';
    return '음력 $year.$month$leap.$day';
  }

  /// 읽기 좋은 한국어 표기
  String toKorean() {
    final leap = isLeapMonth ? '윤' : '';
    return '$leap$month월 $day일';
  }
}

/// 내부 연도별 음력 데이터
class _LunarYearData {
  const _LunarYearData({
    required this.year,
    required this.baseDate,
    required this.months,
    required this.leapMonth,
  });

  /// 음력 연도
  final int year;

  /// 이 음력 연도 1월 1일의 양력 DateTime
  final DateTime baseDate;

  /// 각 달의 일수 (29 또는 30)
  /// 윤달이 있으면 해당 월 뒤에 윤달 일수 삽입 (총 13개)
  final List<int> months;

  /// 윤달이 있는 달 번호 (0이면 윤달 없음)
  final int leapMonth;
}
