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
                  style: TextStyle(
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
                  child: Icon(
                    Icons.close,
                    color: AppColors.textSecondary,
                    size: 18,
                  ),
                ),
              ],
            ),
            _buildEraLabels(maxValue),
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
                  style: TextStyle(fontSize: 10, color: AppColors.textTertiary),
                ),
                Text(
                  '${_currentYear}년', // ignore: unnecessary_brace_in_string_interps
                  style: TextStyle(fontSize: 10, color: AppColors.textTertiary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 시대 구분 라벨 (일제·해방·전쟁·산업화·현대)
  Widget _buildEraLabels(double maxValue) {
    const eras = <_Era>[
      _Era('일제', 1900, 1945),
      _Era('해방', 1945, 1950),
      _Era('전쟁', 1950, 1953),
      _Era('산업화', 1953, 1990),
      _Era('현대', 1990, null), // null → _currentYear
    ];

    final totalRange = _currentYear - _minYear; // e.g. 126

    return SizedBox(
      height: 24,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          // Slider has 24px padding on each side by default
          const sliderPadding = 24.0;
          final trackWidth = width - sliderPadding * 2;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              // Era labels
              for (final era in eras)
                _buildEraLabel(
                  era,
                  trackWidth,
                  sliderPadding,
                  totalRange,
                ),
              // Vertical divider lines at era boundaries
              for (final year in [1945, 1950, 1953, 1990])
                _buildDividerLine(
                  year,
                  trackWidth,
                  sliderPadding,
                  totalRange,
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEraLabel(
    _Era era,
    double trackWidth,
    double sliderPadding,
    int totalRange,
  ) {
    final endYear = era.end ?? _currentYear;
    final startOffset = (era.start - _minYear) / totalRange;
    final endOffset = (endYear - _minYear) / totalRange;
    final center = (startOffset + endOffset) / 2;
    final left = sliderPadding + center * trackWidth;

    return Positioned(
      left: left,
      top: 0,
      child: FractionalTranslation(
        translation: const Offset(-0.5, 0),
        child: Text(
          era.label,
          style: TextStyle(
            fontSize: 10,
            color: AppColors.textTertiary,
          ),
        ),
      ),
    );
  }

  Widget _buildDividerLine(
    int year,
    double trackWidth,
    double sliderPadding,
    int totalRange,
  ) {
    final offset = (year - _minYear) / totalRange;
    final left = sliderPadding + offset * trackWidth;

    return Positioned(
      left: left,
      top: 14,
      child: Container(
        width: 1,
        height: 10,
        color: AppColors.textTertiary.withValues(alpha: 0.4),
      ),
    );
  }
}

class _Era {
  const _Era(this.label, this.start, this.end);
  final String label;
  final int start;
  final int? end;
}
