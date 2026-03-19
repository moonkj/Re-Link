import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../design/tokens/app_spacing.dart';
import '../../../design/glass/app_glass.dart';
import '../providers/canvas_notifier.dart';

/// 캔버스 Time Slider 위젯 (연도별 가족 타임라인 필터)
class TimeSliderWidget extends ConsumerStatefulWidget {
  const TimeSliderWidget({super.key});

  @override
  ConsumerState<TimeSliderWidget> createState() => _TimeSliderWidgetState();
}

class _TimeSliderWidgetState extends ConsumerState<TimeSliderWidget> {
  static const _minYear = 1900;

  int get _currentYear => DateTime.now().year;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(canvasNotifierProvider);
    if (!state.timeSliderVisible) return const SizedBox.shrink();

    final selectedYear = state.timeSliderYear ?? _currentYear;
    final sliderValue = (selectedYear - _minYear).toDouble();
    final maxValue = (_currentYear - _minYear).toDouble();

    return Positioned(
      bottom: 100,
      left: AppSpacing.lg,
      right: AppSpacing.lg,
      child: GlassCard(
        blur: 20,
        opacity: 0.2,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.timeline, color: AppColors.primary, size: 18),
                const SizedBox(width: 8),
                Text(
                  state.timeSliderYear == null ? '전체 기간' : '$selectedYear년',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                // 전체 보기 버튼
                if (state.timeSliderYear != null)
                  GestureDetector(
                    onTap: () => ref
                        .read(canvasNotifierProvider.notifier)
                        .setTimeSliderYear(null),
                    child: const Text(
                      '전체',
                      style: TextStyle(fontSize: 12, color: AppColors.primary),
                    ),
                  ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => ref
                      .read(canvasNotifierProvider.notifier)
                      .toggleTimeSlider(),
                  child: const Icon(
                    Icons.close,
                    color: AppColors.textSecondary,
                    size: 18,
                  ),
                ),
              ],
            ),
            Slider(
              value: sliderValue.clamp(0, maxValue),
              min: 0,
              max: maxValue,
              divisions: _currentYear - _minYear,
              activeColor: AppColors.primary,
              inactiveColor: AppColors.glassSurface,
              onChanged: (v) {
                final year = _minYear + v.round();
                ref
                    .read(canvasNotifierProvider.notifier)
                    .setTimeSliderYear(year);
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_minYear}년', // ignore: unnecessary_brace_in_string_interps
                  style: const TextStyle(fontSize: 10, color: AppColors.textTertiary),
                ),
                Text(
                  '${_currentYear}년', // ignore: unnecessary_brace_in_string_interps
                  style: const TextStyle(fontSize: 10, color: AppColors.textTertiary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
