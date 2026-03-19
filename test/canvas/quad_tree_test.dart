import 'package:flutter_test/flutter_test.dart';
import 'package:re_link/features/canvas/utils/quad_tree.dart';

void main() {
  group('QRect', () {
    const r = QRect(left: 0, top: 0, right: 100, bottom: 100);

    test('contains — 내부 좌표', () {
      expect(r.contains(50, 50), isTrue);
      expect(r.contains(0, 0), isTrue);
      expect(r.contains(100, 100), isTrue);
    });

    test('contains — 외부 좌표', () {
      expect(r.contains(101, 50), isFalse);
      expect(r.contains(50, -1), isFalse);
    });

    test('intersects — 겹치는 두 사각형', () {
      const other = QRect(left: 50, top: 50, right: 150, bottom: 150);
      expect(r.intersects(other), isTrue);
    });

    test('intersects — 겹치지 않는 두 사각형', () {
      const other = QRect(left: 200, top: 200, right: 300, bottom: 300);
      expect(r.intersects(other), isFalse);
    });

    test('midX / midY', () {
      expect(r.midX, 50);
      expect(r.midY, 50);
    });

    test('사분면 분할 — nw 경계', () {
      final nw = r.nw;
      expect(nw.left, 0);
      expect(nw.top, 0);
      expect(nw.right, 50);
      expect(nw.bottom, 50);
    });
  });

  group('QuadTree<String>', () {
    late QuadTree<String> qt;

    setUp(() {
      qt = QuadTree(
        const QRect(left: 0, top: 0, right: 1000, bottom: 1000),
        capacity: 4,
      );
    });

    test('insert & query — 단순 검색', () {
      qt.insert('A', 100, 100);
      qt.insert('B', 500, 500);
      qt.insert('C', 900, 900);

      final result = qt.query(
        const QRect(left: 0, top: 0, right: 200, bottom: 200),
      );
      expect(result, contains('A'));
      expect(result, isNot(contains('B')));
      expect(result, isNot(contains('C')));
    });

    test('capacity 초과 시 자동 분할 후 쿼리', () {
      for (var i = 0; i < 10; i++) {
        qt.insert('node_$i', (i * 90).toDouble(), (i * 80).toDouble());
      }
      final result = qt.query(
        const QRect(left: 0, top: 0, right: 100, bottom: 100),
      );
      expect(result, isNotEmpty);
    });

    test('경계 밖 insert는 무시', () {
      qt.insert('out', 2000, 2000);
      final result = qt.query(
        const QRect(left: 0, top: 0, right: 1000, bottom: 1000),
      );
      expect(result, isNot(contains('out')));
    });

    test('전체 범위 쿼리 — 모든 아이템 반환', () {
      qt.insert('X', 100, 100);
      qt.insert('Y', 700, 700);
      qt.insert('Z', 999, 999);

      final all = qt.query(
        const QRect(left: 0, top: 0, right: 1000, bottom: 1000),
      );
      expect(all.length, 3);
    });

    test('빈 쿼리 범위 — 빈 결과', () {
      qt.insert('A', 100, 100);
      final result = qt.query(
        const QRect(left: 500, top: 500, right: 600, bottom: 600),
      );
      expect(result, isEmpty);
    });
  });
}
