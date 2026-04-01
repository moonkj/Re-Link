import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../design/tokens/app_radius.dart';
import '../../../design/tokens/app_spacing.dart';
import '../../../shared/models/node_model.dart';
import '../../canvas/providers/canvas_notifier.dart';
import '../../canvas/providers/my_node_provider.dart';

/// 팔고조도(八高祖圖) — 8세대 조상 이진 트리 시각화
///
/// "나"를 최하단에 두고 부모 → 조부모 → 증조부모 순으로
/// 위쪽으로 올라가는 이진 트리 구조를 그립니다.
/// 데이터베이스에 없는 조상 자리는 점선 원으로 표시합니다.
class PalgojodoScreen extends ConsumerWidget {
  const PalgojodoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canvasState = ref.watch(canvasNotifierProvider);
    final myNodeAsync = ref.watch(myNodeNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.bgBase,
      appBar: AppBar(
        title: Text(
          '팔고조도 (八高祖圖)',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: myNodeAsync.when(
        loading: () => Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(
          child: Text('오류: $e', style: TextStyle(color: AppColors.textSecondary)),
        ),
        data: (myNodeId) {
          if (myNodeId == null || myNodeId.isEmpty) {
            return _buildEmptyState();
          }
          return _PalgojodoTree(
            nodes: canvasState.nodes,
            edges: canvasState.edges,
            myNodeId: myNodeId,
          );
        },
      ),
    );
  }

  /// "나" 노드가 설정되지 않은 경우
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_off_outlined, size: 48, color: AppColors.textTertiary),
          const SizedBox(height: AppSpacing.lg),
          Text(
            '"나" 설정이 필요합니다',
            style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '캔버스에서 내 노드를 길게 눌러\n"나로 설정"을 해주세요',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }
}

// ── 조상 트리 위젯 ──────────────────────────────────────────────────────────────

/// 이진 트리의 각 슬롯 (실제 노드 또는 빈 자리)
class _AncestorSlot {
  const _AncestorSlot({this.node, required this.generation});
  final NodeModel? node;
  final int generation;
  bool get isEmpty => node == null;
}

class _PalgojodoTree extends StatelessWidget {
  const _PalgojodoTree({
    required this.nodes,
    required this.edges,
    required this.myNodeId,
  });

  final List<NodeModel> nodes;
  final List<NodeEdge> edges;
  final String myNodeId;

  /// 세대 라벨 (0=나, 1=부모, ... 7=7대조)
  static const _genLabels = [
    '나',
    '부모',
    '조부모',
    '증조부모',
    '고조부모',
    '5대조',
    '6대조',
    '7대조',
  ];

  /// BFS로 이진 조상 트리 구축 (최대 8세대)
  ///
  /// 반환: 세대별 슬롯 리스트 (이진 트리 — 세대 N에는 2^N 슬롯)
  /// 각 슬롯은 실제 노드 또는 빈 자리(_AncestorSlot.isEmpty)
  Map<int, List<_AncestorSlot>> _buildAncestorTree() {
    final tree = <int, List<_AncestorSlot>>{};
    final nodeMap = {for (final n in nodes) n.id: n};

    // "나" 노드 찾기
    final myNode = nodeMap[myNodeId];
    if (myNode == null) return tree;

    tree[0] = [_AncestorSlot(node: myNode, generation: 0)];

    // 각 세대에서 부모를 찾아 다음 세대 구성
    for (int gen = 0; gen < 7; gen++) {
      final currentGen = tree[gen];
      if (currentGen == null || currentGen.isEmpty) break;

      final nextGen = <_AncestorSlot>[];
      bool hasAnyNode = false;

      for (final slot in currentGen) {
        if (slot.isEmpty) {
          // 빈 슬롯의 부모도 빈 슬롯 2개
          nextGen.add(_AncestorSlot(generation: gen + 1));
          nextGen.add(_AncestorSlot(generation: gen + 1));
          continue;
        }

        // 이 노드의 부모 찾기
        final parents = _findParents(slot.node!.id, nodeMap);
        // 아버지(남성/첫 번째)
        nextGen.add(
          parents.isNotEmpty
              ? _AncestorSlot(node: parents[0], generation: gen + 1)
              : _AncestorSlot(generation: gen + 1),
        );
        // 어머니(여성/두 번째)
        nextGen.add(
          parents.length > 1
              ? _AncestorSlot(node: parents[1], generation: gen + 1)
              : _AncestorSlot(generation: gen + 1),
        );

        if (parents.isNotEmpty) hasAnyNode = true;
      }

      if (!hasAnyNode) break; // 더 이상 조상 데이터 없음
      tree[gen + 1] = nextGen;
    }

    return tree;
  }

