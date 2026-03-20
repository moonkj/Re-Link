import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../design/glass/app_glass.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../design/tokens/app_spacing.dart';
import '../../../design/tokens/app_radius.dart';
import '../../../shared/models/node_model.dart';
import '../providers/canvas_notifier.dart';
import '../providers/my_node_provider.dart';
import '../utils/generation_utils.dart';
import '../widgets/node_detail_sheet.dart';

/// 가족 목록 (카드 그리드 뷰) — 캔버스의 대체 보기 모드
class FamilyListView extends ConsumerWidget {
  const FamilyListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canvasState = ref.watch(canvasNotifierProvider);
    final nodes = canvasState.nodes;
    final edges = canvasState.edges;
    final myNodeId = ref.watch(myNodeNotifierProvider).valueOrNull;

    // 세대 깊이 계산
    final generations = computeGenerations(nodes: nodes, edges: edges);

    // 정렬: 세대(generation) 오름차순, 같은 세대 내 이름순, Ghost는 마지막
    final sorted = List<NodeModel>.from(nodes)
      ..sort((a, b) {
        // Ghost 노드는 항상 마지막
        if (a.isGhost != b.isGhost) return a.isGhost ? 1 : -1;
        // 세대 오름차순
        final genA = generations[a.id] ?? 0;
        final genB = generations[b.id] ?? 0;
        if (genA != genB) return genA.compareTo(genB);
        // 이름 알파벳순
        return a.name.compareTo(b.name);
      });

    // "나" 노드와의 관계 라벨 매핑
    final relationLabels = _buildRelationLabels(
      nodes: nodes,
      edges: edges,
      myNodeId: myNodeId,
    );

    // 반응형 그리드 열 수 (폰: 2, 태블릿: 3)
    final screenWidth = MediaQuery.sizeOf(context).width;
    final crossAxisCount = screenWidth >= 600 ? 3 : 2;

    return SafeArea(
      child: Column(
        children: [
          // 상단 여백 (AppBar 영역 확보)
          const SizedBox(height: 72),

          // ── 헤더: 가족 N명 ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(25),
                    borderRadius: AppRadius.chipRadius,
                  ),
                  child: Text(
                    '가족 ${nodes.length}명',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),

          // ── 빈 상태 ────────────────────────────────────────────────
          if (nodes.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 64,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      '아직 가족이 없어요',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      '+ 버튼으로 첫 번째 인물을 추가하세요',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // ── 카드 그리드 ────────────────────────────────────────────
          if (nodes.isNotEmpty)
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.sm,
                  AppSpacing.lg,
                  AppSpacing.bottomNavHeight + AppSpacing.xxl,
                ),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: AppSpacing.md,
                  mainAxisSpacing: AppSpacing.md,
                  childAspectRatio: 0.85,
                ),
                itemCount: sorted.length,
                itemBuilder: (context, index) {
                  final node = sorted[index];
                  final isMe = myNodeId == node.id;
                  final relationLabel = relationLabels[node.id];
                  return _FamilyMemberCard(
                    node: node,
                    isMe: isMe,
                    relationLabel: relationLabel,
                    onTap: () => _showNodeDetail(context, node.id),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  /// "나" 노드 기준으로 각 노드의 관계 라벨 생성
  static Map<String, String> _buildRelationLabels({
    required List<NodeModel> nodes,
    required List<NodeEdge> edges,
    required String? myNodeId,
  }) {
    final labels = <String, String>{};
    if (myNodeId == null) return labels;

    for (final edge in edges) {
      final String targetId;
      final RelationType effectiveRelation;

      if (edge.fromNodeId == myNodeId) {
        targetId = edge.toNodeId;
        effectiveRelation = edge.relation;
      } else if (edge.toNodeId == myNodeId) {
        targetId = edge.fromNodeId;
        // 역방향 관계 변환
        effectiveRelation = _reverseRelation(edge.relation);
      } else {
        continue;
      }

      if (!labels.containsKey(targetId)) {
        labels[targetId] = effectiveRelation.label;
      }
    }

    return labels;
  }

  /// 역방향 관계 타입 변환 (parent <-> child)
  static RelationType _reverseRelation(RelationType type) {
    return switch (type) {
      RelationType.parent => RelationType.child,
      RelationType.child => RelationType.parent,
      RelationType.spouse => RelationType.spouse,
      RelationType.sibling => RelationType.sibling,
      RelationType.other => RelationType.other,
    };
  }

  static void _showNodeDetail(BuildContext context, String nodeId) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => NodeDetailSheet(nodeId: nodeId),
    );
  }
}

/// 개별 가족 멤버 카드
class _FamilyMemberCard extends StatelessWidget {
  const _FamilyMemberCard({
    required this.node,
    required this.isMe,
    required this.relationLabel,
    required this.onTap,
  });

