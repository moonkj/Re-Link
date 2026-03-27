import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';

import '../../../core/utils/haptic_service.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../design/tokens/app_spacing.dart';
import '../providers/wrapped_notifier.dart';
import '../services/annual_review_service.dart';
import '../widgets/wrapped_slide.dart';

/// 연말 가족 리뷰 — Spotify Wrapped 스타일 풀스크린 슬라이드쇼
class WrappedScreen extends ConsumerStatefulWidget {
  const WrappedScreen({super.key});

  @override
  ConsumerState<WrappedScreen> createState() => _WrappedScreenState();
}

class _WrappedScreenState extends ConsumerState<WrappedScreen>
    with TickerProviderStateMixin {
  final _pageController = PageController();
  final _summaryKey = GlobalKey();
  int _currentPage = 0;
  bool _sharing = false;

  // 슬라이드별 애니메이션 컨트롤러
  late List<AnimationController> _slideAnimControllers;

  static const _totalSlides = 6;

  // 슬라이드별 그라디언트 색상
  static const List<List<Color>> _gradients = [
    // 1. Intro — primary → secondary
    [AppColors.primaryMint, AppColors.primaryBlue],
    // 2. Numbers — purple gradient
    [Color(0xFF667EEA), Color(0xFF764BA2)],
    // 3. Warmest person — accent (coral) gradient
    [Color(0xFFF4845F), Color(0xFFE8525A)],
    // 4. Monthly chart — teal-green
    [Color(0xFF11998E), Color(0xFF38EF7D)],
    // 5. Bouquet — pink gradient
    [Color(0xFFF093FB), Color(0xFFF5576C)],
    // 6. Summary — primary → secondary (matching intro)
    [AppColors.primaryMint, AppColors.primaryBlue],
  ];

  @override
  void initState() {
    super.initState();
    _slideAnimControllers = List.generate(
      _totalSlides,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 800),
      ),
    );
    // 첫 슬라이드 애니메이션 시작
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _slideAnimControllers[0].forward();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (final ctrl in _slideAnimControllers) {
      ctrl.dispose();
    }
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() => _currentPage = page);
    HapticService.selection();
    // 현재 슬라이드 애니메이션 재생
    _slideAnimControllers[page].forward(from: 0.0);
  }

  Future<void> _shareSummary() async {
    if (_sharing) return;
    setState(() => _sharing = true);
    HapticService.medium();

    try {
      final boundary = _summaryKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final bytes = byteData.buffer.asUint8List();
      final dir = await getTemporaryDirectory();
      final filename =
          'relink_wrapped_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File(p.join(dir.path, filename));
      await file.writeAsBytes(bytes);

      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'image/png')],
        subject: 'Re-Link 연말 가족 리뷰',
      );
    } catch (_) {
      // 공유 실패 무시
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncData = ref.watch(wrappedNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: asyncData.when(
        loading: () => Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: AppColors.accent, size: 48),
              const SizedBox(height: AppSpacing.lg),
              Text(
                '데이터를 불러올 수 없습니다',
                style: TextStyle(
                    color: AppColors.textPrimary, fontSize: 16),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('돌아가기',
                    style: TextStyle(color: AppColors.primary)),
              ),
            ],
          ),
        ),
        data: (data) => Stack(
          children: [
            // ── PageView ───────────────────────────────────────────────
            PageView(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              children: [
                _buildIntroSlide(data),
                _buildNumbersSlide(data),
                _buildWarmestSlide(data),
                _buildMonthlyChartSlide(data),
                _buildBouquetSlide(data),
                _buildSummarySlide(data),
              ],
            ),

            // ── 닫기 버튼 ──────────────────────────────────────────────
            Positioned(
              top: MediaQuery.of(context).padding.top + AppSpacing.sm,
              right: AppSpacing.lg,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),

            // ── 도트 인디케이터 ─────────────────────────────────────────
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + AppSpacing.xxl,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _totalSlides,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin:
                        const EdgeInsets.symmetric(horizontal: 4),
                    width: i == _currentPage ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: i == _currentPage
                          ? Colors.white
                          : Colors.white38,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ── 슬라이드 1: 인트로 ───────────────────────────────────────────────────
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildIntroSlide(AnnualReviewData data) {
    final anim = _slideAnimControllers[0];
    return WrappedSlide(
      gradientColors: _gradients[0],
      child: FadeTransition(
        opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.15),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.auto_awesome, color: Colors.white, size: 48),
              const SizedBox(height: AppSpacing.xxl),
              Text(
                '${data.year}년',
                style: const TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -2,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              const Text(
                '우리 가족 이야기',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),
              Text(
                '스와이프하여 시작 >',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withAlpha(180),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ── 슬라이드 2: 숫자 ─────────────────────────────────────────────────────
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildNumbersSlide(AnnualReviewData data) {
    final anim = _slideAnimControllers[1];
    return WrappedSlide(
      gradientColors: _gradients[1],
      child: FadeTransition(
        opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '올해의 기록',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),
              _AnimatedNumber(
                animation: anim,
                value: data.newMemoriesThisYear,
                label: '개의 새로운 기억',
              ),
              const SizedBox(height: AppSpacing.xxl),
              _AnimatedNumber(
                animation: anim,
                value: data.newNodesThisYear,
                label: '명의 새 가족 구성원',
              ),
              const SizedBox(height: AppSpacing.xxl),
              if (data.streakBest > 0)
                _AnimatedNumber(
                  animation: anim,
                  value: data.streakBest,
                  label: '일 연속 기록 달성',
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ── 슬라이드 3: 가장 따뜻한 사람 ──────────────────────────────────────────
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildWarmestSlide(AnnualReviewData data) {
    final anim = _slideAnimControllers[2];
    final hasWarmest =
        data.warmestNodeName != null && data.warmestNodeMemories > 0;

    return WrappedSlide(
      gradientColors: _gradients[2],
      child: FadeTransition(
        opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1.0).animate(
            CurvedAnimation(parent: anim, curve: Curves.elasticOut),
          ),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: AppSpacing.xxxl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '가장 따뜻했던 사람',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white24,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: Center(
                    child: Text(
                      hasWarmest
                          ? data.warmestNodeName![0]
                          : '?',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  hasWarmest ? data.warmestNodeName! : '아직 기록이 없어요',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                if (hasWarmest) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    '${data.warmestNodeMemories}개의 기억을 함께했어요',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withAlpha(200),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ── 슬라이드 4: 월별 차트 ─────────────────────────────────────────────────
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildMonthlyChartSlide(AnnualReviewData data) {
    final anim = _slideAnimControllers[3];
    final maxVal = data.memoryByMonth.values.fold<int>(
      0,
      (a, b) => a > b ? a : b,
    );

    return WrappedSlide(
      gradientColors: _gradients[3],
      child: FadeTransition(
        opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '월별 기억 현황',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              SizedBox(
                height: 200,
                child: AnimatedBuilder(
                  animation: anim,
                  builder: (context, _) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: data.memoryByMonth.entries.map((entry) {
                        final ratio =
                            maxVal > 0 ? entry.value / maxVal : 0.0;
                        final barHeight = 160.0 * ratio * anim.value;
                        final isActive =
                            entry.key == data.mostActiveMonth &&
                                entry.value > 0;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 2),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (entry.value > 0 &&
                                    anim.value > 0.5)
                                  Text(
                                    '${entry.value}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: isActive
                                          ? Colors.white
                                          : Colors.white70,
                                    ),
                                  ),
                                const SizedBox(height: 4),
                                Container(
                                  height: barHeight.clamp(2.0, 160.0),
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.circular(4),
                                    color: isActive
                                        ? Colors.white
                                        : Colors.white54,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  entry.key.replaceAll('월', ''),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isActive
                                        ? Colors.white
                                        : Colors.white60,
                                    fontWeight: isActive
                                        ? FontWeight.w700
                                        : FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
              if (data.mostActiveMonth != null &&
                  maxVal > 0) ...[
                const SizedBox(height: AppSpacing.xl),
                Text(
                  '${data.mostActiveMonth}이 가장 활발했어요!',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ── 슬라이드 5: 꽃다발 ───────────────────────────────────────────────────
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildBouquetSlide(AnnualReviewData data) {
    final anim = _slideAnimControllers[4];
    return WrappedSlide(
      gradientColors: _gradients[4],
      child: FadeTransition(
        opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.85, end: 1.0).animate(
            CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '올해 보낸 마음',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              Text(
                '${data.totalBouquets}',
                style: const TextStyle(
                  fontSize: 80,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -3,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              const Text(
                '송이',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              Text(
                data.totalBouquets > 0
                    ? '소중한 마음을 전했어요'
                    : '내년엔 꽃을 보내보세요!',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withAlpha(200),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ── 슬라이드 6: 요약 + 공유 ──────────────────────────────────────────────
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildSummarySlide(AnnualReviewData data) {
    final anim = _slideAnimControllers[5];
    return WrappedSlide(
      gradientColors: _gradients[5],
      child: FadeTransition(
        opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 캡처 가능 영역
              RepaintBoundary(
                key: _summaryKey,
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.xxxl),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.primaryMint, AppColors.primaryBlue],
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${data.year}년 Re-Link',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      _SummaryRow(
                          label: '새 기억',
                          value: '${data.newMemoriesThisYear}개'),
                      _SummaryRow(
                          label: '새 가족',
                          value: '${data.newNodesThisYear}명'),
                      _SummaryRow(
                          label: '보낸 마음',
                          value: '${data.totalBouquets}개'),
                      if (data.streakBest > 0)
                        _SummaryRow(
                            label: '최장 스트릭',
                            value: '${data.streakBest}일'),
                      if (data.warmestNodeName != null)
                        _SummaryRow(
                            label: '최다 기억',
                            value: data.warmestNodeName!),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        'Re-Link',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withAlpha(150),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),
              const Text(
                '올해도 소중한 기억을\n기록해주셔서 감사합니다',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              GestureDetector(
                onTap: _sharing ? null : _shareSummary,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(40),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: _sharing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primaryBlue,
                          ),
                        )
                      : const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.share,
                                color: AppColors.primaryBlue, size: 20),
                            SizedBox(width: 8),
                            Text(
                              '공유하기',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryBlue,
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
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// ── 서브 위젯 ──────────────────────────────────────────────────────────────
// ══════════════════════════════════════════════════════════════════════════════

/// 애니메이션 숫자 표시 위젯
class _AnimatedNumber extends StatelessWidget {
  const _AnimatedNumber({
    required this.animation,
    required this.value,
    required this.label,
  });

  final Animation<double> animation;
  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final displayValue = (value * animation.value).round();
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$displayValue',
              style: const TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -3,
                height: 1.0,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withAlpha(200),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// 요약 카드 내 행 위젯
class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              color: Colors.white.withAlpha(200),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
