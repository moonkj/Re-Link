import 'package:flutter/material.dart';
import '../../../core/database/app_database.dart';
import '../../../design/glass/app_glass.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../design/tokens/app_spacing.dart';

/// 캡슐 상태
enum CapsuleState {
  /// 아직 열 수 없음 (openDate > now)
  locked,

  /// 열 수 있는 상태 (openDate <= now && !isOpened)
  openable,

  /// 이미 열린 캡슐
  opened,
}

/// 캡슐 카드 위젯 — 상태별(locked/openable/opened) 아이콘, 색상, 텍스트
class CapsuleCard extends StatefulWidget {
  const CapsuleCard({
    super.key,
    required this.capsule,
    required this.onTap,
    this.onLongPress,
  });

  final CapsulesTableData capsule;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  State<CapsuleCard> createState() => _CapsuleCardState();
}

class _CapsuleCardState extends State<CapsuleCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  CapsuleState get _state {
    if (widget.capsule.isOpened) return CapsuleState.opened;
    if (!widget.capsule.openDate.isAfter(DateTime.now())) {
      return CapsuleState.openable;
    }
    return CapsuleState.locked;
  }

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
    if (_state == CapsuleState.openable) {
      _pulseCtrl.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant CapsuleCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_state == CapsuleState.openable && !_pulseCtrl.isAnimating) {
      _pulseCtrl.repeat(reverse: true);
    } else if (_state != CapsuleState.openable && _pulseCtrl.isAnimating) {
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
      case CapsuleState.locked:
        icon = Icons.lock_outlined;
        iconColor = AppColors.textTertiary;
        statusText = '${_formatDate(widget.capsule.openDate)}에 열림';
        statusColor = AppColors.textTertiary;
      case CapsuleState.openable:
        icon = Icons.auto_awesome;
        iconColor = AppColors.accent;
        statusText = '열어보세요!';
        statusColor = AppColors.accent;
      case CapsuleState.opened:
        icon = Icons.check_circle_outlined;
        iconColor = AppColors.success;
        statusText = widget.capsule.openedAt != null
            ? '${_formatDate(widget.capsule.openedAt!)} 열림'
            : '열림';
        statusColor = AppColors.success;
    }

    final card = GestureDetector(
      onLongPress: widget.onLongPress,
      child: GlassCard(
      onTap: widget.onTap,
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
                  widget.capsule.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: state == CapsuleState.locked
                        ? AppColors.textSecondary
                        : AppColors.textPrimary,
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
                    fontWeight: state == CapsuleState.openable
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          // 화살표
          Icon(
            Icons.chevron_right,
            color: AppColors.textTertiary,
            size: 20,
          ),
        ],
      ),
    ),
    );

    // openable 상태: 부드러운 펄스 애니메이션
    if (state == CapsuleState.openable) {
      return ScaleTransition(
        scale: _pulseAnim,
        child: card,
      );
    }

    return card;
  }

  String _formatDate(DateTime dt) =>
      '${dt.year}년 ${dt.month}월 ${dt.day}일';
}
