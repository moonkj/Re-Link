import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../design/tokens/app_spacing.dart';
import '../../../design/glass/app_glass.dart';
import '../../../core/utils/haptic_service.dart';
import '../../../core/utils/path_utils.dart';
import '../../../shared/models/node_model.dart';
import '../../../shared/models/user_plan.dart';
import '../../subscription/providers/plan_notifier.dart';
import '../../canvas/providers/canvas_notifier.dart';
import '../../canvas/providers/my_node_provider.dart';
import '../models/art_card_config.dart';
import '../widgets/art_tree_painter.dart';
import '../services/art_card_service.dart';

/// 아트 카드 공유 화면 — "나" 기준 4세대 가족트리
class ArtCardScreen extends ConsumerStatefulWidget {
  const ArtCardScreen({super.key});

  @override
  ConsumerState<ArtCardScreen> createState() => _ArtCardScreenState();
}

class _ArtCardScreenState extends ConsumerState<ArtCardScreen> {
  ArtStyle _style = ArtStyle.watercolor;
  bool _isExporting = false;
  final _repaintKey = GlobalKey();

  /// 노드 ID → 미리 로드된 프로필 사진 (dart:ui.Image)
  Map<String, ui.Image> _nodeImages = {};

  /// 이미지 로딩 완료된 노드 photoPath 캐시 (불필요한 재로딩 방지)
  Map<String, String> _loadedPhotoPaths = {};

  /// 현재 로딩 중 여부
  bool _isLoadingImages = false;

  @override
  void initState() {
    super.initState();
    // 첫 프레임 이후 캔버스 데이터 갱신 + 이미지 로딩
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 캔버스 데이터를 최신으로 갱신 (추가한 노드 반영)
      ref.invalidate(canvasNotifierProvider);
      _loadNodeImages();
    });
  }

  @override
  void dispose() {
    // ui.Image 리소스 해제
    for (final img in _nodeImages.values) {
      img.dispose();
    }
    _nodeImages.clear();
    super.dispose();
  }

  /// 노드들의 photoPath에서 dart:ui.Image를 미리 로드
  Future<void> _loadNodeImages() async {
    if (_isLoadingImages) return;
    _isLoadingImages = true;

    try {
      final canvasState = ref.read(canvasNotifierProvider);
      final nodes = canvasState.nodes;

      final newImages = <String, ui.Image>{};
      final newPaths = <String, String>{};

      for (final node in nodes) {
        final path = node.photoPath;
        if (path == null || path.isEmpty) continue;

        // 이미 같은 경로로 로드한 이미지가 있으면 재사용
        if (_loadedPhotoPaths[node.id] == path &&
            _nodeImages.containsKey(node.id)) {
          newImages[node.id] = _nodeImages[node.id]!;
          newPaths[node.id] = path;
          continue;
        }

        // 파일에서 이미지 로드
        final image = await _loadImageFromFile(path);
        if (image != null) {
          newImages[node.id] = image;
          newPaths[node.id] = path;
        }
      }

      // 더 이상 사용하지 않는 이전 이미지 리소스 해제
      for (final entry in _nodeImages.entries) {
        if (!newImages.containsKey(entry.key) ||
            !identical(newImages[entry.key], entry.value)) {
          entry.value.dispose();
        }
      }

      if (mounted) {
        setState(() {
          _nodeImages = newImages;
          _loadedPhotoPaths = newPaths;
        });
      }
    } finally {
      _isLoadingImages = false;
    }
  }

  /// 로컬 파일 경로에서 dart:ui.Image를 로드 (실패 시 null 반환)
  Future<ui.Image?> _loadImageFromFile(String filePath) async {
    try {
      final file = PathUtils.resolveFile(filePath) ?? File(filePath);
      if (!await file.exists()) return null;

      final bytes = await file.readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      codec.dispose();
      return frame.image;
    } catch (_) {
      // 이미지 로드 실패 시 graceful fallback
      return null;
    }
  }

  /// 노드의 photoPath가 변경되었으면 이미지를 재로딩
  void _maybeReloadImages(List<NodeModel> currentNodes) {
    // 현재 노드의 photoPath 맵 구성
    final currentPaths = <String, String>{};
    for (final node in currentNodes) {
      if (node.photoPath != null && node.photoPath!.isNotEmpty) {
        currentPaths[node.id] = node.photoPath!;
      }
    }

    // 기존 로드된 경로와 다르면 재로딩
    if (!_pathMapsEqual(_loadedPhotoPaths, currentPaths)) {
      _loadNodeImages();
    }
  }

  bool _pathMapsEqual(Map<String, String> a, Map<String, String> b) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (a[key] != b[key]) return false;
    }
    return true;
  }

  Future<void> _share() async {
    setState(() => _isExporting = true);
    HapticService.medium();

    try {
      // 한 프레임 대기 — RepaintBoundary가 최신 상태로 렌더링 완료되도록
      await Future.delayed(const Duration(milliseconds: 100));
      if (!mounted) return;

      final file = await ArtCardService.captureToFile(
        repaintKey: _repaintKey,
        pixelRatio: 3.0,
      );

      if (!mounted) return;

      if (file != null) {
        await ArtCardService.shareWithContext(file, context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('이미지 생성에 실패했습니다', style: TextStyle(color: AppColors.textPrimary)),
            backgroundColor: AppColors.bgSurface,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('공유 실패: $e', style: TextStyle(color: AppColors.textPrimary)),
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
    final planAsync = ref.watch(planNotifierProvider);
    final myNodeAsync = ref.watch(myNodeNotifierProvider);
    final isPremium =
        (planAsync.valueOrNull?.index ?? 0) >= UserPlan.plus.index;
    final palette = ArtPalette.forStyle(_style);
    final myNodeId = myNodeAsync.valueOrNull;

    // 노드 목록이 변경되면 이미지 재로딩 트리거
    _maybeReloadImages(canvasState.nodes);

    return Scaffold(
      backgroundColor: AppColors.bgBase,
      appBar: AppBar(
        backgroundColor: AppColors.bgBase,
        centerTitle: true,
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
            onPressed: (myNodeId == null || _isExporting) ? null : _share,
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
                child: myNodeId == null
                    ? _NoMeNodeWarning()
                    : AspectRatio(
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
                                myNodeId: myNodeId,
                                showWatermark: !isPremium,
                                nodeImages: _nodeImages,
                              ),
                              child: const SizedBox.expand(),
                            ),
                          ),
                        ),
                      ),
              ),
            ),
          ),

          // ── 안내 문구 ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.xs,
            ),
            child: Text(
              '* 나를 기준으로 4세대, 최대 20명까지 표시됩니다',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textTertiary,
              ),
            ),
          ),

          // ── 컨트롤 패널 ───────────────────────────────────────────────
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

/// "나" 설정이 안 되어 있을 때 표시하는 경고 위젯
class _NoMeNodeWarning extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.accent.withAlpha(20),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.person_off_outlined,
            size: 40,
            color: AppColors.accent,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          "'나' 설정을 먼저 해주세요",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          '아트 카드는 나를 기준으로\n4대 가족을 보여줍니다.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primary.withAlpha(40),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.info_outline,
                size: 16,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                '캔버스에서 노드를 클릭하여\n"나로 설정"을 선택하세요',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
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
