import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../design/glass/app_glass.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../design/tokens/app_spacing.dart';
import '../../../design/tokens/badge_colors.dart';
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
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
                  AlwaysStoppedAnimation<Color>(AppColors.primary),
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

  // ── Rarity color (MZ-style from BadgeColors) ─────────────────────────────

  Color _rarityColor(BadgeRarity rarity) =>
      BadgeColors.rarityAccent(rarity);

  // ── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final rarityColor = _rarityColor(badge.rarity);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: isEarned
              ? BadgeColors.earnedGradient(badge.rarity)
              : null,
          color: isEarned ? null : BadgeColors.unearnedBg,
          border: isEarned
              ? BadgeColors.earnedBorder(badge.rarity)
              : Border.all(color: BadgeColors.unearnedBorder, width: 1),
          boxShadow: isEarned
              ? BadgeColors.earnedGlow(badge.rarity)
              : null,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ── 아이콘 영역 (56×56) ──
            SizedBox(
              width: 56,
              height: 56,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 메달리온 배경 (earned only)
                  if (isEarned)
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: BadgeColors.medallionBg(badge.rarity),
                        boxShadow: BadgeColors.earnedGlow(badge.rarity),
                      ),
                    ),
                  // 아이콘
                  Icon(
                    badge.icon,
                    size: 32,
                    color: isEarned
                        ? rarityColor
                        : BadgeColors.unearnedIcon,
                  ),
                  // 잠금 오버레이
                  if (!isEarned)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: BadgeColors.lockBadgeBg,
                        ),
                        child: const Icon(
                          Icons.lock,
                          size: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // ── 배지 이름 ──
            Text(
              badge.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isEarned
                    ? AppColors.textPrimary
                    : BadgeColors.unearnedName,
              ),
            ),
            const SizedBox(height: 2),
            // ── 희귀도 필 (earned only) ──
            if (isEarned)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: rarityColor.withAlpha(30),
                ),
                child: Text(
                  badge.rarity.label,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                    color: rarityColor,
                  ),
                ),
              )
            else
              Text(
                badge.rarity.label,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                  color: BadgeColors.unearnedRarity,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
