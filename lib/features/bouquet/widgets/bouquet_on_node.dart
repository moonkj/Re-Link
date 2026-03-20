import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/bouquet_notifier.dart';

/// 캔버스 노드 위에 표시되는 최근 꽃 오버레이
///
/// 이번 주 보내진 꽃 중 최대 3개 이모지를 표시합니다.
/// Detail/Zoom LOD 레벨에서만 보이도록 부모에서 제어합니다.
class BouquetOnNode extends ConsumerWidget {
  const BouquetOnNode({
    super.key,
    required this.toNodeId,
  });

  final String toNodeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bouquetsAsync = ref.watch(bouquetsThisWeekProvider(toNodeId));

    return bouquetsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (bouquets) {
        if (bouquets.isEmpty) return const SizedBox.shrink();

        // 최근 3개 꽃만 표시
        final recentFlowers = bouquets.take(3).toList();

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xCC000000),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final bouquet in recentFlowers)
                Text(
                  bouquet.flowerType.emoji,
                  style: const TextStyle(fontSize: 12),
                ),
              if (bouquets.length > 3) ...[
                const SizedBox(width: 2),
                Text(
                  '+${bouquets.length - 3}',
                  style: const TextStyle(
                    fontSize: 9,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

/// 꽃 뱃지 카운터 — 이번 주 꽃 수를 표시 (NodeDetailSheet 헤더 등에서 사용)
class BouquetBadge extends ConsumerWidget {
  const BouquetBadge({
    super.key,
    required this.toNodeId,
  });

  final String toNodeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bouquetsAsync = ref.watch(bouquetsThisWeekProvider(toNodeId));

    return bouquetsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (bouquets) {
        if (bouquets.isEmpty) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.all(4),
          decoration: const BoxDecoration(
            color: Color(0xFFE53935),
            shape: BoxShape.circle,
          ),
          constraints: const BoxConstraints(
            minWidth: 16,
            minHeight: 16,
          ),
          child: Text(
            '${bouquets.length}',
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        );
      },
    );
  }
}
