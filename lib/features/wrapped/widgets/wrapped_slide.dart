import 'package:flutter/material.dart';

/// 단일 Wrapped 슬라이드 — 그라디언트 배경 + 중앙 콘텐츠
class WrappedSlide extends StatelessWidget {
  const WrappedSlide({
    super.key,
    required this.gradientColors,
    required this.child,
  });

  final List<Color> gradientColors;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
      ),
      child: SafeArea(
        child: Center(child: child),
      ),
    );
  }
}
