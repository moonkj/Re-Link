import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart';
import '../../../core/utils/haptic_service.dart';
import '../../../design/glass/app_glass.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../design/tokens/app_spacing.dart';
import '../../../shared/repositories/node_repository.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../providers/recipe_notifier.dart';
import '../widgets/add_recipe_sheet.dart';
import '../widgets/recipe_card.dart';

/// 가족 레시피 북 메인 화면
class RecipeListScreen extends ConsumerStatefulWidget {
  const RecipeListScreen({super.key});

  @override
  ConsumerState<RecipeListScreen> createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends ConsumerState<RecipeListScreen> {
  final _searchCtrl = TextEditingController();
  Timer? _debounce;

  /// 검색 결과 -- null이면 전체 목록 모드
  List<RecipesTableData>? _searchResults;
  bool _isSearching = false;

  // 노드 이름 캐시 (nodeId -> name)
  Map<String, String> _nodeNameCache = {};

  @override
  void initState() {
    super.initState();
    _loadNodeNames();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  /// 노드 이름 캐시 로드
  Future<void> _loadNodeNames() async {
    final nodes = await ref.read(nodeRepositoryProvider).getAll();
    if (!mounted) return;
    setState(() {
      _nodeNameCache = {for (final n in nodes) n.id: n.name};
    });
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = null;
        _isSearching = false;
      });
      return;
    }
    setState(() => _isSearching = true);
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      final results =
          await ref.read(recipeNotifierProvider.notifier).search(query);
      if (!mounted) return;
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    });
  }

  Future<void> _openAddSheet() async {
    HapticService.light();
    final added = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddRecipeSheet(),
    );
    if (added == true) {
      _loadNodeNames(); // 노드 캐시 새로고침
    }
  }

  Future<void> _deleteRecipe(String id) async {
    HapticService.medium();
    await ref.read(recipeNotifierProvider.notifier).delete(id);
  }

  @override
  Widget build(BuildContext context) {
    final recipesAsync = ref.watch(allRecipesProvider);

    return Scaffold(
      backgroundColor: AppColors.bgBase,
      appBar: AppBar(
        title: Text(
          '가족 레시피',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new,
              color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddSheet,
        backgroundColor: AppColors.primary,
        child: Icon(Icons.add, color: AppColors.onPrimary),
      ),
      body: Column(
        children: [
          // -- 검색 바 ------------------------------------------------
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.pagePadding,
              vertical: AppSpacing.sm,
            ),
            child: GlassCard(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.xs,
              ),
              child: Row(
                children: [
                  Icon(Icons.search, size: 20, color: AppColors.textTertiary),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: _onSearchChanged,
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: '레시피 이름 검색',
                        hintStyle: TextStyle(color: AppColors.textTertiary),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                      ),
                    ),
                  ),
                  if (_searchCtrl.text.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _searchCtrl.clear();
                        _onSearchChanged('');
                      },
                      child: Icon(Icons.close,
                          size: 18, color: AppColors.textTertiary),
                    ),
                ],
              ),
            ),
          ),

          // -- 콘텐츠 -------------------------------------------------
          Expanded(
            child: _isSearching
                ? const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : _searchResults != null
                    ? _buildList(_searchResults!)
                    : recipesAsync.when(
                        data: (recipes) => _buildList(recipes),
                        loading: () => const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        error: (e, _) => Center(
                          child: Text(
                            '불러오기 실패: $e',
                            style: TextStyle(color: AppColors.error),
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<RecipesTableData> recipes) {
    if (recipes.isEmpty) {
      // 검색 결과가 비어있는 경우 vs 전체가 빈 경우
      if (_searchResults != null) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.search_off, size: 48, color: AppColors.textTertiary),
              const SizedBox(height: AppSpacing.lg),
              Text(
                '검색 결과가 없어요',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        );
      }
      return EmptyStateWidget(
        icon: Icons.restaurant_menu_outlined,
        title: '아직 등록된 레시피가 없어요',
        subtitle: '가족의 특별한 레시피를 기록하세요\n할머니의 된장찌개, 아빠의 볶음밥...',
        actionLabel: '첫 레시피 등록',
        onAction: _openAddSheet,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pagePadding,
        AppSpacing.sm,
        AppSpacing.pagePadding,
        AppSpacing.massive + AppSpacing.xxxl, // FAB 영역 확보
      ),
      itemCount: recipes.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (_, i) {
        final recipe = recipes[i];
        final nodeName =
            recipe.nodeId != null ? _nodeNameCache[recipe.nodeId!] : null;
        return RecipeCard(
          recipe: recipe,
          nodeName: nodeName,
          onDelete: () => _deleteRecipe(recipe.id),
        );
      },
    );
  }
}
