import 'package:flutter_test/flutter_test.dart';
import 'package:re_link/features/canvas/providers/canvas_notifier.dart';
import 'package:re_link/shared/models/node_model.dart';

void main() {
  group('CanvasState Focus Mode', () {
    final nodeA = NodeModel(id: 'a', name: 'A', createdAt: DateTime.now());
    final nodeB = NodeModel(id: 'b', name: 'B', createdAt: DateTime.now());
    final nodeC = NodeModel(id: 'c', name: 'C', createdAt: DateTime.now());
    final edge = NodeEdge(
      id: 'e1',
      fromNodeId: 'a',
      toNodeId: 'b',
      relation: RelationType.parent,
      createdAt: DateTime.now(),
    );

    test('focusedNodeId = null → 모든 노드 opacity 1.0', () {
      const state = CanvasState();
      expect(state.nodeOpacity('a'), 1.0);
      expect(state.nodeOpacity('b'), 1.0);
    });

    test('focusedNodeId = "a" → nodeA opacity 1.0', () {
      final state = CanvasState(
        nodes: [nodeA, nodeB, nodeC],
        edges: [edge],
        focusedNodeId: 'a',
      );
      expect(state.nodeOpacity('a'), 1.0);
    });

    test('focusedNodeId = "a" → 연결된 nodeB opacity 0.7', () {
      final state = CanvasState(
        nodes: [nodeA, nodeB, nodeC],
        edges: [edge],
        focusedNodeId: 'a',
      );
      expect(state.nodeOpacity('b'), 0.7);
    });

    test('focusedNodeId = "a" → 연결 없는 nodeC opacity 0.15', () {
      final state = CanvasState(
        nodes: [nodeA, nodeB, nodeC],
        edges: [edge],
        focusedNodeId: 'a',
      );
      expect(state.nodeOpacity('c'), 0.15);
    });

    test('isFocusMode: focusedNodeId 있으면 true', () {
      final state = CanvasState(focusedNodeId: 'a');
      expect(state.isFocusMode, isTrue);
    });

    test('isFocusMode: focusedNodeId null이면 false', () {
      const state = CanvasState();
      expect(state.isFocusMode, isFalse);
    });
  });

  group('CanvasState Time Slider', () {
    final node2000 = NodeModel(
      id: 'n1', name: 'A', createdAt: DateTime.now(),
      birthDate: DateTime(2000, 1, 1),
    );
    final node2010 = NodeModel(
      id: 'n2', name: 'B', createdAt: DateTime.now(),
      birthDate: DateTime(2010, 1, 1),
    );
    final nodeNoBirth = NodeModel(
      id: 'n3', name: 'C', createdAt: DateTime.now(),
    );

    test('timeSliderYear = null → 모든 노드 visible', () {
      const state = CanvasState();
      expect(state.nodeVisibleInTime(node2000), isTrue);
      expect(state.nodeVisibleInTime(node2010), isTrue);
    });

    test('timeSliderYear = 2005 → 2000년생 visible, 2010년생 invisible', () {
      const state = CanvasState(timeSliderYear: 2005);
      expect(state.nodeVisibleInTime(node2000), isTrue);
      expect(state.nodeVisibleInTime(node2010), isFalse);
    });

    test('birthDate 없는 노드는 항상 visible', () {
      const state = CanvasState(timeSliderYear: 2000);
      expect(state.nodeVisibleInTime(nodeNoBirth), isTrue);
    });
  });

  group('CanvasState copyWith', () {
    test('clearFocused=true → focusedNodeId = null', () {
      final state = CanvasState(focusedNodeId: 'a');
      final cleared = state.copyWith(clearFocused: true);
      expect(cleared.focusedNodeId, isNull);
    });

    test('clearTimeSliderYear=true → timeSliderYear = null', () {
      const state = CanvasState(timeSliderYear: 2020);
      final cleared = state.copyWith(clearTimeSliderYear: true);
      expect(cleared.timeSliderYear, isNull);
    });
  });
}
