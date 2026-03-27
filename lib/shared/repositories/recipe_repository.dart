import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../../core/database/app_database.dart';
import 'db_provider.dart';

part 'recipe_repository.g.dart';

@riverpod
RecipeRepository recipeRepository(Ref ref) =>
    RecipeRepository(ref.watch(appDatabaseProvider));

class RecipeRepository {
  RecipeRepository(this._db);
  final AppDatabase _db;
  static const _uuid = Uuid();

  /// 전체 레시피 스트림 (최신순)
  Stream<List<RecipesTableData>> watchAll() => _db.watchAllRecipes();

  /// 특정 노드에 연결된 레시피 목록
  Future<List<RecipesTableData>> getForNode(String nodeId) =>
      _db.getRecipesForNode(nodeId);

  /// 제목 LIKE 검색
  Future<List<RecipesTableData>> search(String query) =>
      _db.searchRecipes(query);

  /// 레시피 생성 (새 ID 생성 후 반환)
  Future<String> create({
    required String title,
    required String ingredients,
    required String instructions,
    String? photoPath,
    String? nodeId,
  }) async {
    final id = _uuid.v4();
    await _db.upsertRecipe(RecipesTableCompanion.insert(
      id: id,
      title: title,
      ingredients: ingredients,
      instructions: instructions,
      photoPath: Value(photoPath),
      nodeId: Value(nodeId),
    ));
    return id;
  }

  /// 레시피 단건 조회
  Future<RecipesTableData?> getById(String id) =>
      (_db.select(_db.recipesTable)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  /// 레시피 삭제
  Future<int> delete(String id) => _db.deleteRecipe(id);
}
