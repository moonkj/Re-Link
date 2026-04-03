/// EdgePainter 확장 테스트 (미커버 경로 보강)
/// 커버: edge_painter.dart — _borderPoint, _midPoint, _smoothPath,
///        _curvePath (장애물 회피), _paintLightweight (대량 노드 모드),
///        _edgeColor, RelationType.label, 연결 모드 엣지 케이스
import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:re_link/shared/models/node_model.dart';
import 'package:re_link/features/canvas/widgets/edge_painter.dart';

NodeModel _makeNode(String id, {double x = 0, double y = 0, bool isGhost = false}) =>
    NodeModel(
      id: id,
      name: 'Node $id',
      isGhost: isGhost,
      temperature: 2,
      positionX: x,
      positionY: y,
      tags: const [],
      createdAt: DateTime(2024),
      updatedAt: DateTime(2024),
    );

NodeEdge _makeEdge(
  String id,
  String fromId,
  String toId,
  RelationType relation,
) =>
    NodeEdge(
      id: id,
      fromNodeId: fromId,
      toNodeId: toId,
      relation: relation,
      createdAt: DateTime(2024),
    );

void main() {
  late PictureRecorder recorder;
  late Canvas canvas;

  setUp(() {
    recorder = PictureRecorder();
    canvas = Canvas(recorder);
  });

  tearDown(() {
    recorder.endRecording();
  });

  // ── 대량 노드 모드 (>30 노드) ─────────────────────────────────────────────

  group('대량 노드 모드 (_paintLightweight)', () {
    test('31개 노드 → _paintLightweight 경로 진입, 크래시 없음', () {
      final nodes = List.generate(
        35,
        (i) => _makeNode('n$i', x: (i % 7) * 200.0, y: (i ~/ 7) * 200.0),
      );
      // 인접 노드 간 엣지
      final edges = <NodeEdge>[];
      for (int i = 0; i < 34; i++) {
        edges.add(_makeEdge('e$i', 'n$i', 'n${i + 1}', RelationType.other));
      }
      final painter = EdgePainter(nodes: nodes, edges: edges);
      expect(
        () => painter.paint(canvas, const Size(4000, 4000)),
        returnsNormally,
      );
    });

    test('대량 모드에서 부부 엣지 → 크래시 없음', () {
      final nodes = List.generate(
        32,
        (i) => _makeNode('n$i', x: (i % 8) * 150.0, y: (i ~/ 8) * 150.0),
      );
      final edges = [
        _makeEdge('e0', 'n0', 'n1', RelationType.spouse),
        _makeEdge('e1', 'n2', 'n3', RelationType.child),
        _makeEdge('e2', 'n4', 'n5', RelationType.parent),
        _makeEdge('e3', 'n6', 'n7', RelationType.sibling),
      ];
      final painter = EdgePainter(nodes: nodes, edges: edges);
      expect(
        () => painter.paint(canvas, const Size(4000, 4000)),
        returnsNormally,
      );
    });

    test('대량 모드 + 연결 중인 임시 선', () {
      final nodes = List.generate(
        33,
        (i) => _makeNode('n$i', x: (i % 8) * 200.0, y: (i ~/ 8) * 200.0),
      );
      final painter = EdgePainter(
        nodes: nodes,
        edges: const [],
        connectingNodeId: 'n0',
        pointerPosition: const Offset(500, 500),
      );
      expect(
        () => painter.paint(canvas, const Size(4000, 4000)),
        returnsNormally,
      );
    });
  });

  // ── _curvePath 장애물 회피 ────────────────────────────────────────────────

  group('_curvePath 장애물 회피', () {
    test('중간 카드가 있으면 우회 경로 생성 (크래시 없음)', () {
      // A와 C가 멀리 떨어져 있고, B가 중간에 위치
      final nodes = [
        _makeNode('A', x: 0, y: 500),
        _makeNode('B', x: 500, y: 500), // 장애물 (중간)
        _makeNode('C', x: 1000, y: 500),
      ];
      final edges = [
        _makeEdge('e1', 'A', 'C', RelationType.sibling),
      ];
      final painter = EdgePainter(nodes: nodes, edges: edges);
      expect(
        () => painter.paint(canvas, const Size(4000, 4000)),
        returnsNormally,
      );
    });

    test('다수 장애물 카드 → 다중 웨이포인트 (크래시 없음)', () {
      final nodes = [
        _makeNode('A', x: 0, y: 500),
        _makeNode('obs1', x: 300, y: 500),
        _makeNode('obs2', x: 600, y: 500),
        _makeNode('obs3', x: 900, y: 500),
        _makeNode('C', x: 1200, y: 500),
      ];
      final edges = [
        _makeEdge('e1', 'A', 'C', RelationType.other),
      ];
      final painter = EdgePainter(nodes: nodes, edges: edges);
      expect(
        () => painter.paint(canvas, const Size(4000, 4000)),
        returnsNormally,
      );
    });
  });

  // ── _borderPoint 동작 (겹치는 노드) ──────────────────────────────────────

  group('_borderPoint 엣지 케이스', () {
    test('같은 위치 노드 → 크래시 없음', () {
      final nodes = [
        _makeNode('A', x: 500, y: 500),
        _makeNode('B', x: 500, y: 500), // 동일 위치
      ];
      final edges = [_makeEdge('e1', 'A', 'B', RelationType.spouse)];
      final painter = EdgePainter(nodes: nodes, edges: edges);
      expect(
        () => painter.paint(canvas, const Size(4000, 4000)),
        returnsNormally,
      );
    });

    test('매우 가까운 노드 → 크래시 없음', () {
      final nodes = [
        _makeNode('A', x: 500, y: 500),
        _makeNode('B', x: 501, y: 500),
      ];
      final edges = [_makeEdge('e1', 'A', 'B', RelationType.child)];
      final painter = EdgePainter(nodes: nodes, edges: edges);
      expect(
        () => painter.paint(canvas, const Size(4000, 4000)),
        returnsNormally,
      );
    });
  });

  // ── parent 관계 (정규화) ──────────────────────────────────────────────────

  group('parent 관계 정규화', () {
    test('parent 관계 엣지 → 부부-자녀 통합선 경로, 크래시 없음', () {
      final nodes = [
        _makeNode('A', x: 200, y: 200),
        _makeNode('B', x: 400, y: 200),
        _makeNode('C', x: 300, y: 500),
      ];
      final edges = [
        _makeEdge('e1', 'A', 'B', RelationType.spouse),
        // parent 관계: C가 A의 부모라는 엣지 → 정규화시 parent=C, child=A
        _makeEdge('e2', 'C', 'A', RelationType.parent),
      ];
      final painter = EdgePainter(nodes: nodes, edges: edges);
      expect(
        () => painter.paint(canvas, const Size(4000, 4000)),
        returnsNormally,
      );
    });
  });

  // ── sibling 엣지 + 같은 부모 부부 자녀 그룹 ──────────────────────────────

  group('sibling 엣지 + 부부 자녀 그룹', () {
    test('같은 부모 자녀 간 sibling은 건너뜀 (크래시 없음)', () {
      final nodes = [
        _makeNode('P1', x: 200, y: 200),
        _makeNode('P2', x: 400, y: 200),
        _makeNode('C1', x: 200, y: 500),
        _makeNode('C2', x: 400, y: 500),
      ];
      final edges = [
        _makeEdge('e1', 'P1', 'P2', RelationType.spouse),
        _makeEdge('e2', 'P1', 'C1', RelationType.child),
        _makeEdge('e3', 'P2', 'C2', RelationType.child),
        _makeEdge('e4', 'C1', 'C2', RelationType.sibling),
      ];
      final painter = EdgePainter(nodes: nodes, edges: edges);
      expect(
        () => painter.paint(canvas, const Size(4000, 4000)),
        returnsNormally,
      );
    });
  });

  // ── shouldRepaint 확장 ────────────────────────────────────────────────────

  group('shouldRepaint 확장', () {
    test('connectingNodeId 변경 시 true', () {
      final nodes = [_makeNode('A')];
      final p1 = EdgePainter(nodes: nodes, edges: const []);
      final p2 = EdgePainter(
        nodes: nodes,
        edges: const [],
        connectingNodeId: 'A',
      );
      expect(p2.shouldRepaint(p1), isTrue);
    });

    test('pointerPosition 변경 시 true', () {
      final nodes = [_makeNode('A')];
      final p1 = EdgePainter(
        nodes: nodes,
        edges: const [],
        connectingNodeId: 'A',
        pointerPosition: const Offset(100, 100),
      );
      final p2 = EdgePainter(
        nodes: nodes,
        edges: const [],
        connectingNodeId: 'A',
        pointerPosition: const Offset(200, 200),
      );
      expect(p2.shouldRepaint(p1), isTrue);
    });

    test('draggingPosition 변경 시 true', () {
      final nodes = [_makeNode('A')];
      final p1 = EdgePainter(
        nodes: nodes,
        edges: const [],
        draggingNodeId: 'A',
        draggingPosition: const Offset(100, 100),
      );
      final p2 = EdgePainter(
        nodes: nodes,
        edges: const [],
        draggingNodeId: 'A',
        draggingPosition: const Offset(200, 200),
      );
      expect(p2.shouldRepaint(p1), isTrue);
    });
  });

  // ── RelationType.label ────────────────────────────────────────────────────

  group('RelationType.label', () {
    test('parent → 부모', () {
      expect(RelationType.parent.label, '부모');
    });

    test('child → 자녀', () {
      expect(RelationType.child.label, '자녀');
    });

    test('spouse → 배우자', () {
      expect(RelationType.spouse.label, '배우자');
    });

    test('sibling → 형제/자매', () {
      expect(RelationType.sibling.label, '형제/자매');
    });

    test('other → 기타', () {
      expect(RelationType.other.label, '기타');
    });
  });

  // ── 빈 엣지 but 다수 노드 ────────────────────────────────────────────────

  group('빈 엣지 + 다수 노드', () {
    test('10개 노드 0개 엣지 → 크래시 없음', () {
      final nodes = List.generate(
        10,
        (i) => _makeNode('n$i', x: i * 150.0, y: 300),
      );
      final painter = EdgePainter(nodes: nodes, edges: const []);
      expect(
        () => painter.paint(canvas, const Size(4000, 4000)),
        returnsNormally,
      );
    });
  });

  // ── 존재하지 않는 연결 모드 노드 ──────────────────────────────────────────

  group('존재하지 않는 연결 모드 노드', () {
    test('연결 모드 소스 노드가 없으면 임시선 스킵', () {
      final nodes = [_makeNode('A', x: 200, y: 200)];
      final painter = EdgePainter(
        nodes: nodes,
        edges: const [],
        connectingNodeId: 'NONEXISTENT',
        pointerPosition: const Offset(500, 500),
      );
      expect(
        () => painter.paint(canvas, const Size(4000, 4000)),
        returnsNormally,
      );
    });
  });

  // ── 부부 없이 child 엣지만 있는 경우 ─────────────────────────────────────

  group('부부 없이 child 엣지만', () {
    test('부부 관계 없는 child 엣지는 일반 선으로 처리', () {
      final nodes = [
        _makeNode('P', x: 300, y: 200),
        _makeNode('C', x: 300, y: 500),
      ];
      final edges = [
        _makeEdge('e1', 'P', 'C', RelationType.child),
      ];
      final painter = EdgePainter(nodes: nodes, edges: edges);
      expect(
        () => painter.paint(canvas, const Size(4000, 4000)),
        returnsNormally,
      );
    });
  });
}
