import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/services/privacy/privacy_service.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../design/tokens/app_radius.dart';
import '../../../design/tokens/app_spacing.dart';
import '../../../design/glass/app_glass.dart';
import '../../../shared/models/memory_model.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/widgets/private_blur_overlay.dart';
import '../../../core/router/app_router.dart';
import '../providers/archive_notifier.dart';
import '../../story/providers/story_feed_notifier.dart';

/// 아카이브 화면 (보관함 탭)
class ArchiveScreen extends ConsumerStatefulWidget {
  const ArchiveScreen({super.key});

  @override
  ConsumerState<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends ConsumerState<ArchiveScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  int _currentTab = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      setState(() => _currentTab = _tabController.index);
      if (_tabController.index > 0) {
        // index 1=사진, 2=음성, 3=메모 → ArchiveFilter.photo/voice/note
        final filter = ArchiveFilter.values[_tabController.index];
        ref.read(archiveNotifierProvider.notifier).setFilter(filter);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(archiveNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.bgBase,
      body: NestedScrollView(
        headerSliverBuilder: (context2, _) => [
          SliverAppBar(
            backgroundColor: AppColors.bgBase,
            pinned: true,
            title: Text(
              '기억',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            actions: [
              // 정렬 메뉴
              PopupMenuButton<ArchiveSortOrder>(
                icon: Icon(Icons.sort, color: AppColors.textSecondary),
                color: AppColors.bgElevated,
                onSelected: (o) =>
                    ref.read(archiveNotifierProvider.notifier).setSortOrder(o),
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: ArchiveSortOrder.newest,
                    child: Text('최신순', style: TextStyle(color: AppColors.textPrimary)),
                  ),
                  PopupMenuItem(
                    value: ArchiveSortOrder.oldest,
                    child: Text('오래된순', style: TextStyle(color: AppColors.textPrimary)),
                  ),
                  PopupMenuItem(
                    value: ArchiveSortOrder.name,
                    child: Text('이름순', style: TextStyle(color: AppColors.textPrimary)),
                  ),
                ],
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(100),
              child: Column(
                children: [
                  // 검색바
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.sm,
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: TextStyle(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: '기억 검색...',
                        hintStyle: TextStyle(color: AppColors.textTertiary),
                        prefixIcon: Icon(Icons.search, color: AppColors.textTertiary),
                        filled: true,
                        fillColor: AppColors.glassSurface,
                        border: OutlineInputBorder(
                          borderRadius: AppRadius.input,
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: (q) => ref
                          .read(archiveNotifierProvider.notifier)
                          .setSearchQuery(q),
                    ),
                  ),
                  // 필터 탭
                  TabBar(
                    controller: _tabController,
                    labelColor: AppColors.primary,
                    unselectedLabelColor: AppColors.textTertiary,
                    indicatorColor: AppColors.primary,
                    tabs: const [
                      Tab(text: '이야기'),
                      Tab(text: '사진'),
                      Tab(text: '음성'),
                      Tab(text: '메모'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
        body: _currentTab == 0
            ? _StoryFeedTab(onPrivateTap: _handlePrivateTap)
            : state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.isEmpty
                    ? EmptyStateWidget(
                        icon: Icons.photo_library_outlined,
                        title: '보관된 기억이 없어요',
                        subtitle: '소중한 기억을 추가하면\n여기에 모입니다',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        itemCount: state.groups.length,
                        itemBuilder: (_, i) {
                          final group = state.groups[i];
                          return _ArchiveGroup(
                            group: group,
                            onPrivateTap: _handlePrivateTap,
                          );
                        },
                      ),
      ),
    );
  }

  Future<void> _handlePrivateTap(MemoryModel memory) async {
    final privacy = ref.read(privacyServiceProvider);
    final enabled = await privacy.isEnabled();
    if (!mounted) return;
    if (enabled) {
      final authed = await privacy.authenticate();
      if (!mounted) return;
      if (!authed) return;
    }
    if (!mounted) return;
    context.push(AppRoutes.memoryPath(memory.nodeId));
  }
}

/// 노드별 기억 그룹
class _ArchiveGroup extends StatelessWidget {
  const _ArchiveGroup({
    required this.group,
    required this.onPrivateTap,
  });
  final ArchiveGroup group;
  final void Function(MemoryModel memory) onPrivateTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 섹션 헤더
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Row(
            children: [
              // 노드 아바타
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withAlpha(60),
                  image: group.node.photoPath != null
                      ? DecorationImage(
                          image: FileImage(File(group.node.photoPath!)),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: group.node.photoPath == null
                    ? Center(
                        child: Text(
                          group.node.name.isNotEmpty ? group.node.name[0] : '?',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.onPrimary,
                          ),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 10),
              Text(
                group.node.name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${group.memories.length}개',
                style: TextStyle(fontSize: 13, color: AppColors.textTertiary),
              ),
            ],
          ),
        ),
        // 기억 목록
        ...group.memories.map((m) => _MemoryTile(
              memory: m,
              onTap: m.isPrivate
                  ? () => onPrivateTap(m)
                  : () => context.push(AppRoutes.memoryPath(m.nodeId)),
            )),
        const SizedBox(height: AppSpacing.md),
      ],
    );
  }
}

class _MemoryTile extends StatelessWidget {
  const _MemoryTile({required this.memory, required this.onTap});
  final MemoryModel memory;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('yyyy.MM.dd').format(
      memory.dateTaken ?? memory.createdAt,
    );
    final (icon, color) = switch (memory.type) {
      MemoryType.photo => (Icons.photo_outlined, AppColors.secondary),
      MemoryType.voice => (Icons.mic_outlined, AppColors.accent),
      MemoryType.note => (Icons.note_outlined, AppColors.primary),
      MemoryType.video => (Icons.videocam_outlined, AppColors.primary),
    };

    return GlassCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.sm),
      onTap: onTap,
      child: Row(
        children: [
          // 사진 썸네일 또는 아이콘 — 비공개 시 블러 오버레이
          if (memory.isPrivate)
            SizedBox(
              width: 56,
              height: 56,
              child: PrivateBlurOverlay(
                onTap: onTap,
                borderRadius: AppRadius.radiusSm,
                showMessage: false,
                iconSize: 16,
                blurSigma: 12,
                child: memory.type == MemoryType.photo && memory.thumbnailPath != null
                    ? Image.file(
                        File(memory.thumbnailPath!),
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: 56,
                        height: 56,
                        color: color.withAlpha(30),
                        child: Icon(icon, color: color, size: 28),
                      ),
              ),
            )
          else
            ClipRRect(
              borderRadius: AppRadius.radiusSm,
              child: memory.type == MemoryType.photo && memory.thumbnailPath != null
                  ? Image.file(
                      File(memory.thumbnailPath!),
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 56,
                      height: 56,
                      color: color.withAlpha(30),
                      child: Icon(icon, color: color, size: 28),
                    ),
            ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        memory.isPrivate
                            ? '비공개 ${memory.type.label}'
                            : (memory.title ?? memory.type.label),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: memory.isPrivate
                              ? AppColors.textTertiary
                              : AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (memory.isPrivate) ...[
                      const SizedBox(width: 4),
                      Icon(Icons.lock, size: 12, color: AppColors.textTertiary),
                    ],
                  ],
                ),
                if (!memory.isPrivate && memory.description != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    memory.description!,
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ] else if (memory.isPrivate) ...[
                  const SizedBox(height: 2),
                  Text(
                    '탭하여 인증 후 열기',
                    style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
                  ),
                ],
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      dateStr,
                      style: TextStyle(fontSize: 11, color: AppColors.textTertiary),
                    ),
                    if (memory.isPrivate) ...[
                      const SizedBox(width: 6),
                      Icon(Icons.lock, size: 12, color: AppColors.accent),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: AppColors.textDisabled, size: 18),
        ],
      ),
    );
  }
}

