import 'package:flutter_test/flutter_test.dart';

/// RecipesTable 필드 구조를 순수하게 검증하기 위한 경량 모델.
/// DB 의존 없이 테이블 스키마 / 검색 로직을 테스트한다.
class _RecipeFields {
  _RecipeFields({
    required this.id,
    required this.title,
    required this.ingredients,
    required this.instructions,
    this.photoPath,
    this.nodeId,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  final String id;
  final String title;
  final String ingredients; // newline-separated
  final String instructions; // newline-separated steps
  final String? photoPath;
  final String? nodeId;
  final DateTime createdAt;
}

/// 제목 / 재료 LIKE 검색을 순수 Dart로 재현
bool _matchesSearch(_RecipeFields recipe, String query) {
  final q = query.toLowerCase();
  return recipe.title.toLowerCase().contains(q) ||
      recipe.ingredients.toLowerCase().contains(q);
}

void main() {
  // ═══════════════════════════════════════════════════════════════════════════
  // 1. 필드 검증
  // ═══════════════════════════════════════════════════════════════════════════
  group('Recipe 모델 필드 검증', () {
    test('필수 필드가 모두 저장된다 (title, ingredients, instructions)', () {
      final recipe = _RecipeFields(
        id: 'r1',
        title: '김치찌개',
        ingredients: '김치\n돼지고기\n두부',
        instructions: '1. 김치를 볶는다\n2. 물을 넣는다\n3. 두부를 넣는다',
      );
      expect(recipe.id, 'r1');
      expect(recipe.title, '김치찌개');
      expect(recipe.ingredients, contains('돼지고기'));
      expect(recipe.instructions, contains('두부를 넣는다'));
    });

    test('createdAt 기본값이 현재 시각 근방이다', () {
      final before = DateTime.now();
      final recipe = _RecipeFields(
        id: 'r2',
        title: '된장찌개',
        ingredients: '된장\n감자',
        instructions: '끓인다',
      );
      final after = DateTime.now();

      expect(recipe.createdAt.isAfter(before.subtract(const Duration(seconds: 1))), isTrue);
      expect(recipe.createdAt.isBefore(after.add(const Duration(seconds: 1))), isTrue);
    });

    test('ingredients는 줄바꿈으로 구분된다', () {
      final recipe = _RecipeFields(
        id: 'r3',
        title: '불고기',
        ingredients: '소고기\n양파\n간장\n설탕\n참기름',
        instructions: '재운다\n굽는다',
      );
      final ingredientList = recipe.ingredients.split('\n');
      expect(ingredientList.length, 5);
      expect(ingredientList.first, '소고기');
      expect(ingredientList.last, '참기름');
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // 2. nullable 필드 처리
  // ═══════════════════════════════════════════════════════════════════════════
  group('nullable 필드 처리', () {
    test('photoPath가 null이면 null 반환', () {
      final recipe = _RecipeFields(
        id: 'r4',
        title: '라면',
        ingredients: '라면\n물',
        instructions: '끓인다',
      );
      expect(recipe.photoPath, isNull);
    });

    test('photoPath가 있으면 경로가 올바르다', () {
      final recipe = _RecipeFields(
        id: 'r5',
        title: '라면',
        ingredients: '라면\n물',
        instructions: '끓인다',
        photoPath: '/photos/ramen.webp',
      );
      expect(recipe.photoPath, '/photos/ramen.webp');
    });

    test('nodeId가 null이면 어떤 노드에도 연결되지 않는다', () {
      final recipe = _RecipeFields(
        id: 'r6',
        title: '카레',
        ingredients: '카레가루\n감자\n당근',
        instructions: '끓인다',
      );
      expect(recipe.nodeId, isNull);
    });

    test('nodeId가 있으면 가족 구성원 노드에 연결된다', () {
      final recipe = _RecipeFields(
        id: 'r7',
        title: '할머니의 잡채',
        ingredients: '당면\n시금치\n당근\n소고기',
        instructions: '볶는다',
        nodeId: 'node-grandma-001',
      );
      expect(recipe.nodeId, 'node-grandma-001');
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // 3. 빈 문자열 / null 처리
  // ═══════════════════════════════════════════════════════════════════════════
  group('빈 문자열 / null 처리', () {
    test('title이 빈 문자열이어도 객체 생성 가능', () {
      final recipe = _RecipeFields(
        id: 'r8',
        title: '',
        ingredients: '',
        instructions: '',
      );
      expect(recipe.title, isEmpty);
      expect(recipe.ingredients, isEmpty);
      expect(recipe.instructions, isEmpty);
    });

    test('photoPath가 빈 문자열이면 빈 문자열이다 (null과 다름)', () {
      final recipe = _RecipeFields(
        id: 'r9',
        title: '테스트',
        ingredients: '재료',
        instructions: '방법',
        photoPath: '',
      );
      expect(recipe.photoPath, isNotNull);
      expect(recipe.photoPath, isEmpty);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // 4. 검색 로직 (title/ingredients LIKE 매칭)
  // ═══════════════════════════════════════════════════════════════════════════
  group('검색 로직 (LIKE 매칭)', () {
    final recipes = [
      _RecipeFields(
        id: 'r10',
        title: '김치찌개',
        ingredients: '김치\n돼지고기\n두부',
        instructions: '끓인다',
      ),
      _RecipeFields(
        id: 'r11',
        title: '된장찌개',
        ingredients: '된장\n두부\n호박',
        instructions: '끓인다',
      ),
      _RecipeFields(
        id: 'r12',
        title: '불고기',
        ingredients: '소고기\n양파\n간장',
        instructions: '굽는다',
      ),
      _RecipeFields(
        id: 'r13',
        title: '두부김치',
        ingredients: '두부\n김치',
        instructions: '볶는다',
      ),
    ];

    test('제목으로 검색 — "찌개"가 포함된 레시피 2개', () {
      final results = recipes.where((r) => _matchesSearch(r, '찌개')).toList();
      expect(results.length, 2);
      expect(results.map((r) => r.title), containsAll(['김치찌개', '된장찌개']));
    });

    test('재료로 검색 — "두부"가 포함된 레시피 3개', () {
      final results = recipes.where((r) => _matchesSearch(r, '두부')).toList();
      expect(results.length, 3);
    });

    test('대소문자 무시 검색 (영문)', () {
      final englishRecipes = [
        _RecipeFields(
          id: 'e1',
          title: 'Pasta Carbonara',
          ingredients: 'Spaghetti\nEgg\nBacon',
          instructions: 'Cook',
        ),
        _RecipeFields(
          id: 'e2',
          title: 'Caesar Salad',
          ingredients: 'Romaine\nCroutons\nParmesan',
          instructions: 'Toss',
        ),
      ];
      final results =
          englishRecipes.where((r) => _matchesSearch(r, 'pasta')).toList();
      expect(results.length, 1);
      expect(results.first.title, 'Pasta Carbonara');
    });

    test('검색어가 빈 문자열이면 전부 매칭', () {
      final results = recipes.where((r) => _matchesSearch(r, '')).toList();
      expect(results.length, recipes.length);
    });

    test('매칭되지 않는 검색어 — 결과 0개', () {
      final results = recipes.where((r) => _matchesSearch(r, '스시')).toList();
      expect(results.length, 0);
    });

    test('instructions는 검색 대상이 아니다', () {
      final results = recipes.where((r) => _matchesSearch(r, '굽는다')).toList();
      expect(results.length, 0);
    });
  });
}
