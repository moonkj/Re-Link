import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../design/tokens/app_spacing.dart';
import '../../../design/glass/app_glass.dart';
import '../../../shared/models/memory_model.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../core/router/app_router.dart';
import '../providers/archive_notifier.dart';

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      final filter = ArchiveFilter.values[_tabController.index];
      ref.read(archiveNotifierProvider.notifier).setFilter(filter);
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
            title: const Text(
              '보관함',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 22,
              ),
            ),
            actions: [
              // 정렬 메뉴
              PopupMenuButton<ArchiveSortOrder>(
                icon: const Icon(Icons.sort, color: AppColors.textSecondary),
                color: AppColors.bgElevated,
                onSelected: (o) =>
                    ref.read(archiveNotifierProvider.notifier).setSortOrder(o),
                itemBuilder: (_) => const [
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
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: '기억 검색...',
                        hintStyle: const TextStyle(color: AppColors.textTertiary),
                        prefixIcon: const Icon(Icons.search, color: AppColors.textTertiary),
                        filled: true,
                        fillColor: AppColors.glassSurface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
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
                      Tab(text: '전체'),
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
        body: state.isLoading
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
                      return _ArchiveGroup(group: group);
                    },
                  ),
      ),
    );
  }
}

/// 노드별 기억 그룹
class _ArchiveGroup extends StatelessWidget {
  const _ArchiveGroup({required this.group});
  final ArchiveGroup group;

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
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 10),
              Text(
                group.node.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${group.memories.length}개',
                style: const TextStyle(fontSize: 13, color: AppColors.textTertiary),
              ),
            ],
          ),
        ),
        // 기억 목록
        ...group.memories.map((m) => _MemoryTile(
              memory: m,
              onTap: () => context.push(AppRoutes.memoryPath(m.nodeId)),
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
    };

    return GlassCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.sm),
      onTap: onTap,
      child: Row(
        children: [
          // 사진 썸네일 또는 아이콘
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
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
                Text(
                  memory.title ?? memory.type.label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (memory.description != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    memory.description!,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      dateStr,
                      style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
                    ),
                    if (memory.isPrivate) ...[
                      const SizedBox(width: 6),
                      const Icon(Icons.lock, size: 12, color: AppColors.textTertiary),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textDisabled, size: 18),
        ],
      ),
    );
  }
}
