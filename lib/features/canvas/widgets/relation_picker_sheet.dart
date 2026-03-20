import 'package:flutter/material.dart';
import '../../../design/glass/app_glass.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../design/tokens/app_spacing.dart';
import '../../../shared/models/node_model.dart';

/// 관계 피커 결과: 관계 선택 또는 삭제
sealed class RelationPickerResult {
  const RelationPickerResult();
}

class RelationSelected extends RelationPickerResult {
  const RelationSelected(this.type);
  final RelationType type;
}

class RelationDeleted extends RelationPickerResult {
  const RelationDeleted();
}

/// 관계 타입 선택 바텀시트
class RelationPickerSheet extends StatefulWidget {
  const RelationPickerSheet({
    super.key,
    required this.fromNode,
    required this.toNode,
    this.existingRelation,
  });

  final NodeModel fromNode;
  final NodeModel toNode;
  final RelationType? existingRelation;

  @override
  State<RelationPickerSheet> createState() => _RelationPickerSheetState();
}

class _RelationPickerSheetState extends State<RelationPickerSheet> {
  /// null이면 메인 메뉴, true이면 부모/자녀 서브 메뉴
  bool _showParentChildSub = false;

  @override
  Widget build(BuildContext context) {
    return GlassBottomSheet(
      child: AnimatedSize(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        child: _showParentChildSub
            ? _buildParentChildSubMenu()
            : _buildMainMenu(),
      ),
    );
  }

  Widget _buildMainMenu() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHandle(),
        Text(
          '${widget.fromNode.name} → ${widget.toNode.name}',
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
        // 1) 부모/자녀 (통합)
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: GlassCard(
            onTap: () => setState(() => _showParentChildSub = true),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Row(
              children: [
                Icon(Icons.swap_vert, color: AppColors.secondary, size: 22),
                const SizedBox(width: AppSpacing.md),
                Text(
                  '부모/자녀',
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
        // 2) 배우자
        _buildRelationTile(
          icon: Icons.favorite_outline,
          color: AppColors.accent,
          label: RelationType.spouse.label,
          onTap: () => Navigator.of(context).pop(const RelationSelected(RelationType.spouse)),
        ),
        // 3) 형제/자매
        _buildRelationTile(
          icon: Icons.people_outline,
          color: AppColors.primary,
          label: RelationType.sibling.label,
          onTap: () => Navigator.of(context).pop(const RelationSelected(RelationType.sibling)),
        ),
        // 4) 기타
        _buildRelationTile(
          icon: Icons.link,
          color: AppColors.textSecondary,
          label: RelationType.other.label,
          onTap: () => Navigator.of(context).pop(const RelationSelected(RelationType.other)),
        ),
        // 기존 관계가 있으면 삭제 버튼 표시
        if (widget.existingRelation != null) ...[
          const SizedBox(height: AppSpacing.sm),
          _buildRelationTile(
            icon: Icons.link_off,
            color: AppColors.error,
            label: '연결 삭제',
            onTap: () =>
                Navigator.of(context).pop(const RelationDeleted()),
          ),
        ],
        const SizedBox(height: AppSpacing.sm),
        _buildCancelButton(),
        const SizedBox(height: AppSpacing.md),
      ],
    );
  }

  Widget _buildParentChildSubMenu() {
    final from = widget.fromNode.name;
    final to = widget.toNode.name;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHandle(),
        // 뒤로가기 + 제목
        Row(
          children: [
            GestureDetector(
              onTap: () => setState(() => _showParentChildSub = false),
              child: Icon(
                Icons.arrow_back_ios_new,
                size: 18,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                '부모/자녀 방향 선택',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          '관계 방향을 선택해 주세요',
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.lg),
        // 옵션 1: fromNode는 toNode의 부모 → child 타입 (from=parent, to=child 컨벤션)
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: GlassCard(
            onTap: () => Navigator.of(context).pop(const RelationSelected(RelationType.child)),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Row(
              children: [
                Icon(Icons.arrow_upward, color: AppColors.secondary, size: 22),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    '$from은(는) $to의 부모',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Icon(Icons.chevron_right, color: AppColors.textTertiary),
              ],
            ),
          ),
        ),
        // 옵션 2: fromNode는 toNode의 자녀 → parent 타입 (from=child, to=parent 컨벤션)
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: GlassCard(
            onTap: () => Navigator.of(context).pop(const RelationSelected(RelationType.parent)),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Row(
              children: [
                Icon(Icons.arrow_downward, color: AppColors.secondary, size: 22),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    '$from은(는) $to의 자녀',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Icon(Icons.chevron_right, color: AppColors.textTertiary),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        _buildCancelButton(),
        const SizedBox(height: AppSpacing.md),
      ],
    );
  }

  // ── 공통 위젯 ───────────────────────────────────────────────────────────────

  Widget _buildHandle() {
    return Container(
      width: 40,
      height: 4,
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.glassBorder,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildRelationTile({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: GlassCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: AppSpacing.md),
            Text(
              label,
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
    );
  }

  Widget _buildCancelButton() {
    return GlassCard(
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
    );
  }
}
