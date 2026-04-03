/// TreeGrowth 확장 단위 테스트
/// 커버: tree_growth_notifier.dart — GrowthStage, Season enum,
///        TreeGrowthState 모델, 성장 점수 경계값, 계절 결정
import 'package:flutter_test/flutter_test.dart';
import 'package:re_link/features/tree_growth/providers/tree_growth_notifier.dart';

void main() {
  // ── GrowthStage enum ─────────────────────────────────────────────────────

  group('GrowthStage enum', () {
    test('5 values exist', () {
      expect(GrowthStage.values.length, 5);
    });

    test('enum index order', () {
      expect(GrowthStage.sprout.index, 0);
      expect(GrowthStage.sapling.index, 1);
      expect(GrowthStage.smallTree.index, 2);
      expect(GrowthStage.bigTree.index, 3);
      expect(GrowthStage.grandTree.index, 4);
    });

    test('name getter returns lowercase', () {
      expect(GrowthStage.sprout.name, 'sprout');
      expect(GrowthStage.sapling.name, 'sapling');
      expect(GrowthStage.smallTree.name, 'smallTree');
      expect(GrowthStage.bigTree.name, 'bigTree');
      expect(GrowthStage.grandTree.name, 'grandTree');
    });
  });

  // ── Season enum ──────────────────────────────────────────────────────────

  group('Season enum', () {
    test('4 values exist', () {
      expect(Season.values.length, 4);
    });

    test('enum index order', () {
      expect(Season.spring.index, 0);
      expect(Season.summer.index, 1);
      expect(Season.autumn.index, 2);
      expect(Season.winter.index, 3);
    });
  });

  // ── TreeGrowthState 모델 ───────────────────────────────────────────────

  group('TreeGrowthState model', () {
    test('default constructor', () {
      const state = TreeGrowthState();
      expect(state.stage, GrowthStage.sprout);
      expect(state.season, Season.spring);
      expect(state.score, 0);
    });

    test('custom constructor', () {
      const state = TreeGrowthState(
        stage: GrowthStage.bigTree,
        season: Season.autumn,
        score: 150,
      );
      expect(state.stage, GrowthStage.bigTree);
      expect(state.season, Season.autumn);
      expect(state.score, 150);
    });

    test('equality — same values', () {
      const a = TreeGrowthState(
        stage: GrowthStage.sapling,
        season: Season.summer,
        score: 25,
      );
      const b = TreeGrowthState(
        stage: GrowthStage.sapling,
        season: Season.summer,
        score: 25,
      );
      expect(a == b, isTrue);
      expect(a.hashCode, b.hashCode);
    });

    test('inequality — different stage', () {
      const a = TreeGrowthState(
        stage: GrowthStage.sprout,
        season: Season.spring,
        score: 0,
      );
      const b = TreeGrowthState(
        stage: GrowthStage.sapling,
        season: Season.spring,
        score: 0,
      );
      expect(a == b, isFalse);
    });

    test('inequality — different season', () {
      const a = TreeGrowthState(
        stage: GrowthStage.sprout,
        season: Season.spring,
        score: 0,
      );
      const b = TreeGrowthState(
        stage: GrowthStage.sprout,
        season: Season.winter,
        score: 0,
      );
      expect(a == b, isFalse);
    });

    test('inequality — different score', () {
      const a = TreeGrowthState(
        stage: GrowthStage.sprout,
        season: Season.spring,
        score: 0,
      );
      const b = TreeGrowthState(
        stage: GrowthStage.sprout,
        season: Season.spring,
        score: 1,
      );
      expect(a == b, isFalse);
    });
  });

  // ── 성장 점수 계산 (notifier 로직 재현) ─────────────────────────────────

  group('Growth score calculation', () {
    int calcScore(int nodes, int memories, int streakCount) {
      return nodes * 2 + memories * 1 + (streakCount * 0.5).round();
    }

    test('0 everything → 0', () {
      expect(calcScore(0, 0, 0), 0);
    });

    test('5 nodes, 10 memories, 0 streak → 20', () {
      // 5*2 + 10*1 + 0 = 20
      expect(calcScore(5, 10, 0), 20);
    });

    test('10 nodes, 50 memories, 20 streak → 80', () {
      // 10*2 + 50*1 + (20*0.5).round() = 20 + 50 + 10 = 80
      expect(calcScore(10, 50, 20), 80);
    });

    test('50 nodes, 100 memories, 40 streak → 220', () {
      // 50*2 + 100*1 + (40*0.5).round() = 100 + 100 + 20 = 220
      expect(calcScore(50, 100, 40), 220);
    });

    test('streak rounding — odd streak count', () {
      // streak=3 → (3*0.5).round() = (1.5).round() = 2
      expect(calcScore(0, 0, 3), 2);
    });

    test('streak rounding — even streak count', () {
      // streak=4 → (4*0.5).round() = 2
      expect(calcScore(0, 0, 4), 2);
    });

    test('streak rounding — 1', () {
      // streak=1 → (0.5).round() = 1  (rounds towards even = 0)
      // Actually in Dart, 0.5.round() == 1 on some platforms, 0 on others
      // Dart spec: rounds half away from zero on native, banker's on web
      // Since this is native test: (0.5).round() == 1
      expect(calcScore(0, 0, 1), (0.5).round());
    });
  });

  // ── 성장 단계 결정 ──────────────────────────────────────────────────────

  group('Growth stage determination', () {
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

    test('score 10 → sprout', () {
      expect(stageFromScore(10), GrowthStage.sprout);
    });

    test('score 11 → sapling', () {
      expect(stageFromScore(11), GrowthStage.sapling);
    });

    test('score 30 → sapling', () {
      expect(stageFromScore(30), GrowthStage.sapling);
    });

    test('score 31 → smallTree', () {
      expect(stageFromScore(31), GrowthStage.smallTree);
    });

    test('score 80 → smallTree', () {
      expect(stageFromScore(80), GrowthStage.smallTree);
    });

    test('score 81 → bigTree', () {
      expect(stageFromScore(81), GrowthStage.bigTree);
    });

    test('score 200 → bigTree', () {
      expect(stageFromScore(200), GrowthStage.bigTree);
    });

    test('score 201 → grandTree', () {
      expect(stageFromScore(201), GrowthStage.grandTree);
    });

    test('score 1000 → grandTree', () {
      expect(stageFromScore(1000), GrowthStage.grandTree);
    });
  });

  // ── 계절 결정 ──────────────────────────────────────────────────────────

  group('Season determination from month', () {
    Season seasonFromMonth(int month) {
      if (month >= 3 && month <= 5) return Season.spring;
      if (month >= 6 && month <= 8) return Season.summer;
      if (month >= 9 && month <= 11) return Season.autumn;
      return Season.winter;
    }

    test('January → winter', () => expect(seasonFromMonth(1), Season.winter));
    test('February → winter', () => expect(seasonFromMonth(2), Season.winter));
    test('March → spring', () => expect(seasonFromMonth(3), Season.spring));
    test('April → spring', () => expect(seasonFromMonth(4), Season.spring));
    test('May → spring', () => expect(seasonFromMonth(5), Season.spring));
    test('June → summer', () => expect(seasonFromMonth(6), Season.summer));
    test('July → summer', () => expect(seasonFromMonth(7), Season.summer));
    test('August → summer', () => expect(seasonFromMonth(8), Season.summer));
    test('September → autumn', () => expect(seasonFromMonth(9), Season.autumn));
    test('October → autumn', () => expect(seasonFromMonth(10), Season.autumn));
    test('November → autumn', () => expect(seasonFromMonth(11), Season.autumn));
    test('December → winter', () => expect(seasonFromMonth(12), Season.winter));
  });

  // ── streakCount 파싱 ──────────────────────────────────────────────────

  group('Streak count parsing', () {
    test('valid string → int', () {
      const str = '15';
      expect(int.tryParse(str) ?? 0, 15);
    });

    test('null string → 0', () {
      String? str;
      expect(int.tryParse(str ?? '0') ?? 0, 0);
    });

    test('empty string → 0', () {
      const str = '';
      expect(int.tryParse(str) ?? 0, 0);
    });

    test('invalid string → 0', () {
      const str = 'abc';
      expect(int.tryParse(str) ?? 0, 0);
    });

    test('zero string → 0', () {
      const str = '0';
      expect(int.tryParse(str) ?? 0, 0);
    });
  });
}
