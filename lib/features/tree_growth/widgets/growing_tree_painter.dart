import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../providers/tree_growth_notifier.dart';

/// 캔버스 배경에 그려지는 가족 나무 CustomPainter
///
/// [GrowthStage]에 따라 나무 크기와 복잡도가 변하고,
/// [Season]에 따라 캐노피 색상이 달라진다.
class GrowingTreePainter extends CustomPainter {
  const GrowingTreePainter({
    required this.stage,
    required this.season,
  });

  final GrowthStage stage;
  final Season season;

  /// 계절별 캐노피 색상
  Color get _canopyColor => switch (season) {
        Season.spring => const Color(0xFFFFB7C5), // 벚꽃 핑크
        Season.summer => const Color(0xFF4CAF50), // 싱그러운 초록
        Season.autumn => const Color(0xFFFF8A65), // 단풍 오렌지
        Season.winter => const Color(0xFFB0BEC5), // 겨울 회색
      };

  /// 계절별 캐노피 내부 그라데이션 보조 색상
  Color get _canopySecondaryColor => switch (season) {
        Season.spring => const Color(0xFFFF8FAB),
        Season.summer => const Color(0xFF2E7D32),
        Season.autumn => const Color(0xFFE64A19),
        Season.winter => const Color(0xFF78909C),
      };

  /// 줄기 색상 (모든 계절 동일)
  static const Color _trunkColor = Color(0xFF5D4037);
  static const Color _trunkDarkColor = Color(0xFF3E2723);

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final bottomY = size.height;

