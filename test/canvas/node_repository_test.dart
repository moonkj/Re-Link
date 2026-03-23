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
    db = AppDatabase.forTesting(
      NativeDatabase.memory(setup: (rawDb) {
        rawDb.execute('PRAGMA foreign_keys = ON');
      }),
    );
    repo = createTestNodeRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('NodeRepository CRUD', () {
    test('create — 노드를 생성하고 반환한다', () async {
      final node = await repo.create(name: '홍길동', positionX: 100, positionY: 200);

      expect(node.name, '홍길동');
      expect(node.positionX, 100);
      expect(node.positionY, 200);
      expect(node.isGhost, false);
      expect(node.temperature, 2);
      expect(node.id, isNotEmpty);
    });

    test('create — ghost node 플래그가 저장된다', () async {
      final node = await repo.create(name: '알 수 없는 조상', isGhost: true);
      expect(node.isGhost, true);
    });

    test('getById — 생성된 노드를 ID로 조회한다', () async {
      final created = await repo.create(name: '김영희');
      final found = await repo.getById(created.id);

      expect(found, isNotNull);
      expect(found!.name, '김영희');
    });

    test('getById — 존재하지 않는 ID는 null 반환', () async {
      final found = await repo.getById('nonexistent-id');
      expect(found, isNull);
    });

    test('count — 노드 수를 반환한다', () async {
      expect(await repo.count(), 0);
      await repo.create(name: 'A');
      await repo.create(name: 'B');
      expect(await repo.count(), 2);
    });

    test('update — 노드 정보를 수정한다', () async {
      final node = await repo.create(name: '원본 이름');
      final updated = node.copyWith(name: '수정된 이름', nickname: '닉네임');
      await repo.update(updated);

      final found = await repo.getById(node.id);
      expect(found!.name, '수정된 이름');
      expect(found.nickname, '닉네임');
    });

    test('updateTemperature — 온도값이 0~5로 반영된다', () async {
      final node = await repo.create(name: '테스트');
      await repo.updateTemperature(node.id, 4);

      final found = await repo.getById(node.id);
      expect(found!.temperature, 4);
    });

    test('updatePosition — 위치가 업데이트된다', () async {
      final node = await repo.create(name: '위치 테스트', positionX: 0, positionY: 0);
      await repo.updatePosition(node.id, 500, 300);

      final found = await repo.getById(node.id);
      expect(found!.positionX, 500);
      expect(found.positionY, 300);
    });

    test('delete — 노드를 삭제한다', () async {
      final node = await repo.create(name: '삭제될 노드');
      await repo.delete(node.id);

      final found = await repo.getById(node.id);
      expect(found, isNull);
      expect(await repo.count(), 0);
    });

    test('watchAll — 스트림이 노드 변경을 emit한다', () async {
      final stream = repo.watchAll();

      // 초기 빈 상태
      final initial = await stream.first;
      expect(initial, isEmpty);

      // 노드 추가
      await repo.create(name: '스트림 테스트');
      final afterAdd = await stream.first;
      expect(afterAdd.length, 1);
      expect(afterAdd.first.name, '스트림 테스트');
    });
  });

  group('NodeRepository — Edge', () {
    test('addEdge — 두 노드 간 관계를 생성한다', () async {
      final a = await repo.create(name: '부모');
      final b = await repo.create(name: '자녀');

      final edge = await repo.addEdge(
        fromNodeId: a.id,
        toNodeId: b.id,
        relation: RelationType.parent,
      );

      expect(edge.fromNodeId, a.id);
      expect(edge.toNodeId, b.id);
      expect(edge.relation, RelationType.parent);
    });

    test('deleteEdge — 관계를 삭제한다', () async {
      final a = await repo.create(name: 'A');
      final b = await repo.create(name: 'B');
      final edge = await repo.addEdge(
        fromNodeId: a.id,
        toNodeId: b.id,
        relation: RelationType.sibling,
      );

      await repo.deleteEdge(edge.id);
      final edges = await repo.getEdgesForNode(a.id);
      expect(edges, isEmpty);
    });

    test('delete node — 연결된 엣지도 cascade 삭제', () async {
      final a = await repo.create(name: 'A');
      final b = await repo.create(name: 'B');
      await repo.addEdge(
        fromNodeId: a.id,
        toNodeId: b.id,
        relation: RelationType.spouse,
      );

      await repo.delete(a.id);

      final edgesA = await repo.getEdgesForNode(a.id);
      final edgesB = await repo.getEdgesForNode(b.id);
      expect(edgesA, isEmpty);
      expect(edgesB, isEmpty);
    });

    test('watchAllEdges — 스트림이 엣지 변경을 emit한다', () async {
      final a = await repo.create(name: 'A');
      final b = await repo.create(name: 'B');

      final edgeStream = repo.watchAllEdges();
      expect(await edgeStream.first, isEmpty);

      await repo.addEdge(
        fromNodeId: a.id,
        toNodeId: b.id,
        relation: RelationType.child,
      );
      final edges = await edgeStream.first;
      expect(edges.length, 1);
    });
  });

  group('NodeModel', () {
    test('copyWith — 지정한 필드만 변경된다', () {
      final node = NodeModel(
        id: 'test-id',
        name: '원본',
        isGhost: false,
        temperature: 2,
        positionX: 0,
        positionY: 0,
        tags: const [],
        createdAt: DateTime(2024),
        updatedAt: DateTime(2024),
      );

      final copy = node.copyWith(name: '복사본', temperature: 5);
      expect(copy.name, '복사본');
      expect(copy.temperature, 5);
      expect(copy.id, node.id); // 변경 안 된 필드
      expect(copy.positionX, node.positionX);
    });

    test('isAlive — deathDate가 없으면 true', () {
      final node = NodeModel(
        id: 'id', name: 'n', isGhost: false, temperature: 2,
        positionX: 0, positionY: 0, tags: const [],
        createdAt: DateTime(2024), updatedAt: DateTime(2024),
      );
      expect(node.isAlive, true);
    });

    test('isAlive — deathDate가 있으면 false', () {
      final node = NodeModel(
        id: 'id', name: 'n', isGhost: false, temperature: 2,
        positionX: 0, positionY: 0, tags: const [],
        createdAt: DateTime(2024), updatedAt: DateTime(2024),
        deathDate: DateTime(2020),
      );
      expect(node.isAlive, false);
    });
  });
}
