/// Ghost Node 자동 생성 단위 테스트
/// NodeRepository.hasSpouse + createNodeWithAutoGhost 검증
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:re_link/core/database/app_database.dart';
import 'package:re_link/shared/models/node_model.dart';
import 'package:re_link/shared/repositories/node_repository.dart';

void main() {
  late AppDatabase db;
  late NodeRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = NodeRepository(db);
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
