import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../shared/repositories/then_now_repository.dart';

part 'then_now_notifier.g.dart';

/// 전체 Then & Now 페어 스트림
@riverpod
Stream<List<ThenNowPair>> allThenNowPairs(Ref ref) =>
    ref.watch(thenNowRepositoryProvider).watchAll();

/// Then & Now CRUD 오퍼레이션
@riverpod
class ThenNowNotifier extends _$ThenNowNotifier {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  ThenNowRepository get _repo => ref.read(thenNowRepositoryProvider);

  /// 새 Then & Now 페어 생성
  Future<ThenNowPair?> createPair({
    required String memoryId1,
    required String memoryId2,
    String? label,
  }) async {
    state = const AsyncLoading();
    try {
      final pair = await _repo.create(
        memoryId1: memoryId1,
        memoryId2: memoryId2,
        label: label,
      );
      state = const AsyncData(null);
      return pair;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }

  /// Then & Now 페어 삭제
  Future<void> deletePair(String id) async {
    state = const AsyncLoading();
    try {
      await _repo.delete(id);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
