import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../design/tokens/app_spacing.dart';
import '../../../design/glass/app_glass.dart';
import '../../../features/subscription/providers/plan_notifier.dart';
import '../../../shared/models/user_plan.dart';
import '../../../core/utils/haptic_service.dart';
import '../services/export_service.dart';

/// Heritage Export 화면 — 가계도 포스터 내보내기
class HeritageExportScreen extends ConsumerStatefulWidget {
  const HeritageExportScreen({super.key});

  @override
  ConsumerState<HeritageExportScreen> createState() =>
      _HeritageExportScreenState();
}

class _HeritageExportScreenState extends ConsumerState<HeritageExportScreen> {
  ExportTemplate _template = ExportTemplate.classic;
  ExportColorTheme _colorTheme = ExportColorTheme.appTheme;
  ExportResolution _resolution = ExportResolution.sns;
  bool _isExporting = false;
  final _repaintKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final planAsync = ref.watch(planNotifierProvider);
    final isPremium = planAsync.valueOrNull == UserPlan.premium;

    return Scaffold(
      backgroundColor: AppColors.bgBase,
      appBar: AppBar(
        backgroundColor: AppColors.bgBase,
        title: Text(
          '가계도 포스터',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
        ),
        actions: [
          TextButton.icon(
            onPressed: _isExporting ? null : _export,
            icon: const Icon(Icons.share, size: 18),
            label: const Text('공유'),
            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── 미리보기 ────────────────────────────────────────────────────
          Expanded(
            child: Center(
              child: RepaintBoundary(
                key: _repaintKey,
                child: _ExportPreview(
                  template: _template,
                  colorTheme: _colorTheme,
                  isPremium: isPremium,
                ),
              ),
            ),
          ),

          // ── 컨트롤 패널 ─────────────────────────────────────────────────
          GlassCard(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 템플릿 선택
                Text(
                  '템플릿',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ExportTemplate.values
                        .map((t) => _TemplateChip(
                              template: t,
                              isSelected: _template == t,
                              onTap: () => setState(() => _template = t),
                            ))
                        .toList(),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // 색상 테마 선택
                Text(
                  '색상 테마',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ExportColorTheme.values
                        .map((ct) => _ColorThemeChip(
                              colorTheme: ct,
                              isSelected: _colorTheme == ct,
                              onTap: () => setState(() => _colorTheme = ct),
                            ))
                        .toList(),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // 해상도 선택
                Text(
                  '해상도',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: ExportResolution.values
                      .map((r) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _ResolutionChip(
                              resolution: r,
                              isSelected: _resolution == r,
                              onTap: () => setState(() => _resolution = r),
                            ),
                          ))
                      .toList(),
                ),
                const SizedBox(height: AppSpacing.lg),

                // 내보내기 버튼
                SizedBox(
                  width: double.infinity,
                  child: PrimaryGlassButton(
                    label: _isExporting ? '생성 중...' : '저장하기',
                    isLoading: _isExporting,
                    onPressed: _isExporting ? null : _export,
                  ),
                ),

                // Premium 안내
                if (!isPremium) ...[
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      '프리미엄에서 워터마크 없이 내보낼 수 있어요',
                      style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _export() async {
    setState(() => _isExporting = true);
    try {
      final file = await ExportService.captureToFile(
        repaintKey: _repaintKey,
        resolution: _resolution,
        pixelRatio: _resolution == ExportResolution.sns ? 2.0 : 3.0,
      );
      if (!mounted) return;
      if (file == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('내보내기에 실패했습니다')),
        );
        return;
      }
      await ExportService.share(file);
      HapticService.heritageExport();
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }
}

/// 포스터 미리보기 (템플릿 × 색상 테마)
class _ExportPreview extends StatelessWidget {
  const _ExportPreview({
    required this.template,
    required this.colorTheme,
    required this.isPremium,
  });

  final ExportTemplate template;
  final ExportColorTheme colorTheme;
  final bool isPremium;

  @override
  Widget build(BuildContext context) {
    // 기본 템플릿 색상
    var (bg, titleColor) = switch (template) {
      ExportTemplate.classic => (const Color(0xFF1E2840), AppColors.primary),
      ExportTemplate.modern => (const Color(0xFF0D1F1A), AppColors.secondary),
      ExportTemplate.minimal => (Colors.white, AppColors.textInverse),
      ExportTemplate.festival => (const Color(0xFF1F0D0D), AppColors.accent),
    };

    // 색상 테마 오버라이드
    switch (colorTheme) {
      case ExportColorTheme.bw:
        bg = const Color(0xFF1A1A1A);
        titleColor = Colors.white;
      case ExportColorTheme.sepia:
        bg = const Color(0xFF3E2723);
        titleColor = const Color(0xFFD7CCC8);
      case ExportColorTheme.custom:
        bg = const Color(0xFF1A0D2E);
        titleColor = const Color(0xFFBB86FC);
      case ExportColorTheme.appTheme:
        break; // 기본 템플릿 색상 유지
    }

    return Container(
      width: 280,
      height: 280,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder, width: 1),
      ),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.account_tree, size: 64, color: titleColor.withAlpha(180)),
                const SizedBox(height: 12),
                Text(
                  'Re-Link',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '가족 가계도',
                  style: TextStyle(
                    fontSize: 13,
                    color: titleColor.withAlpha(160),
                  ),
                ),
              ],
            ),
          ),
          // 워터마크 (비프리미엄)
          if (!isPremium)
            Positioned(
              bottom: 12,
              right: 12,
              child: Text(
                'Re-Link',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withAlpha(80),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TemplateChip extends StatelessWidget {
  const _TemplateChip({
    required this.template,
    required this.isSelected,
    required this.onTap,
  });

  final ExportTemplate template;
  final bool isSelected;
  final VoidCallback onTap;

  static String _label(ExportTemplate t) => switch (t) {
        ExportTemplate.classic => 'Classic',
        ExportTemplate.modern => 'Modern',
        ExportTemplate.minimal => 'Minimal',
        ExportTemplate.festival => 'Festival',
      };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: isSelected
                ? AppColors.primary.withAlpha(40)
                : AppColors.glassSurface,
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.glassBorder,
              width: 1.5,
            ),
          ),
          child: Text(
            _label(template),
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _ColorThemeChip extends StatelessWidget {
  const _ColorThemeChip({
    required this.colorTheme,
    required this.isSelected,
    required this.onTap,
  });

  final ExportColorTheme colorTheme;
  final bool isSelected;
  final VoidCallback onTap;

  static const _previewColors = {
    ExportColorTheme.appTheme: AppColors.primary,
    ExportColorTheme.bw: Colors.white,
    ExportColorTheme.sepia: Color(0xFFD7CCC8),
    ExportColorTheme.custom: Color(0xFFBB86FC),
  };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: isSelected
                ? AppColors.primary.withAlpha(40)
                : AppColors.glassSurface,
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.glassBorder,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _previewColors[colorTheme] ?? AppColors.primary,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                colorTheme.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResolutionChip extends StatelessWidget {
  const _ResolutionChip({
    required this.resolution,
    required this.isSelected,
    required this.onTap,
  });

  final ExportResolution resolution;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: isSelected
              ? AppColors.secondary.withAlpha(40)
              : AppColors.glassSurface,
          border: Border.all(
            color: isSelected ? AppColors.secondary : AppColors.glassBorder,
            width: 1.5,
          ),
        ),
        child: Text(
          resolution.label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? AppColors.secondary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
