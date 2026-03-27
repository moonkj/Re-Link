import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/path_utils.dart';
import '../../../design/glass/app_glass.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../design/tokens/app_spacing.dart';
import '../../../shared/models/memory_model.dart';
import '../../memory/providers/memory_notifier.dart';

/// 두 번째 사진을 선택하기 위한 바텀 시트
/// 동일 노드의 photo 타입 기억 목록을 그리드로 표시
class MemoryPickerSheet extends ConsumerWidget {
  const MemoryPickerSheet({
    super.key,
    required this.nodeId,
    required this.excludeMemoryId,
  });

  final String nodeId;
  final String excludeMemoryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memoriesAsync = ref.watch(memoriesForNodeProvider(nodeId));

    return GlassBottomSheet(
      padding: EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 헤더
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.sm,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '비교할 사진 선택',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Icon(
                    Icons.close,
                    color: AppColors.textSecondary,
                    size: 22,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Text(
              '같은 인물의 사진 중 비교할 사진을 선택하세요.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textTertiary,
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // 사진 그리드
          memoriesAsync.when(
            data: (memories) {
              final photos = memories
                  .where((m) =>
                      m.type == MemoryType.photo &&
                      m.filePath != null &&
                      m.id != excludeMemoryId)
                  .toList();

              if (photos.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(AppSpacing.xxxl),
                  child: Column(
                    children: [
                      Icon(
                        Icons.photo_library_outlined,
                        size: 48,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        '비교할 사진이 없습니다.\n사진을 먼저 추가해 주세요.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return SizedBox(
                height: 320,
                child: GridView.builder(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: photos.length,
                  itemBuilder: (context, index) {
                    final memory = photos[index];
                    return _PhotoGridItem(
                      memory: memory,
                      onTap: () => Navigator.of(context).pop(memory),
                    );
                  },
                ),
              );
            },
            loading: () => Padding(
              padding: const EdgeInsets.all(AppSpacing.xxxl),
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              ),
            ),
            error: (e, _) => Padding(
              padding: const EdgeInsets.all(AppSpacing.xxxl),
              child: Text(
                '사진을 불러오지 못했습니다.',
                style: TextStyle(color: AppColors.error, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoGridItem extends StatelessWidget {
  const _PhotoGridItem({
    required this.memory,
    required this.onTap,
  });

  final MemoryModel memory;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.file(
              File(PathUtils.toAbsolute(memory.filePath!) ?? memory.filePath!),
              fit: BoxFit.cover,
              cacheWidth: 200,
            ),
            // 날짜 오버레이
            if (memory.dateTaken != null)
              Positioned(
                bottom: 4,
                left: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(120),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _shortDate(memory.dateTaken!),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _shortDate(DateTime dt) =>
      '${dt.year.toString().substring(2)}.${dt.month.toString().padLeft(2, '0')}';
}
