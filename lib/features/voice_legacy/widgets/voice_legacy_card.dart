import 'package:flutter/material.dart';
import '../../../core/database/app_database.dart';
import '../../../design/glass/app_glass.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../design/tokens/app_spacing.dart';

/// 보이스 유언 봉인 상태
enum VoiceLegacyState {
  /// 아직 열 수 없음 (openDate > now 또는 openCondition == 'manual')
  sealed,

  /// 열 수 있는 상태 (openDate <= now && !isOpened, 또는 manual 수동 공개 허용)
  openable,

  /// 이미 열린 유언
  opened,
}

/// 보이스 유언 카드 위젯 — 3 상태 (sealed / openable / opened)
class VoiceLegacyCard extends StatefulWidget {
  const VoiceLegacyCard({
    super.key,
    required this.legacy,
    required this.fromName,
    required this.toName,
    required this.onTap,
    this.onLongPress,
  });

  final VoiceLegacyTableData legacy;
  final String fromName;
  final String toName;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  State<VoiceLegacyCard> createState() => _VoiceLegacyCardState();
}

class _VoiceLegacyCardState extends State<VoiceLegacyCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  VoiceLegacyState get _state {
    if (widget.legacy.isOpened) return VoiceLegacyState.opened;
    if (widget.legacy.openCondition == 'manual') {
      return VoiceLegacyState.openable;
    }
    if (widget.legacy.openDate != null &&
        !widget.legacy.openDate!.isAfter(DateTime.now())) {
      return VoiceLegacyState.openable;
    }
    return VoiceLegacyState.sealed;
  }

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.04).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
    if (_state == VoiceLegacyState.openable) {
      _pulseCtrl.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant VoiceLegacyCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_state == VoiceLegacyState.openable && !_pulseCtrl.isAnimating) {
      _pulseCtrl.repeat(reverse: true);
    } else if (_state != VoiceLegacyState.openable &&
        _pulseCtrl.isAnimating) {
      _pulseCtrl.stop();
      _pulseCtrl.value = 0;
    }
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = _state;

    final IconData icon;
    final Color iconColor;
    final String statusText;
    final Color statusColor;

    switch (state) {
      case VoiceLegacyState.sealed:
        icon = Icons.lock_outlined;
        iconColor = AppColors.textTertiary;
        statusText = widget.legacy.openDate != null
            ? '봉인됨 \u2014 ${_formatDate(widget.legacy.openDate!)}에 열 수 있습니다'
            : '봉인됨';
        statusColor = AppColors.textTertiary;
      case VoiceLegacyState.openable:
        icon = Icons.lock_open_outlined;
        iconColor = AppColors.accent;
        statusText = '지금 열 수 있습니다';
        statusColor = AppColors.accent;
      case VoiceLegacyState.opened:
        icon = Icons.play_circle_outlined;
        iconColor = AppColors.success;
        statusText = widget.legacy.openedAt != null
            ? '${_formatDate(widget.legacy.openedAt!)} 열림 \u00b7 ${_formatDuration(widget.legacy.durationSeconds)}'
            : '열림 \u00b7 ${_formatDuration(widget.legacy.durationSeconds)}';
        statusColor = AppColors.success;
    }

    final card = GlassCard(
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          // 아이콘
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: iconColor.withAlpha(25),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: AppSpacing.md),
          // 텍스트
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.legacy.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: state == VoiceLegacyState.sealed
                        ? AppColors.textSecondary
                        : AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${widget.fromName} \u2192 ${widget.toName}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textTertiary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 13,
                    color: statusColor,
                    fontWeight: state == VoiceLegacyState.openable
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: AppColors.textTertiary,
            size: 20,
          ),
        ],
      ),
    );

    // openable 상태: 부드러운 펄스 애니메이션
    if (state == VoiceLegacyState.openable) {
      return ScaleTransition(
        scale: _pulseAnim,
        child: card,
      );
    }

    return card;
  }

  String _formatDate(DateTime dt) =>
      '${dt.year}년 ${dt.month}월 ${dt.day}일';

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    if (m > 0) return '$m분 ${s > 0 ? "${s}초" : ""}';
    return '$s초';
  }
}
