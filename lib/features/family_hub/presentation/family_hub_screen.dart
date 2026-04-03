import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../design/glass/app_glass.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../design/tokens/app_spacing.dart';
import '../../../shared/widgets/feature_tile.dart';
import '../../../shared/widgets/section_label.dart';
import '../../../shared/widgets/tile_divider.dart';
import '../../../shared/models/user_plan.dart';
import '../../auth/providers/auth_notifier.dart';
import '../../subscription/providers/plan_notifier.dart';
import '../../canvas/widgets/birthday_calendar_section.dart';
import '../../family_sync/providers/family_sync_notifier.dart';

/// 가족 탭 — 가족 생활 기능 허브
class FamilyHubScreen extends ConsumerWidget {
  const FamilyHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authNotifierProvider).valueOrNull;
    final localPlan = ref.watch(planNotifierProvider).valueOrNull ?? UserPlan.free;
    final isFamily = (user?.hasFamilyPlan ?? false) ||
        localPlan == UserPlan.family ||
        localPlan == UserPlan.familyPlus;
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
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        children: [
          // ── 달력 섹션 (생일 + 가족 일정, 헤더에 일정 추가 버튼 포함) ──
          const BirthdayCalendarSection(),
          const SizedBox(height: AppSpacing.xl),

          // ── 클라우드 동기화 섹션 (패밀리 플랜) ─────────────────────
          if (isFamily) ...[
            const SectionLabel(label: '클라우드'),
            const SizedBox(height: AppSpacing.sm),
            const _CloudSyncCard(),
            const SizedBox(height: AppSpacing.xl),
          ] else ...[
            const _CloudUpsellCard(),
            const SizedBox(height: AppSpacing.xl),
          ],

          // ── 일상 섹션 ──────────────────────────────────────────────
          const SectionLabel(label: '일상'),
          const SizedBox(height: AppSpacing.sm),
          GlassCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                FeatureTile(
                  icon: Icons.event_note_outlined,
                  iconColor: AppColors.accent,
                  title: '생일 & 일정',
                  subtitle: '생일과 가족 일정을 한눈에',
                  onTap: () => context.push(AppRoutes.birthday),
                ),
                const TileDivider(),
                FeatureTile(
                  icon: Icons.thermostat_outlined,
                  iconColor: AppColors.accent,
                  title: '온도계',
                  subtitle: '가족에게 얼마나 관심을 기울이고 있는지',
                  onTap: () => context.push(AppRoutes.hyodo),
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
                  icon: Icons.login_rounded,
                  iconColor: AppColors.secondary,
                  title: '초대 코드로 합류',
                  subtitle: '전달받은 코드와 파일로 가족 트리 합류',
                  onTap: () => context.push(AppRoutes.joinFamily),
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
                  title: '마음 리포트',
                  subtitle: '올해 보낸 마음 돌아보기',
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


// ── 클라우드 동기화 카드 (패밀리 플랜 전용) ──────────────────────────────────────

class _CloudSyncCard extends ConsumerWidget {
  const _CloudSyncCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(familySyncNotifierProvider);
    final isSyncing = syncState.status == SyncStatus.syncing;
    final lastSyncAt = syncState.lastSyncAt;

    String syncLabel;
    if (isSyncing) {
      syncLabel = '동기화 중...';
    } else if (lastSyncAt != null) {
      final diff = DateTime.now().difference(lastSyncAt);
      if (diff.inMinutes < 1) {
        syncLabel = '방금 동기화됨';
      } else if (diff.inHours < 1) {
        syncLabel = '${diff.inMinutes}분 전 동기화됨';
      } else {
        syncLabel = '${diff.inHours}시간 전 동기화됨';
      }
    } else {
      syncLabel = '아직 동기화 안 됨';
    }

    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          FeatureTile(
            icon: Icons.group_outlined,
            iconColor: AppColors.primary,
            title: '가족 멤버 관리',
            subtitle: '멤버 초대 · 동기화 상태 확인',
            onTap: () => context.push(AppRoutes.familyMembers),
          ),
          const TileDivider(),
          FeatureTile(
            icon: isSyncing ? Icons.sync : Icons.cloud_done_outlined,
            iconColor: isSyncing ? AppColors.secondary : AppColors.primaryMint,
            title: '클라우드 동기화',
            subtitle: syncLabel,
            onTap: isSyncing
                ? () {}
                : () => ref.read(familySyncNotifierProvider.notifier).sync(),
          ),
        ],
      ),
    );
  }
}

// ── 클라우드 업셀 카드 (무료/플러스 플랜) ────────────────────────────────────────

class _CloudUpsellCard extends StatelessWidget {
  const _CloudUpsellCard();

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.cloud_outlined, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '클라우드 동기화',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '패밀리 플랜에서 가족과 실시간 공유',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          GlassButton(
            onPressed: () => context.push(AppRoutes.subscription),
            child: Text(
              '업그레이드',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
