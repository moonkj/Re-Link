import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../design/glass/app_glass.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../design/tokens/app_spacing.dart';
import '../../../shared/models/node_model.dart';
import '../providers/canvas_notifier.dart';
import '../providers/node_notifier.dart';
import 'edit_node_sheet.dart';
import 'vibe_meter_sheet.dart';

/// 노드 상세 바텀시트
class NodeDetailSheet extends ConsumerWidget {
  const NodeDetailSheet({super.key, required this.nodeId});

  final String nodeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final node = ref.watch(canvasNodeProvider(nodeId));
    if (node == null) return const SizedBox.shrink();

    final tempColor = AppColors.tempColor(node.temperature);

    return GlassBottomSheet(
      padding: EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 헤더 (사진 + 이름)
          Container(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.md,
            ),
            child: Row(
              children: [
                // 아바타 (Hero transition from canvas NodeCard)
                Hero(
                  tag: 'node_avatar_${node.id}',
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: tempColor, width: 2.5),
                      color: AppColors.glassSurface,
                      image: node.photoPath != null
                          ? DecorationImage(
                              image: FileImage(File(node.photoPath!)),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: node.photoPath == null
                        ? Center(
                            child: Text(
                              node.name.isNotEmpty ? node.name[0] : '?',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        node.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (node.nickname != null)
                        Text(
                          node.nickname!,
                          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                        ),
                      if (node.birthDate != null)
                        Text(
                          '${node.birthDate!.year}년생'
                          '${node.isAlive ? '' : ' · ${node.deathDate!.year}년 사망'}',
                          style: const TextStyle(fontSize: 13, color: AppColors.textTertiary),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Ghost 노드 → 실제 인물 연결 배너
          if (node.isGhost)
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
              child: GlassCard(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                onTap: () => _convertGhost(context, ref, node),
                child: const Row(
                  children: [
                    Icon(Icons.person_add_outlined,
                        color: AppColors.secondary, size: 20),
                    SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        '실제 인물로 연결하기',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.secondary),
                      ),
                    ),
                    Icon(Icons.chevron_right,
                        color: AppColors.textTertiary, size: 20),
                  ],
                ),
              ),
            ),

          // 온도 슬라이더
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: _TemperatureSlider(node: node),
          ),
          const SizedBox(height: AppSpacing.md),

          // 액션 버튼 행
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    icon: Icons.edit_outlined,
                    label: '편집',
                    onTap: () => _openEdit(context, ref, node),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _ActionButton(
                    icon: Icons.photo_library_outlined,
                    label: '기억',
                    onTap: () {
                      Navigator.of(context).pop();
                      context.push(
                        AppRoutes.memoryPath(node.id),
                        extra: node.name,
                      );
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _ActionButton(
                    icon: Icons.link,
                    label: '연결',
                    onTap: () {
                      Navigator.of(context).pop();
                      ref.read(canvasNotifierProvider.notifier).startConnectMode(node.id);
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _ActionButton(
                    icon: Icons.delete_outline,
                    label: '삭제',
                    color: AppColors.error,
                    onTap: () => _confirmDelete(context, ref, node),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  void _openEdit(BuildContext context, WidgetRef ref, NodeModel node) {
    Navigator.of(context).pop();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EditNodeSheet(node: node),
    );
  }

  void _convertGhost(BuildContext context, WidgetRef ref, NodeModel node) {
    // Ghost 플래그를 false로 설정한 뒤 편집 시트 열기
    Navigator.of(context).pop();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EditNodeSheet(node: node.copyWith(isGhost: false)),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, NodeModel node) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgElevated,
        title: const Text('노드 삭제', style: TextStyle(color: AppColors.textPrimary)),
        content: Text(
          '${node.name}을(를) 삭제합니다.\n관련 기억과 관계도 모두 삭제됩니다.',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('취소')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('삭제', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (!context.mounted) return;
    Navigator.of(context).pop();
    await ref.read(nodeNotifierProvider.notifier).deleteNode(node.id);
  }
}

/// 온도 슬라이더
class _TemperatureSlider extends ConsumerWidget {
  const _TemperatureSlider({required this.node});
  final NodeModel node;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tempColor = AppColors.tempColor(node.temperature);
    const labels = ['냉담', '쌀쌀', '보통', '따뜻', '뜨거움', '열정'];

    return GlassCard(
      onTap: () => showModalBottomSheet<void>(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (_) => VibeMeterSheet(
          nodeId: node.id,
          initialTemperature: node.temperature,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
      child: Row(
        children: [
          Icon(Icons.thermostat, color: tempColor, size: 18),
          const SizedBox(width: AppSpacing.sm),
          Text(
            '온도: ${labels[node.temperature]}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: tempColor,
            ),
          ),
          const Spacer(),
          const Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 16),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = AppColors.textPrimary,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 11, color: color)),
        ],
      ),
    );
  }
}
