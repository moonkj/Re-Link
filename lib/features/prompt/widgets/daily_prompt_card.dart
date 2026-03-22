import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/data/family_prompts.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/haptic_service.dart';
import '../../../design/glass/app_glass.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../design/tokens/app_spacing.dart';
import '../../../design/motion/app_motion.dart';
import '../../../shared/models/node_model.dart';
import '../../../shared/repositories/node_repository.dart';
import '../providers/daily_prompt_notifier.dart';

/// 데일리 가족 프롬프트 카드
///
/// 캔버스 상단에 오버레이로 표시.
/// dismiss 시 오늘 하루 동안 숨김.
/// "기록하기" 탭 시 스낵바 표시.
class DailyPromptCard extends ConsumerStatefulWidget {
  const DailyPromptCard({super.key});

  @override
  ConsumerState<DailyPromptCard> createState() => _DailyPromptCardState();
}

class _DailyPromptCardState extends ConsumerState<DailyPromptCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _slideController;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: AppMotion.enter,
    ));
    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _dismiss() async {
    await _slideController.reverse();
    if (!mounted) return;
    await ref.read(dailyPromptNotifierProvider.notifier).dismiss();
  }

  Future<void> _onRecord() async {
    final nodes = await ref.read(nodeRepositoryProvider).getAll();
    if (!mounted) return;

    if (nodes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '등록된 가족이 없습니다. 먼저 노드를 추가해 주세요.',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          backgroundColor: AppColors.bgSurface,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    final selected = await showModalBottomSheet<NodeModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _NodePickerSheet(nodes: nodes),
    );

    if (selected != null && mounted) {
      HapticService.selection();
      context.push(AppRoutes.memoryPath(selected.id), extra: selected.name);
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(dailyPromptNotifierProvider);

    return asyncState.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (state) {
        if (state.isDismissed) return const SizedBox.shrink();

        final prompt = state.currentPrompt;
        final categoryIcon =
            promptCategoryIcons[prompt.category] ?? '💬';

        return SlideTransition(
          position: _slideAnimation,
          child: GlassCard(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                // ── 카테고리 아이콘 ──────────────────────────────
                Text(
                  categoryIcon,
                  style: const TextStyle(fontSize: 22),
                ),
                const SizedBox(width: AppSpacing.sm),

                // ── 질문 텍스트 ─────────────────────────────────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '오늘의 질문',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textTertiary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        prompt.question,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),

                // ── 기록하기 버튼 ────────────────────────────────
                GestureDetector(
                  onTap: _onRecord,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs + 2,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primaryMint, AppColors.primaryBlue],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '기록하기',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),

                // ── 닫기 버튼 ────────────────────────────────────
                GestureDetector(
                  onTap: _dismiss,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xs),
                    child: Icon(
                      Icons.close,
                      size: 16,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── 노드 선택 바텀시트 ──────────────────────────────────────────────────────

class _NodePickerSheet extends StatelessWidget {
  const _NodePickerSheet({required this.nodes});
  final List<NodeModel> nodes;

  @override
  Widget build(BuildContext context) {
    return GlassBottomSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '기록할 가족 선택',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '누구에 대한 기억을 남길까요?',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 300),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: nodes.length,
              separatorBuilder: (_, __) =>
                  Divider(color: AppColors.glassBorder, height: 1),
              itemBuilder: (context, i) {
                final node = nodes[i];
                return ListTile(
                  leading: CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.primary.withAlpha(30),
                    child: Text(
                      node.name.isNotEmpty ? node.name[0] : '?',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  title: Text(
                    node.name,
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  subtitle: node.nickname != null
                      ? Text(
                          node.nickname!,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textTertiary,
                          ),
                        )
                      : null,
                  onTap: () => Navigator.of(context).pop(node),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
