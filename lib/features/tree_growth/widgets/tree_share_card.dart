import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';
import '../../../design/tokens/app_colors.dart';
import '../providers/tree_growth_notifier.dart';
import 'growing_tree_painter.dart';

/// 나무 성장 SNS 공유 카드 (1080x1350 인스타 비율)
///
/// RepaintBoundary -> toImage -> PNG -> share_plus 패턴으로
/// 현재 나무 성장 상태를 아트 카드로 생성하여 공유한다.
class TreeShareCard extends ConsumerStatefulWidget {
  const TreeShareCard({super.key});

  @override
  ConsumerState<TreeShareCard> createState() => _TreeShareCardState();
}

class _TreeShareCardState extends ConsumerState<TreeShareCard> {
  final GlobalKey _repaintKey = GlobalKey();
  bool _isSharing = false;

  /// 성장 단계 한글 이름
  static String _stageName(GrowthStage stage) => switch (stage) {
        GrowthStage.sprout => '새싹',
        GrowthStage.sapling => '어린 나무',
        GrowthStage.smallTree => '작은 나무',
        GrowthStage.bigTree => '큰 나무',
        GrowthStage.grandTree => '거대한 나무',
      };

  /// 계절 한글 이름
  static String _seasonName(Season season) => switch (season) {
        Season.spring => '봄',
        Season.summer => '여름',
        Season.autumn => '가을',
        Season.winter => '겨울',
      };

  /// 성장 단계별 나무 크기
  static Size _treeSize(GrowthStage stage) => switch (stage) {
        GrowthStage.sprout => const Size(80, 80),
        GrowthStage.sapling => const Size(130, 190),
        GrowthStage.smallTree => const Size(260, 360),
        GrowthStage.bigTree => const Size(400, 520),
        GrowthStage.grandTree => const Size(540, 650),
      };

  Future<void> _shareCard() async {
    if (_isSharing) return;
    setState(() => _isSharing = true);

    try {
      final boundary = _repaintKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final bytes = byteData.buffer.asUint8List();
      final dir = await getTemporaryDirectory();
      final filename =
          'relink_tree_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File(p.join(dir.path, filename));
      await file.writeAsBytes(bytes);

      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'image/png')],
        subject: 'Re-Link 가족 나무',
      );
    } catch (_) {
      // 공유 실패 시 무시
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(treeGrowthNotifierProvider);

    return asyncState.when(
      data: (state) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── 카드 프리뷰 (1080:1350 = 4:5 비율) ────────────────────────
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AspectRatio(
              aspectRatio: 4 / 5,
              child: RepaintBoundary(
                key: _repaintKey,
                child: _CardContent(
                  stage: state.stage,
                  season: state.season,
                  score: state.score,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── 공유 버튼 ─────────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _isSharing ? null : _shareCard,
              icon: _isSharing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.share, size: 20),
              label: Text(_isSharing ? '공유 준비 중...' : '나무 공유하기'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}

/// 실제 카드 콘텐츠 (RepaintBoundary 내부)
class _CardContent extends StatelessWidget {
  const _CardContent({
    required this.stage,
    required this.season,
    required this.score,
  });

  final GrowthStage stage;
  final Season season;
  final int score;

  @override
  Widget build(BuildContext context) {
    final stageName = _TreeShareCardState._stageName(stage);
    final seasonName = _TreeShareCardState._seasonName(season);
    final treeSize = _TreeShareCardState._treeSize(stage);
    final dateStr = DateFormat('yyyy.MM.dd').format(DateTime.now());

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1A2540),
            Color(0xFF0D1117),
          ],
        ),
      ),
      child: Stack(
        children: [
          // ── 배경 장식 ───────────────────────────────────────────────────
          Positioned(
            top: 40,
            right: 20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withAlpha(15),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            left: -20,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryBlue.withAlpha(10),
              ),
            ),
          ),

          // ── 메인 콘텐츠 ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              children: [
                // 제목
                Text(
                  '우리 가족 나무',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withAlpha(180),
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  stageName,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$seasonName / 성장 점수 $score',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withAlpha(140),
                  ),
                ),

                // 나무 그림
                const Spacer(),
                SizedBox(
                  width: treeSize.width.clamp(80, 280),
                  height: treeSize.height.clamp(80, 360),
                  child: CustomPaint(
                    size: Size(
                      treeSize.width.clamp(80, 280),
                      treeSize.height.clamp(80, 360),
                    ),
                    painter: GrowingTreePainter(
                      stage: stage,
                      season: season,
                    ),
                  ),
                ),
                const Spacer(),

                // 날짜
                Text(
                  dateStr,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withAlpha(120),
                  ),
                ),
                const SizedBox(height: 16),

                // Re-Link 워터마크
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withAlpha(180),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Re-Link',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary.withAlpha(200),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withAlpha(180),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
