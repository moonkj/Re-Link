import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../shared/models/memory_model.dart';
import '../../../shared/models/node_model.dart';
import '../../../shared/repositories/memory_repository.dart';
import '../../../shared/repositories/node_repository.dart';

part 'story_feed_notifier.g.dart';

/// Story Feed 아이템 — 기억 + 노드 정보 병합
class StoryFeedItem {
  const StoryFeedItem({
    required this.memory,
    required this.nodeName,
    this.nodePhotoPath,
  });

  final MemoryModel memory;
  final String nodeName;
  final String? nodePhotoPath;
}

/// Story Feed 상태
class StoryFeedState {
  const StoryFeedState({
    this.items = const [],
    this.isLoading = true,
  });

  final List<StoryFeedItem> items;
  final bool isLoading;

  StoryFeedState copyWith({List<StoryFeedItem>? items, bool? isLoading}) =>
      StoryFeedState(
        items: items ?? this.items,
        isLoading: isLoading ?? this.isLoading,
      );
}

@riverpod
class StoryFeedNotifier extends _$StoryFeedNotifier {
  StreamSubscription<List<MemoryModel>>? _memoriesSub;
  StreamSubscription<List<NodeModel>>? _nodesSub;

  List<MemoryModel> _memories = [];
  List<NodeModel> _nodes = [];

  @override
  StoryFeedState build() {
    final memRepo = ref.read(memoryRepositoryProvider);
    final nodeRepo = ref.read(nodeRepositoryProvider);

    _memoriesSub = memRepo.watchAll().listen((mems) {
      _memories = mems;
      _rebuild();
    });

    _nodesSub = nodeRepo.watchAll().listen((nodes) {
      _nodes = nodes;
      _rebuild();
    });

    ref.onDispose(() {
      _memoriesSub?.cancel();
      _nodesSub?.cancel();
    });

    return const StoryFeedState();
  }

  void _rebuild() {
    final nodeMap = {for (final n in _nodes) n.id: n};
    final items = _memories
        .where((m) => !m.isPrivate) // private 기억은 피드에 노출 안 함
        .map((m) {
          final node = nodeMap[m.nodeId];
          return StoryFeedItem(
            memory: m,
            nodeName: node?.name ?? '알 수 없음',
            nodePhotoPath: node?.photoPath,
          );
        })
        .toList();

    state = state.copyWith(items: items, isLoading: false);
  }
}
