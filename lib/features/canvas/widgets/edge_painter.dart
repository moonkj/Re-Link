import 'package:flutter/material.dart';
import '../../../shared/models/node_model.dart';
import '../../../design/tokens/app_colors.dart';
import 'node_card.dart';

/// 노드 간 관계선을 그리는 CustomPainter
class EdgePainter extends CustomPainter {
  const EdgePainter({
    required this.nodes,
    required this.edges,
    this.connectingNodeId,
    this.pointerPosition,
  });

  final List<NodeModel> nodes;
  final List<NodeEdge> edges;

  /// 연결 모드 중인 노드 (현재 드래그 중)
  final String? connectingNodeId;

  /// 연결 모드에서 포인터 위치 (임시 선)
  final Offset? pointerPosition;

  @override
  void paint(Canvas canvas, Size size) {
    for (final edge in edges) {
      final from = _centerOf(edge.fromNodeId);
      final to = _centerOf(edge.toNodeId);
      if (from == null || to == null) continue;
      _drawEdge(canvas, from, to, edge.relation);
    }

    // 연결 중인 임시 선
    if (connectingNodeId != null && pointerPosition != null) {
      final from = _centerOf(connectingNodeId!);
      if (from != null) {
        _drawDashedLine(canvas, from, pointerPosition!);
      }
    }
  }

  Offset? _centerOf(String nodeId) {
    final node = nodes.where((n) => n.id == nodeId).firstOrNull;
    if (node == null) return null;
    return Offset(
      node.positionX + kNodeCardWidth / 2,
      node.positionY + kNodeCardHeight / 2,
    );
  }

  void _drawEdge(Canvas canvas, Offset from, Offset to, RelationType relation) {
    final color = _edgeColor(relation);
    final paint = Paint()
      ..color = color.withAlpha(180)
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = _curvePath(from, to);
    canvas.drawPath(path, paint);

    // 관계 레이블 (중앙)
    final mid = _midPoint(from, to);
    _drawLabel(canvas, mid, relation.label);
  }

  /// 베지어 곡선 경로
  Path _curvePath(Offset from, Offset to) {
    final dx = (to.dx - from.dx) * 0.4;
    final cp1 = Offset(from.dx + dx, from.dy);
    final cp2 = Offset(to.dx - dx, to.dy);
    return Path()
      ..moveTo(from.dx, from.dy)
      ..cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, to.dx, to.dy);
  }

  void _drawDashedLine(Canvas canvas, Offset from, Offset to) {
    final paint = Paint()
      ..color = AppColors.primary.withAlpha(120)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const dashLen = 8.0;
    const gapLen = 5.0;
    final total = (to - from).distance;
    final dir = (to - from) / total;
    double d = 0;
    while (d < total) {
      final start = from + dir * d;
      final end = from + dir * (d + dashLen).clamp(0, total);
      canvas.drawLine(start, end, paint);
      d += dashLen + gapLen;
    }
  }

  void _drawLabel(Canvas canvas, Offset pos, String label) {
    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          fontSize: 10,
          color: Colors.white60,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    // 배경
    final bgRect = Rect.fromCenter(
      center: pos,
      width: tp.width + 8,
      height: tp.height + 4,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bgRect, const Radius.circular(4)),
      Paint()..color = const Color(0xCC0A0A1A),
    );

    tp.paint(canvas, pos - Offset(tp.width / 2, tp.height / 2));
  }

  Offset _midPoint(Offset a, Offset b) =>
      Offset((a.dx + b.dx) / 2, (a.dy + b.dy) / 2);

  Color _edgeColor(RelationType relation) => switch (relation) {
        RelationType.parent => AppColors.secondary,
        RelationType.child => AppColors.secondary,
        RelationType.spouse => AppColors.accent,
        RelationType.sibling => AppColors.primary,
        RelationType.other => Colors.white38,
      };

  @override
  bool shouldRepaint(EdgePainter oldDelegate) =>
      oldDelegate.nodes != nodes ||
      oldDelegate.edges != edges ||
      oldDelegate.connectingNodeId != connectingNodeId ||
      oldDelegate.pointerPosition != pointerPosition;
}
