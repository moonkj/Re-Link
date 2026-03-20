import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/database/app_database.dart';
import '../../../shared/repositories/glossary_repository.dart';

part 'glossary_notifier.g.dart';

/// 전체 단어장 스트림 (가나다순)
@riverpod
Stream<List<GlossaryTableData>> allGlossary(Ref ref) =>
    ref.watch(glossaryRepositoryProvider).watchAll();

/// 단어장 CRUD 오퍼레이션
@riverpod
class GlossaryNotifier extends _$GlossaryNotifier {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  GlossaryRepository get _repo => ref.read(glossaryRepositoryProvider);

  /// 단어 등록
  Future<String?> create({
    required String word,
    required String meaning,
    String? example,
    String? voicePath,
    String? nodeId,
  }) async {
    state = const AsyncLoading();
    try {
      final id = await _repo.create(
        word: word,
        meaning: meaning,
        example: example,
        voicePath: voicePath,
        nodeId: nodeId,
      );
      state = const AsyncData(null);
      return id;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }

  /// 단어 삭제
  Future<bool> delete(String id) async {
    state = const AsyncLoading();
    try {
      await _repo.delete(id);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  /// 검색 (debounce는 UI 레이어에서 처리)
  Future<List<GlossaryTableData>> search(String query) =>
      _repo.search(query);
}