    switch (stage) {
      case GrowthStage.sprout:
        _drawSprout(canvas, centerX, bottomY);
      case GrowthStage.sapling:
        _drawSapling(canvas, centerX, bottomY);
      case GrowthStage.smallTree:
        _drawSmallTree(canvas, centerX, bottomY);
      case GrowthStage.bigTree:
        _drawBigTree(canvas, centerX, bottomY);
      case GrowthStage.grandTree:
        _drawGrandTree(canvas, centerX, bottomY);
    }
  }

  /// sprout: 작은 새싹 — 줄기 + 잎 2개
  void _drawSprout(Canvas canvas, double cx, double by) {
    final stemPaint = Paint()
      ..color = const Color(0xFF66BB6A)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // 줄기
    final stem = Path()
      ..moveTo(cx, by)
      ..quadraticBezierTo(cx - 2, by - 20, cx, by - 35);
    canvas.drawPath(stem, stemPaint);

    // 잎 (좌)
    final leafPaint = Paint()..color = const Color(0xFF81C784);
    final leftLeaf = Path()
      ..moveTo(cx, by - 28)
      ..quadraticBezierTo(cx - 14, by - 42, cx - 6, by - 48)
      ..quadraticBezierTo(cx - 2, by - 38, cx, by - 28);
    canvas.drawPath(leftLeaf, leafPaint);

    // 잎 (우)
    final rightLeaf = Path()
      ..moveTo(cx, by - 32)
      ..quadraticBezierTo(cx + 14, by - 46, cx + 6, by - 52)
      ..quadraticBezierTo(cx + 2, by - 42, cx, by - 32);
    canvas.drawPath(rightLeaf, leafPaint);

    // 씨앗/뿌리
    final seedPaint = Paint()..color = const Color(0xFF8D6E63);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, by + 2), width: 10, height: 6),
      seedPaint,
    );
  }

  /// sapling: 얇은 줄기 + 작은 캐노피 원
  void _drawSapling(Canvas canvas, double cx, double by) {
    const trunkHeight = 80.0;
    const trunkWidth = 6.0;
    const canopyRadius = 30.0;

    // 줄기
    _drawOrganicTrunk(canvas, cx, by, trunkHeight, trunkWidth);

    // 캐노피
    final canopyPaint = Paint()..color = _canopyColor;
    canvas.drawCircle(
      Offset(cx, by - trunkHeight - canopyRadius * 0.6),
      canopyRadius,
      canopyPaint,
    );

    // 캐노피 하이라이트
    final highlightPaint = Paint()
      ..color = _canopySecondaryColor.withAlpha(80);
    canvas.drawCircle(
      Offset(cx - 6, by - trunkHeight - canopyRadius * 0.6 - 6),
      canopyRadius * 0.5,
      highlightPaint,
    );

    // 봄에는 작은 꽃잎 파티클
    if (season == Season.spring) {
      _drawPetals(canvas, cx, by - trunkHeight - canopyRadius, 3, 12.0);
    }
  }

  /// smallTree: 중간 줄기 + 가지 + 중간 캐노피
  void _drawSmallTree(Canvas canvas, double cx, double by) {
    const trunkHeight = 140.0;
    const trunkWidth = 10.0;
    const canopyRadius = 55.0;

    // 줄기
    _drawOrganicTrunk(canvas, cx, by, trunkHeight, trunkWidth);

    // 가지 2개
    _drawBranch(canvas, cx, by - trunkHeight * 0.5, -30, 35, 3);
    _drawBranch(canvas, cx, by - trunkHeight * 0.65, 25, 30, 3);

    // 캐노피 (약간 타원형)
    final canopyCenter = Offset(cx, by - trunkHeight - canopyRadius * 0.4);
    final canopyPaint = Paint()..color = _canopyColor;
    canvas.drawOval(
      Rect.fromCenter(
        center: canopyCenter,
        width: canopyRadius * 2.2,
        height: canopyRadius * 1.8,
      ),
      canopyPaint,
    );

    // 캐노피 그라데이션 효과
    final innerPaint = Paint()..color = _canopySecondaryColor.withAlpha(60);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx - 8, canopyCenter.dy - 8),
        width: canopyRadius * 1.2,
        height: canopyRadius * 1.0,
      ),
      innerPaint,
    );

    if (season == Season.spring) {
      _drawPetals(canvas, cx, canopyCenter.dy, 5, 25.0);
    }

    if (season == Season.winter) {
      _drawBareSpots(canvas, canopyCenter, canopyRadius);
    }
  }

  /// bigTree: 두꺼운 줄기 + 큰 캐노피 + 가지 여러 개
  void _drawBigTree(Canvas canvas, double cx, double by) {
    const trunkHeight = 200.0;
    const trunkWidth = 16.0;
    const canopyRadius = 80.0;

    // 뿌리
    _drawRoots(canvas, cx, by, 3);

    // 줄기
    _drawOrganicTrunk(canvas, cx, by, trunkHeight, trunkWidth);

    // 가지들
    _drawBranch(canvas, cx, by - trunkHeight * 0.4, -35, 50, 4);
    _drawBranch(canvas, cx, by - trunkHeight * 0.55, 30, 45, 4);
    _drawBranch(canvas, cx, by - trunkHeight * 0.7, -20, 35, 3);
    _drawBranch(canvas, cx, by - trunkHeight * 0.8, 18, 30, 3);

    // 캐노피 (다중 원으로 자연스럽게)
    final canopyCenterY = by - trunkHeight - canopyRadius * 0.3;
    final canopyPaint = Paint()..color = _canopyColor;
    final darkCanopyPaint = Paint()..color = _canopySecondaryColor.withAlpha(50);

    // 메인 캐노피
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, canopyCenterY),
        width: canopyRadius * 2.4,
        height: canopyRadius * 2.0,
      ),
      canopyPaint,
    );

    // 좌측 돌출
    canvas.drawCircle(
      Offset(cx - canopyRadius * 0.8, canopyCenterY + 10),
      canopyRadius * 0.7,
      canopyPaint,
    );

    // 우측 돌출
    canvas.drawCircle(
      Offset(cx + canopyRadius * 0.8, canopyCenterY + 5),
      canopyRadius * 0.65,
      canopyPaint,
    );

    // 내부 질감
    canvas.drawCircle(
      Offset(cx - 10, canopyCenterY - 15),
      canopyRadius * 0.6,
      darkCanopyPaint,
    );

    if (season == Season.spring) {
      _drawPetals(canvas, cx, canopyCenterY, 8, 40.0);
    }

    if (season == Season.winter) {
      _drawBareSpots(
        canvas,
        Offset(cx, canopyCenterY),
        canopyRadius,
      );
    }
  }

  /// grandTree: 거대한 나무 — 두꺼운 줄기, 뿌리, 다층 캐노피
  void _drawGrandTree(Canvas canvas, double cx, double by) {
    const trunkHeight = 280.0;
    const trunkWidth = 24.0;
    const canopyRadius = 110.0;

    // 뿌리 (넓게)
    _drawRoots(canvas, cx, by, 5);

    // 줄기 (약간 곡선이 있는 두꺼운 줄기)
    _drawOrganicTrunk(canvas, cx, by, trunkHeight, trunkWidth);

    // 주요 가지들
    _drawBranch(canvas, cx - 4, by - trunkHeight * 0.35, -40, 65, 6);
    _drawBranch(canvas, cx + 4, by - trunkHeight * 0.45, 35, 60, 6);
    _drawBranch(canvas, cx - 2, by - trunkHeight * 0.55, -25, 50, 5);
    _drawBranch(canvas, cx + 2, by - trunkHeight * 0.65, 20, 45, 4);
    _drawBranch(canvas, cx, by - trunkHeight * 0.75, -15, 35, 3);
    _drawBranch(canvas, cx, by - trunkHeight * 0.85, 12, 30, 3);

    // 다층 캐노피
    final canopyCenterY = by - trunkHeight - canopyRadius * 0.2;
    final canopyPaint = Paint()..color = _canopyColor;
    final darkPaint = Paint()..color = _canopySecondaryColor.withAlpha(45);

    // 하단 캐노피 (넓게)
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, canopyCenterY + 30),
        width: canopyRadius * 2.8,
        height: canopyRadius * 1.2,
      ),
      canopyPaint,
    );

    // 메인 캐노피
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, canopyCenterY),
        width: canopyRadius * 2.6,
        height: canopyRadius * 2.2,
      ),
      canopyPaint,
    );

    // 좌상 돌출
    canvas.drawCircle(
      Offset(cx - canopyRadius * 0.9, canopyCenterY - 15),
      canopyRadius * 0.8,
      canopyPaint,
    );

    // 우상 돌출
    canvas.drawCircle(
      Offset(cx + canopyRadius * 0.85, canopyCenterY - 10),
      canopyRadius * 0.75,
      canopyPaint,
    );

    // 상단 돌출
    canvas.drawCircle(
      Offset(cx, canopyCenterY - canopyRadius * 0.7),
      canopyRadius * 0.6,
      canopyPaint,
    );

    // 내부 질감
    canvas.drawCircle(
      Offset(cx - 20, canopyCenterY - 20),
      canopyRadius * 0.7,
      darkPaint,
    );
    canvas.drawCircle(
      Offset(cx + 15, canopyCenterY + 10),
      canopyRadius * 0.5,
      darkPaint,
    );

    if (season == Season.spring) {
      _drawPetals(canvas, cx, canopyCenterY, 12, 55.0);
    }

    if (season == Season.winter) {
      _drawBareSpots(
        canvas,
        Offset(cx, canopyCenterY),
        canopyRadius,
      );
    }
  }

  // ── 헬퍼 메서드 ──────────────────────────────────────────────────────────

  /// 유기적 곡선의 줄기를 Path로 그린다
  void _drawOrganicTrunk(
    Canvas canvas,
    double cx,
    double by,
    double height,
    double width,
  ) {
    final trunkPaint = Paint()
      ..color = _trunkColor
      ..style = PaintingStyle.fill;

    final halfW = width / 2;
    final trunk = Path()
      ..moveTo(cx - halfW * 1.3, by) // 하단 왼쪽 (약간 넓게)
      ..quadraticBezierTo(
        cx - halfW * 0.8,
        by - height * 0.5,
        cx - halfW * 0.6,
        by - height,
      ) // 상단 왼쪽
      ..lineTo(cx + halfW * 0.6, by - height) // 상단 오른쪽
      ..quadraticBezierTo(
        cx + halfW * 0.8,
        by - height * 0.5,
        cx + halfW * 1.3,
        by,
      ) // 하단 오른쪽
      ..close();
    canvas.drawPath(trunk, trunkPaint);

    // 줄기 중심선 (질감)
    final linePaint = Paint()
      ..color = _trunkDarkColor.withAlpha(50)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final centerLine = Path()
      ..moveTo(cx, by - 2)
      ..quadraticBezierTo(cx - 1, by - height * 0.5, cx, by - height + 2);
    canvas.drawPath(centerLine, linePaint);
  }

  /// 가지를 그린다 (각도와 길이 지정)
  void _drawBranch(
    Canvas canvas,
    double startX,
    double startY,
    double angleDeg,
    double length,
    double width,
  ) {
    final angleRad = angleDeg * math.pi / 180;
    final endX = startX + math.cos(angleRad) * length;
    final endY = startY - math.sin(angleRad).abs() * length * 0.3;

    final branchPaint = Paint()
      ..color = _trunkColor
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final branch = Path()
      ..moveTo(startX, startY)
      ..quadraticBezierTo(
        (startX + endX) / 2,
        startY - length * 0.15,
        endX,
        endY,
      );
    canvas.drawPath(branch, branchPaint);
  }

  /// 뿌리를 그린다
  void _drawRoots(Canvas canvas, double cx, double by, int count) {
    final rootPaint = Paint()
      ..color = _trunkColor.withAlpha(180)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final rng = math.Random(42); // 결정적 랜덤 (일관된 모양)
    for (int i = 0; i < count; i++) {
      final angle = -math.pi / 2 +
          (i / (count - 1)) * math.pi * 0.8 -
          math.pi * 0.4;
      final length = 20.0 + rng.nextDouble() * 20;
      final endX = cx + math.cos(angle) * length;
      final endY = by + math.sin(angle).abs() * length * 0.4 + 3;

      final root = Path()
        ..moveTo(cx + (i - count / 2) * 4, by)
        ..quadraticBezierTo(
          cx + (i - count / 2) * 8,
          by + 6,
          endX,
          endY,
        );
      canvas.drawPath(root, rootPaint);
    }
  }

  /// 벚꽃 꽃잎 파티클 (봄 전용)
  void _drawPetals(
    Canvas canvas,
    double cx,
    double cy,
    int count,
    double spread,
  ) {
    final petalPaint = Paint()..color = const Color(0xFFFFCDD2);
    final rng = math.Random(123); // 결정적 랜덤
    for (int i = 0; i < count; i++) {
      final px = cx + (rng.nextDouble() - 0.5) * spread * 3;
      final py = cy + (rng.nextDouble() - 0.5) * spread * 2;
      canvas.drawCircle(Offset(px, py), 2 + rng.nextDouble() * 2, petalPaint);
    }
  }

  /// 겨울 빈 구멍 (잎이 적은 효과)
  void _drawBareSpots(Canvas canvas, Offset center, double radius) {
    final spotPaint = Paint()
      ..color = const Color(0x20FFFFFF)
      ..style = PaintingStyle.fill;
    final rng = math.Random(77);
    for (int i = 0; i < 4; i++) {
      final px = center.dx + (rng.nextDouble() - 0.5) * radius * 1.5;
      final py = center.dy + (rng.nextDouble() - 0.5) * radius * 1.2;
      canvas.drawCircle(Offset(px, py), 8 + rng.nextDouble() * 12, spotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant GrowingTreePainter oldDelegate) =>
      oldDelegate.stage != stage || oldDelegate.season != season;
}
