import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/database/app_database.dart';
import '../../../core/utils/path_utils.dart';
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

  /// 레시피 삭제 (사진 파일도 함께 정리)
  Future<bool> delete(String id) async {
    state = const AsyncLoading();
    try {
      // 삭제 전 사진 경로 수집
      final recipe = await _repo.getById(id);
      await _repo.delete(id);
      // 사진 파일 삭제 (DB 레코드 삭제 성공 후)
      if (recipe?.photoPath != null && recipe!.photoPath!.isNotEmpty) {
        try {
          final absPath = PathUtils.toAbsolute(recipe.photoPath) ?? recipe.photoPath!;
          final file = File(absPath);
          if (await file.exists()) {
            await file.delete();
          }
        } catch (e) {
          debugPrint('[RecipeNotifier] 사진 파일 삭제 실패 (무시): $e');
        }
      }
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
