import 'package:flutter/material.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../shared/models/node_model.dart';

const double _minimapWidth = 120.0;
const double _minimapHeight = 80.0;
const double _canvasSize = 4000.0;

/// 캔버스 미니맵 (우하단 위치)
class MinimapWidget extends StatelessWidget {
  const MinimapWidget({
    super.key,
    required this.nodes,
    required this.transformationController,
  });

  final List<NodeModel> nodes;
  final TransformationController transformationController;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: transformationController,
        builder: (context, _) {
          return Container(
            width: _minimapWidth,
            height: _minimapHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: const Color(0xCC0D1117),
              border: Border.all(color: AppColors.glassBorder, width: 1),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CustomPaint(
                painter: _MinimapPainter(
                  nodes: nodes,
                  transform: transformationController.value,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MinimapPainter extends CustomPainter {
  _MinimapPainter({required this.nodes, required this.transform});

  final List<NodeModel> nodes;
  final Matrix4 transform;

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / _canvasSize;
    final scaleY = size.height / _canvasSize;

    // 노드 점 그리기
    final nodePaint = Paint()
      ..color = AppColors.primary.withAlpha(200)
      ..style = PaintingStyle.fill;

    for (final node in nodes) {
      final x = node.positionX * scaleX;
      final y = node.positionY * scaleY;
      canvas.drawCircle(Offset(x, y), node.isGhost ? 2.0 : 3.0, nodePaint);
    }

    // 뷰포트 사각형 그리기
    final matrix = transform;
    final scale = matrix.getMaxScaleOnAxis();
    final tx = matrix.getTranslation();

    // 뷰포트 좌상단 (캔버스 좌표)
    final vpLeft = -tx.x / scale;
    final vpTop = -tx.y / scale;

    // 뷰포트 크기 (캔버스 좌표) — 실제 화면 크기를 모르므로 추정
    const estimatedScreenW = 390.0;
    const estimatedScreenH = 800.0;
    final vpW = estimatedScreenW / scale;
    final vpH = estimatedScreenH / scale;

    final vpRect = Rect.fromLTWH(
      (vpLeft * scaleX).clamp(0.0, size.width),
      (vpTop * scaleY).clamp(0.0, size.height),
      (vpW * scaleX).clamp(0.0, size.width),
      (vpH * scaleY).clamp(0.0, size.height),
    );

    final vpPaint = Paint()
      ..color = Colors.white.withAlpha(50)
      ..style = PaintingStyle.fill;

    final vpBorderPaint = Paint()
      ..color = Colors.white.withAlpha(120)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawRect(vpRect, vpPaint);
    canvas.drawRect(vpRect, vpBorderPaint);
  }

  @override
  bool shouldRepaint(covariant _MinimapPainter old) =>
      old.nodes != nodes || old.transform != transform;
}
