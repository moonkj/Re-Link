import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/haptic_service.dart';
import '../../../design/glass/app_glass.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../design/tokens/app_spacing.dart';
import '../../../shared/models/memory_model.dart';
import '../../../shared/repositories/memory_repository.dart';
import '../../badges/providers/badge_notifier.dart';
import '../../badges/widgets/badge_earned_dialog.dart';
import '../providers/capsule_notifier.dart';
import 'seal_animation.dart';

/// 캡슐 생성 바텀시트
class CreateCapsuleSheet extends ConsumerStatefulWidget {
  const CreateCapsuleSheet({super.key});

  @override
  ConsumerState<CreateCapsuleSheet> createState() => _CreateCapsuleSheetState();
}

class _CreateCapsuleSheetState extends ConsumerState<CreateCapsuleSheet> {
  final _titleCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  DateTime _openDate = DateTime.now().add(const Duration(days: 30));
  final Set<String> _selectedMemoryIds = {};
  bool _saving = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _messageCtrl.dispose();
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
            // 헤더
            Row(
              children: [
                Icon(Icons.lock_clock_outlined,
                    color: AppColors.primary, size: 22),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  '기억 캡슐 만들기',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            // 제목
            TextField(
              controller: _titleCtrl,
              style: TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                labelText: '캡슐 제목 *',
                hintText: '예: 2027년의 나에게',
                labelStyle: TextStyle(color: AppColors.textSecondary),
                hintStyle: TextStyle(color: AppColors.textTertiary),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.glassBorder)),
                focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primary)),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // 메시지 (선택)
            TextField(
              controller: _messageCtrl,
              style: TextStyle(color: AppColors.textPrimary),
              maxLines: 3,
              decoration: InputDecoration(
                labelText: '메시지 (선택)',
                hintText: '미래의 나에게 보내는 편지...',
                labelStyle: TextStyle(color: AppColors.textSecondary),
                hintStyle: TextStyle(color: AppColors.textTertiary),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.glassBorder)),
                focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primary)),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // 열림 날짜
            Text(
              '열림 날짜',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            GlassCard(
              onTap: _pickDate,
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg, vertical: AppSpacing.md),
              child: Row(
                children: [
                  Icon(Icons.calendar_today_outlined,
                      color: AppColors.primary, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    '${_openDate.year}년 ${_openDate.month}월 ${_openDate.day}일',
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.edit_outlined,
                      color: AppColors.textTertiary, size: 18),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // 기억 선택
            Text(
              '포함할 기억 선택',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            _MemorySelector(
              selectedIds: _selectedMemoryIds,
              onToggle: (id) {
                setState(() {
                  if (_selectedMemoryIds.contains(id)) {
                    _selectedMemoryIds.remove(id);
                  } else {
                    _selectedMemoryIds.add(id);
                  }
                });
                HapticService.light();
              },
            ),
            const SizedBox(height: AppSpacing.xxl),

            // 생성 버튼
            SizedBox(
              width: double.infinity,
              child: PrimaryGlassButton(
                label: '캡슐 봉인하기',
                icon: Icon(Icons.lock_outlined,
                    color: AppColors.onPrimary, size: 18),
                isLoading: _saving,
                onPressed: _canSave ? _save : null,
              ),
            ),
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
          ],
        ),
      ),
    );
  }

  bool get _canSave =>
      _titleCtrl.text.trim().isNotEmpty && !_saving;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _openDate,
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            brightness: Theme.of(context).brightness,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null && mounted) {
      setState(() => _openDate = picked);
      HapticService.selection();
    }
  }

  Future<void> _save() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) return;

    setState(() => _saving = true);

    final id = await ref.read(capsuleNotifierProvider.notifier).create(
          title: title,
          message: _messageCtrl.text.trim().isEmpty
              ? null
              : _messageCtrl.text.trim(),
          openDate: _openDate,
          memoryIds: _selectedMemoryIds.toList(),
        );

    if (!mounted) return;

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
      // 봉인 애니메이션 표시 후 시트 닫기
      await showSealAnimation(context, type: SealAnimationType.seal);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } else {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('캡슐 생성에 실패했습니다.')),
      );
    }
  }
}

/// 기억 선택 체크박스 리스트
class _MemorySelector extends ConsumerWidget {
  const _MemorySelector({
    required this.selectedIds,
    required this.onToggle,
  });

  final Set<String> selectedIds;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memoriesAsync = ref.watch(_allMemoriesProvider);

    return memoriesAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Text(
          '기억을 불러올 수 없습니다.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
      ),
      data: (memories) {
        if (memories.isEmpty) {
          return GlassCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Icon(Icons.info_outline,
                    color: AppColors.textTertiary, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    '아직 저장된 기억이 없습니다.\n기억을 먼저 추가해 주세요.',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return GlassCard(
          padding: EdgeInsets.zero,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 200),
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: memories.length,
              separatorBuilder: (_, __) =>
                  Divider(color: AppColors.glassBorder, height: 1),
              itemBuilder: (context, i) {
                final m = memories[i];
                final isSelected = selectedIds.contains(m.id);
                return ListTile(
                  dense: true,
                  leading: Icon(
                    _memoryIcon(m.type),
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textTertiary,
                    size: 20,
                  ),
                  title: Text(
                    m.title ?? m.type.label,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    _formatDate(m.createdAt),
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textTertiary,
                    ),
                  ),
                  trailing: Checkbox(
                    value: isSelected,
                    onChanged: (_) => onToggle(m.id),
                    activeColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4)),
                  ),
                  onTap: () => onToggle(m.id),
                );
              },
            ),
          ),
        );
      },
    );
  }

  IconData _memoryIcon(MemoryType type) => switch (type) {
        MemoryType.photo => Icons.photo_outlined,
        MemoryType.voice => Icons.mic_outlined,
        MemoryType.note => Icons.note_outlined,
      };

  String _formatDate(DateTime dt) =>
      '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')}';
}

/// 전체 기억 목록 (캡슐 기억 선택용)
final _allMemoriesProvider = StreamProvider<List<MemoryModel>>((ref) {
  return ref.watch(memoryRepositoryProvider).watchAll();
});
