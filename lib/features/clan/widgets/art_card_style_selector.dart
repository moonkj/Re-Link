import 'package:flutter/material.dart';

import '../../../core/utils/haptic_service.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../design/tokens/app_spacing.dart';
import 'clan_art_card_painter.dart';

/// 아트 카드 스타일 3종 수평 칩 선택기
///
/// [SnapshotShareScreen]의 _StyleChip 패턴을 따름.
class ArtCardStyleSelector extends StatelessWidget {
  const ArtCardStyleSelector({
    super.key,
    required this.selectedStyle,
    required this.onStyleChanged,
  });

  final ArtCardStyle selectedStyle;
  final ValueChanged<ArtCardStyle> onStyleChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        itemCount: ArtCardStyle.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (context, index) {
          final style = ArtCardStyle.values[index];
          final isSelected = style == selectedStyle;
          return _ArtStyleChip(
            style: style,
            isSelected: isSelected,
            onTap: () {
              HapticService.selection();
              onStyleChanged(style);
            },
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ── 개별 스타일 칩 ──────────────────────────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════════

class _ArtStyleChip extends StatelessWidget {
  const _ArtStyleChip({
    required this.style,
    required this.isSelected,
    required this.onTap,
  });

  final ArtCardStyle style;
  final bool isSelected;
  final VoidCallback onTap;

  /// 미니 프리뷰 배경색
  Color _previewColor() => switch (style) {
        ArtCardStyle.hanji => const Color(0xFFF5E6D3),
        ArtCardStyle.modern => const Color(0xFF6EC6CA),
        ArtCardStyle.inkWash => const Color(0xFFF8F6F2),
      };

  /// 미니 프리뷰 악센트색
  Color _previewAccent() => switch (style) {
        ArtCardStyle.hanji => const Color(0xFF8B6914),
        ArtCardStyle.modern => const Color(0xFFFFFFFF),
        ArtCardStyle.inkWash => const Color(0xFF1A1A1A),
      };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        width: 72,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.glassBorder,
            width: isSelected ? 2 : 1,
          ),
          color: AppColors.bgSurface,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 미니 프리뷰
            Container(
              width: 36,
              height: 28,
              decoration: BoxDecoration(
                color: _previewColor(),
                borderRadius: BorderRadius.circular(3),
                border: Border.all(
                    color: const Color(0x20000000), width: 0.5),
              ),
              child: Center(
                child: Text(
                  '家',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _previewAccent(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              style.label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color:
                    isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
