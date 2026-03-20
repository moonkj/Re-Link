// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$allRecipesHash() => r'2e9f52f5f6b7ae7888dc186af873f93c5ee842c9';

/// 전체 레시피 스트림 (최신순)
///
/// Copied from [allRecipes].
@ProviderFor(allRecipes)
final allRecipesProvider =
    AutoDisposeStreamProvider<List<RecipesTableData>>.internal(
      allRecipes,
      name: r'allRecipesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$allRecipesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AllRecipesRef = AutoDisposeStreamProviderRef<List<RecipesTableData>>;
String _$recipeNotifierHash() => r'2158a344ef0819a04a7d93c011acf499cad72e49';

/// 레시피 CRUD 오퍼레이션
///
/// Copied from [RecipeNotifier].
@ProviderFor(RecipeNotifier)
final recipeNotifierProvider =
    AutoDisposeNotifierProvider<RecipeNotifier, AsyncValue<void>>.internal(
      RecipeNotifier.new,
      name: r'recipeNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$recipeNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$RecipeNotifier = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
