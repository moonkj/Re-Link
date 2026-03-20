import 'dart:ui';
import 'package:flutter/material.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_shadows.dart';

/// Re-Link Glassmorphism 2.0 / Liquid Glass 컴포넌트
/// 디자인 문서 4.1:
///   Light — blur:24, opacity:0.72, saturation:1.4, noise:3%
///   Dark  — blur:32, opacity:0.60, saturation:1.2, noise:2%
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = AppRadius.glassCard,
    this.padding,
    this.margin,
    this.shadows = AppShadows.glass,
    this.onTap,
    this.width,
    this.height,
  });

  final Widget child;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final List<BoxShadow> shadows;
  final VoidCallback? onTap;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isLight = brightness == Brightness.light;

    // Glassmorphism 2.0 specs
    final blur = isLight ? 24.0 : 32.0;
    final fillOpacity = isLight ? 0.72 : 0.60;
    final borderOpacity = isLight ? 0.40 : 0.20;

    return Container(
      margin: margin,
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: shadows,
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              padding: padding,
              decoration: BoxDecoration(
                borderRadius: borderRadius,
                color: isLight
                    ? Color.fromRGBO(255, 255, 255, fillOpacity)
                    : Color.fromRGBO(255, 255, 255, fillOpacity * 0.25),
                border: Border.all(
                  color: Color.fromRGBO(255, 255, 255, borderOpacity),
                  width: 1.0,
                ),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// 글래스 버튼 — 상태별(normal/pressed/disabled) 피드백 포함
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
    return GestureDetector(
      onTap: isDisabled ? null : widget.onPressed,
      onTapDown: isDisabled ? null : (_) => setState(() => _pressed = true),
      onTapUp: isDisabled ? null : (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedOpacity(
        opacity: isDisabled ? 0.4 : (_pressed ? 0.65 : 1.0),
        duration: const Duration(milliseconds: 80),
        child: ClipRRect(
          borderRadius: widget.borderRadius,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: widget.padding,
              decoration: BoxDecoration(
                borderRadius: widget.borderRadius,
                color: _pressed
                    ? AppColors.glassBorder
                    : (widget.backgroundColor ?? AppColors.glassSurface),
                border: Border.all(
                  color: AppColors.glassBorder,
                  width: 1.0,
                ),
              ),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

/// Primary 글래스 버튼 (Mint→Blue 그라디언트)
class PrimaryGlassButton extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          gradient: const LinearGradient(
            colors: [AppColors.primaryMint, AppColors.primaryBlue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: AppShadows.primaryGlow,
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[icon!, const SizedBox(width: 8)],
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// 글래스 바텀시트 래퍼
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
    return ClipRRect(
      borderRadius: AppRadius.bottomSheet,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 32, sigmaY: 32),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: AppRadius.bottomSheet,
            color: AppColors.isDark
                ? const Color(0xE60D1117)
                : const Color(0xF0FFFFFF),
            border: Border(
              top: BorderSide(color: AppColors.glassBorder, width: 1),
              left: BorderSide(color: AppColors.glassBorder, width: 0.5),
              right: BorderSide(color: AppColors.glassBorder, width: 0.5),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
