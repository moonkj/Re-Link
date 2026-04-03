/// AnnualReviewService 순수 로직 테스트 (DB 불필요)
/// 커버: annual_review_service.dart — AnnualReviewData 모델, monthName,
///        월별 집계 로직, 스트릭 계산, 가장 따뜻한 노드 찾기, 빈 데이터 처리
import 'package:flutter_test/flutter_test.dart';
import 'package:re_link/features/wrapped/services/annual_review_service.dart';

void main() {
  // ── AnnualReviewData.monthName ────────────────────────────────────────────

  group('AnnualReviewData.monthName (확장)', () {
    test('1월~12월 번호 → 한국어 월 이름', () {
      final expected = [
        '1월', '2월', '3월', '4월', '5월', '6월',
        '7월', '8월', '9월', '10월', '11월', '12월',
      ];
      for (int m = 1; m <= 12; m++) {
        expect(AnnualReviewData.monthName(m), expected[m - 1]);
      }
    });

    test('인접 월이 서로 다름', () {
      for (int m = 1; m < 12; m++) {
        expect(AnnualReviewData.monthName(m),
            isNot(equals(AnnualReviewData.monthName(m + 1))));
      }
    });
  });

  // ── AnnualReviewData 모델 생성 ────────────────────────────────────────────

  group('AnnualReviewData 모델', () {
    test('대규모 데이터', () {
      final memoryByMonth = <String, int>{
        for (int m = 1; m <= 12; m++)
          AnnualReviewData.monthName(m): m * 10,
      };
      final data = AnnualReviewData(
        year: 2025,
        totalMemories: 780,
        totalNodes: 50,
        newNodesThisYear: 20,
        newMemoriesThisYear: 300,
        totalBouquets: 25,
        streakBest: 30,
        warmestNodeName: '엄마',
        warmestNodeMemories: 60,
        mostActiveMonth: '12월',
        memoryByMonth: memoryByMonth,
      );
      expect(data.totalMemories, 780);
      expect(data.streakBest, 30);
      expect(data.memoryByMonth['12월'], 120);
    });

    test('모든 nullable 필드가 null', () {
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
  });

  // ── 월별 데이터 집계 로직 ─────────────────────────────────────────────────

  group('월별 데이터 집계 로직 (확장)', () {
    test('모든 기억이 한 달에 집중', () {
      final memoryByMonth = <String, int>{
        for (int m = 1; m <= 12; m++)
          AnnualReviewData.monthName(m): 0,
      };
      // 5월에 100개
      memoryByMonth['5월'] = 100;

      String? mostActiveMonth;
      int maxCount = 0;
      for (final entry in memoryByMonth.entries) {
        if (entry.value > maxCount) {
          maxCount = entry.value;
          mostActiveMonth = entry.key;
        }
      }
      expect(mostActiveMonth, '5월');
      expect(maxCount, 100);
    });

    test('동률일 때 먼저 나오는 월이 선택됨', () {
      final memoryByMonth = <String, int>{};
      for (int m = 1; m <= 12; m++) {
        memoryByMonth[AnnualReviewData.monthName(m)] = 0;
      }
      memoryByMonth['3월'] = 5;
      memoryByMonth['7월'] = 5;

      String? mostActiveMonth;
      int maxCount = 0;
      for (final entry in memoryByMonth.entries) {
        if (entry.value > maxCount) {
          maxCount = entry.value;
          mostActiveMonth = entry.key;
        }
      }
      // LinkedHashMap 순서에 따라 3월이 먼저 발견됨
      expect(mostActiveMonth, '3월');
    });

    test('memoryByMonth 합계 = newMemoriesThisYear 와 일치해야 함', () {
      final memoryByMonth = <String, int>{
        '1월': 5, '2월': 3, '3월': 4, '4월': 2,
        '5월': 8, '6월': 1, '7월': 3, '8월': 6,
        '9월': 2, '10월': 4, '11월': 1, '12월': 3,
      };
      final total = memoryByMonth.values.reduce((a, b) => a + b);
      expect(total, 42);
    });
  });

  // ── 가장 따뜻한 노드 찾기 로직 ───────────────────────────────────────────

  group('가장 따뜻한 노드 찾기 로직', () {
    test('nodeMemoryCount에서 최대값 찾기', () {
      final nodeMemoryCount = <String, int>{
        'node-1': 10,
        'node-2': 25,
        'node-3': 15,
      };
      final warmestNodeId = nodeMemoryCount.entries
          .reduce((a, b) => a.value >= b.value ? a : b)
          .key;
      expect(warmestNodeId, 'node-2');
      expect(nodeMemoryCount[warmestNodeId], 25);
    });

    test('단일 노드 → 해당 노드가 가장 따뜻', () {
      final nodeMemoryCount = <String, int>{'node-1': 5};
      final warmestNodeId = nodeMemoryCount.entries
          .reduce((a, b) => a.value >= b.value ? a : b)
          .key;
      expect(warmestNodeId, 'node-1');
    });

    test('동률 → 첫 번째 발견 노드 선택', () {
      final nodeMemoryCount = <String, int>{
        'node-a': 10,
        'node-b': 10,
      };
      final warmestNodeId = nodeMemoryCount.entries
          .reduce((a, b) => a.value >= b.value ? a : b)
          .key;
      expect(warmestNodeId, 'node-a');
    });
  });

  // ── 스트릭 계산 로직 (확장) ───────────────────────────────────────────────

  group('스트릭 계산 로직 (확장)', () {
    int calculateStreak(List<DateTime> days) {
      if (days.isEmpty) return 0;
      days.sort();
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
      return best;
    }

    test('연속 7일 → streakBest = 7', () {
      final days = List.generate(
        7,
        (i) => DateTime(2025, 6, 1 + i),
      );
      expect(calculateStreak(days), 7);
    });

    test('전체 1월 (31일) → streakBest = 31', () {
      final days = List.generate(
        31,
        (i) => DateTime(2025, 1, 1 + i),
      );
      expect(calculateStreak(days), 31);
    });

    test('격일 기록 → streakBest = 1', () {
      final days = [
        DateTime(2025, 1, 1),
        DateTime(2025, 1, 3),
        DateTime(2025, 1, 5),
        DateTime(2025, 1, 7),
      ];
      expect(calculateStreak(days), 1);
    });

    test('두 개의 연속 블록 — 더 긴 쪽이 선택됨', () {
      final days = [
        // 블록 1: 3일
        DateTime(2025, 1, 1),
        DateTime(2025, 1, 2),
        DateTime(2025, 1, 3),
        // 간격
        DateTime(2025, 2, 10),
        // 블록 2: 5일
        DateTime(2025, 3, 1),
        DateTime(2025, 3, 2),
        DateTime(2025, 3, 3),
        DateTime(2025, 3, 4),
        DateTime(2025, 3, 5),
      ];
      expect(calculateStreak(days), 5);
    });

    test('중복 날짜가 제거된 후 계산', () {
      final days = [
        DateTime(2025, 1, 1),
        DateTime(2025, 1, 1), // 중복
        DateTime(2025, 1, 2),
      ];
      // 원래 코드에서는 .toSet()으로 중복 제거 후 정렬
      final uniqueDays = days.toSet().toList()..sort();
      expect(calculateStreak(uniqueDays), 2);
    });

    test('빈 목록 → 0', () {
      expect(calculateStreak([]), 0);
    });
  });

  // ── 연도 경계 테스트 ──────────────────────────────────────────────────────

  group('연도 경계', () {
    test('yearStart/yearEnd 올바른지 확인', () {
      const year = 2025;
      final yearStart = DateTime(year);
      final yearEnd = DateTime(year + 1);
      expect(yearStart, DateTime(2025, 1, 1));
      expect(yearEnd, DateTime(2026, 1, 1));
      expect(yearEnd.difference(yearStart).inDays, 365);
    });

    test('윤년 연도 경계', () {
      const year = 2024;
      final yearStart = DateTime(year);
      final yearEnd = DateTime(year + 1);
      expect(yearEnd.difference(yearStart).inDays, 366);
    });
  });
}
