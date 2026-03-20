import 'dart:async';
import 'package:flutter/material.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../design/tokens/app_spacing.dart';
import '../../../design/glass/app_glass.dart';
import '../../../shared/models/node_model.dart';

/// Time Slider 연도 변경 시 birth/death 이벤트를 표시하는 토스트
///
/// 사용법: CanvasScreen의 Stack에 Positioned로 배치하고,
/// [message]를 전달하면 페이드인 표시 후 2초 뒤 자동 사라짐.
class TimeEventToast extends StatefulWidget {
  const TimeEventToast({
    super.key,
    required this.message,
  });

  final String? message;

  /// 선택된 연도에 해당하는 birth/death 이벤트 메시지를 생성한다.
  /// 이벤트가 없으면 null 반환.
  static String? buildEventMessage({
    required int? year,
    required List<NodeModel> nodes,
  }) {
    if (year == null) return null;

    final events = <String>[];

    for (final node in nodes) {
      if (node.birthDate?.year == year) {
        events.add('${node.name} 탄생');
      }
      if (node.deathDate?.year == year) {
        events.add('${node.name} 별세');
      }
    }

    if (events.isEmpty) return null;

    final first = events.first;
    if (events.length == 1) {
      return '$year년 — $first';
    }
    return '$year년 — $first 외 ${events.length - 1}명';
  }

  @override
  State<TimeEventToast> createState() => _TimeEventToastState();
}

class _TimeEventToastState extends State<TimeEventToast> {
  String? _displayMessage;
  bool _visible = false;
  Timer? _hideTimer;

  @override
  void didUpdateWidget(TimeEventToast old) {
    super.didUpdateWidget(old);
    if (widget.message != old.message && widget.message != null) {
      _showToast(widget.message!);
    }
  }

  void _showToast(String msg) {
    _hideTimer?.cancel();
    setState(() {
      _displayMessage = msg;
      _visible = true;
    });
    _hideTimer = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() => _visible = false);
    });
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_displayMessage == null) return const SizedBox.shrink();

    return Positioned(
      top: MediaQuery.of(context).padding.top + AppSpacing.appBarHeight + AppSpacing.md,
      left: AppSpacing.xxl,
      right: AppSpacing.xxl,
      child: IgnorePointer(
        child: Center(
          child: AnimatedOpacity(
            opacity: _visible ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: GlassCard(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.auto_awesome,
                    color: AppColors.primaryMint,
                    size: 16,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Flexible(
                    child: Text(
                      _displayMessage!,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
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
