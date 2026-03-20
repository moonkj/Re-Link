import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/haptic_service.dart';
import '../../../design/glass/app_glass.dart';
import '../../../design/motion/app_motion.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../design/tokens/app_spacing.dart';
import '../../../shared/models/temperature_log_model.dart';
import '../providers/temperature_diary_notifier.dart';

/// 온도 일기 빠른 기록 바텀시트
class QuickTempEntry extends ConsumerStatefulWidget {
  const QuickTempEntry({
    super.key,
    required this.nodeId,
    required this.nodeName,
  });

  final String nodeId;
  final String nodeName;

  @override
  ConsumerState<QuickTempEntry> createState() => _QuickTempEntryState();
}

class _QuickTempEntryState extends ConsumerState<QuickTempEntry> {
  int _temperature = 2;
  String? _emotionTag;
  bool _saving = false;

  static const _tempLabels = ['냉담', '쌀쌀', '보통', '따뜻', '뜨거움', '열정'];
  static const _tempIcons = [
    Icons.ac_unit,
    Icons.cloud,
    Icons.wb_sunny,
    Icons.local_fire_department,
    Icons.whatshot,
    Icons.flare,
  ];

  static const _emotionChips = [
    (tag: EmotionTags.joy, label: '기쁨', icon: Icons.sentiment_very_satisfied),
    (tag: EmotionTags.longing, label: '그리움', icon: Icons.favorite_border),
    (tag: EmotionTags.surprise, label: '놀람', icon: Icons.bolt),
    (tag: EmotionTags.love, label: '사랑', icon: Icons.favorite),
    (tag: EmotionTags.sadness, label: '슬픔', icon: Icons.water_drop),
  ];

  Color get _currentTempColor => AppColors.tempColor(_temperature);

  void _onTempChanged(double value) {
    final newTemp = value.round();
    if (newTemp != _temperature) {
      HapticService.vibeMeterStep();
      setState(() => _temperature = newTemp);
    }
  }

  void _onEmotionSelected(String tag) {
    HapticService.selection();
    setState(() {
      _emotionTag = _emotionTag == tag ? null : tag;
    });
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);

    await ref.read(temperatureDiaryNotifierProvider.notifier).addLog(
          nodeId: widget.nodeId,
          temperature: _temperature,
          emotionTag: _emotionTag,
        );

    if (!mounted) return;
    HapticService.memoryAdded();
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return GlassBottomSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── 핸들 ─────────────────────────────────────────────────────
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.glassBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // ── 헤더 ─────────────────────────────────────────────────────
          Text(
            '${widget.nodeName}의 온도 기록',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '오늘의 관계 온도를 남겨보세요',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // ── 온도 아이콘 + 라벨 ───────────────────────────────────────
          AnimatedSwitcher(
            duration: AppMotion.vibeMeterStep,
            transitionBuilder: (child, anim) =>
                ScaleTransition(scale: anim, child: child),
            child: Column(
              key: ValueKey(_temperature),
              children: [
                Icon(
                  _tempIcons[_temperature],
                  color: _currentTempColor,
                  size: 48,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  _tempLabels[_temperature],
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: _currentTempColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── 온도 슬라이더 ────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: SliderTheme(
              data: SliderThemeData(
                activeTrackColor: _currentTempColor,
                inactiveTrackColor: _currentTempColor.withAlpha(40),
                thumbColor: _currentTempColor,
                overlayColor: _currentTempColor.withAlpha(30),
                trackHeight: 6,
                thumbShape: const RoundSliderThumbShape(
                  enabledThumbRadius: 10,
                ),
              ),
              child: Slider(
                value: _temperature.toDouble(),
                min: 0,
                max: 5,
                divisions: 5,
                onChanged: _onTempChanged,
              ),
            ),
          ),

          // ── 슬라이더 라벨 ────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '냉담',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textTertiary,
                  ),
                ),
                Text(
                  '열정',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // ── 감정 태그 ────────────────────────────────────────────────
          Text(
            '감정 태그 (선택)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            alignment: WrapAlignment.center,
            children: _emotionChips.map((chip) {
              final isSelected = _emotionTag == chip.tag;
              return GestureDetector(
                onTap: () => _onEmotionSelected(chip.tag),
                child: AnimatedContainer(
                  duration: AppMotion.fast,
                  curve: AppMotion.standard,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? _currentTempColor.withAlpha(30)
                        : AppColors.glassSurface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? _currentTempColor
                          : AppColors.glassBorder,
                      width: isSelected ? 1.5 : 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        chip.icon,
                        size: 16,
                        color: isSelected
                            ? _currentTempColor
                            : AppColors.textSecondary,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        chip.label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected
                              ? _currentTempColor
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // ── 저장 버튼 ────────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: PrimaryGlassButton(
              label: '기록하기',
              isLoading: _saving,
              onPressed: _saving ? null : _save,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}
