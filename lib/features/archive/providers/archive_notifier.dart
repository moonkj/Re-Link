import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../shared/models/memory_model.dart';
import '../../../shared/models/node_model.dart';
import '../../../shared/repositories/memory_repository.dart';
import '../../../shared/repositories/node_repository.dart';

part 'archive_notifier.g.dart';

/// 아카이브 필터
enum ArchiveFilter { all, photo, voice, note }

/// 아카이브 정렬
enum ArchiveSortOrder { newest, oldest, name }

/// 노드별 기억 그룹
class ArchiveGroup {
  const ArchiveGroup({
    required this.node,
    required this.memories,
  });

  final NodeModel node;
  final List<MemoryModel> memories;
}

/// 아카이브 상태
class ArchiveState {
  const ArchiveState({
    this.groups = const [],
    this.filter = ArchiveFilter.all,
    this.sortOrder = ArchiveSortOrder.newest,
    this.searchQuery = '',
    this.isLoading = true,
  });

  final List<ArchiveGroup> groups;
  final ArchiveFilter filter;
  final ArchiveSortOrder sortOrder;
  final String searchQuery;
  final bool isLoading;

  ArchiveState copyWith({
    List<ArchiveGroup>? groups,
    ArchiveFilter? filter,
    ArchiveSortOrder? sortOrder,
    String? searchQuery,
    bool? isLoading,
  }) =>
      ArchiveState(
        groups: groups ?? this.groups,
        filter: filter ?? this.filter,
        sortOrder: sortOrder ?? this.sortOrder,
        searchQuery: searchQuery ?? this.searchQuery,
        isLoading: isLoading ?? this.isLoading,
      );

  bool get isEmpty => groups.isEmpty || groups.every((g) => g.memories.isEmpty);
}

@riverpod
class ArchiveNotifier extends _$ArchiveNotifier {
  StreamSubscription<List<MemoryModel>>? _memoriesSub;
  StreamSubscription<List<NodeModel>>? _nodesSub;

  List<MemoryModel> _allMemories = [];
  List<NodeModel> _allNodes = [];

  @override
  ArchiveState build() {
    final memRepo = ref.read(memoryRepositoryProvider);
    final nodeRepo = ref.read(nodeRepositoryProvider);

    _memoriesSub = memRepo.watchAll().listen((mems) {
      _allMemories = mems;
      _rebuild();
    });
    _nodesSub = nodeRepo.watchAll().listen((nodes) {
      _allNodes = nodes;
      _rebuild();
    });

    ref.onDispose(() {
      _memoriesSub?.cancel();
      _nodesSub?.cancel();
    });

    return const ArchiveState();
  }

  // ── 필터/정렬 ─────────────────────────────────────────────────────────────

  void setFilter(ArchiveFilter filter) {
    state = state.copyWith(filter: filter);
    _rebuild();
  }

  void setSortOrder(ArchiveSortOrder order) {
    state = state.copyWith(sortOrder: order);
    _rebuild();
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    _rebuild();
  }

  // ── 리빌드 ─────────────────────────────────────────────────────────────────

  void _rebuild() {
    final filter = state.filter;
    final query = state.searchQuery.toLowerCase();
    final order = state.sortOrder;

    // 1. 필터 적용
    var filtered = _allMemories.where((m) {
      if (filter != ArchiveFilter.all && m.type.name != filter.name) return false;
      if (query.isNotEmpty) {
        final titleMatch = m.title?.toLowerCase().contains(query) ?? false;
        final descMatch = m.description?.toLowerCase().contains(query) ?? false;
        return titleMatch || descMatch;
      }
      return true;
    }).toList();

    // 2. 정렬
    switch (order) {
      case ArchiveSortOrder.newest:
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case ArchiveSortOrder.oldest:
        filtered.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      case ArchiveSortOrder.name:
        filtered.sort((a, b) => (a.title ?? '').compareTo(b.title ?? ''));
    }

    // 3. 노드별 그룹핑
    final nodeMap = {for (final n in _allNodes) n.id: n};
    final groupMap = <String, List<MemoryModel>>{};
    for (final m in filtered) {
      groupMap.putIfAbsent(m.nodeId, () => []).add(m);
    }

    final groups = groupMap.entries
        .map((e) {
          final node = nodeMap[e.key];
          if (node == null) return null;
          return ArchiveGroup(node: node, memories: e.value);
        })
        .whereType<ArchiveGroup>()
        .toList();

    // 노드 이름순 정렬
    groups.sort((a, b) => a.node.name.compareTo(b.node.name));

    state = state.copyWith(groups: groups, isLoading: false);
  }
}
