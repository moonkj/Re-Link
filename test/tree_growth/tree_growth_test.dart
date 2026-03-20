import 'package:flutter_test/flutter_test.dart';
import 'package:re_link/features/tree_growth/providers/tree_growth_notifier.dart';

void main() {
  // ── 성장 점수 계산 ──────────────────────────────────────────────────────────
  group('Growth score calculation', () {
    /// 점수 공식: 노드×2 + 기억×1 + (스트릭×0.5).round()
    int calcScore(int nodes, int memories, int streak) {
      return nodes * 2 + memories * 1 + (streak * 0.5).round();
    }

    test('zero inputs produce score 0', () {
      expect(calcScore(0, 0, 0), 0);
    });

    test('node weight is 2', () {
      expect(calcScore(5, 0, 0), 10);
    });

    test('memory weight is 1', () {
      expect(calcScore(0, 10, 0), 10);
    });

    test('streak weight is 0.5 (rounded)', () {
      expect(calcScore(0, 0, 7), 4); // (7 * 0.5).round() = 4
    });

    test('streak odd number rounds correctly', () {
      expect(calcScore(0, 0, 3), 2); // (3 * 0.5).round() = 2
    });

    test('streak even number is exact', () {
      expect(calcScore(0, 0, 10), 5); // (10 * 0.5).round() = 5
    });

    test('combined score with all inputs', () {
      // 3×2 + 4×1 + (6×0.5).round() = 6+4+3 = 13
      expect(calcScore(3, 4, 6), 13);
    });
  });

  // ── 성장 단계 임계값 ────────────────────────────────────────────────────────
  group('Growth stage thresholds', () {
    GrowthStage stageFromScore(int score) {
      if (score <= 10) return GrowthStage.sprout;
      if (score <= 30) return GrowthStage.sapling;
      if (score <= 80) return GrowthStage.smallTree;
      if (score <= 200) return GrowthStage.bigTree;
      return GrowthStage.grandTree;
    }

    test('score 0 → sprout', () {
      expect(stageFromScore(0), GrowthStage.sprout);
    });

    test('score 10 (boundary) → sprout', () {
      expect(stageFromScore(10), GrowthStage.sprout);
    });

    test('score 11 (boundary) → sapling', () {
      expect(stageFromScore(11), GrowthStage.sapling);
    });

    test('score 30 (boundary) → sapling', () {
      expect(stageFromScore(30), GrowthStage.sapling);
    });

    test('score 31 (boundary) → smallTree', () {
      expect(stageFromScore(31), GrowthStage.smallTree);
    });

    test('score 80 (boundary) → smallTree', () {
      expect(stageFromScore(80), GrowthStage.smallTree);
    });

    test('score 81 (boundary) → bigTree', () {
      expect(stageFromScore(81), GrowthStage.bigTree);
    });

    test('score 200 (boundary) → bigTree', () {
      expect(stageFromScore(200), GrowthStage.bigTree);
    });

    test('score 201 (boundary) → grandTree', () {
      expect(stageFromScore(201), GrowthStage.grandTree);
    });

    test('very large score → grandTree', () {
      expect(stageFromScore(9999), GrowthStage.grandTree);
    });
  });

  // ── GrowthStage enum ───────────────────────────────────────────────────────
  group('GrowthStage enum', () {
    test('has exactly 5 values', () {
      expect(GrowthStage.values.length, 5);
    });

    test('order is sprout → sapling → smallTree → bigTree → grandTree', () {
      expect(GrowthStage.values, [
        GrowthStage.sprout,
        GrowthStage.sapling,
        GrowthStage.smallTree,
        GrowthStage.bigTree,
        GrowthStage.grandTree,
      ]);
    });
  });

  // ── 계절 감지 ───────────────────────────────────────────────────────────────
  group('Season detection from month', () {
    Season seasonFromMonth(int month) {
      if (month >= 3 && month <= 5) return Season.spring;
      if (month >= 6 && month <= 8) return Season.summer;
      if (month >= 9 && month <= 11) return Season.autumn;
      return Season.winter;
    }

    test('January → winter', () {
      expect(seasonFromMonth(1), Season.winter);
    });

    test('February → winter', () {
      expect(seasonFromMonth(2), Season.winter);
    });

    test('March → spring', () {
      expect(seasonFromMonth(3), Season.spring);
    });

    test('April → spring', () {
      expect(seasonFromMonth(4), Season.spring);
    });

    test('May → spring', () {
      expect(seasonFromMonth(5), Season.spring);
    });

    test('June → summer', () {
      expect(seasonFromMonth(6), Season.summer);
    });

    test('July → summer', () {
      expect(seasonFromMonth(7), Season.summer);
    });

    test('August → summer', () {
      expect(seasonFromMonth(8), Season.summer);
    });

    test('September → autumn', () {
      expect(seasonFromMonth(9), Season.autumn);
    });

    test('October → autumn', () {
      expect(seasonFromMonth(10), Season.autumn);
    });

    test('November → autumn', () {
      expect(seasonFromMonth(11), Season.autumn);
    });

    test('December → winter', () {
      expect(seasonFromMonth(12), Season.winter);
    });
  });

  // ── Season enum ─────────────────────────────────────────────────────────────
  group('Season enum', () {
    test('has exactly 4 values', () {
      expect(Season.values.length, 4);
    });

    test('order is spring → summer → autumn → winter', () {
      expect(Season.values, [
        Season.spring,
        Season.summer,
        Season.autumn,
        Season.winter,
      ]);
    });
  });

  // ── TreeGrowthState 모델 ───────────────────────────────────────────────────
  group('TreeGrowthState', () {
    test('default constructor values', () {
      const state = TreeGrowthState();
      expect(state.stage, GrowthStage.sprout);
      expect(state.season, Season.spring);
      expect(state.score, 0);
    });

    test('equality with same fields', () {
      const a = TreeGrowthState(
        stage: GrowthStage.bigTree,
        season: Season.autumn,
        score: 150,
      );
      const b = TreeGrowthState(
        stage: GrowthStage.bigTree,
        season: Season.autumn,
        score: 150,
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('inequality with different score', () {
      const a = TreeGrowthState(
        stage: GrowthStage.sprout,
        season: Season.winter,
        score: 5,
      );
      const b = TreeGrowthState(
        stage: GrowthStage.sprout,
        season: Season.winter,
        score: 10,
      );
      expect(a, isNot(equals(b)));
    });

    test('inequality with different stage', () {
      const a = TreeGrowthState(
        stage: GrowthStage.sprout,
        season: Season.winter,
        score: 10,
      );
      const b = TreeGrowthState(
        stage: GrowthStage.sapling,
        season: Season.winter,
        score: 10,
      );
      expect(a, isNot(equals(b)));
    });
  });
}
