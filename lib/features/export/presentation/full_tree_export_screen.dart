import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/path_utils.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../design/tokens/app_spacing.dart';
import '../../../design/glass/app_glass.dart';
import '../../../shared/models/node_model.dart';
import '../../../core/utils/haptic_service.dart';
import '../../canvas/providers/canvas_notifier.dart';
import '../../canvas/widgets/node_card.dart';
import '../../canvas/widgets/edge_painter.dart';
import '../../tree_growth/widgets/tree_growth_overlay.dart';
import '../services/full_tree_export_service.dart';

/// 전체 족보 저장 화면 — 캔버스 전체를 고해상도 이미지로 캡처하여 공유
class FullTreeExportScreen extends ConsumerStatefulWidget {
  const FullTreeExportScreen({super.key});

  @override
  ConsumerState<FullTreeExportScreen> createState() =>
      _FullTreeExportScreenState();
}

class _FullTreeExportScreenState extends ConsumerState<FullTreeExportScreen> {
  bool _isExporting = false;
  final _repaintKey = GlobalKey();
  final _transformCtrl = TransformationController();
  bool _didAutoFit = false;

  /// 내보내기 해상도 배수 (1x = 원본, 2x = 고해상도)
  double _pixelRatio = 2.0;

  /// 배경색 옵션
  _ExportBg _bgOption = _ExportBg.dark;

  @override
  void dispose() {
    _transformCtrl.dispose();
    super.dispose();
  }

  /// LayoutBuilder constraints로 뷰포트에 맞춤
  void _scheduleAutoFit(double vw, double vh, double cw, double ch) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final scaleX = vw / cw;
      final scaleY = vh / ch;
      final fitScale = (scaleX < scaleY ? scaleX : scaleY) * 0.90;
      final dx = (vw - cw * fitScale) / 2;
      final dy = (vh - ch * fitScale) / 2;

