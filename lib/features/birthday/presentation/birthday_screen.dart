import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/haptic_service.dart';
import '../../../design/glass/app_glass.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../design/tokens/app_spacing.dart';
import '../../../features/canvas/providers/family_event_notifier.dart';
import '../../../features/canvas/widgets/add_event_sheet.dart';
import '../../../shared/models/family_event_model.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../providers/birthday_notifier.dart';
import '../widgets/birthday_countdown_card.dart';

/// 생일 & 일정 대시보드 화면
class BirthdayScreen extends ConsumerStatefulWidget {
  const BirthdayScreen({super.key});

  @override
  ConsumerState<BirthdayScreen> createState() => _BirthdayScreenState();
}

class _BirthdayScreenState extends ConsumerState<BirthdayScreen> {
  /// 일정 삭제 확인 다이얼로그 후 삭제 수행
  Future<void> _confirmDeleteEvent(FamilyEventModel event) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgBase,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          '일정 삭제',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
        ),
        content: Text(
          '"${event.title}" 일정을 삭제할까요?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('취소', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('삭제', style: TextStyle(color: AppColors.accent)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref
          .read(familyEventNotifierProvider.notifier)
          .deleteEvent(event.id);
    }
  }

  void _showAddEventSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddEventSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final asyncBirthdays = ref.watch(birthdayNotifierProvider);
    final asyncEvents = ref.watch(familyEventNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.bgBase,
      appBar: AppBar(
        title: Text(
          '생일 & 일정',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
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
          final events = asyncEvents.valueOrNull ?? [];
          final hasNoData = entries.isEmpty && events.isEmpty;

          if (hasNoData) {
            return const EmptyStateWidget(
              icon: Icons.cake_outlined,
              title: '등록된 생일·일정이 없습니다',
              subtitle: '가족 노드에 생년월일을 입력하거나\n일정을 추가하면 여기에 표시됩니다',
            );
          }

          final todayBirthdays = entries.where((e) => e.isToday).toList();
          final upcomingBirthdays = entries.where((e) => !e.isToday).toList();

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              await ref.read(birthdayNotifierProvider.notifier).refresh();
              await ref.read(familyEventNotifierProvider.notifier).refresh();
            },
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.pagePadding),
              children: [
                // ── 오늘 생일 헤더 ───────────────────────────────────
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
                if (todayBirthdays.isEmpty && upcomingBirthdays.isNotEmpty) ...[
                  _SectionHeader(title: '다가오는 생일'),
                  const SizedBox(height: AppSpacing.md),
                ],

                // ── 다가오는 생일 목록 ───────────────────────────────
                ...upcomingBirthdays.map((entry) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: BirthdayCountdownCard(
                    entry: entry,
                    onTap: () => HapticService.light(),
                  ),
                )),

                // ── 가족 일정 섹션 ───────────────────────────────────
                if (entries.isNotEmpty)
                  const SizedBox(height: AppSpacing.xl),

                // 섹션 헤더
                Row(
                  children: [
                    Icon(
                      Icons.event_outlined,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      '가족 일정',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: _showAddEventSheet,
                      child: Text(
                        '+ 추가',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),

                // 일정 없을 때
                if (events.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                    child: Center(
                      child: Text(
                        '등록된 일정이 없습니다.\n+ 추가 버튼으로 일정을 만들어보세요.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textTertiary,
                          height: 1.6,
                        ),
                      ),
                    ),
                  ),

                // 일정 목록
                ...events.map((event) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: _EventCard(
                    event: event,
                    onDelete: () => _confirmDeleteEvent(event),
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

// ── 가족 일정 카드 ─────────────────────────────────────────────────────────────

class _EventCard extends StatelessWidget {
  const _EventCard({required this.event, required this.onDelete});

  final FamilyEventModel event;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final nextDate = event.nextEventDate;
    final daysUntil = event.daysUntil;
    final dDayLabel = daysUntil == 0 ? 'D-day' : 'D-$daysUntil';
    final dateLabel =
        '${nextDate.month}월 ${nextDate.day}일${event.isYearly ? ' · 매년' : ''}';

    return GlassCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          // ── 색상 원형 아이콘 ───────────────────────────────────────
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: event.color.withAlpha(30),
            ),
            child: Center(
              child: Icon(
                event.isYearly
                    ? Icons.repeat_rounded
                    : Icons.event_rounded,
                size: 20,
                color: event.color,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          // ── 제목 + 날짜 ───────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  dateLabel,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),

          // ── D-day 배지 ────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: 3,
            ),
            decoration: BoxDecoration(
              color: event.color.withAlpha(30),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              dDayLabel,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: event.color,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),

          // ── 삭제 버튼 ─────────────────────────────────────────────
          GestureDetector(
            onTap: onDelete,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(
                Icons.close,
                size: 18,
                color: AppColors.textTertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
