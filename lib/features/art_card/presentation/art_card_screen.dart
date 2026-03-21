import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../design/tokens/app_spacing.dart';
import '../../../design/glass/app_glass.dart';
import '../../../core/utils/haptic_service.dart';
import '../../../shared/models/user_plan.dart';
import '../../subscription/providers/plan_notifier.dart';
import '../../canvas/providers/canvas_notifier.dart';
import '../models/art_card_config.dart';
import '../widgets/art_tree_painter.dart';
import '../services/art_card_service.dart';

/// 아트 카드 공유 화면
class ArtCardScreen extends ConsumerStatefulWidget {
  const ArtCardScreen({super.key});

  @override
  ConsumerState<ArtCardScreen> createState() => _ArtCardScreenState();
}

class _ArtCardScreenState extends ConsumerState<ArtCardScreen> {
  ArtStyle _style = ArtStyle.watercolor;
  bool _isExporting = false;
  final _repaintKey = GlobalKey();

  Future<void> _share() async {
    setState(() => _isExporting = true);
    HapticService.medium();

    try {
      final file = await ArtCardService.captureToFile(
        repaintKey: _repaintKey,
        pixelRatio: 3.0,
      );

      if (file != null && mounted) {
        await ArtCardService.share(file);
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canvasState = ref.watch(canvasNotifierProvider);
    final planAsync = ref.watch(planNotifierProvider);
    final isPremium = (planAsync.valueOrNull?.index ?? 0) >= UserPlan.plus.index;
    final palette = ArtPalette.forStyle(_style);

    return Scaffold(
      backgroundColor: AppColors.bgBase,
      appBar: AppBar(
        backgroundColor: AppColors.bgBase,
        title: Text(
          '아트 카드',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton.icon(
            onPressed: _isExporting ? null : _share,
            icon: _isExporting
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  )
                : const Icon(Icons.share, size: 18),
            label: const Text('공유'),
            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── 미리보기 ──────────────────────────────────────────────────
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: AspectRatio(
                  aspectRatio: 1.0,
                  child: RepaintBoundary(
                    key: _repaintKey,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: CustomPaint(
                        painter: ArtTreePainter(
                          nodes: canvasState.nodes,
                          edges: canvasState.edges,
                          style: _style,
                          palette: palette,
                          showWatermark: !isPremium,
                        ),
                        child: const SizedBox.expand(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── 컨트롤 패널 ───────────────────────────────────────────────
          GlassCard(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.xxl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '스타일',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    if (!isPremium)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(20),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '플러스: 워터마크 제거',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: ArtStyle.values
                      .map((s) => Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              child: _StyleChip(
                                style: s,
                                isSelected: _style == s,
                                onTap: () {
                                  HapticService.light();
                                  setState(() => _style = s);
                                },
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 스타일 선택 칩
class _StyleChip extends StatelessWidget {
  const _StyleChip({
    required this.style,
    required this.isSelected,
    required this.onTap,
  });

  final ArtStyle style;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = ArtPalette.forStyle(style);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? AppColors.primary.withAlpha(25)
              : Colors.transparent,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.glassBorder,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 미니 프리뷰 색상 (스타일 배경색)
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: palette.background,
                shape: BoxShape.circle,
                border: Border.all(
                  color: palette.nodeStroke.withAlpha(100),
                  width: 1,
                ),
              ),
              child: Icon(style.icon, size: 14, color: palette.nodeStroke),
            ),
            const SizedBox(height: 6),
            Text(
              style.label,
              style: TextStyle(
                fontSize: 11,
                color: isSelected
                    ? AppColors.primary
                    : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
