import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/path_utils.dart';
import '../../../design/glass/app_glass.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../design/tokens/app_spacing.dart';
import '../../../design/tokens/app_radius.dart';
import '../../../shared/models/node_model.dart';
import '../../../shared/widgets/section_label.dart';
import '../providers/canvas_notifier.dart';
import '../providers/my_node_provider.dart';
import '../widgets/node_detail_sheet.dart';

/// 가족 목록 (섹션별 리스트 뷰) — 캔버스의 대체 보기 모드
///
/// "나" 노드를 기준으로 관계별 섹션(배우자/부모/자녀/형제/조부모/손주/기타/미확인)
/// 으로 그룹화하여 표시한다.
class FamilyListView extends ConsumerWidget {
  const FamilyListView({super.key});

  // ═══════════════════════════════════════════════════════════════════════════
  // ── 섹션 정의 ────────────────────────────────────────────────────────────
  // ═══════════════════════════════════════════════════════════════════════════

  /// 섹션 순서 및 한국어 라벨
  static const List<_SectionKind> _sectionOrder = [
    _SectionKind.me,
    _SectionKind.spouse,
    _SectionKind.parent,
    _SectionKind.child,
    _SectionKind.sibling,
    _SectionKind.grandparent,
    _SectionKind.grandchild,
    _SectionKind.other,
    _SectionKind.unknown,
  ];

  // ═══════════════════════════════════════════════════════════════════════════
  // ── build ────────────────────────────────────────────────────────────────
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canvasState = ref.watch(canvasNotifierProvider);
    final nodes = canvasState.nodes;
    final edges = canvasState.edges;
    final myNodeId = ref.watch(myNodeNotifierProvider).valueOrNull;

