import 'dart:io';
import 'package:flutter/material.dart';
import '../../../shared/models/node_model.dart';
import '../../../design/tokens/app_colors.dart';

const double kNodeCardWidth = 110.0;
const double kNodeCardHeight = 130.0;

/// 캔버스 위 인물 노드 카드
class NodeCard extends StatefulWidget {
  const NodeCard({
    super.key,
    required this.node,
    required this.isSelected,
    required this.isConnectSource,
    required this.isConnectMode,
    required this.onTap,
    required this.onLongPress,
    required this.onDragEnd,
  });

  final NodeModel node;
  final bool isSelected;
  final bool isConnectSource;
  final bool isConnectMode;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final void Function(double dx, double dy) onDragEnd;

  @override
  State<NodeCard> createState() => _NodeCardState();
}

class _NodeCardState extends State<NodeCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final node = widget.node;
    final tempColor = AppColors.tempColor(node.temperature);

    return GestureDetector(
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: AnimatedBuilder(
        animation: _pulseAnim,
        builder: (context, child) {
          final scale = widget.isConnectSource ? _pulseAnim.value : 1.0;
          return Transform.scale(scale: scale, child: child);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: kNodeCardWidth,
          height: kNodeCardHeight,
          decoration: _buildDecoration(node, tempColor),
          child: node.isGhost
              ? _GhostContent(node: node)
              : _NormalContent(node: node, tempColor: tempColor),
        ),
      ),
    );
  }

  BoxDecoration _buildDecoration(NodeModel node, Color tempColor) {
    if (node.isGhost) {
      return BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0x1AFFFFFF),
        border: Border.all(
          color: Colors.white30,
          width: 1.5,
          // 점선 효과는 CustomPaint로 처리 (Flutter Border는 점선 미지원)
        ),
        boxShadow: const [
          BoxShadow(color: Color(0x1A6C63FF), blurRadius: 12),
        ],
      );
    }

    return BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      color: const Color(0x1AFFFFFF),
      border: Border.all(
        color: widget.isSelected
            ? AppColors.nodeSelected
            : widget.isConnectMode && !widget.isConnectSource
                ? tempColor.withAlpha(200)
                : tempColor.withAlpha(160),
        width: widget.isSelected ? 2.5 : 1.5,
      ),
      boxShadow: widget.isSelected
          ? [
              BoxShadow(
                color: AppColors.nodeSelected.withAlpha(100),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ]
          : [
              BoxShadow(
                color: tempColor.withAlpha(60),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
    );
  }
}

/// 일반 노드 콘텐츠
class _NormalContent extends StatelessWidget {
  const _NormalContent({required this.node, required this.tempColor});

  final NodeModel node;
  final Color tempColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 아바타
          _NodeAvatar(node: node, size: 52),
          const SizedBox(height: 6),
          // 이름
          Text(
            node.name,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          if (node.birthDate != null) ...[
            const SizedBox(height: 2),
            Text(
              '${node.birthDate!.year}년생',
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textTertiary,
              ),
            ),
          ],
          const SizedBox(height: 4),
          // 온도 인디케이터
          Container(
            width: 28,
            height: 4,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: tempColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// Ghost Node 콘텐츠 (반투명, 물음표)
class _GhostContent extends StatelessWidget {
  const _GhostContent({required this.node});
  final NodeModel node;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.55,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white38, width: 1.5),
                color: Colors.white10,
              ),
              child: const Icon(Icons.help_outline, color: Colors.white54, size: 24),
            ),
            const SizedBox(height: 6),
            Text(
              node.name.isEmpty ? '미확인' : node.name,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white60,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            const Text(
              'Ghost',
              style: TextStyle(fontSize: 10, color: Colors.white38),
            ),
          ],
        ),
      ),
    );
  }
}

/// 노드 아바타 (사진 or 이니셜)
class _NodeAvatar extends StatelessWidget {
  const _NodeAvatar({required this.node, required this.size});

  final NodeModel node;
  final double size;

  @override
  Widget build(BuildContext context) {
    final hasPhoto = node.photoPath != null;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary.withAlpha(60),
        image: hasPhoto
            ? DecorationImage(
                image: FileImage(File(node.photoPath!)),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: hasPhoto
          ? null
          : Center(
              child: Text(
                node.name.isNotEmpty ? node.name[0] : '?',
                style: TextStyle(
                  fontSize: size * 0.4,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
    );
  }
}

/// Ghost Node 점선 테두리 (CustomPainter)
class GhostNodeBorder extends CustomPainter {
  const GhostNodeBorder();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white38
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const dashWidth = 6.0;
    const dashSpace = 4.0;
    const radius = 16.0;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(radius),
      ));

    _drawDashedPath(canvas, path, paint, dashWidth, dashSpace);
  }

  void _drawDashedPath(
    Canvas canvas,
    Path path,
    Paint paint,
    double dashWidth,
    double dashSpace,
  ) {
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double distance = 0;
      while (distance < metric.length) {
        final end = (distance + dashWidth).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
