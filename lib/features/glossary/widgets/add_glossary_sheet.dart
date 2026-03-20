import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/haptic_service.dart';
import '../../../design/glass/app_glass.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../design/tokens/app_spacing.dart';
import '../../../shared/models/node_model.dart';
import '../../../shared/repositories/node_repository.dart';
import '../providers/glossary_notifier.dart';

/// 단어 추가 바텀시트
class AddGlossarySheet extends ConsumerStatefulWidget {
  const AddGlossarySheet({super.key});

  @override
  ConsumerState<AddGlossarySheet> createState() => _AddGlossarySheetState();
}

class _AddGlossarySheetState extends ConsumerState<AddGlossarySheet> {
  final _wordCtrl = TextEditingController();
  final _meaningCtrl = TextEditingController();
  final _exampleCtrl = TextEditingController();
  bool _saving = false;

  // 선택된 노드 (누가 쓰는 표현인지)
  NodeModel? _selectedNode;

  @override
  void dispose() {
    _wordCtrl.dispose();
    _meaningCtrl.dispose();
    _exampleCtrl.dispose();
    super.dispose();
  }

  bool get _isValid =>
      _wordCtrl.text.trim().isNotEmpty && _meaningCtrl.text.trim().isNotEmpty;

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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 헤더 ──────────────────────────────────────────────
          Text(
            '새 표현 등록',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '가족만의 특별한 표현을 기록하세요',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // ── 단어 (필수) ──────────────────────────────────────
          TextField(
            controller: _wordCtrl,
            style: TextStyle(color: AppColors.textPrimary),
            onChanged: (_) => setState(() {}),
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: '표현 *',
              hintText: '예: 깜순이',
              labelStyle: TextStyle(color: AppColors.textSecondary),
              hintStyle: TextStyle(color: AppColors.textTertiary),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.glassBorder),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── 뜻 (필수) ───────────────────────────────────────
          TextField(
            controller: _meaningCtrl,
            style: TextStyle(color: AppColors.textPrimary),
            onChanged: (_) => setState(() {}),
            textInputAction: TextInputAction.next,
            maxLines: 2,
            minLines: 1,
            decoration: InputDecoration(
              labelText: '뜻 *',
              hintText: '예: 외할머니가 나를 부르던 별명',
              labelStyle: TextStyle(color: AppColors.textSecondary),
              hintStyle: TextStyle(color: AppColors.textTertiary),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.glassBorder),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── 예문 (선택) ─────────────────────────────────────
          TextField(
            controller: _exampleCtrl,
            style: TextStyle(color: AppColors.textPrimary),
            textInputAction: TextInputAction.done,
            maxLines: 2,
            minLines: 1,
            decoration: InputDecoration(
              labelText: '사용 예시 (선택)',
              hintText: '예: "깜순아, 밥 먹으렴~"',
              labelStyle: TextStyle(color: AppColors.textSecondary),
              hintStyle: TextStyle(color: AppColors.textTertiary),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.glassBorder),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // ── 노드 선택 (누가 쓰는 표현?) ─────────────────────
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
                border: Border.all(color: AppColors.glassBorder, width: 0.5),
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
                      _selectedNode?.name ?? '누가 쓰는 표현인가요? (선택)',
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
                      child: Icon(Icons.close, size: 16,
                          color: AppColors.textTertiary),
                    )
                  else
                    Icon(Icons.chevron_right, size: 18,
                        color: AppColors.textTertiary),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // ── 등록 버튼 ──────────────────────────────────────
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
    );
  }

  // ── 노드 선택 바텀시트 ──────────────────────────────────────────────────────

  Future<void> _pickNode() async {
    HapticService.light();
    final nodes = await ref.read(nodeRepositoryProvider).getAll();
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

  // ── 저장 ───────────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    if (!_isValid) return;
    setState(() => _saving = true);

    final id = await ref.read(glossaryNotifierProvider.notifier).create(
          word: _wordCtrl.text.trim(),
          meaning: _meaningCtrl.text.trim(),
          example: _exampleCtrl.text.trim().isEmpty
              ? null
              : _exampleCtrl.text.trim(),
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

// ── 노드 선택 시트 ─────────────────────────────────────────────────────────────

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
            '누가 쓰는 표현인가요?',
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
                      style: const TextStyle(
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
                      ? Icon(Icons.blur_on, size: 14,
                          color: AppColors.textTertiary)
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
