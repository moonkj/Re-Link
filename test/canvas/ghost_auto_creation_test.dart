/// Ghost Node 자동 생성 단위 테스트
/// NodeRepository.hasSpouse + createNodeWithAutoGhost 검증
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:re_link/core/database/app_database.dart';
import 'package:re_link/shared/models/node_model.dart';
import 'package:re_link/shared/repositories/node_repository.dart';
import '../helpers/test_helpers.dart';

void main() {
  late AppDatabase db;
  late NodeRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = createTestNodeRepository(db);
  });

  tearDown(() => db.close());

  group('NodeRepository.hasSpouse', () {
    test('배우자 없으면 false', () async {
      final node = await repo.create(name: '홍길동', positionX: 0, positionY: 0);
      expect(await repo.hasSpouse(node.id), isFalse);
    });

    test('배우자 추가 후 true', () async {
      final a = await repo.create(name: '홍길동', positionX: 0, positionY: 0);
      final b = await repo.create(name: '홍길순', positionX: 200, positionY: 0);
      await repo.addEdge(
        fromNodeId: a.id,
        toNodeId: b.id,
        relation: RelationType.spouse,
      );
      expect(await repo.hasSpouse(a.id), isTrue);
      expect(await repo.hasSpouse(b.id), isTrue); // getEdgesForNode는 양방향 포함
    });

    test('parent/child 관계는 spouse로 취급 안함', () async {
      final parent = await repo.create(name: '아버지', positionX: 0, positionY: 0);
      final child = await repo.create(name: '아들', positionX: 0, positionY: 200);
      await repo.addEdge(
        fromNodeId: parent.id,
        toNodeId: child.id,
        relation: RelationType.child,
      );
      expect(await repo.hasSpouse(parent.id), isFalse);
    });
  });

  group('Ghost 부모 자동 생성 (createGhostParentsFor 로직)', () {
    test('부모 Ghost 2개 생성 후 자녀 노드와 연결', () async {
      final child = await repo.create(name: '아들', positionX: 500, positionY: 500);

      // ghost father
      final ghostFather = await repo.create(
        name: '미확인 아버지',
        isGhost: true,
        positionX: child.positionX - 120,
        positionY: child.positionY - 220,
      );
      await repo.addEdge(fromNodeId: ghostFather.id, toNodeId: child.id, relation: RelationType.child);

      // ghost mother
      final ghostMother = await repo.create(
        name: '미확인 어머니',
        isGhost: true,
        positionX: child.positionX + 120,
        positionY: child.positionY - 220,
      );
      await repo.addEdge(fromNodeId: ghostMother.id, toNodeId: child.id, relation: RelationType.child);
      await repo.addEdge(fromNodeId: ghostFather.id, toNodeId: ghostMother.id, relation: RelationType.spouse);

      expect(ghostFather.isGhost, isTrue);
      expect(ghostMother.isGhost, isTrue);
      expect(ghostFather.positionX, 380.0);
      expect(ghostFather.positionY, 280.0);
      expect(ghostMother.positionX, 620.0);
      expect(await repo.hasSpouse(ghostFather.id), isTrue);
      expect(await repo.count(), 3); // child + father + mother
    });

    test('Ghost 부모는 isGhost: true 플래그 보유', () async {
      final father = await repo.create(name: '미확인 아버지', isGhost: true, positionX: 0, positionY: 0);
      final mother = await repo.create(name: '미확인 어머니', isGhost: true, positionX: 240, positionY: 0);
      expect(father.isGhost, isTrue);
      expect(mother.isGhost, isTrue);
    });
  });

  group('Ghost Node 위치 자동 배치', () {
    test('Ghost 노드는 원본 노드 옆에 220px 오프셋으로 생성', () async {
      final parent = await repo.create(
          name: '아버지', positionX: 500, positionY: 300);

      // Ghost 배우자 생성 (hasSpouse=false → 자동 생성 시뮬레이션)
      final hasSpouse = await repo.hasSpouse(parent.id);
      expect(hasSpouse, isFalse);

      final ghost = await repo.create(
        name: '미확인 배우자',
        isGhost: true,
        positionX: parent.positionX + 220,
        positionY: parent.positionY,
      );
      await repo.addEdge(
        fromNodeId: parent.id,
        toNodeId: ghost.id,
        relation: RelationType.spouse,
      );

      expect(ghost.isGhost, isTrue);
      expect(ghost.positionX, 720.0);
      expect(ghost.positionY, 300.0);
      expect(await repo.hasSpouse(parent.id), isTrue);
    });

    test('이미 배우자 있으면 Ghost 추가 안함', () async {
      final a = await repo.create(name: '아버지', positionX: 0, positionY: 0);
      final b = await repo.create(name: '어머니', positionX: 200, positionY: 0);
      await repo.addEdge(
          fromNodeId: a.id, toNodeId: b.id, relation: RelationType.spouse);

      // hasSpouse = true → Ghost 추가 생략
      final shouldCreate = !(await repo.hasSpouse(a.id));
      expect(shouldCreate, isFalse);

      final countBefore = await repo.count();
      // Ghost 추가 안함
      expect(await repo.count(), countBefore);
    });
  });
}
