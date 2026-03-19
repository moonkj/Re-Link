import 'dart:ui';
import 'package:flutter/material.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_shadows.dart';

/// Re-Link Glassmorphism 2.0 / Liquid Glass 컴포넌트
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = AppRadius.glassCard,
    this.blur = 20.0,
    this.opacity = 0.15,
    this.borderOpacity = 0.2,
    this.padding,
    this.margin,
    this.shadows = AppShadows.glass,
    this.onTap,
    this.width,
    this.height,
  });

  final Widget child;
  final BorderRadius borderRadius;
  final double blur;
  final double opacity;
  final double borderOpacity;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final List<BoxShadow> shadows;
  final VoidCallback? onTap;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    // 다크/라이트 밝기에 따라 glass opacity 자동 조정
    final brightness = Theme.of(context).brightness;
    final effectiveOpacity =
        brightness == Brightness.light ? (opacity * 4.8).clamp(0.0, 1.0) : opacity;
    final effectiveBorderOpacity =
        brightness == Brightness.light ? (borderOpacity * 2.0).clamp(0.0, 1.0) : borderOpacity;

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
                color: Color.fromRGBO(255, 255, 255, effectiveOpacity),
                border: Border.all(
                  color: Color.fromRGBO(255, 255, 255, effectiveBorderOpacity),
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
                    ? AppColors.glassBorder // 눌림 시 약간 더 불투명
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

/// Primary 글래스 버튼 (보라색 그라디언트)
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
            colors: [Color(0xFF6C63FF), Color(0xFF9C94FF)],
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
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          padding: padding,
          decoration: const BoxDecoration(
            borderRadius: AppRadius.bottomSheet,
            color: Color(0xE60A0A1A), // 90% 어두운 배경
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
