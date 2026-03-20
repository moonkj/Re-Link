import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/utils/haptic_service.dart';
import '../../../design/glass/app_glass.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../design/tokens/app_spacing.dart';
import '../providers/family_map_notifier.dart';

/// 위치 기록 카드 — Glass 스타일
class LocationCard extends StatelessWidget {
  const LocationCard({
    super.key,
    required this.pin,
    this.isSelected = false,
    this.onTap,
    this.onDelete,
  });

  final MapPin pin;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: () {
        HapticService.light();
        onTap?.call();
      },
      padding: const EdgeInsets.all(AppSpacing.lg),
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          // 아바타
          _buildAvatar(),
          const SizedBox(width: AppSpacing.md),

          // 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pin.nodeName,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? AppColors.primaryMint
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        pin.address,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (pin.startYear != null || pin.endYear != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    _yearRangeText(),
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // 삭제 버튼
          if (onDelete != null)
            IconButton(
              icon: Icon(
                Icons.close,
                size: 18,
                color: AppColors.textTertiary,
              ),
              onPressed: () {
                HapticService.light();
                onDelete?.call();
              },
              splashRadius: 18,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 28,
                minHeight: 28,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected
            ? AppColors.primaryMint.withAlpha(30)
            : AppColors.glassSurface,
        border: Border.all(
          color: isSelected ? AppColors.primaryMint : AppColors.glassBorder,
          width: 1.5,
        ),
        image: pin.photoPath != null
            ? DecorationImage(
                image: FileImage(File(pin.photoPath!)),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: pin.photoPath == null
          ? Center(
              child: Text(
                pin.nodeName.isNotEmpty ? pin.nodeName[0] : '?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isSelected
                      ? AppColors.primaryMint
                      : AppColors.textSecondary,
                ),
              ),
            )
          : null,
    );
  }

  String _yearRangeText() {
    if (pin.startYear != null && pin.endYear != null) {
      return '${pin.startYear}년 ~ ${pin.endYear}년';
    } else if (pin.startYear != null) {
      return '${pin.startYear}년 ~';
    } else if (pin.endYear != null) {
      return '~ ${pin.endYear}년';
    }
    return '';
  }
}
