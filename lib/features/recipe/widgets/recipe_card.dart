import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/database/app_database.dart';
import '../../../core/utils/haptic_service.dart';
import '../../../design/glass/app_glass.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../design/tokens/app_spacing.dart';

/// 레시피 카드 위젯 -- 탭하면 확장 토글
class RecipeCard extends StatefulWidget {
  const RecipeCard({
    super.key,
    required this.recipe,
    this.nodeName,
    required this.onDelete,
  });

  final RecipesTableData recipe;
  final String? nodeName;
  final VoidCallback onDelete;

  @override
  State<RecipeCard> createState() => _RecipeCardState();
}

class _RecipeCardState extends State<RecipeCard> {
  bool _expanded = false;

  void _toggleExpand() {
    HapticService.light();
    setState(() => _expanded = !_expanded);
  }

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;
    final hasPhoto = recipe.photoPath != null && recipe.photoPath!.isNotEmpty;

    return GlassCard(
      onTap: _toggleExpand,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // -- 사진 영역 -----------------------------------------------
          if (hasPhoto)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              child: Image.file(
                File(recipe.photoPath!),
                width: double.infinity,
                height: 160,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _PhotoPlaceholder(),
              ),
            )
          else
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              child: _PhotoPlaceholder(),
            ),

          // -- 텍스트 영역 ---------------------------------------------
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 제목 + 노드 뱃지
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        recipe.title,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (widget.nodeName != null) ...[
                      const SizedBox(width: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(25),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.primary.withAlpha(60),
                            width: 0.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.person_outline,
                              size: 12,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              widget.nodeName!,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),

                // -- 재료 미리보기 (접힌 상태) --------------------------
                const SizedBox(height: AppSpacing.xs),
                Text(
                  _ingredientPreview(recipe.ingredients),
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                  maxLines: _expanded ? 100 : 2,
                  overflow: TextOverflow.ellipsis,
                ),

                // -- 확장 영역 (재료 전체 + 조리법 + 삭제) --------------
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: _buildExpandedContent(recipe),
                  crossFadeState: _expanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 200),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _ingredientPreview(String ingredients) {
    final items = ingredients
        .split('\n')
        .where((l) => l.trim().isNotEmpty)
        .toList();
    if (items.isEmpty) return '';
    return items.join(', ');
  }

  Widget _buildExpandedContent(RecipesTableData recipe) {
    final steps = recipe.instructions
        .split('\n')
        .where((l) => l.trim().isNotEmpty)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.lg),

        // -- 재료 섹션 ------------------------------------------------
        Text(
          '재료',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.glassSurface,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            recipe.ingredients,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.lg),

        // -- 조리법 섹션 -----------------------------------------------
        Text(
          '만드는 법',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        ...List.generate(steps.length, (i) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withAlpha(25),
                  ),
                  child: Center(
                    child: Text(
                      '${i + 1}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    steps[i],
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),

        const SizedBox(height: AppSpacing.md),

        // -- 등록 날짜 + 공유 + 삭제 ------------------------------------
        Row(
          children: [
            Icon(Icons.access_time, size: 12, color: AppColors.textTertiary),
            const SizedBox(width: 4),
            Text(
              _formatDate(recipe.createdAt),
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textTertiary,
              ),
            ),
            const Spacer(),
            // 공유 버튼
            GestureDetector(
              onTap: () {
                HapticService.light();
                _shareRecipe(recipe);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.share,
                        size: 14, color: AppColors.primary.withAlpha(180)),
                    const SizedBox(width: 4),
                    Text(
                      '공유',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primary.withAlpha(180),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            // 삭제 버튼
            GestureDetector(
              onTap: () {
                HapticService.medium();
                _showDeleteConfirm(context);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.delete_outline,
                        size: 14, color: AppColors.error.withAlpha(180)),
                    const SizedBox(width: 4),
                    Text(
                      '삭제',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.error.withAlpha(180),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _shareRecipe(RecipesTableData recipe) {
    final ingredientSummary = recipe.ingredients
        .split('\n')
        .where((l) => l.trim().isNotEmpty)
        .take(5)
        .join(', ');
    final creatorLine = widget.nodeName != null
        ? '\n만든 사람: ${widget.nodeName}'
        : '';
    final text = '\u{1F373} ${recipe.title}\n\n'
        '재료: $ingredientSummary'
        '$creatorLine\n\n'
        '\u{2014} Re-Link에서 기록한 가족 레시피';
    Share.share(text);
  }

  void _showDeleteConfirm(BuildContext context) {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('레시피 삭제'),
        content: Text('"${widget.recipe.title}"을(를) 삭제할까요?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop(true);
              widget.onDelete();
            },
            child: Text('삭제', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) =>
      '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')}';
}

/// 사진 없을 때 플레이스홀더
class _PhotoPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.glassSurface,
      ),
      child: Center(
        child: Icon(
          Icons.restaurant_outlined,
          size: 40,
          color: AppColors.primary.withAlpha(120),
        ),
      ),
    );
  }
}
