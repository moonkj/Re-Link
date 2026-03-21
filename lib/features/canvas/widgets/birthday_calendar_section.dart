import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../design/glass/app_glass.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../design/tokens/app_spacing.dart';
import '../../../shared/models/family_event_model.dart';
import '../providers/canvas_notifier.dart';
import '../providers/family_event_notifier.dart';
import 'add_event_sheet.dart';

/// 달력에 표시할 날짜 항목 (생일 or 일정)
class _CalendarDayEntry {
  final String label;
  final Color dotColor;
  final bool isBirthday;

  const _CalendarDayEntry({
    required this.label,
    required this.dotColor,
    this.isBirthday = false,
  });
}

/// 가족탭 상단 — 생일 + 일정 달력 + D-day 섹션
class BirthdayCalendarSection extends ConsumerStatefulWidget {
  const BirthdayCalendarSection({super.key});

  @override
  ConsumerState<BirthdayCalendarSection> createState() =>
      _BirthdayCalendarSectionState();
}

class _BirthdayCalendarSectionState
    extends ConsumerState<BirthdayCalendarSection> {
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentMonth = DateTime(now.year, now.month);
  }

  void _prevMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final asyncEvents = ref.watch(familyEventNotifierProvider);
    final canvasState = ref.watch(canvasNotifierProvider);
    final nodes = canvasState.nodes;

    // ── 생일 맵 (day → entries) ──────────────────────────────────
    final birthdayNodes = nodes
        .where((n) =>
            n.birthDate != null && !n.isGhost && n.deathDate == null)
        .toList();

    final dayEntriesMap = <int, List<_CalendarDayEntry>>{};
    for (final node in birthdayNodes) {
      if (node.birthDate!.month == _currentMonth.month) {
        dayEntriesMap.putIfAbsent(node.birthDate!.day, () => []).add(
          _CalendarDayEntry(
            label: '${node.displayName}의 생일',
            dotColor: AppColors.accent,
            isBirthday: true,
          ),
        );
      }
    }

    // ── 일정 맵 (day → entries) ──────────────────────────────────
    final events = asyncEvents.valueOrNull ?? [];
    for (final event in events) {
      final matchesMonth = event.isYearly
          ? event.eventDate.month == _currentMonth.month
          : event.eventDate.year == _currentMonth.year &&
              event.eventDate.month == _currentMonth.month;
      if (matchesMonth) {
        dayEntriesMap.putIfAbsent(event.eventDate.day, () => []).add(
          _CalendarDayEntry(
            label: event.title,
            dotColor: event.color,
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── 달력 헤더 (라벨 + 일정 추가 버튼) ─────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            children: [
              Icon(
                Icons.calendar_month_outlined,
                size: 18,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                '가족 달력',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => _showAddEventSheet(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(20),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.add,
                        size: 14,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '일정 추가',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        // ── 달력 카드 ───────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: GlassCard(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.md,
            ),
            child: Column(
              children: [
                _buildMonthHeader(),
                const SizedBox(height: AppSpacing.md),
                _buildWeekdayHeaders(),
                const SizedBox(height: AppSpacing.xs),
                _buildCalendarGrid(dayEntriesMap),
              ],
            ),
          ),
        ),

        // ── 다가오는 일정 D-day ─────────────────────────────────
        asyncEvents.when(
          loading: () => const SizedBox.shrink(),
          error: (_, _) => const SizedBox.shrink(),
          data: (eventList) {
            // 미래 일정만 (과거 비반복 일정 제외), 상위 5개
            final upcoming = eventList
                .where((e) => e.daysUntil >= 0)
                .take(5)
                .toList();
            if (upcoming.isEmpty) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(
                left: AppSpacing.lg,
                right: AppSpacing.lg,
                top: AppSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.event_outlined,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        '다가오는 일정',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ...upcoming.map((event) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: _EventDdayTile(
                          event: event,
                          onDelete: () => _deleteEvent(event.id),
                        ),
                      )),
                ],
              ),
            );
          },
        ),

      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ── 월 헤더 (< 2026년 3월 >) ──────────────────────────────────────────
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildMonthHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: _prevMonth,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xs),
            child: Icon(
              Icons.chevron_left_rounded,
              color: AppColors.textSecondary,
              size: 24,
            ),
          ),
        ),
        Text(
          '${_currentMonth.year}년 ${_currentMonth.month}월',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        GestureDetector(
          onTap: _nextMonth,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xs),
            child: Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
              size: 24,
            ),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ── 요일 헤더 (일 월 화 수 목 금 토) ─────────────────────────────────────
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildWeekdayHeaders() {
    const days = ['일', '월', '화', '수', '목', '금', '토'];
    return Row(
      children: days.map((d) {
        final isSunday = d == '일';
        final isSaturday = d == '토';
        return Expanded(
          child: Center(
            child: Text(
              d,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSunday
                    ? AppColors.accent
                    : isSaturday
                        ? AppColors.primary
                        : AppColors.textTertiary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ── 달력 그리드 ────────────────────────────────────────────────────────
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildCalendarGrid(
      Map<int, List<_CalendarDayEntry>> dayEntriesMap) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final firstDay =
        DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDay =
        DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    final startWeekday = firstDay.weekday % 7; // 0=일, 1=월, ..., 6=토
    final daysInMonth = lastDay.day;

    final totalCells = startWeekday + daysInMonth;
    final rows = (totalCells / 7).ceil();

    return Column(
      children: List.generate(rows, (row) {
        return Row(
          children: List.generate(7, (col) {
            final index = row * 7 + col;
            final day = index - startWeekday + 1;

            if (day < 1 || day > daysInMonth) {
              return const Expanded(child: SizedBox(height: 48));
            }

            final isToday = _currentMonth.year == today.year &&
                _currentMonth.month == today.month &&
                day == today.day;
            final entries = dayEntriesMap[day];
            final hasEntries = entries != null && entries.isNotEmpty;
            final hasBirthday =
                entries?.any((e) => e.isBirthday) ?? false;
            final hasEvent =
                entries?.any((e) => !e.isBirthday) ?? false;
            final isSunday = col == 0;
            final isSaturday = col == 6;

            return Expanded(
              child: GestureDetector(
                onTap: hasEntries
                    ? () => _showDayPopup(entries)
                    : null,
                child: SizedBox(
                  height: 48,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 날짜 원
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isToday
                              ? AppColors.primary
                              : hasBirthday
                                  ? AppColors.accent.withAlpha(25)
                                  : hasEvent
                                      ? entries!
                                          .firstWhere((e) => !e.isBirthday)
                                          .dotColor
                                          .withAlpha(20)
                                      : Colors.transparent,
                        ),
                        child: Center(
                          child: Text(
                            '$day',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isToday || hasEntries
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                              color: isToday
                                  ? Colors.white
                                  : hasBirthday
                                      ? AppColors.accent
                                      : hasEvent
                                          ? entries!
                                              .firstWhere(
                                                  (e) => !e.isBirthday)
                                              .dotColor
                                          : isSunday
                                              ? AppColors.accent
                                                  .withAlpha(180)
                                              : isSaturday
                                                  ? AppColors.primary
                                                      .withAlpha(180)
                                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                      // 도트 표시 (생일=산호, 일정=커스텀 컬러)
                      if (hasEntries)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: _buildDots(entries),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),
        );
      }),
    );
  }

  /// 날짜 아래 도트 (생일 + 일정 각각 색상 표시, 최대 3개)
  List<Widget> _buildDots(List<_CalendarDayEntry> entries) {
    // 중복 컬러 제거, 최대 3개
    final colors = entries.map((e) => e.dotColor).toSet().take(3);
    return colors.map((c) {
      return Container(
        width: 5,
        height: 5,
        margin: const EdgeInsets.symmetric(horizontal: 1),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: c,
        ),
      );
    }).toList();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ── 날짜 팝업 (생일 + 일정 통합) ──────────────────────────────────────
  // ═══════════════════════════════════════════════════════════════════════════

  void _showDayPopup(List<_CalendarDayEntry> entries) {
    if (!mounted) return;
    final labels = entries.map((e) => e.label).join('\n');
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              entries.any((e) => e.isBirthday)
                  ? Icons.cake
                  : Icons.event,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                labels,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: entries.first.dotColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ── 일정 추가/삭제 ─────────────────────────────────────────────────────
  // ═══════════════════════════════════════════════════════════════════════════

  void _showAddEventSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const AddEventSheet(),
    );
  }

  Future<void> _deleteEvent(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('일정 삭제'),
        content: const Text('이 일정을 삭제할까요?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              '삭제',
              style: TextStyle(color: AppColors.accent),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await ref.read(familyEventNotifierProvider.notifier).deleteEvent(id);
    }
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// ── 일정 D-day 타일 ───────────────────────────────────────────────────────
// ═════════════════════════════════════════════════════════════════════════════

class _EventDdayTile extends StatelessWidget {
  const _EventDdayTile({
    required this.event,
    this.onDelete,
  });

  final FamilyEventModel event;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final isToday = event.isToday;
    final ddayText = isToday ? 'D-Day' : 'D-${event.daysUntil}';
    final ddayColor = isToday
        ? event.color
        : event.daysUntil <= 7
            ? AppColors.tempWarm
            : event.daysUntil <= 30
                ? event.color
                : AppColors.textTertiary;

    return GlassCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          // ── 컬러 아이콘 ─────────────────────────────────────────
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: event.color.withAlpha(25),
              border: Border.all(color: event.color, width: 1.5),
            ),
            child: Center(
              child: Icon(
                event.isYearly
                    ? Icons.repeat_rounded
                    : Icons.event_rounded,
                size: 16,
                color: event.color,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          // ── 제목 + 날짜 ─────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${event.nextEventDate.month}월 ${event.nextEventDate.day}일${event.isYearly ? ' · 매년' : ''}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),

          // ── D-day 배지 ──────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isToday || event.daysUntil <= 30
                  ? ddayColor
                  : ddayColor.withAlpha(25),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              ddayText,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isToday || event.daysUntil <= 30
                    ? Colors.white
                    : AppColors.textSecondary,
              ),
            ),
          ),

          // ── 삭제 버튼 ───────────────────────────────────────────
          if (onDelete != null)
            GestureDetector(
              onTap: onDelete,
              child: Padding(
                padding: const EdgeInsets.only(left: AppSpacing.sm),
                child: Icon(
                  Icons.close,
                  size: 16,
                  color: AppColors.textTertiary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
