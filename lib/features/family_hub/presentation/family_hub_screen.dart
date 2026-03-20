import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../design/glass/app_glass.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../design/tokens/app_spacing.dart';

/// 가족 탭 — 가족 생활 기능 허브
class FamilyHubScreen extends StatelessWidget {
  const FamilyHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgBase,
      appBar: AppBar(
        title: Text(
          '가족',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        children: [
          // ── 일상 섹션 ──────────────────────────────────────────────
          const _SectionLabel(label: '일상'),
          const SizedBox(height: AppSpacing.sm),
          GlassCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _FeatureTile(
                  icon: Icons.cake_outlined,
                  iconColor: AppColors.accent,
                  title: '가족 생일',
                  subtitle: '다가오는 생일 카운트다운',
                  onTap: () => context.push(AppRoutes.birthday),
                ),
                const _TileDivider(),
                _FeatureTile(
                  icon: Icons.thermostat_outlined,
                  iconColor: AppColors.accent,
                  title: '효도 온도계',
                  subtitle: '가족에게 얼마나 관심을 기울이고 있는지',
                  onTap: () => context.push(AppRoutes.hyodo),
                ),
                const _TileDivider(),
                _FeatureTile(
                  icon: Icons.menu_book_outlined,
                  iconColor: AppColors.primary,
                  title: '가족 단어장',
                  subtitle: '우리 가족만의 표현 모음',
                  onTap: () => context.push(AppRoutes.glossary),
                ),
                const _TileDivider(),
                _FeatureTile(
                  icon: Icons.restaurant_menu_outlined,
                  iconColor: AppColors.accent,
                  title: '가족 레시피',
                  subtitle: '가족의 특별한 레시피 모음',
                  onTap: () => context.push(AppRoutes.recipes),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          // ── 공유 섹션 ──────────────────────────────────────────────
          const _SectionLabel(label: '공유'),
          const SizedBox(height: AppSpacing.sm),
          GlassCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _FeatureTile(
                  icon: Icons.group_add_outlined,
                  iconColor: AppColors.primary,
                  title: '가족 초대',
                  subtitle: '초대 코드로 가족 트리 공유',
                  onTap: () => context.push(AppRoutes.invite),
                ),
                const _TileDivider(),
                _FeatureTile(
                  icon: Icons.map_outlined,
                  iconColor: AppColors.secondary,
                  title: '가족 지도',
                  subtitle: '가족이 살았던 곳을 지도에 기록',
                  onTap: () => context.push(AppRoutes.familyMap),
                ),
                const _TileDivider(),
                _FeatureTile(
                  icon: Icons.local_florist_outlined,
                  iconColor: AppColors.accent,
                  title: '꽃다발 리포트',
                  subtitle: '올해 보낸 꽃 돌아보기',
                  onTap: () => context.push(AppRoutes.bouquetWrapped),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xxxl),
        ],
      ),
    );
  }
}

// ── 섹션 레이블 ──────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
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

// ── 기능 타일 ────────────────────────────────────────────────────────────────

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: iconColor, size: 24),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: AppColors.textSecondary,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: AppColors.textTertiary,
        size: 20,
      ),
      onTap: onTap,
    );
  }
}

// ── 구분선 ───────────────────────────────────────────────────────────────────

class _TileDivider extends StatelessWidget {
  const _TileDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 0.5,
      indent: AppSpacing.lg + 24 + AppSpacing.lg, // leading icon area
      color: AppColors.glassBorder,
    );
  }
}
