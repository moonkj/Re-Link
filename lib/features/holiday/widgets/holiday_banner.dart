import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/data/korean_holidays.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/haptic_service.dart';
import '../../../design/glass/app_glass.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../design/tokens/app_spacing.dart';
import '../../../design/motion/app_motion.dart';
import '../providers/holiday_notifier.dart';

/// 한국 명절/기념일 배너
///
/// 캔버스 상단에 오버레이로 표시.
/// - 오늘이 명절: "오늘은 {name}입니다! {message}"
/// - 다가오는 명절 (7일 이내): "{name}까지 D-{days} — {message}"
/// - dismiss 시 같은 명절 기간 동안 재표시 안 함
class HolidayBanner extends ConsumerStatefulWidget {
  const HolidayBanner({super.key});

  @override
  ConsumerState<HolidayBanner> createState() => _HolidayBannerState();
}

class _HolidayBannerState extends ConsumerState<HolidayBanner>
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
    HapticService.light();
    await _slideController.reverse();
    if (!mounted) return;
    await ref.read(holidayNotifierProvider.notifier).dismiss();
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(holidayNotifierProvider);

    return asyncState.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (state) {
        if (!state.hasHoliday) return const SizedBox.shrink();

        final holiday = state.activeHoliday!;
        final isToday = state.todayHoliday != null;

        // 배너 텍스트
        final title = isToday
            ? '오늘은 ${holiday.name}입니다!'
            : '${holiday.name}까지 D-${state.daysUntil}';
        final subtitle = holiday.message;

        // 제사/차례 관련 명절이면 제사 안내 링크 표시
        final showRitualGuide = holiday.type == HolidayType.seollal ||
            holiday.type == HolidayType.chuseok;

        return SlideTransition(
          position: _slideAnimation,
          child: _HolidayBannerCard(
            emoji: holiday.emoji,
            title: title,
            subtitle: subtitle,
            themeColor: holiday.themeColor,
            isToday: isToday,
            onDismiss: _dismiss,
            showRitualGuide: showRitualGuide,
            onRitualGuide: showRitualGuide
                ? () => context.push(AppRoutes.ritualGuide)
                : null,
          ),
        );
      },
    );
  }
}

/// 명절 배너 카드 (Glass 스타일 + 테마 컬러 악센트)
class _HolidayBannerCard extends StatelessWidget {
  const _HolidayBannerCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.themeColor,
    required this.isToday,
    required this.onDismiss,
    this.showRitualGuide = false,
    this.onRitualGuide,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final Color themeColor;
  final bool isToday;
  final VoidCallback onDismiss;
  final bool showRitualGuide;
  final VoidCallback? onRitualGuide;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: themeColor,
              width: 3.0,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              // ── 이모지 ─────────────────────────────────────
              Text(
                emoji,
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: AppSpacing.sm),

              // ── 제목 + 메시지 ────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isToday ? themeColor : AppColors.textPrimary,
                        height: 1.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        height: 1.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (showRitualGuide) ...[
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: onRitualGuide,
                        child: Text(
                          '제사 순서 안내 보기',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: themeColor,
                            decoration: TextDecoration.underline,
                            decorationColor: themeColor,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.xs),

              // ── 닫기 버튼 ────────────────────────────────────
              GestureDetector(
                onTap: onDismiss,
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
      ),
    );
  }
}
