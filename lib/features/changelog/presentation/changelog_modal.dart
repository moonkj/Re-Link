import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design/tokens/app_colors.dart';
import '../../../design/tokens/app_radius.dart';
import '../../../design/tokens/app_spacing.dart';
import '../../../design/tokens/app_typography.dart';
import '../models/changelog_entry.dart';
import '../providers/changelog_notifier.dart';

/// 변경 로그 모달 — 업데이트 후 첫 실행 시 표시
///
/// Glass 스타일 Dialog. 버전 배지 + 변경 항목 + 기여자 + 확인 버튼
class ChangelogModal extends ConsumerWidget {
  const ChangelogModal({
    super.key,
    required this.entry,
  });

  final ChangelogEntry entry;

  /// 변경 로그 모달을 표시
  static Future<void> show(BuildContext context, ChangelogEntry entry) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (_) => ChangelogModal(entry: entry),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final dialogWidth = (screenWidth * 0.88).clamp(300.0, 420.0);

    return Center(
      child: Material(
        color: Colors.transparent,
        child: ClipRRect(
          borderRadius: AppRadius.dialog,
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: isLight ? 24.0 : 32.0,
              sigmaY: isLight ? 24.0 : 32.0,
            ),
            child: Container(
              width: dialogWidth,
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * 0.75,
              ),
              decoration: BoxDecoration(
                borderRadius: AppRadius.dialog,
                color: isLight
                    ? const Color(0xF0FFFFFF)
                    : const Color(0xE60D1117),
                border: Border.all(
                  color: AppColors.glassBorder,
                  width: 1.0,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 32,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── 헤더: 버전 배지 + 제목 ──────────────────────────────
                  _Header(entry: entry),

                  // ── 변경 항목 리스트 ─────────────────────────────────────
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xl,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: AppSpacing.sm),
                          ...entry.changes.map(
                            (item) => _ChangeItemTile(item: item),
                          ),
                          // ── 기여자 섹션 ─────────────────────────────────
                          if (entry.contributors.isNotEmpty) ...[
                            const SizedBox(height: AppSpacing.lg),
                            _ContributorSection(
                              contributors: entry.contributors,
                            ),
                          ],
                          const SizedBox(height: AppSpacing.sm),
                        ],
                      ),
                    ),
                  ),

                  // ── 확인 버튼 ─────────────────────────────────────────
                  _DismissButton(
                    onPressed: () async {
                      await ref
                          .read(changelogNotifierProvider.notifier)
                          .markAsSeen(entry.version);
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── 헤더 위젯 ────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.entry});
  final ChangelogEntry entry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.xxl,
        AppSpacing.xl,
        AppSpacing.sm,
      ),
      child: Column(
        children: [
          // 업데이트 아이콘
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColors.primaryMint, AppColors.primaryBlue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // 버전 배지
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              borderRadius: AppRadius.chipRadius,
              color: AppColors.primaryMint.withAlpha(30),
              border: Border.all(
                color: AppColors.primaryMint.withAlpha(80),
                width: 1.0,
              ),
            ),
            child: Text(
              'v${entry.version}',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.primaryMint,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // 제목
          Text(
            entry.title,
            style: AppTypography.t3.copyWith(
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),

          // 날짜
          Text(
            entry.date,
            style: AppTypography.t6.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── 변경 항목 타일 ──────────────────────────────────────────────────────────

class _ChangeItemTile extends StatelessWidget {
  const _ChangeItemTile({required this.item});
  final ChangeItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs + 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 타입별 아이콘
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _typeColor.withAlpha(25),
            ),
            child: Icon(
              _typeIcon,
              size: 16,
              color: _typeColor,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          // 텍스트
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                item.text,
                style: AppTypography.t5.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color get _typeColor => switch (item.type) {
        'feature' => AppColors.success,
        'fix' => AppColors.error,
        'improvement' => AppColors.info,
        _ => AppColors.textSecondary,
      };

  IconData get _typeIcon => switch (item.type) {
        'feature' => Icons.add_circle_outline,
        'fix' => Icons.build_circle_outlined,
        'improvement' => Icons.trending_up,
        _ => Icons.circle_outlined,
      };
}

// ── 기여자 섹션 ──────────────────────────────────────────────────────────────

class _ContributorSection extends StatelessWidget {
  const _ContributorSection({required this.contributors});
  final List<Contributor> contributors;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: AppRadius.radiusMd,
        color: isLight
            ? const Color(0x0A000000)
            : const Color(0x0AFFFFFF),
        border: Border.all(
          color: isLight
              ? const Color(0x10000000)
              : const Color(0x10FFFFFF),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.favorite,
                size: 16,
                color: AppColors.accentWarm,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '공동 제작자',
                style: AppTypography.labelLarge.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: contributors.map((c) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  borderRadius: AppRadius.chipRadius,
                  gradient: const LinearGradient(
                    colors: [
                      Color(0x20FFD700),
                      Color(0x20FF9970),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: const Color(0x40FFD700),
                    width: 1.0,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star,
                      size: 14,
                      color: Color(0xFFFFD700),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      c.name,
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ── 확인 버튼 ────────────────────────────────────────────────────────────────

class _DismissButton extends StatelessWidget {
  const _DismissButton({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.xxl,
      ),
      child: SizedBox(
        width: double.infinity,
        child: GestureDetector(
          onTap: onPressed,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
            decoration: BoxDecoration(
              borderRadius: AppRadius.button,
              gradient: const LinearGradient(
                colors: [AppColors.primaryMint, AppColors.primaryBlue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x4D6EC6CA),
                  blurRadius: 20,
                  offset: Offset(0, 4),
                  spreadRadius: -2,
                ),
              ],
            ),
            child: const Text(
              '확인',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
