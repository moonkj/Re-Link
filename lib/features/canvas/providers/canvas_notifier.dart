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
  });

  final List<NodeModel> nodes;
  final List<NodeEdge> edges;

  /// 현재 선택된 노드 ID (상세 시트 표시용)
  final String? selectedNodeId;

  /// 롱프레스로 연결 시작한 노드 ID
  final String? connectingNodeId;

  bool get isConnectMode => connectingNodeId != null;

  NodeModel? get selectedNode =>
      selectedNodeId == null ? null : nodes.where((n) => n.id == selectedNodeId).firstOrNull;

  CanvasState copyWith({
    List<NodeModel>? nodes,
    List<NodeEdge>? edges,
    String? selectedNodeId,
    String? connectingNodeId,
    bool clearSelected = false,
    bool clearConnecting = false,
  }) {
    return CanvasState(
      nodes: nodes ?? this.nodes,
      edges: edges ?? this.edges,
      selectedNodeId: clearSelected ? null : (selectedNodeId ?? this.selectedNodeId),
      connectingNodeId: clearConnecting ? null : (connectingNodeId ?? this.connectingNodeId),
    );
  }
}

@riverpod
class CanvasNotifier extends _$CanvasNotifier {
  @override
  CanvasState build() {
    // 노드 스트림 구독
    ref.listen(
      nodeRepositoryProvider.select((r) => r.watchAll()),
      (_, stream) {
        stream.listen((nodes) {
          state = state.copyWith(nodes: nodes);
        });
      },
    );

    // 엣지 스트림 구독
    ref.listen(
      nodeRepositoryProvider.select((r) => r.watchAllEdges()),
      (_, stream) {
        stream.listen((edges) {
          state = state.copyWith(edges: edges);
        });
      },
    );

    // 초기 스트림 구독 시작
    _subscribeStreams();
    return const CanvasState();
  }

  void _subscribeStreams() {
    final repo = ref.read(nodeRepositoryProvider);
    repo.watchAll().listen((nodes) {
      state = state.copyWith(nodes: nodes);
    });
    repo.watchAllEdges().listen((edges) {
      state = state.copyWith(edges: edges);
    });
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

  // ── 노드 위치 드래그 저장 ─────────────────────────────────────────────────

  Future<void> updateNodePosition(String id, double x, double y) async {
    // 즉시 로컬 상태 업데이트 (드래그 중 부드럽게)
    final updatedNodes = state.nodes.map((n) {
      return n.id == id ? n.copyWith(positionX: x, positionY: y) : n;
    }).toList();
    state = state.copyWith(nodes: updatedNodes);
  }

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
