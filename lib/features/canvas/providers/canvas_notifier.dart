import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../shared/models/node_model.dart';
import '../../../shared/repositories/node_repository.dart';

part 'canvas_notifier.g.dart';

/// 캔버스 UI 상태
class CanvasState {
  const CanvasState({
    this.nodes = const [],
    this.edges = const [],
    this.selectedNodeId,
    this.connectingNodeId,
    this.focusedNodeId,
    this.timeSliderVisible = false,
    this.timeSliderYear,
  });

  final List<NodeModel> nodes;
  final List<NodeEdge> edges;

  /// 현재 선택된 노드 ID (상세 시트 표시용)
  final String? selectedNodeId;

  /// 롱프레스로 연결 시작한 노드 ID
  final String? connectingNodeId;

  /// Focus Mode: 더블탭으로 포커스된 노드 ID
  final String? focusedNodeId;

  /// Time Slider 표시 여부
  final bool timeSliderVisible;

  /// Time Slider 선택 연도 (null = 전체 표시)
  final int? timeSliderYear;

  bool get isConnectMode => connectingNodeId != null;
  bool get isFocusMode => focusedNodeId != null;

  NodeModel? get selectedNode =>
      selectedNodeId == null ? null : nodes.where((n) => n.id == selectedNodeId).firstOrNull;

  /// 노드별 포커스 opacity 계산 (Focus Mode)
  double nodeOpacity(String nodeId) {
    if (focusedNodeId == null) return 1.0;
    if (nodeId == focusedNodeId) return 1.0;
    // 포커스 노드와 연결된 노드는 0.7, 나머지는 0.15
    final isFocusedNeighbor = edges.any(
      (e) =>
          (e.fromNodeId == focusedNodeId && e.toNodeId == nodeId) ||
          (e.toNodeId == focusedNodeId && e.fromNodeId == nodeId),
    );
    return isFocusedNeighbor ? 0.7 : 0.15;
  }

  /// Time Slider: 연도 기준 노드 가시성
  bool nodeVisibleInTime(NodeModel node) {
    if (timeSliderYear == null) return true;
    final birth = node.birthDate?.year;
    if (birth == null) return true;
    return birth <= timeSliderYear!;
  }

  CanvasState copyWith({
    List<NodeModel>? nodes,
    List<NodeEdge>? edges,
    String? selectedNodeId,
    String? connectingNodeId,
    String? focusedNodeId,
    bool? timeSliderVisible,
    int? timeSliderYear,
    bool clearSelected = false,
    bool clearConnecting = false,
    bool clearFocused = false,
    bool clearTimeSliderYear = false,
  }) {
    return CanvasState(
      nodes: nodes ?? this.nodes,
      edges: edges ?? this.edges,
      selectedNodeId: clearSelected ? null : (selectedNodeId ?? this.selectedNodeId),
      connectingNodeId: clearConnecting ? null : (connectingNodeId ?? this.connectingNodeId),
      focusedNodeId: clearFocused ? null : (focusedNodeId ?? this.focusedNodeId),
      timeSliderVisible: timeSliderVisible ?? this.timeSliderVisible,
      timeSliderYear: clearTimeSliderYear ? null : (timeSliderYear ?? this.timeSliderYear),
    );
  }
}

@riverpod
class CanvasNotifier extends _$CanvasNotifier {
  StreamSubscription<List<NodeModel>>? _nodesSub;
  StreamSubscription<List<NodeEdge>>? _edgesSub;

  @override
  CanvasState build() {
    final repo = ref.read(nodeRepositoryProvider);

    _nodesSub = repo.watchAll().listen((nodes) {
      state = state.copyWith(nodes: nodes);
    });
    _edgesSub = repo.watchAllEdges().listen((edges) {
      state = state.copyWith(edges: edges);
    });

    ref.onDispose(() {
      _nodesSub?.cancel();
      _edgesSub?.cancel();
    });

    return const CanvasState();
  }

  // ── 선택 ─────────────────────────────────────────────────────────────────

  void selectNode(String? id) {
    if (state.isConnectMode && id != null && id != state.connectingNodeId) {
      // 연결 모드: 대상 노드 선택 → 관계 타입 선택으로 위임
      // 실제 edge 생성은 RelationPickerSheet에서 처리
      return;
    }
    state = state.copyWith(
      selectedNodeId: id,
      clearSelected: id == null,
    );
  }

  void clearSelection() => state = state.copyWith(clearSelected: true);

  // ── 연결 모드 ─────────────────────────────────────────────────────────────

  void startConnectMode(String fromNodeId) {
    state = state.copyWith(
      connectingNodeId: fromNodeId,
      clearSelected: true,
    );
  }

  void cancelConnectMode() {
    state = state.copyWith(clearConnecting: true);
  }

  // ── Focus Mode ────────────────────────────────────────────────────────────

  void setFocus(String? nodeId) {
    state = state.copyWith(
      focusedNodeId: nodeId,
      clearFocused: nodeId == null,
    );
  }

  void clearFocus() => state = state.copyWith(clearFocused: true);

  // ── Time Slider ───────────────────────────────────────────────────────────

  void toggleTimeSlider() {
    state = state.copyWith(
      timeSliderVisible: !state.timeSliderVisible,
      clearTimeSliderYear: !state.timeSliderVisible ? false : true,
    );
  }

  void setTimeSliderYear(int? year) {
    state = state.copyWith(
      timeSliderYear: year,
      clearTimeSliderYear: year == null,
    );
  }

  // ── 노드 위치 드래그 저장 ─────────────────────────────────────────────────

  Future<void> saveNodePosition(String id, double x, double y) async {
    await ref.read(nodeRepositoryProvider).updatePosition(id, x, y);
  }
}

/// 특정 노드 조회 (상세 화면용)
@riverpod
NodeModel? canvasNode(Ref ref, String id) {
  final nodes = ref.watch(canvasNotifierProvider).nodes;
  return nodes.where((n) => n.id == id).firstOrNull;
}
