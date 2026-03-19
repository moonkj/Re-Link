import 'package:flutter_test/flutter_test.dart';
import 'package:re_link/features/canvas/utils/generation_utils.dart';
import 'package:re_link/shared/models/node_model.dart';

NodeModel _node(String id) => NodeModel(
      id: id,
      name: id,
      positionX: 0,
      positionY: 0,
      createdAt: DateTime(2024),
      updatedAt: DateTime(2024),
    );

NodeEdge _edge(String from, String to, [RelationType rel = RelationType.parent]) =>
    NodeEdge(
      id: '${from}_$to',
      fromNodeId: from,
      toNodeId: to,
      relation: rel,
      createdAt: DateTime(2024),
    );

void main() {
  group('computeGenerations', () {
    test('단일 노드 — depth 0', () {
      final result = computeGenerations(
        nodes: [_node('A')],
        edges: [],
      );
      expect(result['A'], 0);
    });

    test('부모-자녀 2단계 체인', () {
      final result = computeGenerations(
        nodes: [_node('A'), _node('B'), _node('C')],
        edges: [_edge('A', 'B'), _edge('B', 'C')],
        rootId: 'A',
      );
      expect(result['A'], 0);
      expect(result['B'], 1);
      expect(result['C'], 2);
    });

    test('연결되지 않은 노드 → depth 0', () {
      final result = computeGenerations(
        nodes: [_node('A'), _node('B'), _node('Z')],
        edges: [_edge('A', 'B')],
        rootId: 'A',
      );
      expect(result['Z'], 0);
    });

    test('rootId 미지정 — 첫 번째 노드가 루트', () {
      final result = computeGenerations(
        nodes: [_node('Root'), _node('Child')],
        edges: [_edge('Root', 'Child')],
      );
      expect(result['Root'], 0);
      expect(result['Child'], 1);
    });

    test('빈 노드 목록 → 빈 맵', () {
      final result = computeGenerations(nodes: [], edges: []);
      expect(result, isEmpty);
    });

    test('무방향 — 역방향 엣지도 동일 깊이', () {
      final result = computeGenerations(
        nodes: [_node('A'), _node('B')],
        edges: [_edge('B', 'A')], // B → A 방향으로 삽입
        rootId: 'A',
      );
      expect(result['A'], 0);
      expect(result['B'], 1);
    });
  });

  group('pseudo3dTransform', () {
    test('depth 0 → scale 1.0, opacity 1.0, translateY 0', () {
      final t = pseudo3dTransform(0);
      expect(t.scale, closeTo(1.0, 0.001));
      expect(t.opacity, closeTo(1.0, 0.001));
      expect(t.translateY, closeTo(0.0, 0.001));
    });

    test('depth 5 → scale 0.90, opacity 0.70, translateY -12', () {
      final t = pseudo3dTransform(5);
      expect(t.scale, closeTo(0.90, 0.001));
      expect(t.opacity, closeTo(0.70, 0.001));
      expect(t.translateY, closeTo(-12.0, 0.001));
    });

    test('depth > 5 → clamp 적용', () {
      final t5 = pseudo3dTransform(5);
      final t10 = pseudo3dTransform(10);
      expect(t10.scale, closeTo(t5.scale, 0.001));
      expect(t10.opacity, closeTo(t5.opacity, 0.001));
    });

    test('depth 2 → 중간값 보간', () {
      final t = pseudo3dTransform(2);
      expect(t.scale, greaterThan(0.90));
      expect(t.scale, lessThan(1.0));
      expect(t.opacity, greaterThan(0.70));
      expect(t.opacity, lessThan(1.0));
    });
  });
}
