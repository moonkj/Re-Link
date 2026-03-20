import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/data/family_prompts.dart';
import '../../../design/glass/app_glass.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../design/tokens/app_spacing.dart';
import '../../../design/motion/app_motion.dart';
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

  void _onRecord() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '기록할 노드를 선택해 주세요',
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
                    child: const Text(
                      '기록하기',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
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
