import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/haptic_service.dart';
import '../../../design/glass/app_glass.dart';
import '../../../design/motion/app_motion.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../design/tokens/app_spacing.dart';
import '../providers/node_notifier.dart';

/// 온도 단계 데이터
class _TempStage {
  const _TempStage({required this.icon, required this.label, required this.color});
  final IconData icon;
  final String label;
  final Color color;
}

const _stages = [
  _TempStage(icon: Icons.ac_unit, label: '냉담', color: Color(0xFF4FC3F7)),
  _TempStage(icon: Icons.cloud, label: '쌀쌀', color: Color(0xFF81C784)),
  _TempStage(icon: Icons.wb_sunny, label: '보통', color: Color(0xFFFFD54F)),
  _TempStage(icon: Icons.local_fire_department, label: '따뜻', color: Color(0xFFFFB74D)),
  _TempStage(icon: Icons.whatshot, label: '뜨거움', color: Color(0xFFFF7043)),
  _TempStage(icon: Icons.flare, label: '열정', color: Color(0xFFE53935)),
];

/// Vibe Meter 바텀시트 — 6단계 아이콘 선택기 + 애니메이션
class VibeMeterSheet extends ConsumerStatefulWidget {
  const VibeMeterSheet({
    super.key,
    required this.nodeId,
    required this.initialTemperature,
  });

  final String nodeId;
  final int initialTemperature;

  @override
  ConsumerState<VibeMeterSheet> createState() => _VibeMeterSheetState();
}

class _VibeMeterSheetState extends ConsumerState<VibeMeterSheet> {
  late int _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialTemperature.clamp(0, 5);
  }

  void _select(int idx) {
    if (_selected == idx) return;
    HapticService.vibeMeterStep();
    setState(() => _selected = idx);
    ref.read(nodeNotifierProvider.notifier).updateTemperature(widget.nodeId, idx);
  }

  @override
  Widget build(BuildContext context) {
    final stage = _stages[_selected];

    return GlassBottomSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 핸들
          Center(
            child: Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(bottom: AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.glassBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // 현재 온도 표시 (아이콘 + 라벨)
          AnimatedSwitcher(
            duration: AppMotion.vibeMeterStep,
            transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
            child: Column(
              key: ValueKey(_selected),
              children: [
                Icon(stage.icon, color: stage.color, size: 48),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  stage.label,
                  style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w700, color: stage.color,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // 6단계 아이콘 선택기
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(_stages.length, (i) {
              final s = _stages[i];
              final isSelected = _selected == i;
              return GestureDetector(
                onTap: () => _select(i),
                child: AnimatedContainer(
                  duration: AppMotion.vibeMeterStep,
                  curve: AppMotion.standard,
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? s.color.withAlpha(50)
                        : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? s.color : Colors.white24,
                      width: isSelected ? 2.0 : 1.0,
                    ),
                    boxShadow: isSelected
                        ? const [
                            BoxShadow(
                              color: Color(0x40000000),
                              blurRadius: 8,
                              spreadRadius: 0,
                            )
                          ]
                        : null,
                  ),
                  child: AnimatedScale(
                    scale: isSelected ? 1.2 : 1.0,
                    duration: AppMotion.vibeMeterStep,
                    curve: AppMotion.standard,
                    child: Icon(
                      s.icon,
                      color: isSelected ? s.color : Colors.white38,
                      size: 28,
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // 트랙 (시각적 온도 게이지)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: SizedBox(
                height: 6,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Stack(
                      children: [
                        Container(color: Colors.white12, width: constraints.maxWidth),
                        AnimatedContainer(
                          duration: AppMotion.vibeMeterStep,
                          curve: AppMotion.standard,
                          width: constraints.maxWidth * (_selected + 1) / _stages.length,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [_stages[0].color, stage.color],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // 닫기 버튼
          SizedBox(
            width: double.infinity,
            child: PrimaryGlassButton(
              label: '완료',
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}
