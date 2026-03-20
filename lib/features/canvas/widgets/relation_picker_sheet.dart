import 'package:flutter/material.dart';
import '../../../design/glass/app_glass.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../design/tokens/app_spacing.dart';
import '../../../shared/models/node_model.dart';

/// 관계 타입 선택 바텀시트
class RelationPickerSheet extends StatelessWidget {
  const RelationPickerSheet({
    super.key,
    required this.fromNode,
    required this.toNode,
  });

  final NodeModel fromNode;
  final NodeModel toNode;

  @override
  Widget build(BuildContext context) {
    return GlassBottomSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40, height: 4,
            margin: const EdgeInsets.only(bottom: AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.glassBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Text(
            '${fromNode.name} → ${toNode.name}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '관계를 선택해 주세요',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.lg),
          ...RelationType.values.map(
            (r) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: GlassCard(
                onTap: () => Navigator.of(context).pop(r),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                child: Row(
                  children: [
                    Icon(_relationIcon(r), color: _relationColor(r), size: 22),
                    const SizedBox(width: AppSpacing.md),
                    Text(
                      r.label,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.chevron_right, color: AppColors.textTertiary),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          GlassCard(
            onTap: () => Navigator.of(context).pop(),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg, vertical: AppSpacing.md,
            ),
            child: Center(
              child: Text('취소', style: TextStyle(color: AppColors.textSecondary)),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }

  IconData _relationIcon(RelationType r) => switch (r) {
        RelationType.parent => Icons.arrow_upward,
        RelationType.child => Icons.arrow_downward,
        RelationType.spouse => Icons.favorite_outline,
        RelationType.sibling => Icons.people_outline,
        RelationType.other => Icons.link,
      };

  Color _relationColor(RelationType r) => switch (r) {
        RelationType.parent => AppColors.secondary,
        RelationType.child => AppColors.secondary,
        RelationType.spouse => AppColors.accent,
        RelationType.sibling => AppColors.primary,
        RelationType.other => AppColors.textSecondary,
      };
}
