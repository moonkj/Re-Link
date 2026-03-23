import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/media/media_service.dart';
import '../../../core/utils/path_utils.dart';
import '../../../design/glass/app_glass.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../design/tokens/app_spacing.dart';
import '../../../shared/models/node_model.dart';
import '../providers/node_notifier.dart';

/// 노드 편집 바텀시트
class EditNodeSheet extends ConsumerStatefulWidget {
  const EditNodeSheet({super.key, required this.node});
  final NodeModel node;

  @override
  ConsumerState<EditNodeSheet> createState() => _EditNodeSheetState();
}

class _EditNodeSheetState extends ConsumerState<EditNodeSheet> {
  late TextEditingController _nameCtrl;
  late TextEditingController _nicknameCtrl;
  late TextEditingController _bioCtrl;
  String? _photoPath;
  DateTime? _birthDate;
  DateTime? _deathDate;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final n = widget.node;
    _nameCtrl = TextEditingController(text: n.name);
    _nicknameCtrl = TextEditingController(text: n.nickname ?? '');
    _bioCtrl = TextEditingController(text: n.bio ?? '');
    _photoPath = n.photoPath;
    _birthDate = n.birthDate;
    _deathDate = n.deathDate;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _nicknameCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GlassBottomSheet(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.glassBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              '인물 편집',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // 사진
            Center(
              child: GestureDetector(
                onTap: _pickPhoto,
                child: Stack(
                  children: [
                    Container(
                      width: 80, height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary, width: 2),
                        color: AppColors.glassSurface,
                        image: _photoPath != null
                            ? DecorationImage(
                                image: PathUtils.resolveFileImage(_photoPath) ??
                                    FileImage(File(_photoPath!)),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: _photoPath == null
                          ? Center(
                              child: Text(
                                widget.node.name.isNotEmpty ? widget.node.name[0] : '?',
                                style: TextStyle(
                                  fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.textPrimary,
                                ),
                              ),
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0, right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle, color: AppColors.primary,
                        ),
                        child: Icon(Icons.camera_alt, size: 14, color: AppColors.onPrimary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // 필드들
            _field('이름', _nameCtrl, Icons.person),
            const SizedBox(height: AppSpacing.sm),
            _field('별명', _nicknameCtrl, Icons.badge_outlined),
            const SizedBox(height: AppSpacing.sm),
            _field('소개', _bioCtrl, Icons.notes, maxLines: 3),
            const SizedBox(height: AppSpacing.md),

            // 생년월일
            _datePicker('생년월일', _birthDate, (d) => setState(() => _birthDate = d)),
            const SizedBox(height: AppSpacing.sm),
            _datePicker('사망일 (선택)', _deathDate, (d) => setState(() => _deathDate = d)),
            const SizedBox(height: AppSpacing.xxl),

            SizedBox(
              width: double.infinity,
              child: PrimaryGlassButton(
                label: '저장',
                isLoading: _saving,
                onPressed: _save,
              ),
            ),
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
          ],
        ),
      ),
    );
  }

  Widget _field(String hint, TextEditingController ctrl, IconData icon, {int maxLines = 1}) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Icon(icon, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: TextField(
              controller: ctrl,
              maxLines: maxLines,
              style: TextStyle(fontSize: 14, color: AppColors.textPrimary),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hint,
                hintStyle: TextStyle(fontSize: 14, color: AppColors.textTertiary),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _datePicker(String label, DateTime? value, void Function(DateTime?) onChanged) {
    return GlassCard(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime(1970),
          firstDate: DateTime(1800),
          lastDate: DateTime.now(),
          builder: (context, child) => Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.dark(primary: AppColors.primary),
            ),
            child: child!,
          ),
        );
        if (!mounted) return;
        onChanged(picked);
      },
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm + 2),
      child: Row(
        children: [
          Icon(Icons.calendar_today_outlined, color: AppColors.primary, size: 18),
          const SizedBox(width: AppSpacing.sm),
          Text(
            value == null
                ? label
                : '${value.year}년 ${value.month}월 ${value.day}일',
            style: TextStyle(
              fontSize: 14,
              color: value == null ? AppColors.textTertiary : AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          if (value != null)
            GestureDetector(
              onTap: () => onChanged(null),
              child: Icon(Icons.clear, color: AppColors.textTertiary, size: 16),
            ),
        ],
      ),
    );
  }

  Future<void> _pickPhoto() async {
    final result = await ref.read(mediaServiceProvider).pickAndSaveAvatar();
    if (!mounted || result == null) return;
    setState(() => _photoPath = result);
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이름을 입력해 주세요')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final updated = widget.node.copyWith(
        name: name,
        nickname: _nicknameCtrl.text.trim().isEmpty ? null : _nicknameCtrl.text.trim(),
        bio: _bioCtrl.text.trim().isEmpty ? null : _bioCtrl.text.trim(),
        photoPath: _photoPath,
        birthDate: _birthDate,
        deathDate: _deathDate,
        updatedAt: DateTime.now(),
      );
      await ref.read(nodeNotifierProvider.notifier).updateNode(updated);
      if (!mounted) return;
      Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
