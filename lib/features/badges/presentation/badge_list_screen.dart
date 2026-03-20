import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../design/glass/app_glass.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../design/tokens/app_spacing.dart';
import '../models/badge_definition.dart';
import '../providers/badge_notifier.dart';
import '../widgets/badge_earned_dialog.dart';

/// 배지 컬렉션 화면 — 20종 배지를 3열 그리드로 표시
class BadgeListScreen extends ConsumerStatefulWidget {
  const BadgeListScreen({super.key});

  @override
  ConsumerState<BadgeListScreen> createState() => _BadgeListScreenState();
}

class _BadgeListScreenState extends ConsumerState<BadgeListScreen> {
  Set<String> _earnedIds = {};

  @override
  void initState() {
    super.initState();
    _loadEarnedIds();
  }

  Future<void> _loadEarnedIds() async {
    final ids =
        await ref.read(badgeNotifierProvider.notifier).getEarnedIds();
    if (mounted) {
      setState(() => _earnedIds = ids);
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncBadges = ref.watch(badgeNotifierProvider);
    final earnedCount = _earnedIds.length;
    final totalCount = BadgeDefinition.values.length;

    return Scaffold(
      backgroundColor: AppColors.bgBase,
      appBar: AppBar(
        title: Text(
          '배지 컬렉션',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      body: asyncBadges.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(
            '배지를 불러올 수 없습니다',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
        data: (_) => ListView(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          children: [
            // 진행률 표시
            _ProgressHeader(
              earnedCount: earnedCount,
              totalCount: totalCount,
            ),
            const SizedBox(height: AppSpacing.xl),
            // 배지 그리드
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: AppSpacing.md,
                mainAxisSpacing: AppSpacing.md,
                childAspectRatio: 0.78,
              ),
              itemCount: BadgeDefinition.values.length,
              itemBuilder: (context, index) {
                final badge = BadgeDefinition.values[index];
                final isEarned = _earnedIds.contains(badge.id);
                return _BadgeCard(
                  badge: badge,
                  isEarned: isEarned,
                  onTap: isEarned
                      ? () => _showBadgeDetail(context, badge)
                      : null,
                );
              },
            ),
            const SizedBox(height: AppSpacing.xxxl),
          ],
        ),
      ),
    );
  }

  void _showBadgeDetail(BuildContext context, BadgeDefinition badge) {
    showDialog<void>(
      context: context,
      builder: (_) => BadgeEarnedDialog(
        badge: badge,
        isReview: true,
      ),
    );
  }
}

// ── 진행률 헤더 ──────────────────────────────────────────────────────────────

class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader({
    required this.earnedCount,
    required this.totalCount,
  });

  final int earnedCount;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    final progress = totalCount > 0 ? earnedCount / totalCount : 0.0;
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '획득 현황',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '$earnedCount / $totalCount 획득',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.glassSurface,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

// ── 배지 카드 ──────────────────────────────────────────────────────────────

class _BadgeCard extends StatelessWidget {
  const _BadgeCard({
    required this.badge,
    required this.isEarned,
    this.onTap,
  });

  final BadgeDefinition badge;
  final bool isEarned;
  final VoidCallback? onTap;

  Color _rarityColor(BadgeRarity rarity) => switch (rarity) {
        BadgeRarity.common => AppColors.textSecondary,
        BadgeRarity.rare => AppColors.secondary,
        BadgeRarity.epic => AppColors.primary,
        BadgeRarity.legendary => AppColors.accent,
      };

  @override
  Widget build(BuildContext context) {
    final rarityColor = _rarityColor(badge.rarity);

    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.md,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 배지 아이콘 + 잠금 오버레이
          SizedBox(
            width: 48,
            height: 48,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 아이콘 (글로우 효과 — 획득 시)
                if (isEarned)
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: rarityColor.withAlpha(80),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                Icon(
                  badge.icon,
                  size: 32,
                  color: isEarned
                      ? rarityColor
                      : AppColors.textDisabled,
                ),
                // 잠금 오버레이
                if (!isEarned)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.bgElevated,
                        border: Border.all(
                          color: AppColors.glassBorder,
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Icons.lock,
                        size: 10,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          // 배지 이름
          Text(
            badge.name,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isEarned
                  ? AppColors.textPrimary
                  : AppColors.textDisabled,
            ),
          ),
          const SizedBox(height: 2),
          // 희귀도 표시
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: isEarned
                  ? rarityColor.withAlpha(25)
                  : Colors.transparent,
            ),
            child: Text(
              badge.rarity.label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w500,
                color: isEarned
                    ? rarityColor
                    : AppColors.textDisabled,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