  final NodeModel node;
  final bool isMe;
  final String? relationLabel;
  final VoidCallback onTap;

  static const double _avatarSize = 64.0;

  @override
  Widget build(BuildContext context) {
    final isGhost = node.isGhost;

    return AnimatedOpacity(
      opacity: isGhost ? 0.55 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: GlassCard(
        onTap: onTap,
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Container(
          decoration: isGhost
              ? BoxDecoration(
                  borderRadius: AppRadius.glassCard,
                  border: Border.all(
                    color: AppColors.nodeBorderGhost,
                    width: 1.5,
                    strokeAlign: BorderSide.strokeAlignOutside,
                  ),
                )
              : null,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ── 아바타 ──────────────────────────────────────────
              _buildAvatar(),
              const SizedBox(height: AppSpacing.sm),

              // ── 이름 + "나" 배지 ──────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      node.displayName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isGhost
                            ? AppColors.textTertiary
                            : AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isMe) ...[
                    const SizedBox(width: AppSpacing.xs),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(30),
                        borderRadius: AppRadius.chipRadius,
                      ),
                      child: const Text(
                        '나',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryMint,
                        ),
                      ),
                    ),
                  ],
                ],
              ),

              // ── 관계 라벨 ──────────────────────────────────────
              if (relationLabel != null && !isMe) ...[
                const SizedBox(height: 2),
                Text(
                  relationLabel!,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              // ── Ghost 라벨 ─────────────────────────────────────
              if (isGhost && relationLabel == null) ...[
                const SizedBox(height: 2),
                Text(
                  '미확인 인물',
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],

              // ── 생년월일 ──────────────────────────────────────
              if (node.birthDate != null) ...[
                const SizedBox(height: 2),
                Text(
                  _formatBirthDate(node.birthDate!, node.deathDate),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textTertiary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// 아바타: 사진이 있으면 원형 사진, 없으면 이니셜 배경
  Widget _buildAvatar() {
    final tempColor = AppColors.tempColor(node.temperature);
    final isGhost = node.isGhost;

    // Ghost 노드: 물음표 아이콘
    if (isGhost) {
      return Container(
        width: _avatarSize,
        height: _avatarSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.nodeGhost.withAlpha(30),
          border: Border.all(
            color: AppColors.nodeBorderGhost,
            width: 1.5,
            style: BorderStyle.solid,
          ),
        ),
        child: Icon(
          Icons.help_outline_rounded,
          color: AppColors.textTertiary,
          size: 28,
        ),
      );
    }

    // 사진이 있는 경우
    if (node.photoPath != null && node.photoPath!.isNotEmpty) {
      return Container(
        width: _avatarSize,
        height: _avatarSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: tempColor, width: 2.0),
        ),
        child: ClipOval(
          child: Image.file(
            File(node.photoPath!),
            width: _avatarSize,
            height: _avatarSize,
            fit: BoxFit.cover,
            // ignore: unnecessary_underscores
            errorBuilder: (_, __, ___) => _initialAvatar(tempColor),
          ),
        ),
      );
    }

    // 사진 없는 경우: 이니셜
    return _initialAvatar(tempColor);
  }

  /// 이니셜 기반 아바타
  Widget _initialAvatar(Color borderColor) {
    final initial = node.name.isNotEmpty ? node.name.characters.first : '?';
    return Container(
      width: _avatarSize,
      height: _avatarSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: borderColor.withAlpha(30),
        border: Border.all(color: borderColor, width: 2.0),
      ),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: borderColor,
          ),
        ),
      ),
    );
  }

  /// 생년월일 포맷 (사망일이 있으면 함께 표시)
  static String _formatBirthDate(DateTime birth, DateTime? death) {
    final birthStr =
        '${birth.year}.${birth.month.toString().padLeft(2, '0')}.${birth.day.toString().padLeft(2, '0')}';
    if (death != null) {
      final deathStr =
          '${death.year}.${death.month.toString().padLeft(2, '0')}.${death.day.toString().padLeft(2, '0')}';
      return '$birthStr ~ $deathStr';
    }
    return birthStr;
  }
}
