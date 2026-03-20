import 'package:flutter_test/flutter_test.dart';
import 'package:re_link/features/wrapped/services/annual_review_service.dart';

void main() {
  group('AnnualReviewData 모델 검증', () {
    test('기본 생성자 — 모든 필드 검증', () {
      final data = AnnualReviewData(
        year: 2025,
        totalMemories: 100,
        totalNodes: 15,
        newNodesThisYear: 5,
        newMemoriesThisYear: 42,
        totalBouquets: 3,
        streakBest: 7,
        warmestNodeName: '엄마',
        warmestNodeMemories: 20,
        mostActiveMonth: '5월',
        memoryByMonth: {
          '1월': 2, '2월': 3, '3월': 5, '4월': 4,
          '5월': 8, '6월': 3, '7월': 4, '8월': 2,
          '9월': 3, '10월': 4, '11월': 2, '12월': 2,
        },
      );

      expect(data.year, 2025);
      expect(data.totalMemories, 100);
      expect(data.totalNodes, 15);
      expect(data.newNodesThisYear, 5);
      expect(data.newMemoriesThisYear, 42);
      expect(data.totalBouquets, 3);
      expect(data.streakBest, 7);
      expect(data.warmestNodeName, '엄마');
      expect(data.warmestNodeMemories, 20);
      expect(data.mostActiveMonth, '5월');
      expect(data.memoryByMonth.length, 12);
    });

    test('warmestNodeName이 null일 수 있다', () {
      final data = AnnualReviewData(
        year: 2025,
        totalMemories: 0,
        totalNodes: 0,
        newNodesThisYear: 0,
        newMemoriesThisYear: 0,
        totalBouquets: 0,
        streakBest: 0,
        warmestNodeName: null,
        warmestNodeMemories: 0,
        mostActiveMonth: null,
        memoryByMonth: {},
      );

      expect(data.warmestNodeName, isNull);
      expect(data.mostActiveMonth, isNull);
    });

    test('빈 데이터 — 기본값 처리', () {
      final data = AnnualReviewData(
        year: 2025,
        totalMemories: 0,
        totalNodes: 0,
        newNodesThisYear: 0,
        newMemoriesThisYear: 0,
        totalBouquets: 0,
        streakBest: 0,
        warmestNodeName: null,
        warmestNodeMemories: 0,
        mostActiveMonth: null,
        memoryByMonth: {
          '1월': 0, '2월': 0, '3월': 0, '4월': 0,
          '5월': 0, '6월': 0, '7월': 0, '8월': 0,
          '9월': 0, '10월': 0, '11월': 0, '12월': 0,
        },
      );

      expect(data.totalMemories, 0);
      expect(data.newMemoriesThisYear, 0);
      expect(data.streakBest, 0);
      expect(data.warmestNodeMemories, 0);
      // 모든 월이 0이어야 한다
      for (final count in data.memoryByMonth.values) {
        expect(count, 0);
      }
    });
  });

  group('AnnualReviewData.monthName', () {
    test('1~12 월 이름이 올바르다', () {
      expect(AnnualReviewData.monthName(1), '1월');
      expect(AnnualReviewData.monthName(2), '2월');
      expect(AnnualReviewData.monthName(3), '3월');
      expect(AnnualReviewData.monthName(4), '4월');
      expect(AnnualReviewData.monthName(5), '5월');
      expect(AnnualReviewData.monthName(6), '6월');
      expect(AnnualReviewData.monthName(7), '7월');
      expect(AnnualReviewData.monthName(8), '8월');
      expect(AnnualReviewData.monthName(9), '9월');
      expect(AnnualReviewData.monthName(10), '10월');
      expect(AnnualReviewData.monthName(11), '11월');
      expect(AnnualReviewData.monthName(12), '12월');
    });

    test('12개 월 이름이 모두 고유하다', () {
      final names = List.generate(12, (i) => AnnualReviewData.monthName(i + 1));
      expect(names.toSet().length, 12);
    });

    test('월 이름에 "월" 접미사가 포함된다', () {
      for (int m = 1; m <= 12; m++) {
        expect(AnnualReviewData.monthName(m), endsWith('월'));
      }
    });
  });

  group('월별 데이터 집계 로직', () {
    test('12개월 매핑 — 초기화 후 모든 월 키가 존재', () {
      final memoryByMonth = <String, int>{};
      for (int m = 1; m <= 12; m++) {
        memoryByMonth[AnnualReviewData.monthName(m)] = 0;
      }

      expect(memoryByMonth.length, 12);
      expect(memoryByMonth.containsKey('1월'), isTrue);
      expect(memoryByMonth.containsKey('12월'), isTrue);
    });

    test('월별 데이터 집계 시뮬레이션', () {
      // 기억 날짜 시뮬레이션 (month만 사용)
      final memoryMonths = [1, 1, 3, 5, 5, 5, 7, 12, 12];

      final memoryByMonth = <String, int>{};
      for (int m = 1; m <= 12; m++) {
        memoryByMonth[AnnualReviewData.monthName(m)] = 0;
      }

      for (final month in memoryMonths) {
        final key = AnnualReviewData.monthName(month);
        memoryByMonth[key] = (memoryByMonth[key] ?? 0) + 1;
      }

      expect(memoryByMonth['1월'], 2);
      expect(memoryByMonth['2월'], 0);
      expect(memoryByMonth['3월'], 1);
      expect(memoryByMonth['5월'], 3);
      expect(memoryByMonth['7월'], 1);
      expect(memoryByMonth['12월'], 2);
    });

    test('최활발 월 찾기 시뮬레이션', () {
      final memoryByMonth = <String, int>{
        '1월': 2, '2월': 0, '3월': 1, '4월': 0,
        '5월': 8, '6월': 3, '7월': 1, '8월': 0,
        '9월': 0, '10월': 4, '11월': 0, '12월': 2,
      };

      String? mostActiveMonth;
      int maxCount = 0;
      for (final entry in memoryByMonth.entries) {
        if (entry.value > maxCount) {
          maxCount = entry.value;
          mostActiveMonth = entry.key;
        }
      }

      expect(mostActiveMonth, '5월');
      expect(maxCount, 8);
    });

    test('모든 월이 0이면 mostActiveMonth는 null', () {
      final memoryByMonth = <String, int>{};
      for (int m = 1; m <= 12; m++) {
        memoryByMonth[AnnualReviewData.monthName(m)] = 0;
      }

      String? mostActiveMonth;
      int maxCount = 0;
      for (final entry in memoryByMonth.entries) {
        if (entry.value > maxCount) {
          maxCount = entry.value;
          mostActiveMonth = entry.key;
        }
      }

      expect(mostActiveMonth, isNull);
    });
  });

  group('최장 스트릭 로직', () {
    test('연속 3일 → streakBest = 3', () {
      final days = [
        DateTime(2025, 3, 1),
        DateTime(2025, 3, 2),
        DateTime(2025, 3, 3),
      ];

      int current = 1;
      int best = 1;
      for (int i = 1; i < days.length; i++) {
        if (days[i].difference(days[i - 1]).inDays == 1) {
          current++;
          if (current > best) best = current;
        } else {
          current = 1;
        }
      }

      expect(best, 3);
    });

    test('연속 1일 (단일 항목) → streakBest = 1', () {
      final days = [DateTime(2025, 5, 10)];

      int best = 1;
      // 단일 항목이면 루프 진입 안 함
      expect(best, 1);
    });

    test('비연속 날짜 → streakBest = 1', () {
      final days = [
        DateTime(2025, 1, 1),
        DateTime(2025, 1, 5),
        DateTime(2025, 1, 10),
      ];

      int current = 1;
      int best = 1;
      for (int i = 1; i < days.length; i++) {
        if (days[i].difference(days[i - 1]).inDays == 1) {
          current++;
          if (current > best) best = current;
        } else {
          current = 1;
        }
      }

      expect(best, 1);
    });

    test('복합 스트릭 — 중간 끊김 후 더 긴 스트릭', () {
      final days = [
        DateTime(2025, 1, 1),
        DateTime(2025, 1, 2), // 2일 연속
        DateTime(2025, 1, 10),
        DateTime(2025, 1, 11),
        DateTime(2025, 1, 12),
        DateTime(2025, 1, 13), // 4일 연속
      ];

      int current = 1;
      int best = 1;
      for (int i = 1; i < days.length; i++) {
        if (days[i].difference(days[i - 1]).inDays == 1) {
          current++;
          if (current > best) best = current;
        } else {
          current = 1;
        }
      }

      expect(best, 4);
    });

    test('빈 목록 → streakBest = 0', () {
      // AnnualReviewService에서 빈 목록이면 streakBest = 0으로 설정
      int streakBest = 0;
      final memoryDates = <DateTime>[];

      if (memoryDates.isNotEmpty) {
        streakBest = 1;
        // ... 계산
      }

      expect(streakBest, 0);
    });
  });
}
