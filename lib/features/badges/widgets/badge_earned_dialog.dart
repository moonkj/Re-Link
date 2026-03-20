import 'package:flutter/material.dart';
import '../../../core/utils/haptic_service.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../design/tokens/app_spacing.dart';
import '../../../design/tokens/app_radius.dart';
import '../models/badge_definition.dart';

/// 배지 획득 축하 다이얼로그
///
/// [isReview]가 true이면 이미 획득한 배지 상세 보기 모드 (햅틱 없음)
class BadgeEarnedDialog extends StatefulWidget {
  const BadgeEarnedDialog({
    super.key,
    required this.badge,
    this.isReview = false,
  });

  final BadgeDefinition badge;
  final bool isReview;

  @override
  State<BadgeEarnedDialog> createState() => _BadgeEarnedDialogState();
}

class _BadgeEarnedDialogState extends State<BadgeEarnedDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _opacityAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scaleAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _opacityAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );
    _controller.forward();

    if (!widget.isReview) {
      HapticService.celebration();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _rarityColor(BadgeRarity rarity) => switch (rarity) {
        BadgeRarity.common => AppColors.textSecondary,
        BadgeRarity.rare => AppColors.secondary,
        BadgeRarity.epic => AppColors.primary,
        BadgeRarity.legendary => AppColors.accent,
      };

  List<Color> _rarityGradient(BadgeRarity rarity) => switch (rarity) {
        BadgeRarity.common => [
            AppColors.textSecondary.withAlpha(60),
            AppColors.textSecondary.withAlpha(30),
          ],
        BadgeRarity.rare => [
            AppColors.secondary.withAlpha(80),
            AppColors.secondary.withAlpha(40),
          ],
        BadgeRarity.epic => [
            AppColors.primary.withAlpha(80),
            AppColors.primary.withAlpha(40),
          ],
        BadgeRarity.legendary => [
            AppColors.accent.withAlpha(100),
            const Color(0xFFFFD700).withAlpha(60),
          ],
      };

  @override
  Widget build(BuildContext context) {
    final badge = widget.badge;
    final rarityColor = _rarityColor(badge.rarity);
    final gradientColors = _rarityGradient(badge.rarity);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnim.value,
          child: ScaleTransition(
            scale: _scaleAnim,
            child: child,
          ),
        );
      },
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(AppSpacing.xxl),
          decoration: BoxDecoration(
            borderRadius: AppRadius.dialog,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.isDark
                    ? const Color(0xFF1E2840)
                    : const Color(0xFFFAFBFC),
                AppColors.isDark
                    ? const Color(0xFF0D1117)
                    : const Color(0xFFFFFFFF),
              ],
            ),
            border: Border.all(
              width: 2,
              color: rarityColor.withAlpha(120),
            ),
            boxShadow: [
              BoxShadow(
                color: rarityColor.withAlpha(50),
                blurRadius: 24,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 축하 헤더
              if (!widget.isReview) ...[
                Text(
                  '축하합니다!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],

              // 배지 아이콘 (큰 원 + 그라데이션 배경 + 글로우)
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: gradientColors,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: rarityColor.withAlpha(80),
                      blurRadius: 20,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: Icon(
                  badge.icon,
                  size: 48,
                  color: rarityColor,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // 배지 이름
              Text(
                badge.name,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              // 배지 설명
              Text(
                badge.description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // 희귀도 라벨
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: rarityColor.withAlpha(25),
                  border: Border.all(
                    color: rarityColor.withAlpha(60),
                    width: 1,
                  ),
                ),
                child: Text(
                  badge.rarity.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: rarityColor,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // 확인 버튼
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    backgroundColor: rarityColor.withAlpha(20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding:
                        const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  ),
                  child: Text(
                    '확인',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: rarityColor,
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
