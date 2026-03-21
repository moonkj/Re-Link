import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../design/glass/app_glass.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../design/tokens/app_spacing.dart';
import '../providers/merge_preview_notifier.dart';
import 'conflict_resolve_screen.dart';

/// .rlink 병합 미리보기 화면
///
/// BackupScreen에서 .rlink 가져오기 시 이 화면으로 라우팅
class MergePreviewScreen extends ConsumerStatefulWidget {
  const MergePreviewScreen({super.key, required this.rlinkPath});
  final String rlinkPath;

  @override
  ConsumerState<MergePreviewScreen> createState() => _MergePreviewScreenState();
}

class _MergePreviewScreenState extends ConsumerState<MergePreviewScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(mergePreviewNotifierProvider.notifier).loadRlink(widget.rlinkPath);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mergePreviewNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.bgBase,
      appBar: AppBar(
        backgroundColor: AppColors.bgBase,
        title: Text(
          '가족 트리 가져오기',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      body: state.isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.primary))
          : state.error != null
              ? _ErrorView(error: state.error!)
              : _PreviewBody(state: state),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error});
  final String error;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 48),
            const SizedBox(height: AppSpacing.lg),
            Text(error,
                style: TextStyle(color: AppColors.textSecondary),
                textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.lg),
            PrimaryGlassButton(
              label: '돌아가기',
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewBody extends ConsumerWidget {
  const _PreviewBody({required this.state});
  final MergePreviewState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        // ── 요약 카드 ───────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: GlassCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                _StatChip(
                  icon: Icons.person_add_outlined,
                  label: '새 인물',
                  count: state.newNodes.length,
                  color: AppColors.primary,
                ),
                const SizedBox(width: AppSpacing.md),
                _StatChip(
                  icon: Icons.warning_amber_outlined,
                  label: '충돌',
                  count: state.conflicts.length,
                  color: AppColors.warning,
                ),
              ],
            ),
          ),
        ),

        // ── 목록 ───────────────────────────────────────────────────────────
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            children: [
              if (state.newNodes.isNotEmpty) ...[
                const _SectionHeader(title: '새로 추가될 인물'),
                ...state.newNodes.map((node) => _NodeTile(
                      name: node.name,
                      subtitle: node.isGhost ? '미확인 인물' : '일반 인물',
                      icon: node.isGhost
                          ? Icons.help_outline
                          : Icons.person_outline,
                      color: AppColors.primary,
                    )),
              ],
              if (state.conflicts.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                const _SectionHeader(title: '충돌 — 해결 필요'),
                ...state.conflicts.map((c) => _ConflictTile(
                      conflict: c,
                      resolution:
                          state.resolutions[c.nodeId] ?? ConflictResolution.mine,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => ConflictResolveScreen(
                            conflict: c,
                            initialResolution: state.resolutions[c.nodeId] ??
                                ConflictResolution.mine,
                          ),
                        ),
                      ),
                    )),
              ],
              if (state.totalIncoming == 0)
                Padding(
                  padding: EdgeInsets.all(AppSpacing.xxl),
                  child: Center(
                    child: Text(
                      '가져올 새로운 인물이 없습니다',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),

        // ── 실행 버튼 ───────────────────────────────────────────────────────
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: SizedBox(
              width: double.infinity,
              child: PrimaryGlassButton(
                label: '병합하기 (${state.totalIncoming}명)',
                isLoading: state.isLoading,
                onPressed: state.totalIncoming == 0
                    ? null
                    : () async {
                        final ok = await ref
                            .read(mergePreviewNotifierProvider.notifier)
                            .applyMerge();
                        if (!context.mounted) return;
                        if (ok) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('병합 완료!'),
                              backgroundColor: AppColors.primary,
                            ),
                          );
                          Navigator.of(context).pop();
                        } else {
                          final err =
                              ref.read(mergePreviewNotifierProvider).error;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(err ?? '병합 실패'),
                              backgroundColor: AppColors.error,
                            ),
                          );
                        }
                      },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
  });
  final IconData icon;
  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: AppSpacing.xs),
        RichText(
          text: TextSpan(children: [
            TextSpan(
              text: '$count',
              style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w700, color: color,
              ),
            ),
            TextSpan(
              text: ' $label',
              style: TextStyle(
                fontSize: 13, color: AppColors.textSecondary,
              ),
            ),
          ]),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12, fontWeight: FontWeight.w600,
          color: AppColors.textSecondary, letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _NodeTile extends StatelessWidget {
  const _NodeTile({
    required this.name,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
  final String name;
  final String subtitle;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600)),
                  Text(subtitle,
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConflictTile extends StatelessWidget {
  const _ConflictTile({
    required this.conflict,
    required this.resolution,
    required this.onTap,
  });
  final MergeConflict conflict;
  final ConflictResolution resolution;
  final VoidCallback onTap;

  String get _resolutionLabel => switch (resolution) {
        ConflictResolution.mine => '내 것 유지',
        ConflictResolution.theirs => '가져온 것 사용',
        ConflictResolution.both => '둘 다 유지',
      };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: GlassCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            const Icon(Icons.warning_amber_outlined,
                color: AppColors.warning, size: 20),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(conflict.myNode.name,
                      style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600)),
                  Text(
                    _resolutionLabel,
                    style: const TextStyle(
                        color: AppColors.warning, fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right,
                color: AppColors.textSecondary, size: 18),
          ],
        ),
      ),
    );
  }
}
