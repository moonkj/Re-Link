import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/database/app_database.dart';
import '../../../shared/repositories/recipe_repository.dart';

part 'recipe_notifier.g.dart';

/// 전체 레시피 스트림 (최신순)
@riverpod
Stream<List<RecipesTableData>> allRecipes(Ref ref) =>
    ref.watch(recipeRepositoryProvider).watchAll();

/// 레시피 CRUD 오퍼레이션
@riverpod
class RecipeNotifier extends _$RecipeNotifier {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  RecipeRepository get _repo => ref.read(recipeRepositoryProvider);

  /// 레시피 등록
  Future<String?> create({
    required String title,
    required String ingredients,
    required String instructions,
    String? photoPath,
    String? nodeId,
  }) async {
    state = const AsyncLoading();
    try {
      final id = await _repo.create(
        title: title,
        ingredients: ingredients,
        instructions: instructions,
        photoPath: photoPath,
        nodeId: nodeId,
      );
      state = const AsyncData(null);
      return id;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }

  /// 레시피 삭제
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
  Future<List<RecipesTableData>> search(String query) =>
      _repo.search(query);
}
