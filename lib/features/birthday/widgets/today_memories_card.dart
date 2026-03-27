import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../core/services/widget/today_memory_service.dart';
import '../../../core/utils/haptic_service.dart';
import '../../../design/glass/app_glass.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../design/tokens/app_spacing.dart';

/// "N년 전 오늘" 기억 카드 — 캔버스나 설정 등에 삽입 가능
/// 오늘의 기억이 없으면 SizedBox.shrink() 반환
class TodayMemoriesCard extends ConsumerWidget {
  const TodayMemoriesCard({super.key, this.maxItems = 3});

  /// 최대 표시 항목 수
  final int maxItems;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncMemories = ref.watch(todayMemoriesProvider);

    return asyncMemories.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (memories) {
        if (memories.isEmpty) return const SizedBox.shrink();

        final displayItems = memories.take(maxItems).toList();
        final hasMore = memories.length > maxItems;

        return GlassCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      '이 날의 기억',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Text(
                    '${memories.length}개',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // 기억 항목 리스트
              ...displayItems.map((memory) => _TodayMemoryItem(
                    memory: memory,
                    onTap: () {
                      HapticService.light();
                      context.push(
                        AppRoutes.memoryPath(memory.nodeId),
                        extra: memory.nodeName,
                      );
                    },
                  )),

              // 더보기
              if (hasMore) ...[
                const SizedBox(height: AppSpacing.sm),
                Center(
                  child: GestureDetector(
                    onTap: () {
                      HapticService.light();
                      // 더보기 시 첫 번째 기억의 노드로 이동
                      if (memories.isNotEmpty) {
                        context.push(
                          AppRoutes.memoryPath(memories.first.nodeId),
                          extra: memories.first.nodeName,
                        );
                      }
                    },
                    child: Text(
                      '더보기 (${memories.length - maxItems}개)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                      ),
                    ),
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

// ── 개별 기억 항목 ────────────────────────────────────────────────────────────────

class _TodayMemoryItem extends StatelessWidget {
  const _TodayMemoryItem({
    required this.memory,
    required this.onTap,
  });

  final TodayMemoryData memory;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Row(
          children: [
            // 썸네일 또는 타입 아이콘
            _Thumbnail(memory: memory),
            const SizedBox(width: AppSpacing.md),

            // 제목 + 노드 이름
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    memory.title ?? _typeLabel(memory.type),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    memory.nodeName,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),

            // N년 전 배지
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(25),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                '${memory.yearsAgo}년 전',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _typeLabel(String type) => switch (type) {
        'photo' => '사진',
        'voice' => '음성 메모',
        'note' => '메모',
        _ => '기억',
      };
}

// ── 썸네일 ──────────────────────────────────────────────────────────────────────

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.memory});

  final TodayMemoryData memory;

  @override
  Widget build(BuildContext context) {
    final imagePath = memory.thumbnailPath ?? memory.filePath;
    final isPhoto = memory.type == 'photo' && imagePath != null;

    if (isPhoto) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          File(imagePath!),
          width: 44,
          height: 44,
          fit: BoxFit.cover,
          cacheWidth: 200,
          errorBuilder: (_, __, ___) => _IconThumbnail(type: memory.type),
        ),
      );
    }

    return _IconThumbnail(type: memory.type);
  }
}

class _IconThumbnail extends StatelessWidget {
  const _IconThumbnail({required this.type});

  final String type;

  @override
  Widget build(BuildContext context) {
    final icon = switch (type) {
      'photo' => Icons.photo_outlined,
      'voice' => Icons.mic_outlined,
      'note' => Icons.note_outlined,
      _ => Icons.memory,
    };

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.glassSurface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 22, color: AppColors.primary),
    );
  }
}
