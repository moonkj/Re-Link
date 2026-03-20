import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/utils/haptic_service.dart';
import '../../../design/glass/app_glass.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../design/tokens/app_spacing.dart';
import '../services/invite_service.dart';

/// 초대 코드를 표시하는 스타일링된 글래스 카드
class InviteCodeCard extends StatelessWidget {
  const InviteCodeCard({
    super.key,
    required this.code,
  });

  final String code;

  @override
  Widget build(BuildContext context) {
    final formatted = InviteService.formatCode(code);

    return GlassCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xxl,
        vertical: AppSpacing.xxxl,
      ),
      child: Column(
        children: [
          // 라벨
          Text(
            '초대 코드',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // 코드 (그라디언트 배경 + 대형 모노스페이스)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xxl,
              vertical: AppSpacing.xl,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withAlpha(25),
                  AppColors.secondary.withAlpha(25),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: AppColors.primary.withAlpha(60),
                width: 1.5,
              ),
            ),
            child: Text(
              formatted,
              style: const TextStyle(
                fontFamily: 'JetBrainsMono',
                fontSize: 36,
                fontWeight: FontWeight.w700,
                letterSpacing: 4,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // 코드 복사 버튼
          GlassButton(
            onPressed: () => _copyCode(context),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.md,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.copy_rounded,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: AppSpacing.sm),
                const Text(
                  '코드 복사',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _copyCode(BuildContext context) {
    Clipboard.setData(ClipboardData(text: code));
    HapticService.light();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('초대 코드가 복사되었습니다'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
