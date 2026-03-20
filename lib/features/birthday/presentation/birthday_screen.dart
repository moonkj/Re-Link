import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/haptic_service.dart';
import '../../../design/glass/app_glass.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../design/tokens/app_spacing.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../providers/birthday_notifier.dart';
import '../widgets/birthday_countdown_card.dart';

/// 가족 생일 대시보드 화면
class BirthdayScreen extends ConsumerWidget {
  const BirthdayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncBirthdays = ref.watch(birthdayNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.bgBase,
      appBar: AppBar(
        title: Text(
          '가족 생일',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: asyncBirthdays.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(
            '데이터를 불러올 수 없습니다',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
        data: (entries) {
          if (entries.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.cake_outlined,
              title: '등록된 생일이 없습니다',
              subtitle: '가족 노드에 생년월일을 입력하면\n생일 카운트다운이 표시됩니다',
            );
          }

          final todayBirthdays = entries.where((e) => e.isToday).toList();
          final upcomingBirthdays = entries.where((e) => !e.isToday).toList();

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () => ref.read(birthdayNotifierProvider.notifier).refresh(),
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.pagePadding),
              children: [
                // 오늘 생일 헤더
                if (todayBirthdays.isNotEmpty) ...[
                  _TodayBirthdayHeader(entries: todayBirthdays),
                  const SizedBox(height: AppSpacing.lg),
                  ...todayBirthdays.map((entry) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: BirthdayCountdownCard(
                      entry: entry,
                      onTap: () => HapticService.light(),
                    ),
                  )),
                  if (upcomingBirthdays.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xl),
                    _SectionHeader(title: '다가오는 생일'),
                    const SizedBox(height: AppSpacing.md),
                  ],
                ],
                if (todayBirthdays.isEmpty) ...[
                  _SectionHeader(title: '다가오는 생일'),
                  const SizedBox(height: AppSpacing.md),
                ],
                // 다가오는 생일 목록
                ...upcomingBirthdays.map((entry) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: BirthdayCountdownCard(
                    entry: entry,
                    onTap: () => HapticService.light(),
                  ),
                )),
                const SizedBox(height: AppSpacing.xxxl),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── 오늘 생일 축하 헤더 ────────────────────────────────────────────────────────

class _TodayBirthdayHeader extends StatelessWidget {
  const _TodayBirthdayHeader({required this.entries});

  final List<BirthdayEntry> entries;

  @override
  Widget build(BuildContext context) {
    final names = entries.map((e) => e.nodeName).join(', ');

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          // 케이크 아이콘
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppColors.accent.withAlpha(40),
                  AppColors.tempWarm.withAlpha(40),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.cake,
                size: 32,
                color: AppColors.accent,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            '$names의 생일입니다!',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.accent,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '오늘은 특별한 날입니다. 축하 메시지를 보내보세요!',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ── 섹션 헤더 ──────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
      ),
    );
  }
}
