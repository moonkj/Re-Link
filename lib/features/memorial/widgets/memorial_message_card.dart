import 'package:flutter/material.dart';
import '../../../core/database/app_database.dart';
import '../../../design/glass/app_glass.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../design/tokens/app_spacing.dart';

/// 개별 추모 메시지 카드 — 부드럽고 차분한 디자인
class MemorialMessageCard extends StatelessWidget {
  const MemorialMessageCard({
    super.key,
    required this.message,
    this.onDelete,
  });

  final MemorialMessagesTableData message;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final date = message.date;
    final dateStr =
        '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: GlassCard(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 메시지 본문
            Text(
              message.message,
              style: TextStyle(
                fontSize: 15,
                color: AppColors.textPrimary,
                height: 1.6,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // 하단: 작성자 + 날짜 + 삭제
            Row(
              children: [
                // 촛불 아이콘
                Icon(
                  Icons.local_fire_department_outlined,
                  color: AppColors.textTertiary.withAlpha(120),
                  size: 14,
                ),
                const SizedBox(width: AppSpacing.xs),

                // 작성자
                if (message.authorName != null &&
                    message.authorName!.isNotEmpty) ...[
                  Text(
                    message.authorName!,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs),
                    child: Text(
                      '·',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ),
                ],

                // 날짜
                Text(
                  dateStr,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textTertiary,
                  ),
                ),

                const Spacer(),

                // 삭제 버튼
                if (onDelete != null)
                  GestureDetector(
                    onTap: onDelete,
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.close,
                        size: 14,
                        color: AppColors.textTertiary.withAlpha(100),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