    return SafeArea(
      child: Column(
        children: [
          // 상단 여백 (AppBar 영역 확보)
          const SizedBox(height: 72),

          // ── 헤더: 가족 N명 ──────────────────────────────────────────────
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

          // ── 빈 상태 ──────────────────────────────────────────────────────
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

          // ── 섹션별 리스트 ────────────────────────────────────────────────
          if (nodes.isNotEmpty)
            Expanded(
              child: _buildSectionedList(
                context: context,
                nodes: nodes,
                edges: edges,
                myNodeId: myNodeId,
              ),
            ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ── 섹션별 리스트 빌드 ──────────────────────────────────────────────────
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildSectionedList({
    required BuildContext context,
    required List<NodeModel> nodes,
    required List<NodeEdge> edges,
    required String? myNodeId,
  }) {
    final groups = _groupByRelation(
      nodes: nodes,
      edges: edges,
      myNodeId: myNodeId,
    );

    // 관계 라벨 매핑 (각 노드에 대해 "나"와의 관계)
    final relationLabels = _buildRelationLabels(
      nodes: nodes,
      edges: edges,
      myNodeId: myNodeId,
    );

    // 비어있지 않은 섹션만 필터
    final activeSections = _sectionOrder
        .where((kind) => (groups[kind] ?? []).isNotEmpty)
        .toList();

    // 위젯 목록: 섹션 헤더 + 멤버 타일
    final items = <Widget>[];
    for (final kind in activeSections) {
      final members = groups[kind]!;
      // 섹션 헤더
      items.add(Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.sm,
        ),
        child: SectionLabel(label: '${kind.label} (${members.length})'),
      ));
      // 멤버 타일
      for (final node in members) {
        final isMe = myNodeId == node.id;
        final relationLabel = relationLabels[node.id];
        items.add(Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.xs,
          ),
          child: _FamilyMemberTile(
            node: node,
            isMe: isMe,
            relationLabel: relationLabel,
            onTap: () => _showNodeDetail(context, node.id),
          ),
        ));
      }
    }

    return ListView(
      padding: EdgeInsets.only(
        bottom: AppSpacing.bottomNavHeight + AppSpacing.xxl,
      ),
      children: items,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ── 관계별 그룹화 알고리즘 ──────────────────────────────────────────────
  // ═══════════════════════════════════════════════════════════════════════════

  /// "나" 노드(myNodeId) 기준으로 모든 노드를 관계 섹션으로 분류한다.
  ///
  /// myNodeId가 null이면 전체 목록을 "기타 가족"에 넣어 이름순 정렬한다.
  static Map<_SectionKind, List<NodeModel>> _groupByRelation({
    required List<NodeModel> nodes,
    required List<NodeEdge> edges,
    required String? myNodeId,
  }) {
    final groups = <_SectionKind, List<NodeModel>>{
      for (final kind in _sectionOrder) kind: [],
    };

    if (myNodeId == null) {
      // "나" 미설정 — 전체를 "기타 가족"에 이름순
      final sorted = List<NodeModel>.from(nodes)
        ..sort((a, b) => a.name.compareTo(b.name));
      groups[_SectionKind.other] = sorted;
      return groups;
    }

    // 에지에 연결된 노드 ID 집합 (미확인 판별용)
    final connectedNodeIds = <String>{};
    for (final e in edges) {
      connectedNodeIds.add(e.fromNodeId);
      connectedNodeIds.add(e.toNodeId);
    }

    // ── 1) "나" 직접 관계 (1촌) ─────────────────────────────────────────
    final mySpouses = <String>{};
    final myParents = <String>{};
    final myChildren = <String>{};
    final mySiblings = <String>{};

    for (final edge in edges) {
      final String targetId;
      final RelationType effectiveRelation;

      if (edge.fromNodeId == myNodeId) {
        targetId = edge.toNodeId;
        effectiveRelation = edge.relation;
      } else if (edge.toNodeId == myNodeId) {
        targetId = edge.fromNodeId;
        effectiveRelation = _reverseRelation(edge.relation);
      } else {
        continue;
      }

      switch (effectiveRelation) {
        case RelationType.spouse:
          mySpouses.add(targetId);
        case RelationType.parent:
          myParents.add(targetId);
        case RelationType.child:
          myChildren.add(targetId);
        case RelationType.sibling:
          mySiblings.add(targetId);
        case RelationType.other:
          break; // "기타"는 나중에 처리
      }
    }

    // ── 2) 조부모 (2촌 직계존속): 부모의 부모 ──────────────────────────────
    final grandparents = <String>{};
    for (final parentId in myParents) {
      for (final edge in edges) {
        final String targetId;
        final RelationType effectiveRelation;

        if (edge.fromNodeId == parentId) {
          targetId = edge.toNodeId;
          effectiveRelation = edge.relation;
        } else if (edge.toNodeId == parentId) {
          targetId = edge.fromNodeId;
          effectiveRelation = _reverseRelation(edge.relation);
        } else {
          continue;
        }

        if (effectiveRelation == RelationType.parent && targetId != myNodeId) {
          grandparents.add(targetId);
        }
      }
    }

    // ── 3) 손주 (2촌 직계비속): 자녀의 자녀 ──────────────────────────────
    final grandchildren = <String>{};
    for (final childId in myChildren) {
      for (final edge in edges) {
        final String targetId;
        final RelationType effectiveRelation;

        if (edge.fromNodeId == childId) {
          targetId = edge.toNodeId;
          effectiveRelation = edge.relation;
        } else if (edge.toNodeId == childId) {
          targetId = edge.fromNodeId;
          effectiveRelation = _reverseRelation(edge.relation);
        } else {
          continue;
        }

        if (effectiveRelation == RelationType.child && targetId != myNodeId) {
          grandchildren.add(targetId);
        }
      }
    }

    // ── 4) 분류 ────────────────────────────────────────────────────────────
    final assigned = <String>{myNodeId};
    assigned.addAll(mySpouses);
    assigned.addAll(myParents);
    assigned.addAll(myChildren);
    assigned.addAll(mySiblings);
    assigned.addAll(grandparents);
    assigned.addAll(grandchildren);

    for (final node in nodes) {
      if (node.id == myNodeId) {
        groups[_SectionKind.me]!.add(node);
      } else if (mySpouses.contains(node.id)) {
        groups[_SectionKind.spouse]!.add(node);
      } else if (myParents.contains(node.id)) {
        groups[_SectionKind.parent]!.add(node);
      } else if (myChildren.contains(node.id)) {
        groups[_SectionKind.child]!.add(node);
      } else if (mySiblings.contains(node.id)) {
        groups[_SectionKind.sibling]!.add(node);
      } else if (grandparents.contains(node.id)) {
        groups[_SectionKind.grandparent]!.add(node);
      } else if (grandchildren.contains(node.id)) {
        groups[_SectionKind.grandchild]!.add(node);
      } else if (node.isGhost && !connectedNodeIds.contains(node.id)) {
        groups[_SectionKind.unknown]!.add(node);
      } else {
        groups[_SectionKind.other]!.add(node);
      }
    }

    // 각 섹션 내 이름순 정렬 ("나" 섹션 제외)
    for (final kind in _sectionOrder) {
      if (kind == _SectionKind.me) continue;
      groups[kind]!.sort((a, b) => a.name.compareTo(b.name));
    }

    return groups;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ── 관계 라벨 매핑 ──────────────────────────────────────────────────────
  // ═══════════════════════════════════════════════════════════════════════════

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
        effectiveRelation = _reverseRelation(edge.relation);
      } else {
        continue;
      }

      // 커스텀 라벨이 있으면 우선 사용
      if (!labels.containsKey(targetId)) {
        labels[targetId] = edge.label ?? effectiveRelation.label;
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

// ═════════════════════════════════════════════════════════════════════════════
// ── 섹션 종류 enum ──────────────────────────────────────────────────────────
// ═════════════════════════════════════════════════════════════════════════════

enum _SectionKind {
  me('나'),
  spouse('배우자'),
  parent('부모'),
  child('자녀'),
  sibling('형제/자매'),
  grandparent('조부모'),
  grandchild('손주'),
  other('기타 가족'),
  unknown('미확인');

  const _SectionKind(this.label);
  final String label;
}

// ═════════════════════════════════════════════════════════════════════════════
// ── 가족 멤버 타일 (가로 카드) ──────────────────────────────────────────────
// ═════════════════════════════════════════════════════════════════════════════

class _FamilyMemberTile extends StatelessWidget {
  const _FamilyMemberTile({
    required this.node,
    required this.isMe,
    required this.relationLabel,
    required this.onTap,
  });

  final NodeModel node;
  final bool isMe;
  final String? relationLabel;
  final VoidCallback onTap;

  static const double _avatarSize = 48.0;

  @override
  Widget build(BuildContext context) {
    final isGhost = node.isGhost;

    return AnimatedOpacity(
      opacity: isGhost ? 0.55 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: GlassCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            // ── 아바타 ──────────────────────────────────────────────
            _buildAvatar(),
            const SizedBox(width: AppSpacing.md),

            // ── 이름 + 관계 + 생년월일 ──────────────────────────────
            Expanded(child: _buildInfo()),

            // ── 셰브론 ──────────────────────────────────────────────
            Icon(
              Icons.chevron_right,
              size: 20,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }

  // ── 아바타 ──────────────────────────────────────────────────────────────

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
          ),
        ),
        child: Icon(
          Icons.help_outline_rounded,
          color: AppColors.textTertiary,
          size: 22,
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
            PathUtils.resolveFile(node.photoPath) ?? File(node.photoPath!),
            width: _avatarSize,
            height: _avatarSize,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stack) => _initialAvatar(tempColor),
          ),
        ),
      );
    }

    // 사진 없는 경우: 이니셜
    return _initialAvatar(tempColor);
  }

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
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: borderColor,
          ),
        ),
      ),
    );
  }

  // ── 정보 영역 ──────────────────────────────────────────────────────────

  Widget _buildInfo() {
    final isGhost = node.isGhost;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── 이름 + "나" 배지 ──────────────────────────────────────
        Row(
          children: [
            Flexible(
              child: Text(
                node.displayName,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
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

        // ── 관계 라벨 ──────────────────────────────────────────────
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

        // ── Ghost 라벨 ────────────────────────────────────────────
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

        // ── 생년월일 ──────────────────────────────────────────────
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
    );
  }

  // ── 생년월일 포맷 ──────────────────────────────────────────────────────

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
