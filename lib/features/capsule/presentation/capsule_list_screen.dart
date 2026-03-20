import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart';
import '../../../core/utils/haptic_service.dart';
import '../../../design/glass/app_glass.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../design/tokens/app_spacing.dart';
import '../../../shared/models/memory_model.dart';
import '../../../shared/repositories/capsule_repository.dart';
import '../../../shared/repositories/memory_repository.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../providers/capsule_notifier.dart';
import '../widgets/capsule_card.dart';
import '../widgets/create_capsule_sheet.dart';

/// 기억 캡슐 목록 화면
class CapsuleListScreen extends ConsumerWidget {
  const CapsuleListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final capsulesAsync = ref.watch(allCapsulesProvider);

    return Scaffold(
      backgroundColor: AppColors.bgBase,
      appBar: AppBar(
        title: Text(
          '기억 캡슐',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new,
              color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateSheet(context),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: capsulesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(
            '캡슐을 불러올 수 없습니다.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
        data: (capsules) {
          if (capsules.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.lock_clock_outlined,
              title: '아직 캡슐이 없어요',
              subtitle: '소중한 기억을 담아\n미래의 나에게 선물해 보세요.',
              actionLabel: '첫 캡슐 만들기',
              onAction: () => _showCreateSheet(context),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.pagePadding,
              AppSpacing.lg,
              AppSpacing.pagePadding,
              100, // FAB 아래 여백
            ),
            itemCount: capsules.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, i) {
              final capsule = capsules[i];
              return CapsuleCard(
                capsule: capsule,
                onTap: () => _onCapsuleTap(context, ref, capsule),
              );
            },
          );
        },
      ),
    );
  }

  void _showCreateSheet(BuildContext context) {
    HapticService.light();
    showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CreateCapsuleSheet(),
    );
  }

  void _onCapsuleTap(
    BuildContext context,
    WidgetRef ref,
    CapsulesTableData capsule,
  ) {
    final now = DateTime.now();

    if (capsule.isOpened) {
      // 이미 열린 캡슐 → 내용 보기
      _showOpenedCapsuleDetail(context, ref, capsule);
    } else if (!capsule.openDate.isAfter(now)) {
      // 열 수 있는 캡슐 → 열기 확인
      _showOpenConfirm(context, ref, capsule);
    } else {
      // 잠긴 캡슐 → 안내
      HapticService.light();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${capsule.openDate.year}년 ${capsule.openDate.month}월 ${capsule.openDate.day}일에 열 수 있어요.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// 열기 확인 다이얼로그
  void _showOpenConfirm(
    BuildContext context,
    WidgetRef ref,
    CapsulesTableData capsule,
  ) {
    HapticService.medium();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.auto_awesome, color: AppColors.accent, size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '캡슐을 열까요?',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          '"${capsule.title}" 캡슐을 열면\n다시 봉인할 수 없습니다.',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              '취소',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final success = await ref
                  .read(capsuleNotifierProvider.notifier)
                  .open(capsule.id);
              if (success) {
                HapticService.celebration();
              }
            },
            child: const Text(
              '열기',
              style: TextStyle(
                color: AppColors.accent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 열린 캡슐 상세 보기
  void _showOpenedCapsuleDetail(
    BuildContext context,
    WidgetRef ref,
    CapsulesTableData capsule,
  ) {
    HapticService.light();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _OpenedCapsuleSheet(capsule: capsule),
    );
  }
}

/// 열린 캡슐 내용 바텀시트
class _OpenedCapsuleSheet extends ConsumerWidget {
  const _OpenedCapsuleSheet({required this.capsule});
  final CapsulesTableData capsule;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GlassBottomSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Row(
            children: [
              const Icon(Icons.auto_awesome,
                  color: AppColors.accent, size: 22),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  capsule.title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              // 삭제 버튼
              IconButton(
                icon: Icon(Icons.delete_outline,
                    color: AppColors.error, size: 20),
                onPressed: () => _confirmDelete(context, ref),
              ),
            ],
          ),

          // 메시지
          if (capsule.message != null && capsule.message!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            GlassCard(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.format_quote,
                      color: AppColors.primary, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      capsule.message!,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                        height: 1.6,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),

          // 날짜 정보
          Text(
            '만든 날: ${_formatDate(capsule.createdAt)}',
            style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
          ),
          if (capsule.openedAt != null)
            Text(
              '열린 날: ${_formatDate(capsule.openedAt!)}',
              style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
            ),
          const SizedBox(height: AppSpacing.lg),

          // 포함된 기억 목록
          Text(
            '포함된 기억',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _CapsuleMemories(capsuleId: capsule.id),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          '캡슐 삭제',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          '"${capsule.title}" 캡슐을 삭제할까요?\n포함된 기억은 삭제되지 않습니다.',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('취소',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await ref
                  .read(capsuleNotifierProvider.notifier)
                  .delete(capsule.id);
              if (context.mounted) {
                HapticService.heavy();
                Navigator.of(context).pop(); // 바텀시트 닫기
              }
            },
            child: const Text(
              '삭제',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) =>
      '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')}';
}

/// 캡슐에 포함된 기억 리스트
class _CapsuleMemories extends ConsumerWidget {
  const _CapsuleMemories({required this.capsuleId});
  final String capsuleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<List<CapsuleItemsTableData>>(
      future: ref.read(capsuleRepositoryProvider).getItems(capsuleId),
      builder: (context, itemsSnap) {
        if (itemsSnap.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        final items = itemsSnap.data ?? [];
        if (items.isEmpty) {
          return GlassCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Text(
              '포함된 기억이 없습니다.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          );
        }

        return GlassCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (int i = 0; i < items.length; i++) ...[
                if (i > 0) Divider(color: AppColors.glassBorder, height: 1),
                _MemoryItemTile(memoryId: items[i].memoryId),
              ],
            ],
          ),
        );
      },
    );
  }
}

/// 개별 기억 항목 타일
class _MemoryItemTile extends ConsumerWidget {
  const _MemoryItemTile({required this.memoryId});
  final String memoryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<MemoryModel?>(
      future: ref.read(memoryRepositoryProvider).getById(memoryId),
      builder: (context, snap) {
        final memory = snap.data;
        if (memory == null) {
          return ListTile(
            dense: true,
            leading: Icon(Icons.broken_image_outlined,
                color: AppColors.textTertiary, size: 20),
            title: Text(
              '삭제된 기억',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textTertiary,
                fontStyle: FontStyle.italic,
              ),
            ),
          );
        }

        final IconData icon;
        switch (memory.type) {
          case MemoryType.photo:
            icon = Icons.photo_outlined;
          case MemoryType.voice:
            icon = Icons.mic_outlined;
          case MemoryType.note:
            icon = Icons.note_outlined;
        }

        return ListTile(
          dense: true,
          leading: memory.type == MemoryType.photo &&
                  memory.thumbnailPath != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.file(
                    File(memory.thumbnailPath!),
                    width: 36,
                    height: 36,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 36,
                      height: 36,
                      color: AppColors.glassSurface,
                      child: Icon(icon, color: AppColors.textTertiary, size: 18),
                    ),
                  ),
                )
              : Icon(icon, color: AppColors.primary, size: 20),
          title: Text(
            memory.title ?? memory.type.label,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            '${memory.type.label} · ${_formatDate(memory.createdAt)}',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textTertiary,
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime dt) =>
      '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')}';
}