/// 이야기 탭 — Story Feed 인라인 표시
class _StoryFeedTab extends ConsumerWidget {
  const _StoryFeedTab({required this.onPrivateTap});
  final void Function(MemoryModel memory) onPrivateTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(storyFeedNotifierProvider);

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.items.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.auto_stories_outlined,
        title: '아직 이야기가 없어요',
        subtitle: '가족 구성원을 추가하고\n첫 기억을 남겨보세요',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      itemCount: state.items.length,
      itemBuilder: (_, i) {
        final item = state.items[i];
        final memory = item.memory;
        final dateStr = DateFormat('yyyy년 M월 d일').format(
          memory.dateTaken ?? memory.createdAt,
        );

        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: GlassCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            onTap: memory.isPrivate
                ? () => onPrivateTap(memory)
                : () => context.push(AppRoutes.memoryPath(memory.nodeId)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── 헤더: 노드 이름 + 날짜 ─────────────────────────────
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withAlpha(60),
                        image: item.nodePhotoPath != null
                            ? DecorationImage(
                                image: FileImage(File(item.nodePhotoPath!)),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: item.nodePhotoPath == null
                          ? Center(
                              child: Text(
                                item.nodeName.isNotEmpty
                                    ? item.nodeName[0]
                                    : '?',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.onPrimary,
                                ),
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.nodeName,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            dateStr,
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 비공개 잠금 또는 타입 칩
                    if (memory.isPrivate)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          borderRadius: AppRadius.radiusSm,
                          color: AppColors.accent.withAlpha(30),
                        ),
                        child: const Icon(Icons.lock,
                            size: 16, color: AppColors.accent),
                      )
                    else
                      _StoryTypeChip(type: memory.type),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),

                // ── 콘텐츠 ─────────────────────────────────────────────
                if (memory.isPrivate)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: PrivateBlurOverlay(
                      onTap: () => onPrivateTap(memory),
                      borderRadius: BorderRadius.circular(10),
                      message: '비공개 기억입니다\n탭하여 인증 후 보기',
                      blurSigma: 20,
                      child: SizedBox(
                        height: 120,
                        width: double.infinity,
                        child: Container(
                          color: AppColors.glassSurface,
                          child: Center(
                            child: Icon(
                              switch (memory.type) {
                                MemoryType.photo => Icons.photo_outlined,
                                MemoryType.voice => Icons.mic_outlined,
                                MemoryType.note => Icons.note_outlined,
                                MemoryType.video => Icons.videocam_outlined,
                              },
                              size: 40,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  _StoryContent(memory: memory),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// 이야기 탭 — 타입 칩
class _StoryTypeChip extends StatelessWidget {
  const _StoryTypeChip({required this.type});
  final MemoryType type;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (type) {
      MemoryType.photo => (Icons.photo_outlined, AppColors.secondary),
      MemoryType.voice => (Icons.mic_outlined, AppColors.accent),
      MemoryType.note => (Icons.note_outlined, AppColors.primary),
      MemoryType.video => (Icons.videocam_outlined, AppColors.primary),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: AppRadius.radiusSm,
        color: color.withAlpha(30),
      ),
      child: Icon(icon, size: 16, color: color),
    );
  }
}

/// 이야기 탭 — 콘텐츠 (사진/음성/메모)
class _StoryContent extends StatelessWidget {
  const _StoryContent({required this.memory});
  final MemoryModel memory;

  @override
  Widget build(BuildContext context) {
    return switch (memory.type) {
      MemoryType.photo => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (memory.thumbnailPath != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(
                  File(memory.thumbnailPath!),
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                ),
              ),
            if (memory.description != null) ...[
              const SizedBox(height: 8),
              Text(
                memory.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style:
                    TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
            ],
          ],
        ),
      MemoryType.voice => Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accent.withAlpha(40),
              ),
              child: const Icon(Icons.play_arrow,
                  color: AppColors.accent, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    memory.title ?? '음성 기억',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (memory.formattedDuration != null)
                    Text(
                      memory.formattedDuration!,
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textTertiary),
                    ),
                ],
              ),
            ),
          ],
        ),
      MemoryType.note => Text(
          memory.description ?? memory.title ?? '',
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
      MemoryType.video => const SizedBox.shrink(),
    };
  }
}
