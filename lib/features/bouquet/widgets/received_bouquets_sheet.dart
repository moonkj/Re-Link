import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../design/glass/app_glass.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../design/tokens/app_spacing.dart';
import '../../../shared/models/bouquet_model.dart';
import '../../canvas/providers/canvas_notifier.dart';
import '../providers/bouquet_notifier.dart';

/// 받은 마음 확인 바텀시트 — "나" 노드 클릭 시 표시
class ReceivedBouquetsSheet extends ConsumerStatefulWidget {
  const ReceivedBouquetsSheet({
    super.key,
    required this.myNodeId,
  });

  final String myNodeId;

  @override
  ConsumerState<ReceivedBouquetsSheet> createState() =>
      _ReceivedBouquetsSheetState();
}

class _ReceivedBouquetsSheetState extends ConsumerState<ReceivedBouquetsSheet> {
  @override
  void initState() {
    super.initState();
    // 시트를 열면 모든 마음을 읽음 처리
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(bouquetNotifierProvider.notifier)
          .markAllAsRead(widget.myNodeId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bouquetsAsync =
        ref.watch(receivedBouquetsProvider(widget.myNodeId));
    final nodes = ref.watch(canvasNotifierProvider).nodes;

    return GlassBottomSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 드래그 핸들
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.glassBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // 헤더
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.favorite_rounded,
                color: AppColors.accent,
                size: 22,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '받은 마음',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '가족이 보내준 마음들이에요',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.lg),

          // 마음 목록
          bouquetsAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(AppSpacing.xxl),
              child: Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            error: (e, _) => Padding(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: Center(
                child: Text(
                  '오류가 발생했습니다',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            ),
            data: (bouquets) {
              if (bouquets.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.xxl,
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.favorite_border_rounded,
                        size: 48,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        '아직 받은 마음이 없어요',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '가족에게 먼저 마음을 보내보세요',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                );
              }

              // 최대 높이 제한 (스크롤 가능)
              return ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.4,
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                  ),
                  itemCount: bouquets.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final bouquet = bouquets[index];
                    // 보낸 사람 이름 조회
                    final senderNode = nodes
                        .where((n) => n.id == bouquet.fromNodeId)
                        .firstOrNull;
                    final senderName = senderNode?.name ?? '알 수 없음';

                    return _ReceivedBouquetCard(
                      bouquet: bouquet,
                      senderName: senderName,
                    );
                  },
                ),
              );
            },
          ),

          const SizedBox(height: AppSpacing.lg),

          // 닫기 버튼
          GlassCard(
            onTap: () => Navigator.of(context).pop(),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Center(
              child: Text(
                '닫기',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}

/// 개별 받은 마음 카드
class _ReceivedBouquetCard extends StatelessWidget {
  const _ReceivedBouquetCard({
    required this.bouquet,
    required this.senderName,
  });

  final Bouquet bouquet;
  final String senderName;

  @override
  Widget build(BuildContext context) {
    final date = bouquet.createdAt;
    final dateStr =
        '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
    final timeStr =
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

    return GlassCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          // 이모지
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.accent.withAlpha(20),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                bouquet.flowerType.emoji,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          // 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        senderName,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (!bouquet.isRead)
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(left: AppSpacing.xs),
                        decoration: const BoxDecoration(
                          color: AppColors.accent,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${bouquet.flowerType.label}  ·  $dateStr $timeStr',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
