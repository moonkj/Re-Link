import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../design/glass/app_glass.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../design/tokens/app_spacing.dart';
import '../../../design/motion/app_motion.dart';
import '../providers/streak_notifier.dart';

/// 스트릭 배지 — 앱바에 표시되는 작은 위젯
/// 🔥 아이콘 + 스트릭 카운트, 탭하면 상세 다이얼로그
class StreakBadge extends ConsumerWidget {
  const StreakBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streakAsync = ref.watch(streakNotifierProvider);

    return streakAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (streak) {
        // 스트릭 0이면 아이콘만 표시 (그레이)
        final hasStreak = streak.count > 0;
        final fireColor = hasStreak
            ? const Color(0xFFFF6B35) // 오렌지 계열
            : AppColors.textTertiary;

        return Tooltip(
          message: '기억 스트릭',
          child: GlassCard(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            onTap: () => _showStreakDetail(context, streak),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 불꽃 아이콘 (스트릭 있으면 그라디언트 효과)
                hasStreak
                    ? ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [
                            Color(0xFFFF6B35), // 오렌지
                            Color(0xFFE8525A), // 레드
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ).createShader(bounds),
                        child: const Icon(
                          Icons.local_fire_department,
                          color: Colors.white,
                          size: 18,
                        ),
                      )
                    : Icon(
                        Icons.local_fire_department,
                        color: fireColor,
                        size: 18,
                      ),
                const SizedBox(width: 3),
                // 카운트 (AnimatedSwitcher로 변경 애니메이션)
                AnimatedSwitcher(
                  duration: AppMotion.fast,
                  transitionBuilder: (child, animation) => ScaleTransition(
                    scale: animation,
                    child: child,
                  ),
                  child: Text(
                    '${streak.count}',
                    key: ValueKey<int>(streak.count),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: hasStreak ? fireColor : AppColors.textTertiary,
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

  void _showStreakDetail(BuildContext context, StreakState streak) {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => _StreakDetailDialog(streak: streak),
    );
  }
}

/// 스트릭 상세 다이얼로그
class _StreakDetailDialog extends StatelessWidget {
  const _StreakDetailDialog({required this.streak});

  final StreakState streak;

  @override
  Widget build(BuildContext context) {
    final hasStreak = streak.count > 0;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: GlassCard(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 불꽃 아이콘 (큰 버전)
            hasStreak
                ? ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [
                        Color(0xFFFF6B35),
                        Color(0xFFE8525A),
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ).createShader(bounds),
                    child: const Icon(
                      Icons.local_fire_department,
                      color: Colors.white,
                      size: 48,
                    ),
                  )
                : Icon(
                    Icons.local_fire_department,
                    color: AppColors.textTertiary,
                    size: 48,
                  ),
            const SizedBox(height: AppSpacing.lg),

            // 스트릭 카운트
            Text(
              hasStreak ? '${streak.count}일 연속' : '스트릭 시작하기',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            // 설명
            Text(
              hasStreak
                  ? streak.isTodayRecorded
                      ? '오늘도 기록 완료! 내일도 이어가세요.'
                      : '오늘 기억을 기록하면 스트릭이 이어져요!'
                  : '매일 기억을 기록하면 스트릭이 쌓여요.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),

            // 프리즈 정보
            if (streak.freezeRemaining > 0) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: AppColors.info.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.ac_unit,
                      color: AppColors.info,
                      size: 16,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      '프리즈 ${streak.freezeRemaining}회 남음',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.info,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],

            // 오늘 기록 상태 표시
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  streak.isTodayRecorded
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: streak.isTodayRecorded
                      ? AppColors.success
                      : AppColors.textTertiary,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  streak.isTodayRecorded ? '오늘 기록 완료' : '오늘 아직 기록 안 함',
                  style: TextStyle(
                    fontSize: 13,
                    color: streak.isTodayRecorded
                        ? AppColors.success
                        : AppColors.textTertiary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // 다음 마일스톤
            if (hasStreak) _NextMilestoneInfo(currentCount: streak.count),

            // 닫기 버튼
            const SizedBox(height: AppSpacing.md),
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Text(
                '닫기',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 다음 마일스톤까지 남은 일수
class _NextMilestoneInfo extends StatelessWidget {
  const _NextMilestoneInfo({required this.currentCount});

  final int currentCount;

  @override
  Widget build(BuildContext context) {
    // 다음 마일스톤 찾기
    int? nextMilestone;
    for (final m in StreakState.milestones) {
      if (m > currentCount) {
        nextMilestone = m;
        break;
      }
    }

    if (nextMilestone == null) {
      // 모든 마일스톤 달성
      return Text(
        'Lv. MAX (모든 마일스톤 달성!)',
        style: TextStyle(
          fontSize: 12,
          color: AppColors.warning,
          fontWeight: FontWeight.w600,
        ),
      );
    }

    final remaining = nextMilestone - currentCount;
    return Text(
      '다음 마일스톤까지 $remaining일',
      style: TextStyle(
        fontSize: 12,
        color: AppColors.textTertiary,
      ),
    );
  }
}
