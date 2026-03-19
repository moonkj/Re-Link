import 'package:flutter/material.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../design/tokens/app_spacing.dart';
import '../../../design/glass/app_glass.dart';

/// 무한 캔버스 화면 (Phase 1: genealogy_chart / infinite_canvas 통합 예정)
class CanvasScreen extends StatefulWidget {
  const CanvasScreen({super.key});

  @override
  State<CanvasScreen> createState() => _CanvasScreenState();
}

class _CanvasScreenState extends State<CanvasScreen> {
  final TransformationController _controller = TransformationController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgBase,
      body: Stack(
        children: [
          // 배경 그라디언트
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.5,
                colors: [
                  Color(0xFF1A1040),
                  Color(0xFF0A0A1A),
                ],
              ),
            ),
          ),
          // 무한 캔버스
          InteractiveViewer(
            transformationController: _controller,
            minScale: 0.3,
            maxScale: 3.0,
            boundaryMargin: const EdgeInsets.all(double.infinity),
            child: RepaintBoundary(
              child: SizedBox(
                width: 4000,
                height: 4000,
                child: Stack(
                  children: [
                    // TODO: Phase 1 — 노드 렌더링
                    Center(
                      child: GlassCard(
                        padding: const EdgeInsets.all(AppSpacing.xxl),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.account_tree,
                              size: 48,
                              color: AppColors.primary,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            const Text(
                              '가족 트리를 시작해 보세요',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            const Text(
                              '+ 버튼으로 첫 번째 노드를 추가하세요',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // 상단 앱바
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    GlassCard(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.sm,
                      ),
                      child: const Text(
                        'Re-Link',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const Spacer(),
                    GlassCard(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      onTap: () {},
                      child: const Icon(
                        Icons.search,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    GlassCard(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      onTap: () {},
                      child: const Icon(
                        Icons.person,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // FAB — 노드 추가
          Positioned(
            bottom: AppSpacing.xxl,
            right: AppSpacing.lg,
            child: GestureDetector(
              onTap: _onAddNode,
              child: Container(
                width: AppSpacing.fabSize,
                height: AppSpacing.fabSize,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFF6C63FF), Color(0xFF9C94FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x4D6C63FF),
                      blurRadius: 20,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 28),
              ),
            ),
          ),
          // 캔버스 컨트롤 (줌 리셋)
          Positioned(
            bottom: AppSpacing.xxl,
            left: AppSpacing.lg,
            child: Column(
              children: [
                GlassCard(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  onTap: _resetZoom,
                  child: const Icon(
                    Icons.center_focus_strong,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onAddNode() {
    // TODO: Phase 1 — 노드 추가 바텀시트
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => const GlassBottomSheet(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '노드 추가',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: AppSpacing.lg),
            Text(
              'Phase 1에서 구현 예정',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  void _resetZoom() {
    _controller.value = Matrix4.identity();
  }
}
