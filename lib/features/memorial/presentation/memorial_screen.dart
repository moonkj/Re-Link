import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/haptic_service.dart';
import '../../../core/utils/lunar_calendar.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../design/tokens/app_spacing.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../providers/memorial_notifier.dart';
import '../widgets/add_memorial_sheet.dart';
import '../widgets/memorial_message_card.dart';

/// E-7 "마지막 페이지" — 추모 공간 화면
/// 고인의 추모 메시지를 남기고 열람하는 화면
class MemorialScreen extends ConsumerWidget {
  const MemorialScreen({
    super.key,
    required this.nodeId,
    required this.nodeName,
    this.photoPath,
    this.birthDate,
    this.deathDate,
  });

  final String nodeId;
  final String nodeName;
  final String? photoPath;
  final DateTime? birthDate;
  final DateTime? deathDate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messagesAsync =
        ref.watch(memorialMessagesForNodeProvider(nodeId));

    return Scaffold(
      backgroundColor: AppColors.bgBase,
      body: CustomScrollView(
        slivers: [
          // ── App Bar ──────────────────────────────────────────────────
          SliverAppBar(
            backgroundColor: AppColors.bgBase,
            foregroundColor: AppColors.textPrimary,
            elevation: 0,
            pinned: true,
            title: Text(
              '추모 공간',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            centerTitle: true,
          ),

          // ── 헤더: 프로필 + 생몰년 + 경과일 ────────────────────────
          SliverToBoxAdapter(
            child: _MemorialHeader(
              nodeName: nodeName,
              photoPath: photoPath,
              birthDate: birthDate,
              deathDate: deathDate,
            ),
          ),

          // ── 인용구 ─────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.pagePadding,
                vertical: AppSpacing.md,
              ),
              child: Text(
                '"기억되는 한, 우리 곁에 있어요."',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: AppColors.textTertiary,
                  height: 1.5,
                ),
              ),
            ),
          ),

