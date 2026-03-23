import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/utils/path_utils.dart';
import '../../../design/glass/app_glass.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../design/tokens/app_spacing.dart';
import '../providers/birthday_notifier.dart';

/// 생일 카운트다운 카드 — 각 BirthdayEntry를 표시
class BirthdayCountdownCard extends StatelessWidget {
  const BirthdayCountdownCard({
    super.key,
    required this.entry,
    this.onTap,
  });

  final BirthdayEntry entry;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isToday = entry.isToday;

    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          // 아바타
          _Avatar(
            photoPath: entry.photoPath,
            name: entry.nodeName,
            isToday: isToday,
          ),
          const SizedBox(width: AppSpacing.md),

          // 이름 + 나이 + 생년월일
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        entry.nodeName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isToday) ...[
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.auto_awesome,
                        size: 16,
                        color: AppColors.accent,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${entry.turningAge}세 생일',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatDate(entry.birthDate),
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),

          // D-day 배지
          _DdayBadge(daysUntil: entry.daysUntil, isToday: isToday),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.year}.${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')}';
}

// ── 아바타 ──────────────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.photoPath,
    required this.name,
    required this.isToday,
  });

  final String? photoPath;
  final String name;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.glassSurface,
        border: Border.all(
          color: isToday ? AppColors.accent : AppColors.primary,
          width: isToday ? 2.5 : 1.5,
        ),
        image: photoPath != null
            ? DecorationImage(
                image: PathUtils.resolveFileImage(photoPath) ??
                    FileImage(File(photoPath!)),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: photoPath == null
          ? Center(
              child: Text(
                name.isNotEmpty ? name[0] : '?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: isToday ? AppColors.accent : AppColors.primary,
                ),
              ),
            )
          : null,
    );
  }
}

// ── D-day 배지 ─────────────────────────────────────────────────────────────────

class _DdayBadge extends StatelessWidget {
  const _DdayBadge({
    required this.daysUntil,
    required this.isToday,
  });

  final int daysUntil;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final text = isToday ? '오늘!' : 'D-$daysUntil';
    final bgColor = isToday
        ? AppColors.accent
        : daysUntil <= 7
            ? AppColors.tempWarm
            : daysUntil <= 30
                ? AppColors.primary
                : AppColors.glassSurface;
    final textColor = isToday || daysUntil <= 30
        ? Colors.white
        : AppColors.textSecondary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }
}
