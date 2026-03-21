import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../design/glass/app_glass.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../design/tokens/app_spacing.dart';
import '../providers/family_event_notifier.dart';

/// 가족 일정 추가/편집 바텀시트
class AddEventSheet extends ConsumerStatefulWidget {
  const AddEventSheet({super.key, this.initialDate});

  /// 달력에서 선택한 날짜 (선택적)
  final DateTime? initialDate;

  @override
  ConsumerState<AddEventSheet> createState() => _AddEventSheetState();
}

class _AddEventSheetState extends ConsumerState<AddEventSheet> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  DateTime? _eventDate;
  bool _isYearly = false;
  int _selectedColorIndex = 0;
  bool _saving = false;

  /// 일정 컬러 팔레트
  static const _colorOptions = [
    Color(0xFF8B5CF6), // Violet (primary)
    Color(0xFF06B6D4), // Cyan
    Color(0xFFF43F5E), // Rose
    Color(0xFFFB923C), // Orange
    Color(0xFF10B981), // Emerald
    Color(0xFFF59E0B), // Amber
  ];

  @override
  void initState() {
    super.initState();
    _eventDate = widget.initialDate;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GlassBottomSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 드래그 핸들 ──────────────────────────────────────────
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.glassBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // ── 제목 ────────────────────────────────────────────────
          Text(
            '일정 추가',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // ── 일정 이름 ───────────────────────────────────────────
          _GlassField(
            controller: _titleCtrl,
            icon: Icons.event_outlined,
            hint: '일정 이름 (예: 결혼기념일)',
          ),
          const SizedBox(height: AppSpacing.md),

          // ── 메모 ────────────────────────────────────────────────
          _GlassField(
            controller: _descCtrl,
            icon: Icons.notes_outlined,
            hint: '메모 (선택)',
            maxLines: 2,
          ),
          const SizedBox(height: AppSpacing.md),

          // ── 날짜 선택 ───────────────────────────────────────────
          GlassCard(
            onTap: _pickDate,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    _eventDate != null
                        ? '${_eventDate!.year}년 ${_eventDate!.month}월 ${_eventDate!.day}일'
                        : '날짜 선택',
                    style: TextStyle(
                      fontSize: 15,
                      color: _eventDate != null
                          ? AppColors.textPrimary
                          : AppColors.textTertiary,
                    ),
                  ),
                ),
                if (_eventDate != null)
                  GestureDetector(
                    onTap: () => setState(() => _eventDate = null),
                    child: Icon(
                      Icons.close,
                      size: 18,
                      color: AppColors.textTertiary,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // ── 매년 반복 토글 ──────────────────────────────────────
          GlassCard(
            onTap: () => setState(() => _isYearly = !_isYearly),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.repeat_outlined,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    '매년 반복',
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Switch.adaptive(
                  value: _isYearly,
                  activeTrackColor: AppColors.primary,
                  onChanged: (v) => setState(() => _isYearly = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // ── 컬러 선택 ───────────────────────────────────────────
          Text(
            '컬러',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: List.generate(_colorOptions.length, (i) {
              final c = _colorOptions[i];
              final selected = i == _selectedColorIndex;
              return GestureDetector(
                onTap: () => setState(() => _selectedColorIndex = i),
                child: Container(
                  width: 32,
                  height: 32,
                  margin: const EdgeInsets.only(right: AppSpacing.sm),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: c,
                    border: selected
                        ? Border.all(color: AppColors.textPrimary, width: 2.5)
                        : null,
                  ),
                  child: selected
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : null,
                ),
              );
            }),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // ── 저장 버튼 ───────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: PrimaryGlassButton(
              label: '저장',
              isLoading: _saving,
              onPressed: _canSave ? _save : null,
            ),
          ),

          // ── 키보드 여백 ─────────────────────────────────────────
          SizedBox(
            height: MediaQuery.of(context).viewInsets.bottom,
          ),
        ],
      ),
    );
  }

  bool get _canSave =>
      _titleCtrl.text.trim().isNotEmpty && _eventDate != null && !_saving;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _eventDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _eventDate = picked);
    }
  }

  Future<void> _save() async {
    if (!_canSave) return;
    setState(() => _saving = true);

    try {
      await ref.read(familyEventNotifierProvider.notifier).addEvent(
            title: _titleCtrl.text.trim(),
            description: _descCtrl.text.trim().isEmpty
                ? null
                : _descCtrl.text.trim(),
            eventDate: _eventDate!,
            isYearly: _isYearly,
            colorValue: _colorOptions[_selectedColorIndex].toARGB32(),
          );

      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('일정 저장 실패: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

// ── 글래스 텍스트 필드 ──────────────────────────────────────────────────────

class _GlassField extends StatelessWidget {
  const _GlassField({
    required this.controller,
    required this.icon,
    required this.hint,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final IconData icon;
  final String hint;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        crossAxisAlignment: maxLines > 1
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(top: maxLines > 1 ? 12 : 0),
            child: Icon(icon, size: 18, color: AppColors.textSecondary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: TextField(
              controller: controller,
              maxLines: maxLines,
              style: TextStyle(
                fontSize: 15,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: AppColors.textTertiary),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
