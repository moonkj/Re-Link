import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../design/glass/app_glass.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../design/tokens/app_spacing.dart';
import '../../art_card/presentation/art_card_screen.dart';

/// 탐색 탭 — 뿌리/특별한 기억/성과 허브
class ExploreHubScreen extends StatelessWidget {
  const ExploreHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgBase,
      appBar: AppBar(
        title: Text(
          '탐색',
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
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.pagePadding,
          vertical: AppSpacing.sm,
        ),
        children: [
          // ── 뿌리 섹션 ──
          _SectionLabel(title: '뿌리'),
          const SizedBox(height: AppSpacing.sm),
          GlassCard(
            child: Column(
              children: [
                _FeatureTile(
                  icon: Icons.account_tree_outlined,
                  iconColor: AppColors.secondary,
                  title: '족보 가져오기',
                  subtitle: '세대별 가족 일괄 입력',
                  onTap: () => context.push(AppRoutes.jokbo),
                ),
                const _TileDivider(),
                _FeatureTile(
                  icon: Icons.park_outlined,
                  iconColor: AppColors.primaryBlue,
                  title: '팔고조도',
                  subtitle: '8세대 조상 트리 시각화',
                  onTap: () => context.push(AppRoutes.palgojodo),
                ),
                const _TileDivider(),
                _FeatureTile(
                  icon: Icons.family_restroom,
                  iconColor: AppColors.secondary,
                  title: '성씨 탐색기',
                  subtitle: '한국 성씨 \u00b7 본관 \u00b7 역사 탐색',
                  onTap: () => context.push(AppRoutes.clan),
                ),
                const _TileDivider(),
                _FeatureTile(
                  icon: Icons.auto_stories,
                  iconColor: AppColors.primary,
                  title: '제사 순서 안내',
                  subtitle: '전통 제사/차례 절차 가이드',
                  onTap: () => context.push(AppRoutes.ritualGuide),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // ── 특별한 기억 섹션 ──
          _SectionLabel(title: '특별한 기억'),
          const SizedBox(height: AppSpacing.sm),
          GlassCard(
            child: Column(
              children: [
                _FeatureTile(
                  icon: Icons.lock_clock_outlined,
                  iconColor: AppColors.accent,
                  title: '기억 캡슐',
                  subtitle: '미래의 나에게 보내는 기억',
                  onTap: () => context.push(AppRoutes.capsules),
                ),
                const _TileDivider(),
                _FeatureTile(
                  icon: Icons.mic_outlined,
                  iconColor: AppColors.secondary,
                  title: '보이스 유언',
                  subtitle: '가족에게 남기는 봉인된 음성 메시지',
                  onTap: () => context.push(AppRoutes.voiceLegacy),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // ── 성과 섹션 ──
          _SectionLabel(title: '성과'),
          const SizedBox(height: AppSpacing.sm),
          GlassCard(
            child: Column(
              children: [
                _FeatureTile(
                  icon: Icons.emoji_events_outlined,
                  iconColor: AppColors.primary,
                  title: '배지 컬렉션',
                  subtitle: '가족 기록 활동으로 배지 획득',
                  onTap: () => context.push(AppRoutes.badges),
                ),
                const _TileDivider(),
                _FeatureTile(
                  icon: Icons.auto_awesome,
                  iconColor: AppColors.accent,
                  title: '연말 가족 리뷰',
                  subtitle: '올해의 가족 기억 돌아보기',
                  onTap: () => context.push(AppRoutes.wrapped),
                ),
                const _TileDivider(),
                _FeatureTile(
                  icon: Icons.palette_outlined,
                  iconColor: AppColors.secondary,
                  title: '아트 카드',
                  subtitle: '수채화 \u00b7 미니멀 \u00b7 한지 \u00b7 모던',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ArtCardScreen(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.huge),
        ],
      ),
    );
  }
}

// ── Private Widgets ──────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
      ),
    );
  }
}

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

class _TileDivider extends StatelessWidget {
  const _TileDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 0.5,
      indent: AppSpacing.lg,
      endIndent: AppSpacing.lg,
      color: AppColors.glassBorder,
    );
  }
}
