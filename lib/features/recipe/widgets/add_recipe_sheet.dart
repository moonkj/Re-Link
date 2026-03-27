import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/utils/haptic_service.dart';
import '../../../core/utils/path_utils.dart';
import '../../../design/glass/app_glass.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../design/tokens/app_spacing.dart';
import '../../../shared/models/node_model.dart';
import '../../../shared/repositories/node_repository.dart';
import '../providers/recipe_notifier.dart';

/// 레시피 추가 바텀시트
class AddRecipeSheet extends ConsumerStatefulWidget {
  const AddRecipeSheet({super.key});

  @override
  ConsumerState<AddRecipeSheet> createState() => _AddRecipeSheetState();
}

class _AddRecipeSheetState extends ConsumerState<AddRecipeSheet> {
  final _titleCtrl = TextEditingController();
  final _ingredientsCtrl = TextEditingController();
  final _instructionsCtrl = TextEditingController();
  bool _saving = false;

  /// 선택된 사진 경로
  String? _photoPath;

  /// 선택된 노드 (누구의 레시피인지)
  NodeModel? _selectedNode;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _ingredientsCtrl.dispose();
    _instructionsCtrl.dispose();
    super.dispose();
  }

  bool get _isValid =>
      _titleCtrl.text.trim().isNotEmpty &&
      _ingredientsCtrl.text.trim().isNotEmpty &&
      _instructionsCtrl.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return GlassBottomSheet(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xxl,
        AppSpacing.xxl,
        AppSpacing.xxl,
        AppSpacing.xxl + bottomInset,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // -- 헤더 -------------------------------------------------
            Text(
              '새 레시피 등록',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '가족의 특별한 레시피를 기록하세요',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // -- 사진 선택 --------------------------------------------
            GestureDetector(
              onTap: _pickPhoto,
              child: Container(
                width: double.infinity,
                height: 140,
                decoration: BoxDecoration(
                  color: AppColors.glassSurface,
                  borderRadius: BorderRadius.circular(14),
                  border:
                      Border.all(color: AppColors.glassBorder, width: 0.5),
                  image: _photoPath != null
                      ? DecorationImage(
                          image: PathUtils.resolveFileImage(_photoPath) ??
                              FileImage(File(_photoPath!)),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _photoPath == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_a_photo_outlined,
                            size: 32,
                            color: AppColors.textTertiary,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            '사진 추가 (선택)',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      )
                    : Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          child: GestureDetector(
                            onTap: () => setState(() => _photoPath = null),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // -- 레시피 이름 (필수) ------------------------------------
            TextField(
              controller: _titleCtrl,
              style: TextStyle(color: AppColors.textPrimary),
              onChanged: (_) => setState(() {}),
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: '레시피 이름 *',
                hintText: '예: 할머니의 된장찌개',
                labelStyle: TextStyle(color: AppColors.textSecondary),
                hintStyle: TextStyle(color: AppColors.textTertiary),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.glassBorder),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primary),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // -- 재료 (필수) -------------------------------------------
            TextField(
              controller: _ingredientsCtrl,
              style: TextStyle(color: AppColors.textPrimary),
              onChanged: (_) => setState(() {}),
              textInputAction: TextInputAction.next,
              maxLines: 4,
              minLines: 2,
              decoration: InputDecoration(
                labelText: '재료 *',
                hintText: '한 줄에 하나씩 입력\n예:\n된장 2큰술\n두부 반 모\n감자 1개',
                labelStyle: TextStyle(color: AppColors.textSecondary),
                hintStyle: TextStyle(color: AppColors.textTertiary),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.glassBorder),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primary),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // -- 만드는 법 (필수) --------------------------------------
            TextField(
              controller: _instructionsCtrl,
              style: TextStyle(color: AppColors.textPrimary),
              onChanged: (_) => setState(() {}),
              textInputAction: TextInputAction.done,
              maxLines: 5,
              minLines: 2,
              decoration: InputDecoration(
                labelText: '만드는 법 *',
                hintText:
                    '한 줄에 한 단계씩\n예:\n멸치 육수를 끓인다\n된장을 풀어 넣는다\n두부와 감자를 넣는다',
                labelStyle: TextStyle(color: AppColors.textSecondary),
                hintStyle: TextStyle(color: AppColors.textTertiary),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.glassBorder),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primary),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // -- 노드 선택 (누구의 레시피?) ----------------------------
            GestureDetector(
              onTap: _pickNode,
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: AppColors.glassSurface,
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: AppColors.glassBorder, width: 0.5),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 18,
                      color: _selectedNode != null
                          ? AppColors.primary
                          : AppColors.textTertiary,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        _selectedNode?.name ?? '누구의 레시피인가요? (선택)',
                        style: TextStyle(
                          fontSize: 14,
                          color: _selectedNode != null
                              ? AppColors.textPrimary
                              : AppColors.textTertiary,
                        ),
                      ),
                    ),
                    if (_selectedNode != null)
                      GestureDetector(
                        onTap: () => setState(() => _selectedNode = null),
                        child: Icon(Icons.close,
                            size: 16, color: AppColors.textTertiary),
                      )
                    else
                      Icon(Icons.chevron_right,
                          size: 18, color: AppColors.textTertiary),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // -- 등록 버튼 --------------------------------------------
            SizedBox(
              width: double.infinity,
              child: PrimaryGlassButton(
                label: '등록하기',
                isLoading: _saving,
                onPressed: _isValid ? _submit : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -- 사진 선택 -------------------------------------------------------

  Future<void> _pickPhoto() async {
    HapticService.light();
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      imageQuality: 85,
    );
    if (picked != null && mounted) {
      setState(() => _photoPath = picked.path);
    }
  }

  // -- 노드 선택 바텀시트 -----------------------------------------------

  Future<void> _pickNode() async {
    HapticService.light();
    final nodes = await ref.read(nodeRepositoryProvider).getControllableNodes();
    if (!mounted || nodes.isEmpty) return;

    final picked = await showModalBottomSheet<NodeModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _NodePickerSheet(nodes: nodes),
    );

    if (picked != null && mounted) {
      setState(() => _selectedNode = picked);
    }
  }

  // -- 저장 -------------------------------------------------------------

  Future<void> _submit() async {
    if (!_isValid) return;
    setState(() => _saving = true);

    final id = await ref.read(recipeNotifierProvider.notifier).create(
          title: _titleCtrl.text.trim(),
          ingredients: _ingredientsCtrl.text.trim(),
          instructions: _instructionsCtrl.text.trim(),
          photoPath: _photoPath,
          nodeId: _selectedNode?.id,
        );

    if (!mounted) return;
    setState(() => _saving = false);

    if (id != null) {
      HapticService.medium();
      Navigator.of(context).pop(true);
    }
  }
}

// -- 노드 선택 시트 --------------------------------------------------------

class _NodePickerSheet extends StatelessWidget {
  const _NodePickerSheet({required this.nodes});
  final List<NodeModel> nodes;

  @override
  Widget build(BuildContext context) {
    return GlassBottomSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '누구의 레시피인가요?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.4,
            ),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: nodes.length,
              separatorBuilder: (_, __) =>
                  Divider(color: AppColors.glassBorder, height: 1),
              itemBuilder: (ctx, i) {
                final node = nodes[i];
                return ListTile(
                  leading: CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.primary.withAlpha(30),
                    child: Text(
                      node.name.isNotEmpty ? node.name[0] : '?',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  title: Text(
                    node.name,
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  subtitle: node.nickname != null
                      ? Text(
                          node.nickname!,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        )
                      : null,
                  trailing: node.isGhost
                      ? Icon(Icons.blur_on,
                          size: 14, color: AppColors.textTertiary)
                      : null,
                  onTap: () {
                    HapticService.light();
                    Navigator.of(ctx).pop(node);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
