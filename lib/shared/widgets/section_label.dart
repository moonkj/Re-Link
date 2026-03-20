import 'package:flutter/material.dart';
import '../../design/tokens/app_colors.dart';

/// 공통 섹션 레이블 — 모든 화면에서 동일 스타일
class SectionLabel extends StatelessWidget {
  const SectionLabel({super.key, required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
      ),
    );
  }
}
