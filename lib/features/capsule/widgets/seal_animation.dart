import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/utils/haptic_service.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../design/motion/app_motion.dart';

/// 캡슐 봉인/열림 애니메이션 오버레이
///
/// [SealAnimationType.seal] — 캡슐 생성 완료 시 봉인 연출
///   캡슐 아이콘 scale(0->1.2->1.0) + rotation(0->360°)
///   자물쇠 fade-in (300ms 딜레이)
///   배경 원형 ripple (Mint, 3단계 확산)
///
/// [SealAnimationType.unseal] — 캡슐 열기 시 열림 연출
///   자물쇠 회전 + scale 축소
///   캡슐 아이콘 bounce
enum SealAnimationType { seal, unseal }

/// 봉인/열림 애니메이션을 보여주고 완료 시 [onComplete]를 호출하는 위젯.
/// 보통 [showSealAnimation]을 통해 다이얼로그/오버레이로 사용.
class SealAnimation extends StatefulWidget {
  const SealAnimation({
    super.key,
    required this.type,
    this.onComplete,
  });

  final SealAnimationType type;
  final VoidCallback? onComplete;

  @override
  State<SealAnimation> createState() => _SealAnimationState();
}

class _SealAnimationState extends State<SealAnimation>
    with TickerProviderStateMixin {
  // ── 캡슐 아이콘 scale + rotation ─────────────────────────────────────
  late final AnimationController _capsuleCtrl;
  late final Animation<double> _capsuleScale;
  late final Animation<double> _capsuleRotation;

  // ── 자물쇠 fade-in ──────────────────────────────────────────────────
  late final AnimationController _lockCtrl;
  late final Animation<double> _lockOpacity;
  late final Animation<double> _lockScale;

  // ── 배경 ripple (3단계 확산) ────────────────────────────────────────
  late final AnimationController _rippleCtrl;

  @override
  void initState() {
    super.initState();

    if (widget.type == SealAnimationType.seal) {
      _initSealAnimation();
    } else {
      _initUnsealAnimation();
    }
  }

  void _initSealAnimation() {
    // 캡슐: 600ms scale(0->1.2->1.0) + rotation(0->360°)
    _capsuleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _capsuleScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.2), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 40),
    ]).animate(CurvedAnimation(
      parent: _capsuleCtrl,
      curve: AppMotion.enter,
    ));
    _capsuleRotation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _capsuleCtrl, curve: AppMotion.standard),
    );

    // 자물쇠: 300ms 딜레이 후 400ms fade-in + scale(0.5->1.0)
    _lockCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _lockOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _lockCtrl, curve: AppMotion.enter),
    );
    _lockScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _lockCtrl, curve: AppMotion.spring),
    );

    // 배경 ripple: 1200ms, 3단계 확산
    _rippleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // 시작 시퀀스
    _capsuleCtrl.forward();
    _rippleCtrl.forward();

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _lockCtrl.forward();
        HapticService.celebration();
      }
    });

    // 완료 콜백 (총 1500ms 후)
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) widget.onComplete?.call();
    });
  }

  void _initUnsealAnimation() {
    // 자물쇠: 회전 + scale 축소 (0->1)
    _lockCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _lockOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _lockCtrl, curve: AppMotion.exit),
    );
    _lockScale = Tween<double>(begin: 1.0, end: 0.3).animate(
      CurvedAnimation(parent: _lockCtrl, curve: AppMotion.exit),
    );

    // 캡슐: 300ms 딜레이 후 bounce scale
    _capsuleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _capsuleScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.8, end: 1.3), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(
      parent: _capsuleCtrl,
      curve: AppMotion.spring,
    ));
    _capsuleRotation = Tween<double>(begin: 0.0, end: 0.0).animate(
      _capsuleCtrl,
    );

    // ripple
    _rippleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    // 시작 시퀀스
    _lockCtrl.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _capsuleCtrl.forward();
        _rippleCtrl.forward();
        HapticService.celebration();
      }
    });

    // 완료 콜백
    Future.delayed(const Duration(milliseconds: 1300), () {
      if (mounted) widget.onComplete?.call();
    });
  }

  @override
  void dispose() {
    _capsuleCtrl.dispose();
    _lockCtrl.dispose();
    _rippleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      child: Center(
        child: SizedBox(
          width: 200,
          height: 200,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // ── 배경 ripple (3단계 원형 확산) ──────────────────
              AnimatedBuilder(
                animation: _rippleCtrl,
                builder: (_, __) => CustomPaint(
                  size: const Size(200, 200),
                  painter: _RipplePainter(
                    progress: _rippleCtrl.value,
                    color: AppColors.primary,
                  ),
                ),
              ),

              // ── 캡슐 아이콘 ──────────────────────────────────
              AnimatedBuilder(
                animation: _capsuleCtrl,
                builder: (_, child) => Transform.scale(
                  scale: _capsuleScale.value,
                  child: Transform.rotate(
                    angle: _capsuleRotation.value,
                    child: child,
                  ),
                ),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [AppColors.primaryMint, AppColors.primaryBlue],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x30000000),
                        blurRadius: 16,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    widget.type == SealAnimationType.seal
                        ? Icons.lock_clock_outlined
                        : Icons.auto_awesome,
                    color: AppColors.onPrimary,
                    size: 36,
                  ),
                ),
              ),

              // ── 자물쇠 아이콘 ──────────────────────────────────
              AnimatedBuilder(
                animation: _lockCtrl,
                builder: (_, child) => Opacity(
                  opacity: _lockOpacity.value.clamp(0.0, 1.0),
                  child: Transform.scale(
                    scale: _lockScale.value,
                    child: child,
                  ),
                ),
                child: Positioned(
                  bottom: 30,
                  right: 50,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.type == SealAnimationType.seal
                          ? AppColors.accent
                          : AppColors.success,
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x26000000),
                          blurRadius: 10,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      widget.type == SealAnimationType.seal
                          ? Icons.lock_outlined
                          : Icons.lock_open_outlined,
                      color: AppColors.onPrimary,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 원형 ripple 3단계 확산 painter
class _RipplePainter extends CustomPainter {
  const _RipplePainter({required this.progress, required this.color});
  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    for (int i = 0; i < 3; i++) {
      final delay = i * 0.15;
      final t = ((progress - delay) / (1.0 - delay)).clamp(0.0, 1.0);
      if (t <= 0) continue;

      final radius = t * (size.width / 2);
      final alpha = ((1.0 - t) * 80).toInt().clamp(0, 255);

      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = color.withAlpha(alpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RipplePainter old) =>
      old.progress != progress || old.color != color;
}

/// 봉인 애니메이션을 다이얼로그 오버레이로 표시
Future<void> showSealAnimation(
  BuildContext context, {
  required SealAnimationType type,
}) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.transparent,
    pageBuilder: (ctx, _, __) => SealAnimation(
      type: type,
      onComplete: () {
        if (ctx.mounted) Navigator.of(ctx).pop();
      },
    ),
    transitionDuration: const Duration(milliseconds: 100),
  );
}
