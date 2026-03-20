import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../design/tokens/app_spacing.dart';
import '../../../design/glass/app_glass.dart';
import '../../../shared/models/bouquet_model.dart';
import '../../../shared/repositories/bouquet_repository.dart';

part 'bouquet_wrapped_screen.g.dart';

/// 연간 꽃다발 데이터 프로바이더
@riverpod
Future<List<Bouquet>> yearlyBouquets(Ref ref) =>
    ref.watch(bouquetRepositoryProvider).getThisYear();

/// 연말 가족 꽃다발 리포트 (Spotify Wrapped 스타일)
class BouquetWrappedScreen extends ConsumerWidget {
  const BouquetWrappedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncBouquets = ref.watch(yearlyBouquetsProvider);

    return Scaffold(
      backgroundColor: AppColors.bgBase,
      body: asyncBouquets.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('데이터를 불러올 수 없습니다')),
        data: (bouquets) => _WrappedPageView(bouquets: bouquets),
      ),
    );
  }
}

class _WrappedPageView extends StatefulWidget {
  const _WrappedPageView({required this.bouquets});
  final List<Bouquet> bouquets;

  @override
  State<_WrappedPageView> createState() => _WrappedPageViewState();
}

class _WrappedPageViewState extends State<_WrappedPageView> {
  final _controller = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bouquets = widget.bouquets;
    final totalCount = bouquets.length;

    // 가장 많이 받은 사람 Top 3
    final receiverCounts = <String, int>{};
    for (final b in bouquets) {
      receiverCounts[b.toNodeId] = (receiverCounts[b.toNodeId] ?? 0) + 1;
    }
    final topReceivers = receiverCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // 가장 많이 보낸 꽃 타입
    final flowerCounts = <FlowerType, int>{};
    for (final b in bouquets) {
      flowerCounts[b.flowerType] = (flowerCounts[b.flowerType] ?? 0) + 1;
    }
    final topFlower = flowerCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // 꽃을 보낸 고유 날짜 수
    final uniqueDays = bouquets
        .map((b) => '${b.date.year}-${b.date.month}-${b.date.day}')
        .toSet()
        .length;

    return Stack(
      children: [
        PageView(
          controller: _controller,
          onPageChanged: (i) => setState(() => _currentPage = i),
          children: [
            _TotalPage(totalCount: totalCount),
            _TopReceiversPage(topReceivers: topReceivers.take(3).toList()),
            _TopFlowerPage(
              topFlower: topFlower.isNotEmpty ? topFlower.first : null,
              totalCount: totalCount,
            ),
            _SummaryPage(uniqueDays: uniqueDays, totalCount: totalCount),
          ],
        ),
        // 닫기 버튼 + 페이지 인디케이터
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
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(Icons.close, color: Colors.white, size: 20),
                  ),
                  const Spacer(),
                  // 페이지 인디케이터
                  Row(
                    children: List.generate(
                      4,
                      (i) => Container(
                        width: i == _currentPage ? 20 : 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: i == _currentPage
                              ? Colors.white
                              : Colors.white.withAlpha(80),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Page 1 — 올해의 꽃
class _TotalPage extends StatelessWidget {
  const _TotalPage({required this.totalCount});
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6C63FF), Color(0xFF48CAE4)],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${DateTime.now().year}년',
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                '$totalCount',
                style: const TextStyle(
                  fontSize: 80,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  height: 1,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              const Text(
                '송이의 꽃을 보냈어요',
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              // 꽃 이모지 산포
              const Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 12,
                children: [
                  Text('\u{1F339}', style: TextStyle(fontSize: 36)),
                  Text('\u{1F337}', style: TextStyle(fontSize: 28)),
                  Text('\u{1F33B}', style: TextStyle(fontSize: 32)),
                  Text('\u{1FAB7}', style: TextStyle(fontSize: 30)),
                  Text('\u{1F338}', style: TextStyle(fontSize: 34)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Page 2 — 가장 많이 받은 사람 Top 3
class _TopReceiversPage extends StatelessWidget {
  const _TopReceiversPage({required this.topReceivers});
  final List<MapEntry<String, int>> topReceivers;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFF6B6B), Color(0xFF6C63FF)],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '가장 많이 꽃을 받은 사람',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.huge),
              if (topReceivers.isEmpty)
                const Text(
                  '아직 기록이 없어요',
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                )
              else
                ...topReceivers.asMap().entries.map((entry) {
                  final rank = entry.key + 1;
                  final count = entry.value.value;
                  final emoji = rank == 1
                      ? '\u{1F451}'
                      : rank == 2
                          ? '\u{1F948}'
                          : '\u{1F949}';
                  final fontSize =
                      rank == 1 ? 48.0 : rank == 2 ? 36.0 : 28.0;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(emoji, style: const TextStyle(fontSize: 28)),
                        const SizedBox(width: AppSpacing.md),
                        Text(
                          '$count송이',
                          style: TextStyle(
                            fontSize: fontSize,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }
}

/// Page 3 — 가장 많이 보낸 꽃
class _TopFlowerPage extends StatelessWidget {
  const _TopFlowerPage({required this.topFlower, required this.totalCount});
  final MapEntry<FlowerType, int>? topFlower;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFF48CAE4), Color(0xFF6C63FF)],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '가장 많이 보낸 꽃',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.huge),
              if (topFlower != null) ...[
                Text(
                  topFlower!.key.emoji,
                  style: const TextStyle(fontSize: 72),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  topFlower!.key.label,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '${topFlower!.value}송이 \u00B7 ${totalCount > 0 ? (topFlower!.value * 100 ~/ totalCount) : 0}%',
                  style: const TextStyle(fontSize: 18, color: Colors.white70),
                ),
              ] else
                const Text(
                  '아직 기록이 없어요',
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Page 4 — 마무리
class _SummaryPage extends StatelessWidget {
  const _SummaryPage({required this.uniqueDays, required this.totalCount});
  final int uniqueDays;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF6C63FF), Color(0xFF1A1A2E)],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '가족에게 마음을 전한',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                '$uniqueDays일',
                style: const TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              Text(
                '총 $totalCount송이의 꽃으로\n소중한 마음을 전했어요',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: AppSpacing.huge),
              const Text(
                '\u{1F338} 내년에도 함께해요 \u{1F338}',
                style: TextStyle(fontSize: 20, color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
