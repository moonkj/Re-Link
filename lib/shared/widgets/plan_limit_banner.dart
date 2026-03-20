import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/errors/app_error.dart';
import '../../core/router/app_router.dart';
import '../../design/tokens/app_colors.dart';
import '../../design/tokens/app_spacing.dart';

/// 플랜 제한 초과 시 SnackBar 표시 헬퍼
void showPlanLimitSnackBar(BuildContext context, PlanLimitError error) {
  if (!context.mounted) return;

  final featureLabel = switch (error.feature) {
    'node' => '노드',
    'photo' => '사진',
    'voice' => '음성',
    _ => error.feature,
  };
  final requiredPlanName = error.requiredPlan.toUpperCase();

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: AppColors.bgElevated,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(AppSpacing.md),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.glassBorder),
      ),
      content: Row(
        children: [
          const Icon(Icons.lock_outline, color: AppColors.accent, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              '$featureLabel 한도 초과\n$requiredPlanName 이상으로 업그레이드하세요',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 13),
            ),
          ),
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              context.push(AppRoutes.subscription);
            },
            child: const Text('업그레이드', style: TextStyle(color: AppColors.primary, fontSize: 13)),
          ),
        ],
      ),
    ),
  );
}
