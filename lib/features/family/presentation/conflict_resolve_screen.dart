import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../design/glass/app_glass.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../design/tokens/app_spacing.dart';
import '../providers/merge_preview_notifier.dart';

/// 개별 충돌 해결 화면
///
/// 내 노드 vs 상대방 노드를 나란히 보여주고 선택
class ConflictResolveScreen extends ConsumerStatefulWidget {
  const ConflictResolveScreen({
    super.key,
    required this.conflict,
    required this.initialResolution,
  });

  final MergeConflict conflict;
  final ConflictResolution initialResolution;

  @override
  ConsumerState<ConflictResolveScreen> createState() =>
      _ConflictResolveScreenState();
}

class _ConflictResolveScreenState
    extends ConsumerState<ConflictResolveScreen> {
  late ConflictResolution _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialResolution;
  }

  void _apply() {
    ref
        .read(mergePreviewNotifierProvider.notifier)
        .setResolution(widget.conflict.nodeId, _selected);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.conflict;

    return Scaffold(
      backgroundColor: AppColors.bgBase,
      appBar: AppBar(
        backgroundColor: AppColors.bgBase,
        title: const Text(
          '충돌 해결',
          style: TextStyle(
              color: AppColors.textPrimary, fontWeight: FontWeight.w700),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                const Text(
                  '같은 ID의 인물이 두 곳에 존재합니다.\n어떤 버전을 사용할지 선택하세요.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                ),
                const SizedBox(height: AppSpacing.lg),

                // ── 내 버전 ────────────────────────────────────────────────
                _VersionCard(
                  title: '내 버전',
                  node: c.myNode,
                  isSelected: _selected == ConflictResolution.mine,
                  onTap: () => setState(() => _selected = ConflictResolution.mine),
                  selectionColor: AppColors.primary,
                ),
                const SizedBox(height: AppSpacing.md),

                // ── 가져온 버전 ────────────────────────────────────────────
                _VersionCard(
                  title: '가져온 버전',
                  node: c.theirNode,
                  isSelected: _selected == ConflictResolution.theirs,
                  onTap: () =>
                      setState(() => _selected = ConflictResolution.theirs),
                  selectionColor: AppColors.secondary,
                ),
                const SizedBox(height: AppSpacing.md),

                // ── 둘 다 유지 ────────────────────────────────────────────
                GlassCard(
                  onTap: () => setState(() => _selected = ConflictResolution.both),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      Icon(
                        Icons.call_split,
                        color: _selected == ConflictResolution.both
                            ? AppColors.accent
                            : AppColors.textSecondary,
                        size: 20,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '둘 다 유지',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: _selected == ConflictResolution.both
                                    ? AppColors.accent
                                    : AppColors.textPrimary,
                              ),
                            ),
                            const Text(
                              '가져온 버전이 새 이름으로 복사됩니다',
                              style: TextStyle(
                                  color: AppColors.textSecondary, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      if (_selected == ConflictResolution.both)
                        const Icon(Icons.check_circle,
                            color: AppColors.accent, size: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── 확인 버튼 ───────────────────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: SizedBox(
                width: double.infinity,
                child: PrimaryGlassButton(label: '선택 완료', onPressed: _apply),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VersionCard extends StatelessWidget {
  const _VersionCard({
    required this.title,
    required this.node,
    required this.isSelected,
    required this.onTap,
    required this.selectionColor,
  });

  final String title;
  final dynamic node; // NodeModel
  final bool isSelected;
  final VoidCallback onTap;
  final Color selectionColor;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? selectionColor.withAlpha(40) : Colors.white10,
              border: Border.all(
                color: isSelected ? selectionColor : Colors.white24,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: const Icon(Icons.person, color: Colors.white70, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    color: isSelected ? selectionColor : AppColors.textTertiary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  node.name as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    fontSize: 16,
                  ),
                ),
                if ((node.bio as String?) != null)
                  Text(
                    node.bio as String,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          if (isSelected)
            Icon(Icons.check_circle, color: selectionColor, size: 22),
        ],
      ),
    );
  }
}
