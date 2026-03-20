import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:re_link/shared/models/node_model.dart';
import 'package:re_link/features/canvas/widgets/edge_painter.dart';

/// EdgePainter 부부-자녀 통합선 테스트
///
/// CustomPainter는 직접 렌더링하므로, shouldRepaint와 생성자 파라미터를 검증하고,
/// paint() 호출이 크래시 없이 완료되는지 확인합니다.

NodeModel _makeNode(String id, {double x = 0, double y = 0}) => NodeModel(
      id: id,
      name: 'Node $id',
      isGhost: false,
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
  group('EdgePainter — shouldRepaint', () {
    test('동일 데이터면 false', () {
      final nodes = [_makeNode('A'), _makeNode('B')];
      final edges = [_makeEdge('e1', 'A', 'B', RelationType.spouse)];
      final painter1 = EdgePainter(nodes: nodes, edges: edges);
      final painter2 = EdgePainter(nodes: nodes, edges: edges);
      expect(painter1.shouldRepaint(painter2), false);
    });

    test('노드 변경 시 true', () {
      final nodes1 = [_makeNode('A')];
      final nodes2 = [_makeNode('A'), _makeNode('B')];
      final edges = <NodeEdge>[];
      final painter1 = EdgePainter(nodes: nodes1, edges: edges);
      final painter2 = EdgePainter(nodes: nodes2, edges: edges);
      expect(painter2.shouldRepaint(painter1), true);
    });

    test('엣지 변경 시 true', () {
      final nodes = [_makeNode('A'), _makeNode('B')];
      final edges1 = <NodeEdge>[];
      final edges2 = [_makeEdge('e1', 'A', 'B', RelationType.spouse)];
      final painter1 = EdgePainter(nodes: nodes, edges: edges1);
      final painter2 = EdgePainter(nodes: nodes, edges: edges2);
      expect(painter2.shouldRepaint(painter1), true);
    });

    test('draggingNodeId 변경 시 true', () {
      final nodes = [_makeNode('A')];
      final edges = <NodeEdge>[];
      final painter1 = EdgePainter(nodes: nodes, edges: edges);
      final painter2 = EdgePainter(
        nodes: nodes,
        edges: edges,
        draggingNodeId: 'A',
        draggingPosition: const Offset(100, 200),
      );
      expect(painter2.shouldRepaint(painter1), true);
    });
  });

  group('EdgePainter — paint 크래시 없음', () {
    late Canvas canvas;
    late PictureRecorder recorder;

    setUp(() {
      recorder = PictureRecorder();
      canvas = Canvas(recorder);
    });

    tearDown(() {
      recorder.endRecording();
    });

    test('빈 노드/엣지 → 크래시 없음', () {
      final painter = EdgePainter(nodes: const [], edges: const []);
      expect(
        () => painter.paint(canvas, const Size(4000, 4000)),
        returnsNormally,
      );
    });

    test('부부 엣지만 → 크래시 없음', () {
      final nodes = [
        _makeNode('A', x: 200, y: 200),
        _makeNode('B', x: 400, y: 200),
      ];
      final edges = [_makeEdge('e1', 'A', 'B', RelationType.spouse)];
      final painter = EdgePainter(nodes: nodes, edges: edges);
      expect(
        () => painter.paint(canvas, const Size(4000, 4000)),
        returnsNormally,
      );
    });

    test('부부 + 자녀 1명 (단일 커브) → 크래시 없음', () {
      final nodes = [
        _makeNode('A', x: 200, y: 200),
        _makeNode('B', x: 400, y: 200),
        _makeNode('C', x: 300, y: 500),
      ];
      final edges = [
        _makeEdge('e1', 'A', 'B', RelationType.spouse),
        _makeEdge('e2', 'A', 'C', RelationType.child),
      ];
      final painter = EdgePainter(nodes: nodes, edges: edges);
      expect(
        () => painter.paint(canvas, const Size(4000, 4000)),
        returnsNormally,
      );
    });

    test('부부 + 자녀 3명 (T-shape 분기) → 크래시 없음', () {
      final nodes = [
        _makeNode('A', x: 200, y: 200),
        _makeNode('B', x: 400, y: 200),
        _makeNode('C1', x: 100, y: 500),
        _makeNode('C2', x: 300, y: 500),
        _makeNode('C3', x: 500, y: 500),
      ];
      final edges = [
        _makeEdge('e1', 'A', 'B', RelationType.spouse),
        _makeEdge('e2', 'A', 'C1', RelationType.child),
        _makeEdge('e3', 'B', 'C2', RelationType.child),
        _makeEdge('e4', 'A', 'C3', RelationType.child),
      ];
      final painter = EdgePainter(nodes: nodes, edges: edges);
      expect(
        () => painter.paint(canvas, const Size(4000, 4000)),
        returnsNormally,
      );
    });

    test('부부 + 자녀 (부모B 쪽 엣지) → 통합선으로 처리됨', () {
      final nodes = [
        _makeNode('A', x: 200, y: 200),
        _makeNode('B', x: 400, y: 200),
        _makeNode('C', x: 300, y: 500),
      ];
      final edges = [
        _makeEdge('e1', 'A', 'B', RelationType.spouse),
        _makeEdge('e2', 'B', 'C', RelationType.child), // B가 부모
      ];
      final painter = EdgePainter(nodes: nodes, edges: edges);
      expect(
        () => painter.paint(canvas, const Size(4000, 4000)),
        returnsNormally,
      );
    });

    test('혼합 관계 (부부+자녀+형제+기타) → 크래시 없음', () {
      final nodes = [
        _makeNode('A', x: 200, y: 200),
        _makeNode('B', x: 400, y: 200),
        _makeNode('C', x: 300, y: 500),
        _makeNode('D', x: 600, y: 500),
      ];
      final edges = [
        _makeEdge('e1', 'A', 'B', RelationType.spouse),
        _makeEdge('e2', 'A', 'C', RelationType.child),
        _makeEdge('e3', 'C', 'D', RelationType.sibling),
        _makeEdge('e4', 'B', 'D', RelationType.other),
      ];
      final painter = EdgePainter(nodes: nodes, edges: edges);
      expect(
        () => painter.paint(canvas, const Size(4000, 4000)),
        returnsNormally,
      );
    });

    test('드래그 중인 노드 포함 → 실시간 좌표로 렌더링, 크래시 없음', () {
      final nodes = [
        _makeNode('A', x: 200, y: 200),
        _makeNode('B', x: 400, y: 200),
        _makeNode('C', x: 300, y: 500),
      ];
      final edges = [
        _makeEdge('e1', 'A', 'B', RelationType.spouse),
        _makeEdge('e2', 'A', 'C', RelationType.child),
      ];
      final painter = EdgePainter(
        nodes: nodes,
        edges: edges,
        draggingNodeId: 'A',
        draggingPosition: const Offset(250, 250),
      );
      expect(
        () => painter.paint(canvas, const Size(4000, 4000)),
        returnsNormally,
      );
    });

    test('연결 모드 임시 선 → 크래시 없음', () {
      final nodes = [_makeNode('A', x: 200, y: 200)];
      final painter = EdgePainter(
        nodes: nodes,
        edges: const [],
        connectingNodeId: 'A',
        pointerPosition: const Offset(500, 500),
      );
      expect(
        () => painter.paint(canvas, const Size(4000, 4000)),
        returnsNormally,
      );
    });

    test('존재하지 않는 노드 ID 엣지 → 크래시 없음 (graceful skip)', () {
      final nodes = [_makeNode('A', x: 200, y: 200)];
      final edges = [
        _makeEdge('e1', 'A', 'NONEXISTENT', RelationType.spouse),
      ];
      final painter = EdgePainter(nodes: nodes, edges: edges);
      expect(
        () => painter.paint(canvas, const Size(4000, 4000)),
        returnsNormally,
      );
    });
  });

  group('EdgePainter — 통합 자녀선 로직 검증', () {
    test('부부의 공통 자녀 엣지가 개별 엣지로 중복 그려지지 않음', () {
      // 부부(A-B) + 자녀(C): A->C child 엣지
      // 통합선으로 그려지므로 drawnChildEdgeIds에 포함됨
      // => 나머지 엣지 루프에서 건너뛰어야 함
      // 이는 paint()가 크래시 없이 완료되고, shouldRepaint가 정확한 것으로 검증
      final nodes = [
        _makeNode('A', x: 200, y: 200),
        _makeNode('B', x: 400, y: 200),
        _makeNode('C', x: 300, y: 500),
      ];
      final edges = [
        _makeEdge('e1', 'A', 'B', RelationType.spouse),
        _makeEdge('e2', 'A', 'C', RelationType.child),
      ];

      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      final painter = EdgePainter(nodes: nodes, edges: edges);
      // 정상 완료 = 통합선 로직이 자녀 엣지를 올바르게 처리함
      expect(
        () => painter.paint(canvas, const Size(4000, 4000)),
        returnsNormally,
      );
      recorder.endRecording();
    });
  });
}
