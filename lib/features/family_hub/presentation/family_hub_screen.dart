import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../design/glass/app_glass.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../design/tokens/app_spacing.dart';
import '../../../shared/widgets/feature_tile.dart';
import '../../../shared/widgets/section_label.dart';
import '../../../shared/widgets/tile_divider.dart';

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
          const SectionLabel(label: '일상'),
          const SizedBox(height: AppSpacing.sm),
          GlassCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                FeatureTile(
                  icon: Icons.cake_outlined,
                  iconColor: AppColors.accent,
                  title: '가족 생일',
                  subtitle: '다가오는 생일 카운트다운',
                  onTap: () => context.push(AppRoutes.birthday),
                ),
                const TileDivider(),
                FeatureTile(
                  icon: Icons.thermostat_outlined,
                  iconColor: AppColors.accent,
                  title: '효도 온도계',
                  subtitle: '가족에게 얼마나 관심을 기울이고 있는지',
                  onTap: () => context.push(AppRoutes.hyodo),
                ),
                const TileDivider(),
                FeatureTile(
                  icon: Icons.menu_book_outlined,
                  iconColor: AppColors.primary,
                  title: '가족 단어장',
                  subtitle: '우리 가족만의 표현 모음',
                  onTap: () => context.push(AppRoutes.glossary),
                ),
                const TileDivider(),
                FeatureTile(
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
          const SectionLabel(label: '공유'),
          const SizedBox(height: AppSpacing.sm),
          GlassCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                FeatureTile(
                  icon: Icons.group_add_outlined,
                  iconColor: AppColors.primary,
                  title: '가족 초대',
                  subtitle: '초대 코드로 가족 트리 공유',
                  onTap: () => context.push(AppRoutes.invite),
                ),
                const TileDivider(),
                FeatureTile(
                  icon: Icons.map_outlined,
                  iconColor: AppColors.secondary,
                  title: '가족 지도',
                  subtitle: '가족이 살았던 곳을 지도에 기록',
                  onTap: () => context.push(AppRoutes.familyMap),
                ),
                const TileDivider(),
                FeatureTile(
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
