import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/router/app_router.dart';
import '../../../design/glass/app_glass.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../design/tokens/app_spacing.dart';
import '../../../shared/models/memory_model.dart';
import '../../../shared/models/node_model.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../memory/providers/memory_notifier.dart';
import '../providers/canvas_notifier.dart';
import '../providers/node_notifier.dart';
import '../../temperature/widgets/quick_temp_entry.dart';
import '../../bouquet/widgets/bouquet_on_node.dart';
import '../../bouquet/widgets/flower_picker.dart';
import '../../art_card/presentation/art_card_screen.dart';
import 'edit_node_sheet.dart';
import 'node_card.dart';
import 'vibe_meter_sheet.dart';

/// 노드 상세 바텀시트 (4탭 구조: 타임라인 / 메모 / 음성 / 관계)
class NodeDetailSheet extends ConsumerStatefulWidget {
  const NodeDetailSheet({super.key, required this.nodeId});

  final String nodeId;

  @override
  ConsumerState<NodeDetailSheet> createState() => _NodeDetailSheetState();
}

class _NodeDetailSheetState extends ConsumerState<NodeDetailSheet>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final node = ref.watch(canvasNodeProvider(widget.nodeId));
    if (node == null) return const SizedBox.shrink();

    final tempColor = AppColors.tempColor(node.temperature);

    return GlassBottomSheet(
      padding: EdgeInsets.zero,
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.72,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── 헤더 (사진 + 이름) ──────────────────────────────────────
            _Header(
              node: node,
              tempColor: tempColor,
              onAvatarTap: () => _showPhotoFullScreen(context, node),
              onTempTap: () => _showVibeMeter(context, node),
            ),

            // ── 온도 일기 바로가기 ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.xs,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GlassCard(
                      onTap: () => _openQuickTempEntry(context, node),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.edit_calendar,
                              color: tempColor, size: 16),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            '온도 일기',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: tempColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: GlassCard(
                      onTap: () {
                        Navigator.of(context).pop();
                        context.push(
                          AppRoutes.temperatureDiaryPath(node.id),
                          extra: node.name,
                        );
                      },
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.show_chart,
                              color: AppColors.primary, size: 16),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            '그래프 보기',
                            style: TextStyle(
                              fontSize: 13,
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
            ),

            // ── Ghost 노드 배너 ─────────────────────────────────────────
            if (node.isGhost) ...[
              // Ghost 라벨 표시
              Builder(builder: (context) {
                final edges = ref.watch(canvasNotifierProvider).edges;
                final label = resolveGhostLabel(node, edges);
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
                  child: Row(
                    children: [
                      Icon(Icons.help_outline,
                          color: AppColors.textTertiary, size: 16),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              }),
              // 실제 인물로 연결하기
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                child: GlassCard(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                  onTap: () => _convertGhost(context, ref, node),
                  child: Row(
                    children: [
                      const Icon(Icons.person_add_outlined,
                          color: AppColors.secondary, size: 20),
                      const SizedBox(width: AppSpacing.sm),
                      const Expanded(
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
              // 채우기 유도 CTA — 가족에게 공유
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg),
                child: GlassCard(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                  onTap: () => _shareGhostInfo(node),
                  child: Row(
                    children: [
                      const Icon(Icons.share_outlined,
                          color: AppColors.primary, size: 20),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '이 분을 알고 계신 가족이 있나요?',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary),
                            ),
                            SizedBox(height: 2),
                            Text(
                              '가족에게 물어보기',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textTertiary),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right,
                          color: AppColors.textTertiary, size: 20),
                    ],
                  ),
                ),
              ),
            ],

            // ── TabBar ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Theme(
                data: Theme.of(context).copyWith(
                  tabBarTheme: TabBarThemeData(
                    dividerColor: Colors.transparent,
                  ),
                ),
                child: TabBar(
                  controller: _tabController,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textTertiary,
                  indicatorColor: AppColors.primary,
                  indicatorSize: TabBarIndicatorSize.label,
                  labelStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                  tabs: const [
                    Tab(text: '타임라인'),
                    Tab(text: '메모'),
                    Tab(text: '음성'),
                    Tab(text: '관계'),
                  ],
                ),
              ),
            ),

            // ── TabBarView ──────────────────────────────────────────────
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _TimelineTab(node: node),
                  _MemoTab(nodeId: node.id),
                  _VoiceTab(nodeId: node.id),
                  _RelationTab(nodeId: node.id),
                ],
              ),
            ),

            // ── 액션 버튼 행 ────────────────────────────────────────────
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
                        ref
                            .read(canvasNotifierProvider.notifier)
                            .startConnectMode(node.id);
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _FlowerActionButton(
                      nodeId: node.id,
                      onTap: () => _showFlowerPicker(context, ref, node),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.palette_outlined,
                      label: '아트',
                      color: AppColors.secondary,
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const ArtCardScreen(),
                          ),
                        );
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
      ),
    );
  }

  // ── 아바타 탭 → 사진 풀스크린 ────────────────────────────────────────────
  void _showPhotoFullScreen(BuildContext context, NodeModel node) {
    if (node.photoPath == null) return;
    showDialog<void>(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) => _PhotoFullScreenDialog(photoPath: node.photoPath!),
    );
  }

  // ── 온도 일기 빠른 기록 ──────────────────────────────────────────────────
  void _openQuickTempEntry(BuildContext context, NodeModel node) {
    showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => QuickTempEntry(
        nodeId: node.id,
        nodeName: node.name,
      ),
    );
  }

  // ── 온도 뱃지 탭 → VibeMeterSheet ────────────────────────────────────────
  void _showVibeMeter(BuildContext context, NodeModel node) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => VibeMeterSheet(
        nodeId: node.id,
        initialTemperature: node.temperature,
      ),
    );
  }

  // ── 꽃 보내기 (Memory Bouquet) ─────────────────────────────────────────
  void _showFlowerPicker(
      BuildContext context, WidgetRef ref, NodeModel node) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => FlowerPickerSheet(
        fromNodeId: 'self',
        toNodeId: node.id,
        toNodeName: node.name,
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

  void _shareGhostInfo(NodeModel node) {
    final nameText = node.name.isNotEmpty ? node.name : '미확인 인물';
    final message =
        'Re-Link에서 가족 트리를 만들고 있어요. $nameText을(를) 아시나요? 알고 계시다면 알려주세요!';
    Share.share(message, subject: 'Re-Link 가족 트리');
  }

  void _convertGhost(BuildContext context, WidgetRef ref, NodeModel node) {
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
        title:
            Text('노드 삭제', style: TextStyle(color: AppColors.textPrimary)),
        content: Text(
          '${node.name}을(를) 삭제합니다.\n관련 기억과 관계도 모두 삭제됩니다.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('취소')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child:
                const Text('삭제', style: TextStyle(color: AppColors.error)),
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

// ═══════════════════════════════════════════════════════════════════════════════
// ── Header (아바타 + 이름 + 온도 뱃지) ───────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════════

class _Header extends StatelessWidget {
  const _Header({
    required this.node,
    required this.tempColor,
    required this.onAvatarTap,
    required this.onTempTap,
  });

  final NodeModel node;
  final Color tempColor;
  final VoidCallback onAvatarTap;
  final VoidCallback onTempTap;

  @override
  Widget build(BuildContext context) {
    const labels = ['냉담', '쌀쌀', '보통', '따뜻', '뜨거움', '열정'];

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          // 아바타 (탭 → 풀스크린)
          GestureDetector(
            onTap: onAvatarTap,
            child: Hero(
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
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  node.name,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (node.nickname != null)
                  Text(
                    node.nickname!,
                    style: TextStyle(
                        fontSize: 14, color: AppColors.textSecondary),
                  ),
                if (node.birthDate != null)
                  Text(
                    '${node.birthDate!.year}년생'
                    '${node.isAlive ? '' : ' · ${node.deathDate!.year}년 사망'}',
                    style: TextStyle(
                        fontSize: 13, color: AppColors.textTertiary),
                  ),
              ],
            ),
          ),
          // 온도 뱃지 (탭 → VibeMeterSheet)
          GestureDetector(
            onTap: onTempTap,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
              decoration: BoxDecoration(
                color: tempColor.withAlpha(30),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: tempColor.withAlpha(80)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.thermostat, color: tempColor, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    labels[node.temperature],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: tempColor,
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
}

// ═══════════════════════════════════════════════════════════════════════════════
// ── Tab 1: 타임라인 ──────────────────────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════════

class _TimelineTab extends ConsumerWidget {
  const _TimelineTab({required this.node});
  final NodeModel node;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memoriesAsync = ref.watch(memoriesForNodeProvider(node.id));

    return memoriesAsync.when(
      loading: () => const Center(
          child: CircularProgressIndicator(strokeWidth: 2)),
      error: (e, _) => Center(
        child: Text('오류: $e',
            style: TextStyle(color: AppColors.textSecondary)),
      ),
      data: (memories) {
        // 타임라인 이벤트 수집: 생일, 사망, 기억들
        final events = <_TimelineEvent>[];

        if (node.birthDate != null) {
          events.add(_TimelineEvent(
            date: node.birthDate!,
            icon: Icons.cake_outlined,
            title: '출생',
            subtitle: '${node.birthDate!.year}년 ${node.birthDate!.month}월 ${node.birthDate!.day}일',
            color: AppColors.success,
          ));
        }

        if (node.deathDate != null) {
          events.add(_TimelineEvent(
            date: node.deathDate!,
            icon: Icons.local_florist_outlined,
            title: '사망',
            subtitle: '${node.deathDate!.year}년 ${node.deathDate!.month}월 ${node.deathDate!.day}일',
            color: AppColors.textTertiary,
          ));
        }

        // 기억(Memory)을 타임라인에 추가
        for (final m in memories) {
          final date = m.dateTaken ?? m.createdAt;
          events.add(_TimelineEvent(
            date: date,
            icon: switch (m.type) {
              MemoryType.photo => Icons.photo_outlined,
              MemoryType.voice => Icons.mic_outlined,
              MemoryType.note => Icons.note_outlined,
            },
            title: m.title ?? m.type.label,
            subtitle: m.description ??
                '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}',
            color: switch (m.type) {
              MemoryType.photo => AppColors.secondary,
              MemoryType.voice => AppColors.accent,
              MemoryType.note => AppColors.primary,
            },
          ));
        }

        if (events.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(AppSpacing.xxl),
            child: EmptyStateWidget(
              icon: Icons.timeline_outlined,
              title: '타임라인이 비어있습니다',
              subtitle: '생년월일이나 기억을 추가하면\n타임라인에 표시됩니다.',
            ),
          );
        }

        // 날짜 내림차순 정렬 (최신 순)
        events.sort((a, b) => b.date.compareTo(a.date));

        return ListView.builder(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index];
            final isLast = index == events.length - 1;
            return _TimelineEventCard(event: event, isLast: isLast);
          },
        );
      },
    );
  }
}

class _TimelineEvent {
  const _TimelineEvent({
    required this.date,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  final DateTime date;
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
}

class _TimelineEventCard extends StatelessWidget {
  const _TimelineEventCard({
    required this.event,
    required this.isLast,
  });

  final _TimelineEvent event;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 타임라인 선 + 점
          SizedBox(
            width: 32,
            child: Column(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: event.color,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 1.5,
                      color: AppColors.glassBorder,
                    ),
                  ),
              ],
            ),
          ),
          // 이벤트 카드
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: GlassCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    Icon(event.icon, color: event.color, size: 20),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            event.subtitle,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ── Tab 2: 메모 ──────────────────────────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════════

class _MemoTab extends ConsumerWidget {
  const _MemoTab({required this.nodeId});
  final String nodeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memoriesAsync = ref.watch(memoriesForNodeProvider(nodeId));

    return memoriesAsync.when(
      loading: () => const Center(
          child: CircularProgressIndicator(strokeWidth: 2)),
      error: (e, _) => Center(
        child: Text('오류: $e',
            style: TextStyle(color: AppColors.textSecondary)),
      ),
      data: (memories) {
        final notes =
            memories.where((m) => m.type == MemoryType.note).toList();

        if (notes.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(AppSpacing.xxl),
            child: EmptyStateWidget(
              icon: Icons.note_outlined,
              title: '메모가 없습니다',
              subtitle: '기억 화면에서 메모를 추가해보세요.',
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          itemCount: notes.length,
          itemBuilder: (context, index) {
            final note = notes[index];
            final date = note.dateTaken ?? note.createdAt;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: GlassCard(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.note_outlined,
                            color: AppColors.primary, size: 18),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            note.title ?? '메모',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (note.isPrivate)
                          Icon(Icons.lock_outline,
                              color: AppColors.textTertiary, size: 14),
                      ],
                    ),
                    if (note.description != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        note.description!,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ── Tab 3: 음성 ──────────────────────────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════════

class _VoiceTab extends ConsumerWidget {
  const _VoiceTab({required this.nodeId});
  final String nodeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memoriesAsync = ref.watch(memoriesForNodeProvider(nodeId));

    return memoriesAsync.when(
      loading: () => const Center(
          child: CircularProgressIndicator(strokeWidth: 2)),
      error: (e, _) => Center(
        child: Text('오류: $e',
            style: TextStyle(color: AppColors.textSecondary)),
      ),
      data: (memories) {
        final voices =
            memories.where((m) => m.type == MemoryType.voice).toList();

        if (voices.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(AppSpacing.xxl),
            child: EmptyStateWidget(
              icon: Icons.mic_off_outlined,
              title: '음성 기억이 없습니다',
              subtitle: '기억 화면에서 음성을 녹음해보세요.',
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          itemCount: voices.length,
          itemBuilder: (context, index) {
            final voice = voices[index];
            final date = voice.dateTaken ?? voice.createdAt;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: GlassCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.md,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.accent.withAlpha(30),
                      ),
                      child: const Icon(Icons.mic_outlined,
                          color: AppColors.accent, size: 20),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            voice.title ?? '음성 녹음',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (voice.formattedDuration != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withAlpha(20),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          voice.formattedDuration!,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.accent,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ── Tab 4: 관계 ──────────────────────────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════════

class _RelationTab extends ConsumerWidget {
  const _RelationTab({required this.nodeId});
  final String nodeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canvasState = ref.watch(canvasNotifierProvider);
    final edges = canvasState.edges
        .where((e) => e.fromNodeId == nodeId || e.toNodeId == nodeId)
        .toList();

    if (edges.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(AppSpacing.xxl),
        child: EmptyStateWidget(
          icon: Icons.people_outline,
          title: '연결된 관계가 없습니다',
          subtitle: '캔버스에서 노드를 연결해보세요.',
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      itemCount: edges.length,
      itemBuilder: (context, index) {
        final edge = edges[index];
        final otherId =
            edge.fromNodeId == nodeId ? edge.toNodeId : edge.fromNodeId;
        final otherNode =
            canvasState.nodes.where((n) => n.id == otherId).firstOrNull;
        final otherName = otherNode?.name ?? '알 수 없음';
        final relationColor = _relationColor(edge.relation);

        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: GlassCard(
            onTap: () =>
                _showChangeRelationSheet(context, ref, edge, otherName),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            child: Row(
              children: [
                // 아바타 또는 이니셜
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: relationColor.withAlpha(30),
                    border: Border.all(color: relationColor.withAlpha(80)),
                    image: otherNode?.photoPath != null
                        ? DecorationImage(
                            image:
                                FileImage(File(otherNode!.photoPath!)),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: otherNode?.photoPath == null
                      ? Center(
                          child: Text(
                            otherName.isNotEmpty ? otherName[0] : '?',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: relationColor,
                            ),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        otherName,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            edge.relation.label,
                            style: TextStyle(
                              fontSize: 12,
                              color: relationColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.edit_outlined,
                              size: 12, color: AppColors.textTertiary),
                        ],
                      ),
                    ],
                  ),
                ),
                // 관계 삭제 버튼
                GestureDetector(
                  onTap: () =>
                      _confirmDeleteEdge(context, ref, edge, otherName),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.close,
                      size: 16,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _relationColor(RelationType relation) => switch (relation) {
        RelationType.parent => AppColors.secondary,
        RelationType.child => AppColors.secondary,
        RelationType.spouse => AppColors.accent,
        RelationType.sibling => AppColors.primary,
        RelationType.other => AppColors.textTertiary,
      };

  /// 관계 타입 변경 바텀시트 표시
  Future<void> _showChangeRelationSheet(
    BuildContext context,
    WidgetRef ref,
    NodeEdge edge,
    String otherName,
  ) async {
    final newRelation = await showModalBottomSheet<RelationType>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _ChangeRelationSheet(
        otherName: otherName,
        currentRelation: edge.relation,
      ),
    );
    if (newRelation == null || newRelation == edge.relation) return;
    if (!context.mounted) return;
    await ref
        .read(nodeNotifierProvider.notifier)
        .updateEdgeRelation(edge.id, newRelation);
  }

  Future<void> _confirmDeleteEdge(
    BuildContext context,
    WidgetRef ref,
    NodeEdge edge,
    String otherName,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgElevated,
        title:
            Text('연결 삭제', style: TextStyle(color: AppColors.textPrimary)),
        content: Text(
          '$otherName과(와)의 ${edge.relation.label} 관계를 삭제합니다.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('삭제', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(nodeNotifierProvider.notifier).deleteEdge(edge.id);
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ── 관계 타입 변경 바텀시트 ─────────────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════════

class _ChangeRelationSheet extends StatelessWidget {
  const _ChangeRelationSheet({
    required this.otherName,
    required this.currentRelation,
  });

  final String otherName;
  final RelationType currentRelation;

  @override
  Widget build(BuildContext context) {
    return GlassBottomSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.glassBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Text(
            otherName,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '관계를 변경해 주세요',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.lg),
          ...RelationType.values.map(
            (r) {
              final isSelected = r == currentRelation;
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: GlassCard(
                  onTap: () => Navigator.of(context).pop(r),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  child: Row(
                    children: [
                      Icon(_relationIcon(r),
                          color: _relationColor(r), size: 22),
                      const SizedBox(width: AppSpacing.md),
                      Text(
                        r.label,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      if (isSelected)
                        Icon(Icons.check_circle,
                            color: AppColors.primary, size: 20)
                      else
                        Icon(Icons.chevron_right,
                            color: AppColors.textTertiary),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          GlassCard(
            onTap: () => Navigator.of(context).pop(),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Center(
              child: Text('취소',
                  style: TextStyle(color: AppColors.textSecondary)),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }

  IconData _relationIcon(RelationType r) => switch (r) {
        RelationType.parent => Icons.arrow_upward,
        RelationType.child => Icons.arrow_downward,
        RelationType.spouse => Icons.favorite_outline,
        RelationType.sibling => Icons.people_outline,
        RelationType.other => Icons.link,
      };

  Color _relationColor(RelationType r) => switch (r) {
        RelationType.parent => AppColors.secondary,
        RelationType.child => AppColors.secondary,
        RelationType.spouse => AppColors.accent,
        RelationType.sibling => AppColors.primary,
        RelationType.other => AppColors.textSecondary,
      };
}

// ═══════════════════════════════════════════════════════════════════════════════
// ── 사진 풀스크린 다이얼로그 (InteractiveViewer pinch zoom) ──────────────────
// ═══════════════════════════════════════════════════════════════════════════════

class _PhotoFullScreenDialog extends StatelessWidget {
  const _PhotoFullScreenDialog({required this.photoPath});
  final String photoPath;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Stack(
            children: [
              // 사진 (pinch zoom)
              Center(
                child: InteractiveViewer(
                  clipBehavior: Clip.none,
                  constrained: false,
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Image.file(
                    File(photoPath),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              // 닫기 버튼
              Positioned(
                top: AppSpacing.md,
                right: AppSpacing.md,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black54,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ── 액션 버튼 ────────────────────────────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════════

class _ActionButton extends StatelessWidget {
  _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    Color? color,
  }) : color = color ?? AppColors.textPrimary;

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

/// 꽃 보내기 액션 버튼 — 이번 주 꽃 수 뱃지 포함
class _FlowerActionButton extends ConsumerWidget {
  const _FlowerActionButton({
    required this.nodeId,
    required this.onTap,
  });

  final String nodeId;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            children: [
              Icon(Icons.local_florist_outlined,
                  color: AppColors.accent, size: 22),
              const SizedBox(height: 4),
              Text(
                '꽃',
                style: TextStyle(fontSize: 11, color: AppColors.accent),
              ),
            ],
          ),
          Positioned(
            top: -4,
            right: -4,
            child: BouquetBadge(toNodeId: nodeId),
          ),
        ],
      ),
    );
  }
}