  /// 특정 노드의 부모 목록 반환 (최대 2명)
  ///
  /// edge 규칙 (두 패턴 모두 fromNode=부모, toNode=자녀):
  /// - relation=parent: fromNodeId가 부모, toNodeId가 자녀
  /// - relation=child:  fromNodeId가 부모, toNodeId가 자녀
  List<NodeModel> _findParents(String nodeId, Map<String, NodeModel> nodeMap) {
    final parentIds = <String>{};

    for (final edge in edges) {
      // relation == parent: fromNode이 부모, toNode이 자녀
      if (edge.relation == RelationType.parent &&
          edge.toNodeId == nodeId) {
        parentIds.add(edge.fromNodeId);
      }
      // relation == child: fromNode이 부모, toNode이 자녀
      if (edge.relation == RelationType.child &&
          edge.toNodeId == nodeId) {
        parentIds.add(edge.fromNodeId);
      }
    }

    return parentIds
        .map((id) => nodeMap[id])
        .whereType<NodeModel>()
        .take(2)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final tree = _buildAncestorTree();

    if (tree.isEmpty || tree[0]?.isEmpty == true) {
      return Center(
        child: Text(
          '조상 데이터가 없습니다',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    final maxGen = tree.keys.reduce(max);

    // 노드 카드 크기
    const nodeW = 82.0;
    const nodeH = 56.0;
    const hGap = 16.0; // 같은 세대 노드 간 수평 간격
    const vGap = 90.0; // 세대 간 수직 간격

    // 최상위 세대의 슬롯 수로 캔버스 폭 결정
    final topSlotCount = tree[maxGen]?.length ?? 1;
    final canvasW = max(
      MediaQuery.of(context).size.width,
      topSlotCount * (nodeW + hGap) + 80,
    );
    final canvasH = (maxGen + 1) * (nodeH + vGap) + 160.0;

    // 각 슬롯의 위치 계산
    final positions = _calculatePositions(
      tree: tree,
      maxGen: maxGen,
      nodeW: nodeW,
      nodeH: nodeH,
      hGap: hGap,
      vGap: vGap,
      canvasW: canvasW,
      canvasH: canvasH,
    );

    return InteractiveViewer(
      constrained: false,
      clipBehavior: Clip.none,
      minScale: 0.2,
      maxScale: 3.0,
      boundaryMargin: const EdgeInsets.all(200),
      child: SizedBox(
        width: canvasW,
        height: canvasH,
        child: CustomPaint(
          painter: _TreeLinePainter(
            tree: tree,
            positions: positions,
            nodeW: nodeW,
            nodeH: nodeH,
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              for (final entry in positions.entries)
                Positioned(
                  left: entry.value.dx,
                  top: entry.value.dy,
                  child: _AncestorCard(
                    slot: entry.key,
                    genLabel: entry.key.generation < _genLabels.length
                        ? _genLabels[entry.key.generation]
                        : '${entry.key.generation}대조',
                    width: nodeW,
                    height: nodeH,
                    isMe: entry.key.generation == 0,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// 이진 트리 구조에 맞는 위치 계산
  /// 최하단(나)을 기준으로 위로 올라가며 배치
  Map<_AncestorSlot, Offset> _calculatePositions({
    required Map<int, List<_AncestorSlot>> tree,
    required int maxGen,
    required double nodeW,
    required double nodeH,
    required double hGap,
    required double vGap,
    required double canvasW,
    required double canvasH,
  }) {
    final result = <_AncestorSlot, Offset>{};

    for (final entry in tree.entries) {
      final gen = entry.key;
      final slots = entry.value;
      final count = slots.length;

      // 세대 간 수평 간격: 상위 세대일수록 노드 수가 많으므로 간격 자동 조정
      final totalWidth = count * nodeW + (count - 1) * hGap;
      final startX = (canvasW - totalWidth) / 2;

      // 수직 위치: gen 0(나)이 가장 아래, maxGen이 가장 위
      final y = canvasH - 80 - gen * (nodeH + vGap);

      for (int i = 0; i < slots.length; i++) {
        final x = startX + i * (nodeW + hGap);
        result[slots[i]] = Offset(x, y);
      }
    }

    return result;
  }
}

// ── 조상 노드 카드 ───────────────────────────────────────────────────────────────

class _AncestorCard extends StatelessWidget {
  const _AncestorCard({
    required this.slot,
    required this.genLabel,
    required this.width,
    required this.height,
    this.isMe = false,
  });

  final _AncestorSlot slot;
  final String genLabel;
  final double width;
  final double height;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    // 빈 슬롯 — 점선 원
    if (slot.isEmpty) {
      return SizedBox(
        width: width,
        height: height,
        child: CustomPaint(
          painter: _DashedCirclePainter(
            color: AppColors.textDisabled,
          ),
          child: Center(
            child: Text(
              '?',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textDisabled,
              ),
            ),
          ),
        ),
      );
    }

    final node = slot.node!;
    final isGhost = node.isGhost;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        color: isMe
            ? AppColors.primary.withAlpha(30)
            : isGhost
                ? AppColors.glassSurface.withAlpha(10)
                : AppColors.glassSurface,
        border: Border.all(
          color: isMe
              ? AppColors.primary
              : isGhost
                  ? AppColors.nodeBorderGhost
                  : AppColors.glassBorder,
          width: isMe ? 2.0 : 1.0,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              node.name.isEmpty ? '?' : node.name,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isMe
                    ? AppColors.primary
                    : isGhost
                        ? AppColors.textTertiary
                        : AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            genLabel,
            style: TextStyle(
              fontSize: 9,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── 점선 원 페인터 (빈 조상 슬롯용) ─────────────────────────────────────────────

class _DashedCirclePainter extends CustomPainter {
  const _DashedCirclePainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 4;

    // 점선 원: 작은 호(arc)를 반복
    const dashCount = 20;
    const dashAngle = (2 * pi) / dashCount;
    const gapRatio = 0.4;

    for (int i = 0; i < dashCount; i++) {
      final startAngle = i * dashAngle;
      final sweepAngle = dashAngle * (1 - gapRatio);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DashedCirclePainter old) =>
      old.color != color;
}

// ── 트리 연결선 페인터 ───────────────────────────────────────────────────────────

class _TreeLinePainter extends CustomPainter {
  const _TreeLinePainter({
    required this.tree,
    required this.positions,
    required this.nodeW,
    required this.nodeH,
  });

  final Map<int, List<_AncestorSlot>> tree;
  final Map<_AncestorSlot, Offset> positions;
  final double nodeW;
  final double nodeH;

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = AppColors.glassBorder
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final dashedPaint = Paint()
      ..color = AppColors.textDisabled.withAlpha(80)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // 각 세대의 자녀 → 부모 연결선
    for (final entry in tree.entries) {
      final gen = entry.key;
      if (gen == 0) continue; // "나" 세대는 위에 부모 연결만

      final parentSlots = entry.value;
      final childGen = tree[gen - 1];
      if (childGen == null) continue;

      // 이진 트리: 부모 슬롯 인덱스 i*2, i*2+1 → 자녀 슬롯 인덱스 i
      for (int childIdx = 0; childIdx < childGen.length; childIdx++) {
        final childSlot = childGen[childIdx];
        final childPos = positions[childSlot];
        if (childPos == null) continue;

        // 자녀 카드의 상단 중앙
        final childTop = Offset(
          childPos.dx + nodeW / 2,
          childPos.dy,
        );

        // 아버지 (인덱스 childIdx * 2)
        final fatherIdx = childIdx * 2;
        if (fatherIdx < parentSlots.length) {
          final fatherSlot = parentSlots[fatherIdx];
          final fatherPos = positions[fatherSlot];
          if (fatherPos != null) {
            final fatherBottom = Offset(
              fatherPos.dx + nodeW / 2,
              fatherPos.dy + nodeH,
            );
            final paint = fatherSlot.isEmpty ? dashedPaint : linePaint;
            _drawCurvedLine(canvas, fatherBottom, childTop, paint);
          }
        }

        // 어머니 (인덱스 childIdx * 2 + 1)
        final motherIdx = childIdx * 2 + 1;
        if (motherIdx < parentSlots.length) {
          final motherSlot = parentSlots[motherIdx];
          final motherPos = positions[motherSlot];
          if (motherPos != null) {
            final motherBottom = Offset(
              motherPos.dx + nodeW / 2,
              motherPos.dy + nodeH,
            );
            final paint = motherSlot.isEmpty ? dashedPaint : linePaint;
            _drawCurvedLine(canvas, motherBottom, childTop, paint);
          }
        }
      }
    }
  }

  /// 부모 하단 → 자녀 상단으로 부드러운 곡선 연결
  void _drawCurvedLine(
    Canvas canvas,
    Offset from,
    Offset to,
    Paint paint,
  ) {
    final midY = (from.dy + to.dy) / 2;
    final path = Path()
      ..moveTo(from.dx, from.dy)
      ..cubicTo(
        from.dx,
        midY,
        to.dx,
        midY,
        to.dx,
        to.dy,
      );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _TreeLinePainter old) =>
      old.tree != tree || old.positions != positions;
}
