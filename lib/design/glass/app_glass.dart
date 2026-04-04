import 'package:flutter/material.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_shadows.dart';

/// Re-Link Clean Card System
/// Solid backgrounds, no blur, no glow — clean and sharp.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = AppRadius.glassCard,
    this.padding,
    this.margin,
    this.shadows = AppShadows.glass,
    this.onTap,
    this.onLongPress,
    this.width,
    this.height,
  });

  final Widget child;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final List<BoxShadow> shadows;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isLight = brightness == Brightness.light;

    final bgColor = isLight
        ? const Color(0xFFFFFFFF)   // solid white
        : const Color(0xFF1E2040);  // nightSurface

    final borderColor = isLight
        ? const Color(0x1A000000)   // 10% black
        : const Color(0x33FFFFFF);  // 20% white

    final card = Container(
      margin: margin,
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        color: bgColor,
        border: Border.all(
          color: borderColor,
          width: 1.0,
        ),
        boxShadow: shadows,
      ),
      padding: padding,
      child: child,
    );

    if (onTap != null || onLongPress != null) {
      return GestureDetector(onTap: onTap, onLongPress: onLongPress, child: card);
    }
    return card;
  }
}

/// Clean solid button with press feedback
class GlassButton extends StatefulWidget {
  const GlassButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.borderRadius = AppRadius.button,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    this.backgroundColor,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;

  @override
  State<GlassButton> createState() => _GlassButtonState();
}

class _GlassButtonState extends State<GlassButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null;
    final isLight = Theme.of(context).brightness == Brightness.light;

    final defaultBg = isLight
        ? const Color(0xFFF1F5F9)   // dayElevated
        : const Color(0xFF2C2D52);  // nightElevated

    final pressedBg = isLight
        ? const Color(0xFFE2E8F0)   // slightly darker
        : const Color(0xFF363660);  // slightly lighter

    final borderColor = isLight
        ? const Color(0x1A000000)
        : const Color(0x33FFFFFF);

    return GestureDetector(
      onTap: isDisabled ? null : widget.onPressed,
      onTapDown: isDisabled ? null : (_) => setState(() => _pressed = true),
      onTapUp: isDisabled ? null : (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedOpacity(
        opacity: isDisabled ? 0.4 : 1.0,
        duration: const Duration(milliseconds: 80),
        child: Container(
          padding: widget.padding,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius,
            color: _pressed
                ? pressedBg
                : (widget.backgroundColor ?? defaultBg),
            border: Border.all(
              color: borderColor,
              width: 1.0,
            ),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

/// Primary button — gradient with shimmer, NO glow
class PrimaryGlassButton extends StatefulWidget {
  const PrimaryGlassButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.borderRadius = AppRadius.button,
    this.padding = const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final bool isLoading;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry padding;

  @override
  State<PrimaryGlassButton> createState() => _PrimaryGlassButtonState();
}

class _PrimaryGlassButtonState extends State<PrimaryGlassButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmerCtrl;

  @override
  void initState() {
    super.initState();
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _startShimmerLoop();
  }

  Future<void> _startShimmerLoop() async {
    while (mounted) {
      await _shimmerCtrl.forward(from: 0);
      if (!mounted) break;
      await Future.delayed(const Duration(seconds: 5));
    }
  }

  @override
  void dispose() {
    _shimmerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null;

    return GestureDetector(
      onTap: widget.isLoading ? null : widget.onPressed,
      child: AnimatedOpacity(
        opacity: isDisabled ? 0.5 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: AnimatedBuilder(
          animation: _shimmerCtrl,
          builder: (context, child) {
            return Container(
              padding: widget.padding,
              decoration: BoxDecoration(
                borderRadius: widget.borderRadius,
                gradient: const LinearGradient(
                  colors: [AppColors.primaryMint, AppColors.primaryBlue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryMint.withValues(alpha: 0.20),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: widget.borderRadius,
                child: Stack(
                  children: [
                    child!,
                    if (!widget.isLoading)
                      Positioned.fill(
                        child: _ShimmerOverlay(progress: _shimmerCtrl.value),
                      ),
                  ],
                ),
              ),
            );
          },
          child: widget.isLoading
              ? Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation(AppColors.onPrimary),
                    ),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.icon != null) ...[
                      widget.icon!,
                      const SizedBox(width: 8),
                    ],
                    Text(
                      widget.label,
                      style: TextStyle(
                        color: AppColors.onPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

/// Diagonal shimmer overlay for PrimaryGlassButton
class _ShimmerOverlay extends StatelessWidget {
  const _ShimmerOverlay({required this.progress});
  final double progress;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth + 80;
        final offset = -40.0 + totalWidth * progress;
        return Transform.translate(
          offset: Offset(offset, 0),
          child: Container(
            width: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withAlpha(0),
                  Colors.white.withAlpha(38),
                  Colors.white.withAlpha(0),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Clean solid bottom sheet
class GlassBottomSheet extends StatelessWidget {
  const GlassBottomSheet({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    final bgColor = isLight
        ? const Color(0xFFFFFFFF)
        : const Color(0xFF1E2040);   // nightSurface

    final borderColor = isLight
        ? const Color(0x1A000000)
        : const Color(0x33FFFFFF);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: AppRadius.bottomSheet,
        color: bgColor,
        border: Border(
          top: BorderSide(color: borderColor, width: 1),
          left: BorderSide(color: borderColor, width: 0.5),
          right: BorderSide(color: borderColor, width: 0.5),
        ),
      ),
      child: child,
    );
  }
}
