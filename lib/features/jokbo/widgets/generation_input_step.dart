import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../design/glass/app_glass.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../design/tokens/app_spacing.dart';
import '../../../core/utils/haptic_service.dart';
import '../providers/jokbo_import_notifier.dart';

/// 세대별 가족 입력 스텝 위젯
class GenerationInputStep extends ConsumerStatefulWidget {
  const GenerationInputStep({
    super.key,
    required this.generation,
  });

  final int generation;

  @override
  ConsumerState<GenerationInputStep> createState() =>
      _GenerationInputStepState();
}

class _GenerationInputStepState extends ConsumerState<GenerationInputStep> {
  final _nameController = TextEditingController();
  String? _selectedGender;
  String? _selectedParentTempId;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final jokboState = ref.watch(jokboImportNotifierProvider);
    final currentEntries = jokboState.entries
        .where((e) => e.generation == widget.generation)
        .toList();
    final previousEntries = widget.generation > 1
        ? jokboState.entries
            .where((e) => e.generation == widget.generation - 1)
            .toList()
        : <JokboEntry>[];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 세대 헤더
          _buildHeader(),
          const SizedBox(height: AppSpacing.lg),

          // 힌트 텍스트
          if (widget.generation > 1)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Text(
                '이전 세대의 자녀를 추가하세요',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ),

          // 입력된 항목 목록
          if (currentEntries.isNotEmpty) ...[
            ...currentEntries.map((entry) => _buildEntryCard(
                  entry,
                  previousEntries,
                )),
            const SizedBox(height: AppSpacing.lg),
          ],

          // 새 인물 추가 폼
          _buildAddForm(previousEntries),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [AppColors.primaryMint, AppColors.primaryBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Text(
              '${widget.generation}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${widget.generation}세대 가족 추가',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                widget.generation == 1 ? '가장 윗세대 (조상)' : '${widget.generation - 1}세대의 자녀 세대',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEntryCard(
    JokboEntry entry,
    List<JokboEntry> previousEntries,
  ) {
    final parentName = entry.parentTempId != null
        ? previousEntries
            .where((e) => e.tempId == entry.parentTempId)
            .map((e) => e.name)
            .firstOrNull
        : null;

    final spouseName = entry.spouseTempId != null
        ? ref
            .read(jokboImportNotifierProvider)
            .entries
            .where((e) => e.tempId == entry.spouseTempId)
            .map((e) => e.name)
            .firstOrNull
        : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Dismissible(
        key: ValueKey(entry.tempId),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: AppSpacing.xl),
          decoration: BoxDecoration(
            color: AppColors.error.withAlpha(30),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.delete_outline, color: AppColors.error),
        ),
        onDismissed: (_) {
          HapticService.light();
          ref.read(jokboImportNotifierProvider.notifier).removeEntry(entry.tempId);
        },
        child: GlassCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              // 성별 아이콘
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: entry.gender == '남'
                      ? AppColors.primaryBlue.withAlpha(30)
                      : entry.gender == '여'
                          ? AppColors.accent.withAlpha(30)
                          : AppColors.glassSurface,
                ),
                child: Icon(
                  entry.gender == '남'
                      ? Icons.man
                      : entry.gender == '여'
                          ? Icons.woman
                          : Icons.person_outline,
                  size: 20,
                  color: entry.gender == '남'
                      ? AppColors.primaryBlue
                      : entry.gender == '여'
                          ? AppColors.accent
                          : AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              // 이름 및 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (parentName != null || spouseName != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        [
                          if (parentName != null) '$parentName의 자녀',
                          if (spouseName != null) '$spouseName의 배우자',
                        ].join(' · '),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // 삭제 버튼
              IconButton(
                icon: Icon(Icons.close, size: 18, color: AppColors.textTertiary),
                onPressed: () {
                  HapticService.light();
                  ref
                      .read(jokboImportNotifierProvider.notifier)
                      .removeEntry(entry.tempId);
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddForm(List<JokboEntry> previousEntries) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '새 인물 추가',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // 이름 입력
          TextField(
            controller: _nameController,
            style: TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              labelText: '이름 *',
              labelStyle: TextStyle(color: AppColors.textSecondary),
              hintText: '예: 홍길동',
              hintStyle: TextStyle(color: AppColors.textDisabled),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.glassBorder),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // 성별 선택
          Text(
            '성별',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              _GenderChip(
                label: '남',
                icon: Icons.man,
                isSelected: _selectedGender == '남',
                color: AppColors.primaryBlue,
                onTap: () {
                  HapticService.selection();
                  setState(() {
                    _selectedGender = _selectedGender == '남' ? null : '남';
                  });
                },
              ),
              const SizedBox(width: AppSpacing.sm),
              _GenderChip(
                label: '여',
                icon: Icons.woman,
                isSelected: _selectedGender == '여',
                color: AppColors.accent,
                onTap: () {
                  HapticService.selection();
                  setState(() {
                    _selectedGender = _selectedGender == '여' ? null : '여';
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // 부모 선택 (2세대 이상일 때만)
          if (previousEntries.isNotEmpty) ...[
            Text(
              '부모',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.sm),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.glassBorder),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButton<String?>(
                value: _selectedParentTempId,
                isExpanded: true,
                underline: const SizedBox(),
                hint: Text(
                  '부모 선택 (선택사항)',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                dropdownColor: AppColors.bgSurface,
                icon: Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
                items: [
                  DropdownMenuItem<String?>(
                    value: null,
                    child: Text(
                      '선택 안 함',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  ...previousEntries.map((parent) => DropdownMenuItem<String?>(
                        value: parent.tempId,
                        child: Text(
                          parent.name,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      )),
                ],
                onChanged: (v) {
                  HapticService.selection();
                  setState(() => _selectedParentTempId = v);
                },
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],

          // 추가 버튼
          SizedBox(
            width: double.infinity,
            child: GlassButton(
              onPressed: _addEntry,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add, color: AppColors.primary, size: 18),
                  const SizedBox(width: AppSpacing.sm),
                  const Text(
                    '추가',
                    style: TextStyle(
                      fontSize: 15,
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
    );
  }

  void _addEntry() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('이름을 입력하세요'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    HapticService.medium();
    ref.read(jokboImportNotifierProvider.notifier).addEntry(
          name: name,
          generation: widget.generation,
          gender: _selectedGender,
          parentTempId: _selectedParentTempId,
        );

    // 폼 초기화
    _nameController.clear();
    setState(() {
      _selectedGender = null;
      _selectedParentTempId = null;
    });
  }
}

/// 성별 선택 칩
class _GenderChip extends StatelessWidget {
  const _GenderChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: isSelected ? color.withAlpha(25) : Colors.transparent,
          border: Border.all(
            color: isSelected ? color : AppColors.glassBorder,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? color : AppColors.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? color : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
