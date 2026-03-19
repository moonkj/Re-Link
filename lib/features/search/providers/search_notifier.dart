import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../shared/models/memory_model.dart';
import '../../../shared/models/node_model.dart';
import '../../../shared/repositories/memory_repository.dart';
import '../../../shared/repositories/node_repository.dart';

part 'search_notifier.g.dart';

class SearchResult {
  const SearchResult({this.nodes = const [], this.memories = const []});
  const SearchResult.empty()
      : nodes = const [],
        memories = const [];

  final List<NodeModel> nodes;
  final List<MemoryModel> memories;

  bool get isEmpty => nodes.isEmpty && memories.isEmpty;
}

@riverpod
class SearchNotifier extends _$SearchNotifier {
  @override
  AsyncValue<SearchResult> build() => const AsyncData(SearchResult.empty());

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      state = const AsyncData(SearchResult.empty());
      return;
    }
    state = const AsyncLoading();
    try {
      final results = await Future.wait([
        ref.read(nodeRepositoryProvider).searchNodes(query),
        ref.read(memoryRepositoryProvider).searchMemories(query),
      ]);
      state = AsyncData(SearchResult(
        nodes: results[0] as List<NodeModel>,
        memories: results[1] as List<MemoryModel>,
      ));
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  void clear() => state = const AsyncData(SearchResult.empty());
}
