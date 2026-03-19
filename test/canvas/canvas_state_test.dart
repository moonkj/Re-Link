import 'package:flutter_test/flutter_test.dart';
import 'package:re_link/features/canvas/providers/canvas_notifier.dart';
import 'package:re_link/shared/models/node_model.dart';

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

void main() {
  group('CanvasState', () {
    test('초기 상태 — 빈 노드/엣지, 연결 모드 없음', () {
      const state = CanvasState();
      expect(state.nodes, isEmpty);
      expect(state.edges, isEmpty);
      expect(state.isConnectMode, false);
      expect(state.connectingNodeId, isNull);
      expect(state.selectedNodeId, isNull);
    });

    test('isConnectMode — connectingNodeId가 있으면 true', () {
      final state = const CanvasState().copyWith(connectingNodeId: 'node-1');
      expect(state.isConnectMode, true);
    });

    test('isConnectMode — connectingNodeId가 없으면 false', () {
      final state = const CanvasState();
      expect(state.isConnectMode, false);
    });

    test('copyWith — nodes 업데이트', () {
      const state = CanvasState();
      final node = _makeNode('1');
      final updated = state.copyWith(nodes: [node]);

      expect(updated.nodes.length, 1);
      expect(updated.nodes.first.id, '1');
    });

    test('copyWith — clearSelected=true 시 selectedNodeId가 null로', () {
      final state = const CanvasState().copyWith(selectedNodeId: 'node-1');
      expect(state.selectedNodeId, 'node-1');

      final cleared = state.copyWith(clearSelected: true);
      expect(cleared.selectedNodeId, isNull);
    });

    test('copyWith — clearConnecting=true 시 connectingNodeId가 null로', () {
      final state = const CanvasState().copyWith(connectingNodeId: 'node-2');
      expect(state.connectingNodeId, 'node-2');

      final cleared = state.copyWith(clearConnecting: true);
      expect(cleared.connectingNodeId, isNull);
    });

    test('selectedNode — selectedNodeId에 해당하는 노드를 반환한다', () {
      final node = _makeNode('42');
      final state = CanvasState(nodes: [node], selectedNodeId: '42');

      expect(state.selectedNode, isNotNull);
      expect(state.selectedNode!.id, '42');
    });

    test('selectedNode — selectedNodeId가 null이면 null 반환', () {
      final state = CanvasState(nodes: [_makeNode('1')]);
      expect(state.selectedNode, isNull);
    });

    test('selectedNode — 없는 ID면 null 반환', () {
      final state = CanvasState(
        nodes: [_makeNode('1')],
        selectedNodeId: 'nonexistent',
      );
      expect(state.selectedNode, isNull);
    });

    test('copyWith — 기존 값 유지 (변경하지 않은 필드)', () {
      final node = _makeNode('1');
      final edge = NodeEdge(
        id: 'e1',
        fromNodeId: '1',
        toNodeId: '2',
        relation: RelationType.parent,
        createdAt: DateTime(2024),
      );
      final state = CanvasState(
        nodes: [node],
        edges: [edge],
        selectedNodeId: 'sel',
        connectingNodeId: 'conn',
      );

      // nodes만 변경
      final onlyNodes = state.copyWith(nodes: [_makeNode('2'), _makeNode('3')]);
      expect(onlyNodes.edges, [edge]); // 유지
      expect(onlyNodes.selectedNodeId, 'sel'); // 유지
      expect(onlyNodes.connectingNodeId, 'conn'); // 유지
      expect(onlyNodes.nodes.length, 2);
    });
  });
}
