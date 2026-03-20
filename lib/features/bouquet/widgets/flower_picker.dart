import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/haptic_service.dart';
import '../../../design/glass/app_glass.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../design/tokens/app_spacing.dart';
import '../../../shared/models/bouquet_model.dart';
import '../providers/bouquet_notifier.dart';

/// 꽃 선택 바텀시트 — 5종 꽃을 그리드로 표시
class FlowerPickerSheet extends ConsumerWidget {
  const FlowerPickerSheet({
    super.key,
    required this.fromNodeId,
    required this.toNodeId,
    required this.toNodeName,
  });

  final String fromNodeId;
  final String toNodeId;
  final String toNodeName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GlassBottomSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 드래그 핸들
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.glassBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // 헤더
          Text(
            '$toNodeName에게 꽃 보내기',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '마음을 담아 꽃을 보내보세요',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // 꽃 그리드 (5개 → 3+2 레이아웃)
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            alignment: WrapAlignment.center,
            children: FlowerType.values.map((flower) {
              return _FlowerCard(
                flower: flower,
                onTap: () => _sendFlower(context, ref, flower),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // 취소 버튼
          GlassCard(
            onTap: () => Navigator.of(context).pop(),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Center(
              child: Text(
                '취소',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }

  Future<void> _sendFlower(
    BuildContext context,
    WidgetRef ref,
    FlowerType flower,
  ) async {
    await ref.read(bouquetNotifierProvider.notifier).sendFlower(
          fromNodeId: fromNodeId,
          toNodeId: toNodeId,
          flowerType: flower,
        );
    await HapticService.light();
    if (!context.mounted) return;
    Navigator.of(context).pop(flower);
  }
}

/// 개별 꽃 카드
class _FlowerCard extends StatelessWidget {
  const _FlowerCard({
    required this.flower,
    required this.onTap,
  });

  final FlowerType flower;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      width: 96,
      height: 96,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            flower.emoji,
            style: const TextStyle(fontSize: 36),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            flower.label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
