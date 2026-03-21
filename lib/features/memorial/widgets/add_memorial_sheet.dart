import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/haptic_service.dart';
import '../../../design/glass/app_glass.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../design/tokens/app_spacing.dart';
import '../../badges/providers/badge_notifier.dart';
import '../../badges/widgets/badge_earned_dialog.dart';
import '../providers/memorial_notifier.dart';

/// 추모 메시지 작성 바텀시트
class AddMemorialSheet extends ConsumerStatefulWidget {
  const AddMemorialSheet({
    super.key,
    required this.nodeId,
    required this.nodeName,
  });

  final String nodeId;
  final String nodeName;

  @override
  ConsumerState<AddMemorialSheet> createState() => _AddMemorialSheetState();
}

class _AddMemorialSheetState extends ConsumerState<AddMemorialSheet> {
  final _messageController = TextEditingController();
  final _authorController = TextEditingController();
  final _messageFocus = FocusNode();
  bool _isSaving = false;

  @override
  void dispose() {
    _messageController.dispose();
    _authorController.dispose();
    _messageFocus.dispose();
    super.dispose();
  }

  bool get _isValid => _messageController.text.trim().isNotEmpty;

  Future<void> _save() async {
    if (!_isValid || _isSaving) return;

    setState(() => _isSaving = true);
    HapticService.medium();

    final id = await ref.read(memorialNotifierProvider.notifier).addMessage(
          nodeId: widget.nodeId,
          message: _messageController.text.trim(),
          authorName: _authorController.text.trim().isEmpty
              ? null
              : _authorController.text.trim(),
        );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (id != null) {
      // 배지 조건 확인
      final newBadges = await ref.read(badgeNotifierProvider.notifier).checkAndAward();
      if (newBadges.isNotEmpty && mounted) {
        await showDialog(
          context: context,
          builder: (_) => BadgeEarnedDialog(badge: newBadges.first),
        );
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return GlassBottomSheet(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.xl,
        AppSpacing.xl,
        AppSpacing.xl + bottomInset,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 핸들
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.glassBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // 타이틀
          Row(
            children: [
              Icon(
                Icons.local_fire_department_outlined,
                color: AppColors.textTertiary,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '${widget.nodeName}에게 보내는 말',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),

          // 메시지 입력
          Container(
            decoration: BoxDecoration(
              color: AppColors.glassSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: TextField(
              controller: _messageController,
              focusNode: _messageFocus,
              autofocus: true,
              maxLines: 5,
              minLines: 3,
              maxLength: 500,
              style: TextStyle(
                fontSize: 15,
                color: AppColors.textPrimary,
                height: 1.5,
              ),
              decoration: InputDecoration(
                hintText: '전하고 싶은 말을 적어주세요...',
                hintStyle: TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 15,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(AppSpacing.lg),
                counterStyle: TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 11,
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // 작성자 이름 (선택)
          Container(
            decoration: BoxDecoration(
              color: AppColors.glassSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: TextField(
              controller: _authorController,
              maxLength: 20,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: '작성자 이름 (선택)',
                hintStyle: TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 14,
                ),
                prefixIcon: Icon(
                  Icons.person_outline,
                  color: AppColors.textTertiary,
                  size: 18,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                counterText: '',
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // 저장 버튼
          SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: _isValid && !_isSaving ? _save : null,
              child: AnimatedOpacity(
                opacity: _isValid ? 1.0 : 0.4,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: AppColors.textPrimary.withAlpha(
                      _isValid ? 30 : 15,
                    ),
                    border: Border.all(
                      color: AppColors.glassBorder,
                    ),
                  ),
                  child: Center(
                    child: _isSaving
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.textSecondary,
                            ),
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.local_fire_department_outlined,
                                color: AppColors.textSecondary,
                                size: 18,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Text(
                                '추모 메시지 남기기',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
