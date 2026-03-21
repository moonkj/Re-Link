import 'package:flutter/material.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../shared/models/node_model.dart';

const double _minimapShortSide = 80.0;
const double _minimapLongSide = 120.0;
const double _canvasSize = 4000.0;

/// 캔버스 미니맵 (좌하단 위치)
///
/// - 가로/세로 모드에 따라 미니맵 비율 자동 변경
/// - 실제 화면 크기 기반 정확한 뷰포트 표시
class MinimapWidget extends StatelessWidget {
  const MinimapWidget({
    super.key,
    required this.nodes,
    required this.transformationController,
    required this.screenSize,
  });

  final List<NodeModel> nodes;
  final TransformationController transformationController;
  final Size screenSize;

  @override
  Widget build(BuildContext context) {
    // 화면 방향에 따라 미니맵 비율 결정
    final isLandscape = screenSize.width > screenSize.height;
    final minimapW = isLandscape ? _minimapLongSide : _minimapShortSide;
    final minimapH = isLandscape ? _minimapShortSide : _minimapLongSide;

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: transformationController,
        builder: (context, _) {
          return Container(
            width: minimapW,
            height: minimapH,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: AppColors.isDark
                  ? const Color(0xCC0F0F1A)
                  : const Color(0xCCF8FAFC),
              border: Border.all(color: AppColors.glassBorder, width: 1),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CustomPaint(
                painter: _MinimapPainter(
                  nodes: nodes,
                  transform: transformationController.value,
                  screenSize: screenSize,
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
  _MinimapPainter({
    required this.nodes,
    required this.transform,
    required this.screenSize,
  });

  final List<NodeModel> nodes;
  final Matrix4 transform;
  final Size screenSize;

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

    // ── 나무 성장 표시 (캔버스 중앙) ──
    // Tree is positioned at: top: 1700 of 4000x4000 canvas → Y ≈ 2000 (중앙)
    final treeX = (_canvasSize / 2) * scaleX; // 캔버스 수평 중앙
    final treeY = 2000.0 * scaleY; // 캔버스 수직 중앙
    // 캐노피 (작은 원)
    final treePaint = Paint()
      ..color = const Color(0xFF34D399) // 에메랄드 그린
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(treeX, treeY - 3), 4.0, treePaint);
    // 줄기 (작은 사각형)
    canvas.drawRect(
      Rect.fromCenter(center: Offset(treeX, treeY), width: 2, height: 4),
      Paint()..color = const Color(0xFF8B6F47),
    );

    // 뷰포트 사각형 그리기 — 실제 화면 크기 사용
    final matrix = transform;
    final scale = matrix.getMaxScaleOnAxis();
    final tx = matrix.getTranslation();

    // 뷰포트 좌상단 (캔버스 좌표)
    final vpLeft = -tx.x / scale;
    final vpTop = -tx.y / scale;

    // 뷰포트 크기 (캔버스 좌표) — 실제 화면 크기 기반
    final vpW = screenSize.width / scale;
    final vpH = screenSize.height / scale;

    final vpRect = Rect.fromLTWH(
      (vpLeft * scaleX).clamp(0.0, size.width),
      (vpTop * scaleY).clamp(0.0, size.height),
      (vpW * scaleX).clamp(1.0, size.width),
      (vpH * scaleY).clamp(1.0, size.height),
    );

    final vpPaint = Paint()
      ..color = AppColors.isDark
          ? Colors.white.withAlpha(50)
          : Colors.black.withAlpha(30)
      ..style = PaintingStyle.fill;

    final vpBorderPaint = Paint()
      ..color = AppColors.isDark
          ? Colors.white.withAlpha(120)
          : Colors.black.withAlpha(80)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawRect(vpRect, vpPaint);
    canvas.drawRect(vpRect, vpBorderPaint);
  }

  @override
  bool shouldRepaint(covariant _MinimapPainter old) =>
      old.nodes != nodes ||
      old.transform != transform ||
      old.screenSize != screenSize;
}
