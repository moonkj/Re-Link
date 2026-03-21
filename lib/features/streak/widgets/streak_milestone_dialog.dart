import 'package:flutter/material.dart';
import '../../../core/utils/haptic_service.dart';
import '../../../design/glass/app_glass.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../design/tokens/app_spacing.dart';
import '../../../design/motion/app_motion.dart';
import '../providers/streak_notifier.dart';

/// 마일스톤 달성 축하 다이얼로그
/// 7일=⭐, 30일=🌟, 100일=💫, 365일=🏆
class StreakMilestoneDialog extends StatefulWidget {
  const StreakMilestoneDialog({super.key, required this.streak});

  final StreakState streak;

  /// 마일스톤 달성 시 다이얼로그 표시
  static Future<void> showIfMilestone(
    BuildContext context,
    StreakState streak,
  ) async {
    if (!streak.isMilestone) return;
    HapticService.heavy();
    // 약간의 딜레이 후 표시 (저장 완료 피드백이 먼저 보이도록)
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => StreakMilestoneDialog(streak: streak),
    );
  }

  @override
  State<StreakMilestoneDialog> createState() => _StreakMilestoneDialogState();
}

class _StreakMilestoneDialogState extends State<StreakMilestoneDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppMotion.slow,
      vsync: this,
    );
    _scaleAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    _fadeAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final streak = widget.streak;
    final emoji = streak.milestoneEmoji;
    final message = streak.milestoneMessage;

    // 마일스톤별 색상
    final milestoneColor = switch (streak.count) {
      7 => const Color(0xFFFFD54F),   // 금색
      30 => const Color(0xFFFF9800),  // 오렌지
      100 => const Color(0xFFE040FB), // 보라
      365 => const Color(0xFFFFD700), // 골드
      _ => AppColors.primary,
    };

    return FadeTransition(
      opacity: _fadeAnim,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: GlassCard(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xxl,
              vertical: AppSpacing.xxxl,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 이모지 (큰 텍스트)
                Text(
                  emoji,
                  style: const TextStyle(fontSize: 64),
                ),
                const SizedBox(height: AppSpacing.lg),

                // 타이틀
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [
                      milestoneColor,
                      milestoneColor.withAlpha(180),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
                  child: Text(
                    '${streak.count}일 연속 기록!',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // 서브타이틀
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xxl),

                // 확인 버튼
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xxxl,
                      vertical: AppSpacing.md,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          milestoneColor,
                          milestoneColor.withAlpha(180),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '계속하기',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
