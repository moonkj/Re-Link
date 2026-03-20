import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/errors/app_error.dart';
import '../../../core/services/media/media_service.dart';
import '../../../design/glass/app_glass.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../design/tokens/app_spacing.dart';
import '../providers/node_notifier.dart';

/// 노드 추가 바텀시트
class AddNodeSheet extends ConsumerStatefulWidget {
  const AddNodeSheet({
    super.key,
    this.initialPositionX = 200,
    this.initialPositionY = 200,
  });

  final double initialPositionX;
  final double initialPositionY;

  @override
  ConsumerState<AddNodeSheet> createState() => _AddNodeSheetState();
}

class _AddNodeSheetState extends ConsumerState<AddNodeSheet> {
  final _nameCtrl = TextEditingController();
  final _nicknameCtrl = TextEditingController();
  String? _photoPath;
  DateTime? _birthDate;
  bool _isGhost = false;
  bool _autoGhostParents = true;
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _nicknameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GlassBottomSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          Text(
            '새 인물 추가',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: _pickPhoto,
                child: _PhotoButton(photoPath: _photoPath),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  children: [
                    _GlassField(controller: _nameCtrl, hint: '이름 *', icon: Icons.person),
                    const SizedBox(height: AppSpacing.sm),
                    _GlassField(controller: _nicknameCtrl, hint: '별명 (선택)', icon: Icons.badge_outlined),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // 생년월일
          GlassCard(
            onTap: _pickBirthDate,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm + 2,
            ),
            child: Row(
              children: [
                const Icon(Icons.cake_outlined, color: AppColors.primary, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  _birthDate == null
                      ? '생년월일 (선택)'
                      : '${_birthDate!.year}년 ${_birthDate!.month}월 ${_birthDate!.day}일',
                  style: TextStyle(
                    fontSize: 14,
                    color: _birthDate == null ? AppColors.textTertiary : AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                if (_birthDate != null)
                  GestureDetector(
                    onTap: () => setState(() => _birthDate = null),
                    child: Icon(Icons.clear, color: AppColors.textTertiary, size: 18),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Ghost Node 토글
          GlassCard(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.xs,
            ),
            child: Row(
              children: [
                Icon(Icons.help_outline, color: AppColors.textSecondary, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Ghost Node',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                      Text('실제 인물이 확인되지 않은 조상',
                          style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                    ],
                  ),
                ),
                Switch(
                  value: _isGhost,
                  onChanged: (v) => setState(() => _isGhost = v),
                  activeThumbColor: AppColors.primary,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // 부모 Ghost 자동 생성 토글
          GlassCard(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.xs,
            ),
            child: Row(
              children: [
                const Icon(Icons.account_tree_outlined, color: AppColors.secondary, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('부모 Ghost 자동 생성',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                      Text('아버지·어머니 Ghost 노드를 자동으로 추가',
                          style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                    ],
                  ),
                ),
                Switch(
                  value: _autoGhostParents,
                  onChanged: (v) => setState(() => _autoGhostParents = v),
                  activeThumbColor: AppColors.secondary,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          SizedBox(
            width: double.infinity,
            child: PrimaryGlassButton(
              label: '추가하기',
              isLoading: _saving,
              onPressed: _save,
            ),
          ),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }

  Future<void> _pickPhoto() async {
    final result = await ref.read(mediaServiceProvider).pickAndSaveAvatar();
    if (!mounted || result == null) return;
    setState(() => _photoPath = result);
  }

  Future<void> _pickBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(1970),
      firstDate: DateTime(1800),
      lastDate: DateTime.now(),
      helpText: '생년월일 선택',
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (!mounted || picked == null) return;
    setState(() => _birthDate = picked);
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
      final notifier = ref.read(nodeNotifierProvider.notifier);
      final node = await notifier.createNode(
            name: name,
            nickname: _nicknameCtrl.text.trim().isEmpty ? null : _nicknameCtrl.text.trim(),
            photoPath: _photoPath,
            birthDate: _birthDate,
            isGhost: _isGhost,
            positionX: widget.initialPositionX,
            positionY: widget.initialPositionY,
          );
      if (!mounted) return;
      if (node != null) {
        if (_autoGhostParents) {
          await notifier.createGhostParentsFor(node);
        }
        if (mounted) Navigator.of(context).pop(node);
      }
    } on PlanLimitError catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: AppColors.warning,
          action: SnackBarAction(
            label: '업그레이드',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

class _PhotoButton extends StatelessWidget {
  const _PhotoButton({this.photoPath});
  final String? photoPath;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primary, width: 1.5),
        color: AppColors.glassSurface,
        image: photoPath != null
            ? DecorationImage(image: FileImage(File(photoPath!)), fit: BoxFit.cover)
            : null,
      ),
      child: photoPath == null
          ? const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_a_photo_outlined, color: AppColors.primary, size: 22),
                SizedBox(height: 2),
                Text('사진', style: TextStyle(fontSize: 10, color: AppColors.primary)),
              ],
            )
          : null,
    );
  }
}

class _GlassField extends StatelessWidget {
  const _GlassField({
    required this.controller,
    required this.hint,
    required this.icon,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 18),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: TextField(
              controller: controller,
              style: TextStyle(fontSize: 14, color: AppColors.textPrimary),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hint,
                hintStyle: TextStyle(fontSize: 14, color: AppColors.textTertiary),
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
