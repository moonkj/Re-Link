import 'package:flutter/material.dart';
import '../../design/tokens/app_colors.dart';
import '../../design/tokens/app_spacing.dart';

/// 타일 간 구분선 (아이콘 영역 이후부터)
class TileDivider extends StatelessWidget {
  const TileDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 0.5,
      indent: AppSpacing.lg + 24 + AppSpacing.lg,
      color: AppColors.glassBorder,
    );
  }
}
