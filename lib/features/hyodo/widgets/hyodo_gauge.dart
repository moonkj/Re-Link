import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../design/tokens/app_colors.dart';

/// 효도 온도 반원형 게이지 위젯
///
/// [score] 0.0~100.0 범위의 점수
/// [level] 레벨 텍스트 (냉담/쌀쌀/보통/따뜻/뜨거움/열정)
/// [nodeName] 아래에 표시할 노드 이름
/// [size] 게이지 전체 크기 (기본 150)
class HyodoGauge extends StatelessWidget {
  const HyodoGauge({
    super.key,
    required this.score,
    required this.level,
    this.nodeName,
    this.size = 150.0,
    this.showLabel = true,
  });

  final double score;
  final String level;
  final String? nodeName;
  final double size;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 0.75, // 반원 + 하단 텍스트
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size * 0.55,
            child: CustomPaint(
              painter: _GaugePainter(score: score),
              child: Center(
                child: Padding(
                  padding: EdgeInsets.only(top: size * 0.10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        score.toInt().toString(),
                        style: TextStyle(
                          fontSize: size * 0.20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        level,
                        style: TextStyle(
                          fontSize: size * 0.09,
                          fontWeight: FontWeight.w600,
                          color: _colorForScore(score),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (showLabel && nodeName != null) ...[
            const SizedBox(height: 4),
            Text(
              nodeName!,
              style: TextStyle(
                fontSize: size * 0.09,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  static Color _colorForScore(double score) {
    if (score < 16) return AppColors.tempIcy;
    if (score < 31) return AppColors.tempCool;
    if (score < 51) return AppColors.tempNeutral;
    if (score < 71) return AppColors.tempWarm;
    if (score < 86) return AppColors.tempHot;
    return AppColors.tempFire;
  }
}

/// 반원형 게이지 CustomPainter
class _GaugePainter extends CustomPainter {
  const _GaugePainter({required this.score});

  final double score;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.9);
    final radius = size.width * 0.42;
    const strokeWidth = 12.0;
    const startAngle = math.pi; // 180도 (왼쪽)
    const sweepAngle = math.pi; // 180도 (반원)

    final rect = Rect.fromCircle(center: center, radius: radius);

    // ── 배경 호 ───────────────────────────────────────────────────────────────
    final bgPaint = Paint()
      ..color = AppColors.isDark
          ? const Color(0x33FFFFFF)
          : const Color(0x1A000000)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, startAngle, sweepAngle, false, bgPaint);

    // ── 채워진 호 (그라디언트) ──────────────────────────────────────────────────
    if (score > 0) {
      final fillSweep = sweepAngle * (score / 100.0).clamp(0.0, 1.0);

      final gradientPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..shader = SweepGradient(
          startAngle: startAngle,
          endAngle: startAngle + sweepAngle,
          colors: const [
            AppColors.tempIcy,
            AppColors.tempCool,
            AppColors.tempNeutral,
            AppColors.tempWarm,
            AppColors.tempHot,
            AppColors.tempFire,
          ],
          stops: const [0.0, 0.15, 0.35, 0.55, 0.75, 1.0],
        ).createShader(rect);

      canvas.drawArc(rect, startAngle, fillSweep, false, gradientPaint);
    }

    // ── 끝점 인디케이터 (작은 원) ─────────────────────────────────────────────
    if (score > 0) {
      final fillRatio = (score / 100.0).clamp(0.0, 1.0);
      final endAngle = startAngle + sweepAngle * fillRatio;
      final dotCenter = Offset(
        center.dx + radius * math.cos(endAngle),
        center.dy + radius * math.sin(endAngle),
      );

      // 외곽 하얀 원
      final outerDot = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(dotCenter, strokeWidth * 0.5, outerDot);

      // 내부 색상 원
      final innerDot = Paint()
        ..color = _colorForScore(score)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(dotCenter, strokeWidth * 0.3, innerDot);
    }
  }

  static Color _colorForScore(double score) {
    if (score < 16) return AppColors.tempIcy;
    if (score < 31) return AppColors.tempCool;
    if (score < 51) return AppColors.tempNeutral;
    if (score < 71) return AppColors.tempWarm;
    if (score < 86) return AppColors.tempHot;
    return AppColors.tempFire;
  }

  @override
  bool shouldRepaint(covariant _GaugePainter old) => old.score != score;
}
