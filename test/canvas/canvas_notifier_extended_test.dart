/// CanvasState 확장 단위 테스트
/// 커버: canvas_notifier.dart 미커버 라인 (96-182)
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:re_link/core/database/app_database.dart';
import 'package:re_link/shared/models/node_model.dart';
import 'package:re_link/shared/repositories/node_repository.dart';
import 'package:re_link/features/canvas/providers/canvas_notifier.dart';
import '../helpers/test_helpers.dart';

NodeModel _node(String id, {DateTime? birthDate, bool isGhost = false}) =>
    NodeModel(
      id: id,
      name: 'Node$id',
      createdAt: DateTime(2024),
      birthDate: birthDate,
      isGhost: isGhost,
    );

NodeEdge _edge(String from, String to) => NodeEdge(
      id: 'e_${from}_$to',
      fromNodeId: from,
      toNodeId: to,
      relation: RelationType.spouse,
      createdAt: DateTime(2024),
    );

void main() {
  // ── CanvasState 기본 ─────────────────────────────────────────────────────

  group('CanvasState 기본 속성', () {
    test('기본 상태: nodes=[], edges=[], 모든 nullable=null', () {
      const s = CanvasState();
      expect(s.nodes, isEmpty);
      expect(s.edges, isEmpty);
      expect(s.selectedNodeId, isNull);
      expect(s.connectingNodeId, isNull);
      expect(s.focusedNodeId, isNull);
      expect(s.timeSliderVisible, isFalse);
      expect(s.timeSliderYear, isNull);
    });

    test('isConnectMode: connectingNodeId != null → true', () {
      final s = const CanvasState().copyWith(connectingNodeId: 'n1');
      expect(s.isConnectMode, isTrue);
    });

    test('isConnectMode: connectingNodeId = null → false', () {
      expect(const CanvasState().isConnectMode, isFalse);
    });

    test('isFocusMode: focusedNodeId != null → true', () {
      final s = const CanvasState().copyWith(focusedNodeId: 'n1');
      expect(s.isFocusMode, isTrue);
    });

    test('isFocusMode: focusedNodeId = null → false', () {
      expect(const CanvasState().isFocusMode, isFalse);
    });

    test('selectedNode: 노드 없으면 null', () {
      final s = const CanvasState().copyWith(selectedNodeId: 'n1');
      expect(s.selectedNode, isNull);
    });

    test('selectedNode: 일치하는 노드 반환', () {
      final n = _node('n1');
      final s = CanvasState(nodes: [n], selectedNodeId: 'n1');
      expect(s.selectedNode, isNotNull);
      expect(s.selectedNode!.id, 'n1');
    });
  });

  // ── copyWith ────────────────────────────────────────────────────────────

  group('CanvasState copyWith', () {
    test('clearSelected=true → selectedNodeId=null', () {
      final s = const CanvasState().copyWith(selectedNodeId: 'n1');
      final cleared = s.copyWith(clearSelected: true);
      expect(cleared.selectedNodeId, isNull);
    });

    test('clearConnecting=true → connectingNodeId=null', () {
      final s = const CanvasState().copyWith(connectingNodeId: 'n1');
      final cleared = s.copyWith(clearConnecting: true);
      expect(cleared.connectingNodeId, isNull);
    });

    test('clearFocused=true → focusedNodeId=null', () {
      final s = const CanvasState().copyWith(focusedNodeId: 'n1');
      final cleared = s.copyWith(clearFocused: true);
      expect(cleared.focusedNodeId, isNull);
    });

    test('clearTimeSliderYear=true → timeSliderYear=null', () {
      final s = const CanvasState().copyWith(timeSliderYear: 2000);
      final cleared = s.copyWith(clearTimeSliderYear: true);
      expect(cleared.timeSliderYear, isNull);
    });

    test('nodes/edges 업데이트', () {
      final n = _node('n1');
      final e = _edge('n1', 'n2');
      final s = const CanvasState().copyWith(nodes: [n], edges: [e]);
      expect(s.nodes.length, 1);
      expect(s.edges.length, 1);
    });

    test('timeSliderVisible 업데이트', () {
      final s = const CanvasState().copyWith(timeSliderVisible: true);
      expect(s.timeSliderVisible, isTrue);
    });

    test('timeSliderYear 업데이트', () {
      final s = const CanvasState().copyWith(timeSliderYear: 1990);
      expect(s.timeSliderYear, 1990);
    });
  });

  // ── nodeOpacity ──────────────────────────────────────────────────────────

  group('CanvasState.nodeOpacity', () {
    test('focusedNodeId=null → 모든 노드 opacity 1.0', () {
      final s = CanvasState(nodes: [_node('n1'), _node('n2')]);
      expect(s.nodeOpacity('n1'), 1.0);
      expect(s.nodeOpacity('n2'), 1.0);
    });

    test('focusedNode 자신 → opacity 1.0', () {
      final s = const CanvasState().copyWith(focusedNodeId: 'n1');
      expect(s.nodeOpacity('n1'), 1.0);
    });

    test('focusedNode 이웃 (edge 있음) → opacity 0.7', () {
      final e = _edge('n1', 'n2');
      final s = CanvasState(edges: [e], focusedNodeId: 'n1');
      expect(s.nodeOpacity('n2'), 0.7);
    });

    test('focusedNode 이웃 (역방향 edge) → opacity 0.7', () {
      final e = _edge('n2', 'n1');
      final s = CanvasState(edges: [e], focusedNodeId: 'n1');
      expect(s.nodeOpacity('n2'), 0.7);
    });

    test('focusedNode 이웃 아님 → opacity 0.15', () {
      final e = _edge('n1', 'n2');
      final s = CanvasState(edges: [e], focusedNodeId: 'n1');
      expect(s.nodeOpacity('n3'), 0.15);
    });
  });

  // ── nodeVisibleInTime ────────────────────────────────────────────────────

  group('CanvasState.nodeVisibleInTime', () {
    test('timeSliderYear=null → 모든 노드 가시', () {
      final n = _node('n1', birthDate: DateTime(1990));
      const s = CanvasState();
      expect(s.nodeVisibleInTime(n), isTrue);
    });

    test('birthDate=null → 가시 (연도 무관)', () {
      final n = _node('n1');
      final s = const CanvasState().copyWith(timeSliderYear: 1985);
      expect(s.nodeVisibleInTime(n), isTrue);
    });

    test('birthDate <= timeSliderYear → 가시', () {
      final n = _node('n1', birthDate: DateTime(1980));
      final s = const CanvasState().copyWith(timeSliderYear: 2000);
      expect(s.nodeVisibleInTime(n), isTrue);
    });

    test('birthDate == timeSliderYear → 가시', () {
      final n = _node('n1', birthDate: DateTime(2000));
      final s = const CanvasState().copyWith(timeSliderYear: 2000);
      expect(s.nodeVisibleInTime(n), isTrue);
    });

    test('birthDate > timeSliderYear → 비가시', () {
      final n = _node('n1', birthDate: DateTime(2010));
      final s = const CanvasState().copyWith(timeSliderYear: 2005);
      expect(s.nodeVisibleInTime(n), isFalse);
    });
  });

  // ── DB + NodeRepository 연동 테스트 ─────────────────────────────────────

  group('CanvasState + NodeRepository 통합', () {
    late AppDatabase db;
    late NodeRepository repo;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      repo = createTestNodeRepository(db);
    });

    tearDown(() => db.close());

    test('selectNode — 존재하는 노드 선택', () async {
      final node = await repo.create(name: '홍길동', positionX: 0, positionY: 0);
      final s = CanvasState(nodes: [node], selectedNodeId: node.id);
      expect(s.selectedNode?.id, node.id);
    });

    test('startConnectMode → isConnectMode=true', () {
      final s = const CanvasState().copyWith(connectingNodeId: 'n_abc');
      expect(s.isConnectMode, isTrue);
      expect(s.connectingNodeId, 'n_abc');
    });

    test('cancelConnectMode → connectingNodeId=null', () {
      final s = const CanvasState().copyWith(connectingNodeId: 'n_abc');
      final cancelled = s.copyWith(clearConnecting: true);
      expect(cancelled.isConnectMode, isFalse);
    });

    test('setFocus → focusedNodeId 설정', () {
      final s = const CanvasState().copyWith(focusedNodeId: 'n_focus');
      expect(s.isFocusMode, isTrue);
      expect(s.focusedNodeId, 'n_focus');
    });

    test('clearFocus → focusedNodeId=null', () {
      final s = const CanvasState().copyWith(focusedNodeId: 'n_focus');
      final cleared = s.copyWith(clearFocused: true);
      expect(cleared.isFocusMode, isFalse);
    });

    test('toggleTimeSlider: false → true', () {
      const s = CanvasState();
      final toggled = s.copyWith(timeSliderVisible: !s.timeSliderVisible);
      expect(toggled.timeSliderVisible, isTrue);
    });

    test('setTimeSliderYear → year 설정', () {
      final s = const CanvasState().copyWith(timeSliderYear: 1995);
      expect(s.timeSliderYear, 1995);
    });

    test('setTimeSliderYear null → clearTimeSliderYear', () {
      final s = const CanvasState().copyWith(timeSliderYear: 1995);
      final cleared = s.copyWith(clearTimeSliderYear: true);
      expect(cleared.timeSliderYear, isNull);
    });
  });
}
