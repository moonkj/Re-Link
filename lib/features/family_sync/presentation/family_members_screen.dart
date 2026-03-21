import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../design/tokens/app_spacing.dart';
import '../../../design/glass/app_glass.dart';
import '../providers/family_sync_notifier.dart';
import '../providers/family_members_notifier.dart';

/// 가족 멤버 화면 — 동기화 상태 배너 + 멤버 목록 + 초대 FAB
class FamilyMembersScreen extends ConsumerWidget {
  const FamilyMembersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(familySyncNotifierProvider);
    final membersAsync = ref.watch(familyMembersNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('가족 멤버'),
        actions: [
          IconButton(
            icon: syncState.status == SyncStatus.syncing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.sync_rounded),
            tooltip: '동기화',
            onPressed: syncState.status == SyncStatus.syncing
                ? null
                : () => ref.read(familySyncNotifierProvider.notifier).sync(),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── 동기화 상태 배너 ──────────────────────────────────────────────
          _SyncStatusBanner(syncState: syncState),

          // ── 멤버 목록 ─────────────────────────────────────────────────────
          Expanded(
            child: membersAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.pagePadding),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        size: 48,
                        color: AppColors.error,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        '멤버 목록을 불러오지 못했습니다.',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),
              data: (members) => members.isEmpty
                  ? _EmptyMembersView()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.pagePadding,
                        vertical: AppSpacing.md,
                      ),
                      itemCount: members.length,
                      itemBuilder: (context, index) => _MemberCard(
                        member: members[index],
                        onRemove: () => ref
                            .read(familyMembersNotifierProvider.notifier)
                            .removeMember(members[index].id),
                      ),
                    ),
            ),
          ),

          // ── 하단: 그룹 탈퇴 버튼 ─────────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pagePadding,
                AppSpacing.sm,
                AppSpacing.pagePadding,
                AppSpacing.lg,
              ),
              child: TextButton(
                onPressed: () => _confirmLeaveGroup(context, ref),
                child: const Text(
                  '그룹 탈퇴',
                  style: TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

      // ── FAB: 초대 링크 생성 ──────────────────────────────────────────────
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createAndShareInviteLink(context, ref),
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('초대 링크 생성'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
      ),
    );
  }

  Future<void> _createAndShareInviteLink(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final link = await ref
        .read(familyMembersNotifierProvider.notifier)
        .createInviteLink();
    if (!context.mounted) return;
    if (link == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('초대 링크 생성에 실패했습니다.')),
      );
      return;
    }
    await Share.share(
      'Re-Link 가족 그룹에 초대합니다!\n$link',
      subject: 'Re-Link 가족 초대',
    );
  }

  Future<void> _confirmLeaveGroup(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('그룹 탈퇴'),
        content: const Text('정말 가족 그룹에서 탈퇴하시겠어요?\n탈퇴 후에는 동기화된 데이터에 접근할 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              '탈퇴',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (!context.mounted) return;
    await ref.read(familyMembersNotifierProvider.notifier).leaveGroup();
    if (!context.mounted) return;
    Navigator.of(context).pop();
  }
}

// ── 동기화 상태 배너 ─────────────────────────────────────────────────────────

class _SyncStatusBanner extends StatelessWidget {
  const _SyncStatusBanner({required this.syncState});
  final FamilySyncState syncState;

  @override
  Widget build(BuildContext context) {
    if (syncState.status == SyncStatus.idle) return const SizedBox.shrink();

    final (bgColor, icon, message) = switch (syncState.status) {
      SyncStatus.syncing => (
          const Color(0xFF0EA5E9), // sky-500
          Icons.sync_rounded,
          '동기화 중...',
        ),
      SyncStatus.success => (
          AppColors.success,
          Icons.check_circle_outline_rounded,
          syncState.lastSyncAt != null
              ? '마지막 동기화: ${_formatTime(syncState.lastSyncAt!)}'
              : '동기화 완료',
        ),
      SyncStatus.error => (
          AppColors.error,
          Icons.error_outline_rounded,
          syncState.errorMessage ?? '동기화 실패',
        ),
      SyncStatus.idle => (AppColors.success, Icons.check_circle_outline_rounded, ''),
    };

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pagePadding,
        vertical: AppSpacing.sm,
      ),
      color: bgColor.withValues(alpha: 0.15),
      child: Row(
        children: [
          Icon(icon, size: 16, color: bgColor),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 13,
                color: bgColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inSeconds < 60) return '방금 전';
    if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

// ── 멤버 카드 ────────────────────────────────────────────────────────────────

class _MemberCard extends StatelessWidget {
  const _MemberCard({
    required this.member,
    required this.onRemove,
  });
  final FamilyMember member;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final displayName = member.name ?? member.email ?? '알 수 없음';
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';

    return GlassCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      child: Row(
        children: [
          // 아바타
          CircleAvatar(
            radius: AppSpacing.avatarSm,
            backgroundColor: AppColors.primary.withValues(alpha: 0.15),
            child: Text(
              initial,
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          // 이름/이메일
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      displayName,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        fontSize: 15,
                      ),
                    ),
                    if (member.isOwner) ...[
                      const SizedBox(width: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          '방장',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (member.email != null && member.name != null)
                  Text(
                    member.email!,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),

          // 내보내기(추방) 버튼
          if (!member.isOwner)
            IconButton(
              icon: Icon(
                Icons.person_remove_outlined,
                color: AppColors.error.withValues(alpha: 0.7),
                size: 20,
              ),
              tooltip: '멤버 내보내기',
              onPressed: onRemove,
            ),
        ],
      ),
    );
  }
}

// ── 빈 상태 뷰 ───────────────────────────────────────────────────────────────

class _EmptyMembersView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.group_outlined,
              size: 64,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              '아직 가족 멤버가 없어요',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '초대 링크를 만들어 가족을 초대해보세요.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
