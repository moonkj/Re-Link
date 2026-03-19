import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../design/tokens/app_spacing.dart';
import '../../../design/glass/app_glass.dart';
import '../../../shared/models/node_model.dart';
import '../providers/canvas_notifier.dart';
import '../providers/node_notifier.dart';
import '../widgets/node_card.dart';
import '../widgets/edge_painter.dart';
import '../widgets/add_node_sheet.dart';
import '../widgets/node_detail_sheet.dart';
import '../widgets/relation_picker_sheet.dart';

/// 무한 캔버스 메인 화면
class CanvasScreen extends ConsumerStatefulWidget {
  const CanvasScreen({super.key});

  @override
  ConsumerState<CanvasScreen> createState() => _CanvasScreenState();
}

class _CanvasScreenState extends ConsumerState<CanvasScreen> {
  final TransformationController _transformCtrl = TransformationController();

  /// 드래그 중인 노드 ID
  String? _draggingId;

  /// 연결 모드 포인터 위치 (캔버스 좌표)
  Offset? _connectPointer;

  @override
  void dispose() {
    _transformCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canvasState = ref.watch(canvasNotifierProvider);
    final nodes = canvasState.nodes;
    final edges = canvasState.edges;
    final isConnectMode = canvasState.isConnectMode;

    return Scaffold(
      backgroundColor: AppColors.bgBase,
      body: Stack(
        children: [
          // ── 배경 ────────────────────────────────────────────────────────
          _CanvasBackground(),

          // ── 무한 캔버스 ──────────────────────────────────────────────────
          InteractiveViewer(
            transformationController: _transformCtrl,
            minScale: 0.3,
            maxScale: 3.0,
            boundaryMargin: const EdgeInsets.all(double.infinity),
            // 드래그 중에는 캔버스 팬 비활성화
            panEnabled: _draggingId == null && !isConnectMode,
            child: RepaintBoundary(
              child: SizedBox(
                width: 4000,
                height: 4000,
                child: Stack(
                  children: [
                    // 관계선 레이어
                    Positioned.fill(
                      child: CustomPaint(
                        painter: EdgePainter(
                          nodes: nodes,
                          edges: edges,
                          connectingNodeId: canvasState.connectingNodeId,
                          pointerPosition: _connectPointer,
                        ),
                      ),
                    ),

                    // 빈 상태 안내
                    if (nodes.isEmpty) _EmptyHint(),

                    // 노드 카드들
                    ...nodes.map((node) => _DraggableNodeCard(
                          key: ValueKey(node.id),
                          node: node,
                          canvasState: canvasState,
                          onDragStarted: () => setState(() => _draggingId = node.id),
                          onDragEnded: (dx, dy) async {
                            setState(() => _draggingId = null);
                            await ref
                                .read(canvasNotifierProvider.notifier)
                                .saveNodePosition(node.id, dx, dy);
                          },
                          onTap: () => _onNodeTap(node, canvasState),
                          onLongPress: () => _onNodeLongPress(node),
                        )),
                  ],
                ),
              ),
            ),
          ),

          // ── 상단 앱바 ────────────────────────────────────────────────────
          Positioned(
            top: 0, left: 0, right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    GlassCard(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg, vertical: AppSpacing.sm,
                      ),
                      child: const Text(
                        'Re-Link',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // 노드 수 표시
                    if (nodes.isNotEmpty)
                      GlassCard(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md, vertical: AppSpacing.sm,
                        ),
                        child: Text(
                          '${nodes.length}명',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    const SizedBox(width: AppSpacing.sm),
                    GlassCard(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      onTap: _resetZoom,
                      child: const Icon(
                        Icons.center_focus_strong,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── 연결 모드 배너 ───────────────────────────────────────────────
          if (isConnectMode)
            Positioned(
              top: 100, left: AppSpacing.lg, right: AppSpacing.lg,
              child: GlassCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg, vertical: AppSpacing.md,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.link, color: AppColors.primary),
                    const SizedBox(width: AppSpacing.sm),
                    const Expanded(
                      child: Text(
                        '연결할 인물을 탭하세요',
                        style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => ref.read(canvasNotifierProvider.notifier).cancelConnectMode(),
                      child: const Icon(Icons.close, color: AppColors.textSecondary, size: 20),
                    ),
                  ],
                ),
              ),
            ),

          // ── FAB (노드 추가) ──────────────────────────────────────────────
          Positioned(
            bottom: AppSpacing.xxl + 80, // 하단 네비게이션 위
            right: AppSpacing.lg,
            child: GestureDetector(
              onTap: isConnectMode ? null : _showAddNodeSheet,
              child: AnimatedOpacity(
                opacity: isConnectMode ? 0.3 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  width: AppSpacing.fabSize,
                  height: AppSpacing.fabSize,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFF6C63FF), Color(0xFF9C94FF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x4D6C63FF),
                        blurRadius: 20,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 28),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── 이벤트 ─────────────────────────────────────────────────────────────────

  void _onNodeTap(NodeModel node, CanvasState state) {
    if (state.isConnectMode) {
      _handleConnectTap(node, state);
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => NodeDetailSheet(nodeId: node.id),
    );
  }

  Future<void> _handleConnectTap(NodeModel toNode, CanvasState state) async {
    final fromId = state.connectingNodeId!;
    if (toNode.id == fromId) return;

    final fromNode = state.nodes.where((n) => n.id == fromId).firstOrNull;
    if (fromNode == null) return;

    // 관계 타입 선택
    final relation = await showModalBottomSheet<RelationType>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => RelationPickerSheet(fromNode: fromNode, toNode: toNode),
    );

    if (!mounted) return;
    ref.read(canvasNotifierProvider.notifier).cancelConnectMode();

    if (relation != null) {
      await ref.read(nodeNotifierProvider.notifier).addEdge(
            fromNodeId: fromId,
            toNodeId: toNode.id,
            relation: relation,
          );
    }
  }

  void _onNodeLongPress(NodeModel node) {
    ref.read(canvasNotifierProvider.notifier).startConnectMode(node.id);
  }

  Future<void> _showAddNodeSheet() async {
    // 캔버스 중심 좌표 계산
    final matrix = _transformCtrl.value;
    final scale = matrix.getMaxScaleOnAxis();
    final tx = matrix.getTranslation();
    final screenSize = MediaQuery.of(context).size;
    final cx = (screenSize.width / 2 - tx.x) / scale;
    final cy = (screenSize.height / 2 - tx.y) / scale;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddNodeSheet(
        initialPositionX: cx.clamp(100, 3800),
        initialPositionY: cy.clamp(100, 3800),
      ),
    );
  }

  void _resetZoom() {
    final dx = -(4000 / 2 - MediaQuery.of(context).size.width / 2);
    final dy = -(4000 / 2 - MediaQuery.of(context).size.height / 2);
    _transformCtrl.value = Matrix4.translationValues(dx, dy, 0);
  }
}

/// 드래그 가능한 노드 카드 래퍼
class _DraggableNodeCard extends StatefulWidget {
  const _DraggableNodeCard({
    super.key,
    required this.node,
    required this.canvasState,
    required this.onTap,
    required this.onLongPress,
    required this.onDragStarted,
    required this.onDragEnded,
  });

  final NodeModel node;
  final CanvasState canvasState;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onDragStarted;
  final void Function(double dx, double dy) onDragEnded;

  @override
  State<_DraggableNodeCard> createState() => _DraggableNodeCardState();
}

class _DraggableNodeCardState extends State<_DraggableNodeCard> {
  late double _x;
  late double _y;
  Offset? _dragStart;
  Offset? _posStart;

  @override
  void initState() {
    super.initState();
    _x = widget.node.positionX;
    _y = widget.node.positionY;
  }

  @override
  void didUpdateWidget(_DraggableNodeCard old) {
    super.didUpdateWidget(old);
    // 드래그 중이 아닐 때만 외부 위치 업데이트 수용
    if (_dragStart == null) {
      _x = widget.node.positionX;
      _y = widget.node.positionY;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.canvasState;
    return Positioned(
      left: _x,
      top: _y,
      child: GestureDetector(
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        onPanStart: (d) {
          _dragStart = d.globalPosition;
          _posStart = Offset(_x, _y);
          widget.onDragStarted();
        },
        onPanUpdate: (d) {
          if (_dragStart == null || _posStart == null) return;
          final delta = d.globalPosition - _dragStart!;
          setState(() {
            _x = (_posStart!.dx + delta.dx).clamp(0.0, 3900.0);
            _y = (_posStart!.dy + delta.dy).clamp(0.0, 3900.0);
          });
        },
        onPanEnd: (_) {
          _dragStart = null;
          _posStart = null;
          widget.onDragEnded(_x, _y);
        },
        child: NodeCard(
          node: widget.node,
          isSelected: state.selectedNodeId == widget.node.id,
          isConnectSource: state.connectingNodeId == widget.node.id,
          isConnectMode: state.isConnectMode,
          onTap: widget.onTap,
          onLongPress: widget.onLongPress,
          onDragEnd: widget.onDragEnded,
        ),
      ),
    );
  }
}

/// 빈 캔버스 안내
class _EmptyHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 1800,
      left: 1600,
      child: SizedBox(
        width: 800,
        child: Column(
          children: [
            const Icon(Icons.account_tree_outlined, size: 64, color: AppColors.primary),
            const SizedBox(height: 16),
            const Text(
              '가족 트리를 시작해 보세요',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              '+ 버튼으로 첫 번째 인물을 추가하세요',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// 배경 (그라디언트 + 그리드 점)
class _CanvasBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GridPainter(),
      child: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.5,
            colors: [Color(0xFF1A1040), Color(0xFF0A0A1A)],
          ),
        ),
      ),
    );
  }
}

/// 배경 그리드 점
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x1AFFFFFF)
      ..strokeWidth = 1;
    const spacing = 32.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
