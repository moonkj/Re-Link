import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/utils/path_utils.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../design/tokens/app_spacing.dart';

/// 공유용 Then & Now 카드 (RepaintBoundary 대상)
/// 두 이미지를 나란히 배치하고 라벨 + 날짜 + Re-Link 워터마크 표시
class ThenNowCard extends StatelessWidget {
  const ThenNowCard({
    super.key,
    required this.repaintKey,
    required this.beforeImagePath,
    required this.afterImagePath,
    this.label,
    this.beforeDate,
    this.afterDate,
  });

  final GlobalKey repaintKey;
  final String beforeImagePath;
  final String afterImagePath;
  final String? label;
  final DateTime? beforeDate;
  final DateTime? afterDate;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: repaintKey,
      child: Container(
        width: 360,
        decoration: BoxDecoration(
          color: AppColors.isDark
              ? const Color(0xFF1A1A2E)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(40),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 라벨 헤더
            if (label != null && label!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.sm,
                ),
                child: Text(
                  label!,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

            // 두 이미지 나란히
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  // 과거 사진
                  Expanded(
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: Image.file(
                              PathUtils.resolveFile(beforeImagePath) ?? File(beforeImagePath),
                              fit: BoxFit.cover,
                              cacheWidth: 400,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '그때',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        if (beforeDate != null)
                          Text(
                            _formatDate(beforeDate!),
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.textTertiary,
                            ),
                          ),
                      ],
                    ),
                  ),

                  // 화살표 구분선
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      size: 20,
                      color: AppColors.primary,
                    ),
                  ),

                  // 현재 사진
                  Expanded(
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: Image.file(
                              PathUtils.resolveFile(afterImagePath) ?? File(afterImagePath),
                              fit: BoxFit.cover,
                              cacheWidth: 400,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '지금',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        if (afterDate != null)
                          Text(
                            _formatDate(afterDate!),
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.textTertiary,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Re-Link 워터마크
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.link_rounded,
                    size: 14,
                    color: AppColors.textTertiary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Re-Link',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textTertiary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) =>
      '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')}';
}
