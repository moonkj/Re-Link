import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../design/tokens/app_colors.dart';
import '../providers/tree_growth_notifier.dart';
import 'growing_tree_painter.dart';
import 'tree_share_card.dart';

/// 캔버스 배경에 표시되는 가족 나무 성장 오버레이
///
/// [treeGrowthNotifierProvider]를 구독하여 현재 성장 단계와 계절에 따라
/// 나무를 그린다. 반투명(opacity 0.3)으로 노드를 가리지 않는다.
/// InteractiveViewer 내부 Stack에 Positioned로 배치하여
/// 4000x4000 캔버스 하단 중앙에 위치한다.
class TreeGrowthOverlay extends ConsumerWidget {
  const TreeGrowthOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(treeGrowthNotifierProvider);

    return asyncState.when(
      data: (state) => RepaintBoundary(
        child: Opacity(
          opacity: 0.3,
          child: CustomPaint(
            size: _sizeForStage(state.stage),
            painter: GrowingTreePainter(
              stage: state.stage,
              season: state.season,
            ),
          ),
        ),
      ),
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  /// 성장 단계별 페인터 영역 크기
  Size _sizeForStage(GrowthStage stage) => switch (stage) {
        GrowthStage.sprout => const Size(60, 60),
        GrowthStage.sapling => const Size(100, 150),
        GrowthStage.smallTree => const Size(200, 280),
        GrowthStage.bigTree => const Size(320, 420),
        GrowthStage.grandTree => const Size(500, 600),
      };

  /// 나무 공유 시트를 표시한다 (설정 등에서 호출)
  static void showShareSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const SafeArea(
          child: TreeShareCard(),
        ),
      ),
    );
  }
}
