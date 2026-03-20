import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:re_link/shared/models/node_model.dart';

/// 부부 자석 스냅 로직 테스트
///
/// canvas_screen.dart의 _spouseSnap 로직을 순수 함수로 추출하여 테스트합니다.
/// 실제 구현은 _CanvasScreenState._spouseSnap이지만, 로직 자체를 검증합니다.

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

/// _spouseSnap 로직을 재현한 순수 함수 (canvas_screen.dart 동일 로직)
Offset spouseSnap(
  String nodeId,
  double x,
  double y,
  List<NodeModel> nodes,
  List<NodeEdge> edges,
) {
  const snapDistance = 200.0;
  const snapGap = 130.0;

  final spouseEdge = edges
      .where((e) =>
          e.relation == RelationType.spouse &&
          (e.fromNodeId == nodeId || e.toNodeId == nodeId))
      .firstOrNull;
  if (spouseEdge == null) return Offset(x, y);

  final spouseId = spouseEdge.fromNodeId == nodeId
      ? spouseEdge.toNodeId
      : spouseEdge.fromNodeId;
  final spouse = nodes.where((n) => n.id == spouseId).firstOrNull;
  if (spouse == null) return Offset(x, y);

  final dx = x - spouse.positionX;
  final dy = y - spouse.positionY;
  final dist = Offset(dx, dy).distance;

  if (dist < snapDistance) {
    final side = dx >= 0 ? 1.0 : -1.0;
    return Offset(spouse.positionX + side * snapGap, spouse.positionY);
  }

  return Offset(x, y);
}

void main() {
  group('부부 자석 스냅', () {
    test('배우자가 없으면 원래 좌표 반환', () {
      final nodes = [_makeNode('A', x: 500, y: 500)];
      final edges = <NodeEdge>[];

      final result = spouseSnap('A', 600, 600, nodes, edges);
      expect(result, const Offset(600, 600));
    });

    test('배우자가 있지만 거리가 200px 초과이면 스냅하지 않음', () {
      final nodes = [
        _makeNode('A', x: 100, y: 100),
        _makeNode('B', x: 500, y: 500),
      ];
      final edges = [_makeEdge('e1', 'A', 'B', RelationType.spouse)];

      // A를 (400, 400)으로 드래그 — B(500,500)에서 약 141px
      // 하지만 이는 200px 이내이므로 스냅됨
      // A를 (100, 100)으로 놔둔 상태에서 (100, 100)에서 B(500,500)까지 거리 ≈ 565px
      final result = spouseSnap('A', 100, 100, nodes, edges);
      // 거리 = sqrt(400^2 + 400^2) ≈ 565 > 200 → 스냅 안됨
      expect(result, const Offset(100, 100));
    });

    test('배우자가 200px 이내이면 오른쪽에 스냅', () {
      final nodes = [
        _makeNode('A', x: 500, y: 300),
        _makeNode('B', x: 500, y: 300),
      ];
      final edges = [_makeEdge('e1', 'A', 'B', RelationType.spouse)];

      // A를 B 오른쪽 근처로 드래그 (B.x + 50, B.y)
      final result = spouseSnap('A', 550, 300, nodes, edges);
      // 거리 = 50 < 200 → 스냅됨, 오른쪽
      expect(result.dx, 500 + 130); // spouse.x + snapGap
      expect(result.dy, 300); // spouse.y와 같은 높이
    });

    test('배우자가 200px 이내이면 왼쪽에 스냅', () {
      final nodes = [
        _makeNode('A', x: 500, y: 300),
        _makeNode('B', x: 500, y: 300),
      ];
      final edges = [_makeEdge('e1', 'A', 'B', RelationType.spouse)];

      // A를 B 왼쪽 근처로 드래그 (B.x - 50, B.y)
      final result = spouseSnap('A', 450, 300, nodes, edges);
      // 거리 = 50 < 200 → 스냅됨, 왼쪽
      expect(result.dx, 500 - 130); // spouse.x - snapGap
      expect(result.dy, 300); // spouse.y와 같은 높이
    });

    test('스냅 시 Y 좌표가 배우자와 동일해짐 (수평 정렬)', () {
      final nodes = [
        _makeNode('A', x: 500, y: 300),
        _makeNode('B', x: 500, y: 300),
      ];
      final edges = [_makeEdge('e1', 'A', 'B', RelationType.spouse)];

      // A를 (520, 380)으로 드래그 — 약간 아래, 오른쪽
      final result = spouseSnap('A', 520, 380, nodes, edges);
      // 거리 = sqrt(20^2+80^2) ≈ 82 < 200 → 스냅됨
      expect(result.dy, 300); // Y가 배우자(300)로 맞춰짐
    });

    test('비-배우자 관계는 무시됨', () {
      final nodes = [
        _makeNode('A', x: 500, y: 300),
        _makeNode('B', x: 510, y: 300),
      ];
      // parent 관계만 있음 (spouse 아님)
      final edges = [_makeEdge('e1', 'A', 'B', RelationType.parent)];

      final result = spouseSnap('A', 510, 300, nodes, edges);
      // 배우자 엣지가 없으므로 원래 좌표 반환
      expect(result, const Offset(510, 300));
    });

    test('fromNodeId/toNodeId 양방향 모두 인식', () {
      final nodes = [
        _makeNode('A', x: 500, y: 300),
        _makeNode('B', x: 500, y: 300),
      ];
      // B → A 방향 엣지 (A가 toNodeId)
      final edges = [_makeEdge('e1', 'B', 'A', RelationType.spouse)];

      final result = spouseSnap('A', 520, 300, nodes, edges);
      // A의 배우자 B를 찾아서 스냅 적용
      expect(result.dx, 500 + 130);
      expect(result.dy, 300);
    });
  });

  group('CanvasState — spouse edge 유틸', () {
    test('spouse 엣지가 edges 리스트에 존재', () {
      final edges = [
        _makeEdge('e1', 'A', 'B', RelationType.spouse),
        _makeEdge('e2', 'A', 'C', RelationType.child),
      ];
      final spouseEdges =
          edges.where((e) => e.relation == RelationType.spouse).toList();
      expect(spouseEdges.length, 1);
      expect(spouseEdges.first.fromNodeId, 'A');
      expect(spouseEdges.first.toNodeId, 'B');
    });
  });
}
