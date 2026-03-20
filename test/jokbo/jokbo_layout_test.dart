import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:re_link/features/jokbo/services/jokbo_layout_service.dart';

void main() {
  // ── 상수 검증 ──────────────────────────────────────────────────────────────
  group('JokboLayoutService constants', () {
    test('center is (2000, 2000)', () {
      expect(JokboLayoutService.center, const Offset(2000, 2000));
    });

    test('generationSpacing is 200', () {
      expect(JokboLayoutService.generationSpacing, 200.0);
    });

    test('nodeSpacing is 180', () {
      expect(JokboLayoutService.nodeSpacing, 180.0);
    });
  });

  // ── 빈 입력 ────────────────────────────────────────────────────────────────
  group('Empty input', () {
    test('empty generations map returns empty layout', () {
      final result = JokboLayoutService.calculateLayout({});
      expect(result, isEmpty);
    });

    test('generation with empty id list is skipped', () {
      final result = JokboLayoutService.calculateLayout({1: []});
      expect(result, isEmpty);
    });
  });

  // ── 1세대 1명 → 캔버스 중앙 ──────────────────────────────────────────────
  group('Single generation single node', () {
    test('1 generation 1 node is placed at center area', () {
      final result = JokboLayoutService.calculateLayout({
        1: ['A'],
      });

      expect(result.length, 1);
      expect(result.containsKey('A'), true);

      final pos = result['A']!;
      // x: center.dx - (1-1)/2 * 180 = 2000
      expect(pos.dx, 2000.0);
      // y depends on formula: center.dy - (1/2 - 1 + 1) * 200 = 2000 - 100 = 1900
      // With totalGens=1, gen=1: y = 2000 - (1/2 - 1 + 1) * 200 = 2000 - 100 = 1900
      expect(pos.dy, 1900.0);
    });
  });

  // ── 2세대 2명 → 부모-자식 세로 배치 ───────────────────────────────────────
  group('Two generations', () {
    test('2 generations 1 node each: vertical spacing', () {
      final result = JokboLayoutService.calculateLayout({
        1: ['parent'],
        2: ['child'],
      });

      expect(result.length, 2);

      final parentPos = result['parent']!;
      final childPos = result['child']!;

      // Both at x=2000 (single node per gen)
      expect(parentPos.dx, 2000.0);
      expect(childPos.dx, 2000.0);

      // Vertical gap = generationSpacing (200)
      expect(childPos.dy - parentPos.dy, 200.0);
    });

    test('2 generations with 2 nodes in gen 2: horizontal spread', () {
      final result = JokboLayoutService.calculateLayout({
        1: ['parent'],
        2: ['childA', 'childB'],
      });

      expect(result.length, 3);

      final childA = result['childA']!;
      final childB = result['childB']!;

      // Horizontal gap = nodeSpacing (180)
      expect((childB.dx - childA.dx).abs(), 180.0);

      // Children are centered: startX = 2000 - (2-1)/2 * 180 = 2000 - 90 = 1910
      expect(childA.dx, 1910.0);
      expect(childB.dx, 2090.0);
    });
  });

  // ── 3세대 배치 ─────────────────────────────────────────────────────────────
  group('Three generations', () {
    test('3 generations with 1, 2, 4 nodes', () {
      final result = JokboLayoutService.calculateLayout({
        1: ['grandparent'],
        2: ['parentA', 'parentB'],
        3: ['childA', 'childB', 'childC', 'childD'],
      });

      expect(result.length, 7);

      // All nodes should be present
      expect(result.containsKey('grandparent'), true);
      expect(result.containsKey('parentA'), true);
      expect(result.containsKey('parentB'), true);
      expect(result.containsKey('childA'), true);
      expect(result.containsKey('childD'), true);

      // Vertical: each generation separated by 200
      final gpY = result['grandparent']!.dy;
      final pY = result['parentA']!.dy;
      final cY = result['childA']!.dy;

      expect(pY - gpY, 200.0);
      expect(cY - pY, 200.0);
    });

    test('3rd generation 4 nodes are horizontally centered', () {
      final result = JokboLayoutService.calculateLayout({
        1: ['gp'],
        2: ['pA', 'pB'],
        3: ['c1', 'c2', 'c3', 'c4'],
      });

      final c1 = result['c1']!;
      final c2 = result['c2']!;
      final c3 = result['c3']!;
      final c4 = result['c4']!;

      // Spacing between consecutive nodes = 180
      expect((c2.dx - c1.dx).abs(), closeTo(180.0, 0.01));
      expect((c3.dx - c2.dx).abs(), closeTo(180.0, 0.01));
      expect((c4.dx - c3.dx).abs(), closeTo(180.0, 0.01));

      // startX = 2000 - (4-1)/2 * 180 = 2000 - 270 = 1730
      expect(c1.dx, 1730.0);
      expect(c4.dx, 2270.0);

      // Average x should be center (2000)
      final avgX = (c1.dx + c2.dx + c3.dx + c4.dx) / 4;
      expect(avgX, 2000.0);
    });
  });

  // ── x/y 좌표 간격 일관성 ──────────────────────────────────────────────────
  group('Coordinate spacing consistency', () {
    test('all nodes in same generation share the same y', () {
      final result = JokboLayoutService.calculateLayout({
        1: ['a1', 'a2', 'a3'],
        2: ['b1', 'b2'],
      });

      final y1 = result['a1']!.dy;
      expect(result['a2']!.dy, y1);
      expect(result['a3']!.dy, y1);

      final y2 = result['b1']!.dy;
      expect(result['b2']!.dy, y2);
    });

    test('horizontal spacing is always nodeSpacing (180)', () {
      final result = JokboLayoutService.calculateLayout({
        1: ['n1', 'n2', 'n3', 'n4', 'n5'],
      });

      final positions = ['n1', 'n2', 'n3', 'n4', 'n5']
          .map((id) => result[id]!.dx)
          .toList();

      for (int i = 1; i < positions.length; i++) {
        expect(positions[i] - positions[i - 1], closeTo(180.0, 0.01));
      }
    });

    test('vertical spacing is always generationSpacing (200)', () {
      final result = JokboLayoutService.calculateLayout({
        1: ['g1'],
        2: ['g2'],
        3: ['g3'],
        4: ['g4'],
      });

      final ys = [1, 2, 3, 4].map((g) {
        final key = 'g$g';
        return result[key]!.dy;
      }).toList();

      for (int i = 1; i < ys.length; i++) {
        expect(ys[i] - ys[i - 1], closeTo(200.0, 0.01));
      }
    });
  });

  // ── 경계 클램핑 (100~3900) ────────────────────────────────────────────────
  group('Canvas boundary clamping', () {
    test('many nodes in one generation clamp to min 100', () {
      // 50 nodes in one row: startX = 2000 - (49/2)*180 = 2000 - 4410 = -2410
      // first node would be at -2410 → clamped to 100
      final ids = List.generate(50, (i) => 'node$i');
      final result = JokboLayoutService.calculateLayout({1: ids});

      for (final entry in result.entries) {
        expect(entry.value.dx, greaterThanOrEqualTo(100.0));
        expect(entry.value.dx, lessThanOrEqualTo(3900.0));
        expect(entry.value.dy, greaterThanOrEqualTo(100.0));
        expect(entry.value.dy, lessThanOrEqualTo(3900.0));
      }
    });

    test('many generations clamp y to boundaries', () {
      // 30 generations: some will exceed the 4000 canvas
      final generations = <int, List<String>>{};
      for (int g = 1; g <= 30; g++) {
        generations[g] = ['node_g$g'];
      }
      final result = JokboLayoutService.calculateLayout(generations);

      for (final entry in result.entries) {
        expect(entry.value.dy, greaterThanOrEqualTo(100.0));
        expect(entry.value.dy, lessThanOrEqualTo(3900.0));
      }
    });
  });

  // ── 세대 수에 따른 전체 영역 크기 ─────────────────────────────────────────
  group('Total area based on generation count', () {
    test('single generation occupies horizontal space only', () {
      final result = JokboLayoutService.calculateLayout({
        1: ['a', 'b', 'c'],
      });

      final xs = result.values.map((o) => o.dx).toList();
      final ys = result.values.map((o) => o.dy).toList();

      final width = xs.reduce((a, b) => a > b ? a : b) -
          xs.reduce((a, b) => a < b ? a : b);
      final height = ys.reduce((a, b) => a > b ? a : b) -
          ys.reduce((a, b) => a < b ? a : b);

      // 3 nodes: 2 gaps * 180 = 360
      expect(width, closeTo(360.0, 0.01));
      // single generation: no vertical spread
      expect(height, 0.0);
    });

    test('4 generations vertical span is 3 * 200 = 600', () {
      final result = JokboLayoutService.calculateLayout({
        1: ['a'],
        2: ['b'],
        3: ['c'],
        4: ['d'],
      });

      final ys = result.values.map((o) => o.dy).toList()..sort();
      final verticalSpan = ys.last - ys.first;
      expect(verticalSpan, closeTo(600.0, 0.01));
    });
  });
}