      final m = Matrix4.identity();
      m.storage[0] = fitScale;
      m.storage[5] = fitScale;
      m.storage[10] = 1.0;
      m.storage[12] = dx;
      m.storage[13] = dy;
      _transformCtrl.value = m;
    });
  }

  Future<void> _export() async {
    setState(() => _isExporting = true);
    HapticService.medium();

    try {
      // 한 프레임 대기 — RepaintBoundary 렌더링 완료
      await Future.delayed(const Duration(milliseconds: 150));
      if (!mounted) return;

      final file = await FullTreeExportService.captureToFile(
        repaintKey: _repaintKey,
        pixelRatio: _pixelRatio,
      );

      if (!mounted) return;

      if (file != null) {
        await FullTreeExportService.shareWithContext(file, context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '이미지 생성에 실패했습니다',
              style: TextStyle(color: AppColors.textPrimary),
            ),
            backgroundColor: AppColors.bgSurface,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '내보내기 실패: $e',
              style: TextStyle(color: AppColors.textPrimary),
            ),
            backgroundColor: AppColors.bgSurface,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canvasState = ref.watch(canvasNotifierProvider);
    final nodes = canvasState.nodes;
    final edges = canvasState.edges;

    // 콘텐츠 영역 계산 (노드 위치 기반)
    final positions = nodes.map((n) => Offset(n.positionX, n.positionY)).toList();
    final contentBounds = FullTreeExportService.computeContentBounds(
      nodePositions: positions,
      nodeWidth: kNodeCardWidth,
      nodeHeight: kNodeCardHeight,
      padding: 300.0,
    );

    // 캔버스 크기 결정 — 콘텐츠 기반 or 기본 4000x4000
    final canvasW = contentBounds?.width ?? 4000.0;
    final canvasH = contentBounds?.height ?? 4000.0;
    final offsetX = contentBounds?.left ?? 0.0;
    final offsetY = contentBounds?.top ?? 0.0;

    final bgColor = switch (_bgOption) {
      _ExportBg.dark => const Color(0xFF0D1117),
      _ExportBg.light => const Color(0xFFF5F7FA),
      _ExportBg.transparent => Colors.transparent,
    };

    return Scaffold(
      backgroundColor: AppColors.bgBase,
      appBar: AppBar(
        backgroundColor: AppColors.bgBase,
        title: Text(
          '전체 족보 저장',
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
            onPressed: (nodes.isEmpty || _isExporting) ? null : _export,
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
      body: nodes.isEmpty
          ? _buildEmptyState()
          : Column(
              children: [
                // ── 미리보기 (스크롤/줌 가능) ──────────────────────────
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                    if (!_didAutoFit && nodes.isNotEmpty) {
                      _didAutoFit = true;
                      _scheduleAutoFit(
                        constraints.maxWidth,
                        constraints.maxHeight,
                        canvasW,
                        canvasH,
                      );
                    }
                    return InteractiveViewer(
                    transformationController: _transformCtrl,
                    constrained: false,
                    clipBehavior: Clip.none,
                    minScale: 0.02,
                    maxScale: 2.0,
                    boundaryMargin: const EdgeInsets.all(double.infinity),
                    child: RepaintBoundary(
                      key: _repaintKey,
                      child: Container(
                        width: canvasW,
                        height: canvasH,
                        color: bgColor,
                        child: Stack(
                          clipBehavior: Clip.hardEdge,
                          children: [
                            // 가족 나무 성장 배경 (캔버스 크기에 맞춰 제한)
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              top: 0,
                              child: FittedBox(
                                fit: BoxFit.contain,
                                alignment: Alignment.bottomCenter,
                                child: TreeGrowthOverlay(),
                              ),
                            ),
                            // 관계선 레이어
                            Positioned.fill(
                              child: CustomPaint(
                                painter: EdgePainter(
                                  nodes: _offsetNodes(nodes, offsetX, offsetY),
                                  edges: edges,
                                ),
                              ),
                            ),
                            // 노드 카드들 (캔버스와 동일한 NodeCard 사용)
                            ..._offsetNodes(nodes, offsetX, offsetY).map(
                              (node) => Positioned(
                                left: node.positionX,
                                top: node.positionY,
                                child: _ExportNodeCard(
                                  node: node,
                                  edges: edges,
                                ),
                              ),
                            ),
                            // 워터마크 (하단 우측)
                            Positioned(
                              bottom: 20,
                              right: 20,
                              child: Text(
                                'Re-Link',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: _bgOption == _ExportBg.light
                                      ? AppColors.textTertiary
                                      : Colors.white.withAlpha(60),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                  }),
                ),

                // ── 컨트롤 패널 ─────────────────────────────────────────
                GlassCard(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(24)),
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.xxl,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 정보 행
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 16,
                            color: AppColors.textTertiary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${nodes.length}명 \u00b7 ${(canvasW * _pixelRatio).round()}x${(canvasH * _pixelRatio).round()}px',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // 배경색 선택
                      Text(
                        '배경',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: _ExportBg.values.map((bg) {
                          final selected = _bgOption == bg;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () {
                                HapticService.light();
                                setState(() => _bgOption = bg);
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: selected
                                      ? AppColors.primary.withAlpha(40)
                                      : AppColors.glassSurface,
                                  border: Border.all(
                                    color: selected
                                        ? AppColors.primary
                                        : AppColors.glassBorder,
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
                                        color: bg._previewColor,
                                        border: Border.all(
                                          color: AppColors.glassBorder,
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      bg._label,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: selected
                                            ? FontWeight.w600
                                            : FontWeight.w400,
                                        color: selected
                                            ? AppColors.primary
                                            : AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
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
                        children: [
                          _ResChip(
                            label: '1x',
                            isSelected: _pixelRatio == 1.0,
                            onTap: () => setState(() => _pixelRatio = 1.0),
                          ),
                          const SizedBox(width: 8),
                          _ResChip(
                            label: '2x (추천)',
                            isSelected: _pixelRatio == 2.0,
                            onTap: () => setState(() => _pixelRatio = 2.0),
                          ),
                          const SizedBox(width: 8),
                          _ResChip(
                            label: '3x',
                            isSelected: _pixelRatio == 3.0,
                            onTap: () => setState(() => _pixelRatio = 3.0),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // 내보내기 버튼
                      SizedBox(
                        width: double.infinity,
                        child: PrimaryGlassButton(
                          label: _isExporting ? '생성 중...' : '저장 및 공유',
                          isLoading: _isExporting,
                          onPressed: (nodes.isEmpty || _isExporting)
                              ? null
                              : _export,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  /// 노드 좌표를 콘텐츠 영역 기준으로 오프셋
  List<NodeModel> _offsetNodes(
    List<NodeModel> nodes,
    double offsetX,
    double offsetY,
  ) {
    return nodes
        .map((n) => n.copyWith(
              positionX: n.positionX - offsetX,
              positionY: n.positionY - offsetY,
            ))
        .toList();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_tree_outlined,
            size: 64,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            '가족 트리가 비어있습니다',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '홈 캔버스에서 가족을 추가한 후\n전체 족보를 저장할 수 있어요',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ── 내보내기용 간소화 노드 카드 ─────────────────────────────────────────────

/// 내보내기 전용 노드 카드 (애니메이션 없이 정적 렌더링)
class _ExportNodeCard extends StatelessWidget {
  const _ExportNodeCard({
    required this.node,
    required this.edges,
  });

  final NodeModel node;
  final List<NodeEdge> edges;

  @override
  Widget build(BuildContext context) {
    final isGhost = node.isGhost;
    final tempColor = AppColors.tempColor(node.temperature);
    final ghostLabel = isGhost ? resolveGhostLabel(node, edges) : null;

    return Container(
      width: kNodeCardWidth,
      height: kNodeCardHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isGhost
            ? AppColors.glassSurface.withAlpha(30)
            : AppColors.glassSurface,
        border: Border.all(
          color: isGhost
              ? AppColors.nodeBorderGhost
              : tempColor.withAlpha(120),
          width: isGhost ? 1.0 : 1.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 프로필 사진 또는 아이콘
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isGhost
                  ? AppColors.textDisabled.withAlpha(30)
                  : tempColor.withAlpha(30),
            ),
            child: node.photoPath != null && node.photoPath!.isNotEmpty
                ? ClipOval(
                    child: Image.file(
                      PathUtils.resolveFile(node.photoPath) ?? File(node.photoPath!),
                      fit: BoxFit.cover,
                      width: 44,
                      height: 44,
                      cacheWidth: 200,
                      errorBuilder: (_, e, s) => Icon(
                        Icons.person,
                        size: 24,
                        color: isGhost
                            ? AppColors.textDisabled
                            : tempColor,
                      ),
                    ),
                  )
                : Icon(
                    isGhost ? Icons.help_outline : Icons.person,
                    size: 24,
                    color: isGhost ? AppColors.textDisabled : tempColor,
                  ),
          ),
          const SizedBox(height: 6),
          // 이름
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              isGhost
                  ? (ghostLabel ?? '?')
                  : node.name.isEmpty
                      ? '?'
                      : node.name,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isGhost
                    ? AppColors.textTertiary
                    : AppColors.textPrimary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
          // 닉네임 (있을 때만)
          if (!isGhost && node.nickname != null && node.nickname!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                node.nickname!,
                style: TextStyle(
                  fontSize: 9,
                  color: AppColors.textTertiary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}

// ── 배경 옵션 ────────────────────────────────────────────────────────────────

enum _ExportBg {
  dark,
  light,
  transparent;

  String get _label => switch (this) {
        _ExportBg.dark => '다크',
        _ExportBg.light => '라이트',
        _ExportBg.transparent => '투명',
      };

  Color get _previewColor => switch (this) {
        _ExportBg.dark => const Color(0xFF0D1117),
        _ExportBg.light => const Color(0xFFF5F7FA),
        _ExportBg.transparent => Colors.white,
      };
}

// ── 해상도 칩 ────────────────────────────────────────────────────────────────

class _ResChip extends StatelessWidget {
  const _ResChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticService.light();
        onTap();
      },
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
          label,
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