          // ── 구분선 ─────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.pagePadding,
                vertical: AppSpacing.sm,
              ),
              child: Divider(
                color: AppColors.glassBorder,
                height: 1,
              ),
            ),
          ),

          // ── 섹션 제목 ──────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pagePadding,
                AppSpacing.lg,
                AppSpacing.pagePadding,
                AppSpacing.md,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.local_fire_department_outlined,
                    color: AppColors.textTertiary,
                    size: 18,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    '추모 메시지',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  messagesAsync.whenData((msgs) {
                    return Text(
                      '${msgs.length}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textTertiary,
                      ),
                    );
                  }).value ??
                      const SizedBox.shrink(),
                ],
              ),
            ),
          ),

          // ── 메시지 목록 ────────────────────────────────────────────
          messagesAsync.when(
            loading: () => const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            error: (e, _) => SliverFillRemaining(
              child: Center(
                child: Text(
                  '오류: $e',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            ),
            data: (messages) {
              if (messages.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xxl),
                    child: EmptyStateWidget(
                      icon: Icons.local_fire_department_outlined,
                      title: '아직 추모 메시지가 없습니다',
                      subtitle:
                          '${nodeName}에게 전하고 싶은 말을\n남겨보세요.',
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pagePadding,
                ),
                sliver: SliverList.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    return MemorialMessageCard(
                      message: msg,
                      onDelete: () => _confirmDelete(
                        context,
                        ref,
                        msg.id,
                        msg.message,
                      ),
                    );
                  },
                ),
              );
            },
          ),

          // 하단 여백 (FAB 겹침 방지)
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSheet(context),
        backgroundColor: AppColors.bgSurface,
        foregroundColor: AppColors.textPrimary,
        elevation: 2,
        icon: Icon(
          Icons.local_fire_department_outlined,
          color: AppColors.textSecondary,
          size: 20,
        ),
        label: Text(
          '메시지 남기기',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  void _showAddSheet(BuildContext context) {
    HapticService.light();
    showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddMemorialSheet(
        nodeId: nodeId,
        nodeName: nodeName,
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    String messageId,
    String messageText,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgElevated,
        title: Text(
          '메시지 삭제',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          '이 추모 메시지를 삭제하시겠습니까?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              '삭제',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    HapticService.heavy();
    await ref.read(memorialNotifierProvider.notifier).deleteMessage(messageId);
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ── 추모 헤더 (프로필 사진 + 이름 + 생몰년 + 경과일) ───────────────────────────
// ═══════════════════════════════════════════════════════════════════════════════

class _MemorialHeader extends StatelessWidget {
  const _MemorialHeader({
    required this.nodeName,
    this.photoPath,
    this.birthDate,
    this.deathDate,
  });

  final String nodeName;
  final String? photoPath;
  final DateTime? birthDate;
  final DateTime? deathDate;

  @override
  Widget build(BuildContext context) {
    final daysSincePassing = deathDate != null
        ? DateTime.now().difference(deathDate!).inDays
        : null;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pagePadding,
        vertical: AppSpacing.lg,
      ),
      child: Column(
        children: [
          // 프로필 사진
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.glassBorder,
                width: 2,
              ),
              color: AppColors.glassSurface,
              image: photoPath != null
                  ? DecorationImage(
                      image: FileImage(File(photoPath!)),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.black.withAlpha(30),
                        BlendMode.darken,
                      ),
                    )
                  : null,
            ),
            child: photoPath == null
                ? Center(
                    child: Text(
                      nodeName.isNotEmpty ? nodeName[0] : '?',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(height: AppSpacing.md),

          // 이름
          Text(
            nodeName,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),

          // 생몰년
          if (birthDate != null || deathDate != null) ...[
            Text(
              _buildLifespan(),
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],

          // 경과일
          if (daysSincePassing != null)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.glassSurface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: Text(
                '떠난 지 $daysSincePassing일',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textTertiary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

          // ── 음력/양력 기일 정보 ──────────────────────────────────────
          if (deathDate != null) ...[
            const SizedBox(height: AppSpacing.md),
            _AnniversaryBadge(deathDate: deathDate!),
          ],
        ],
      ),
    );
  }

  String _buildLifespan() {
    final birth = birthDate;
    final death = deathDate;

    if (birth != null && death != null) {
      return '${birth.year}.${birth.month.toString().padLeft(2, '0')}.${birth.day.toString().padLeft(2, '0')}'
          ' — '
          '${death.year}.${death.month.toString().padLeft(2, '0')}.${death.day.toString().padLeft(2, '0')}';
    } else if (birth != null) {
      return '${birth.year}년생';
    } else if (death != null) {
      return '${death.year}.${death.month.toString().padLeft(2, '0')}.${death.day.toString().padLeft(2, '0')} 영면';
    }
    return '';
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ── 음력/양력 기일 뱃지 위젯 ──────────────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════════

class _AnniversaryBadge extends StatelessWidget {
  const _AnniversaryBadge({required this.deathDate});
  final DateTime deathDate;

  @override
  Widget build(BuildContext context) {
    // 양력 기일 → 음력 변환 시도
    final lunarDate = LunarCalendar.solarToLunar(deathDate);

    // 다음 양력 기일
    final nextSolar = LunarCalendar.nextSolarAnniversary(
      month: deathDate.month,
      day: deathDate.day,
    );

    // 다음 음력 기일 (음력 변환 성공 시)
    DateTime? nextLunar;
    if (lunarDate != null) {
      nextLunar = LunarCalendar.nextAnniversary(
        lunarMonth: lunarDate.month,
        lunarDay: lunarDate.day,
      );
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final solarDaysLeft = nextSolar.difference(today).inDays;
    final lunarDaysLeft = nextLunar?.difference(today).inDays;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.glassSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.glassBorder, width: 0.5),
      ),
      child: Column(
        children: [
          // 양력 기일
          _AnniversaryRow(
            label: '양력 기일',
            dateText: _formatDate(nextSolar),
            daysLeft: solarDaysLeft,
          ),

          // 음력 기일
          if (lunarDate != null && nextLunar != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Divider(color: AppColors.glassBorder, height: 1),
            const SizedBox(height: AppSpacing.sm),
            _AnniversaryRow(
              label: '음력 기일 (${lunarDate.toKorean()})',
              dateText: _formatDate(nextLunar),
              daysLeft: lunarDaysLeft!,
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) =>
      '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')}';
}

class _AnniversaryRow extends StatelessWidget {
  const _AnniversaryRow({
    required this.label,
    required this.dateText,
    required this.daysLeft,
  });

  final String label;
  final String dateText;
  final int daysLeft;

  @override
  Widget build(BuildContext context) {
    final isToday = daysLeft == 0;
    final isSoon = daysLeft > 0 && daysLeft <= 7;

    return Row(
      children: [
        Icon(
          Icons.event_outlined,
          size: 14,
          color: isToday
              ? AppColors.accent
              : isSoon
                  ? AppColors.warning
                  : AppColors.textTertiary,
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Text(
          dateText,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: isToday
                ? AppColors.accent.withAlpha(30)
                : isSoon
                    ? AppColors.warning.withAlpha(30)
                    : AppColors.glassSurface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            isToday ? '오늘' : 'D-$daysLeft',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isToday
                  ? AppColors.accent
                  : isSoon
                      ? AppColors.warning
                      : AppColors.textTertiary,
            ),
          ),
        ),
      ],
    );
  }
}
