/// NodeRepository 확장 단위 테스트
/// 커버: node_repository.dart — getAll, createWithModel, updateFromModel,
///        hasSpouse, updatePosition, updateTemperature, searchNodes, addEdge, deleteEdge
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

  // ── getAll ────────────────────────────────────────────────────────────────

  group('getAll', () {
    test('빈 DB → 빈 리스트', () async {
      expect(await repo.getAll(), isEmpty);
    });

    test('노드 2개 생성 후 getAll → 2개 반환', () async {
      await repo.create(name: '홍길동', positionX: 0, positionY: 0);
      await repo.create(name: '김철수', positionX: 100, positionY: 100);
      expect((await repo.getAll()).length, 2);
    });
  });

  // ── createWithModel ───────────────────────────────────────────────────────

  group('createWithModel', () {
    test('모델로 노드 생성 후 getById로 조회 가능', () async {
      final model = NodeModel(
        id: 'fixed-uuid-1234',
        name: '외부노드',
        createdAt: DateTime(2024),
        positionX: 50.0,
        positionY: 80.0,
      );
      await repo.createWithModel(model);
      final found = await repo.getById('fixed-uuid-1234');
      expect(found, isNotNull);
      expect(found!.name, '외부노드');
    });

    test('createWithModel — position +20 오프셋 적용', () async {
      final model = NodeModel(
        id: 'offset-test',
        name: '오프셋테스트',
        createdAt: DateTime(2024),
        positionX: 100.0,
        positionY: 200.0,
      );
      await repo.createWithModel(model);
      final found = await repo.getById('offset-test');
      expect(found!.positionX, 120.0);
      expect(found.positionY, 220.0);
    });

    test('createWithModel — isGhost, tags, temperature 보존', () async {
      final model = NodeModel(
        id: 'ghost-merge',
        name: '고스트',
        createdAt: DateTime(2024),
        isGhost: true,
        temperature: 4,
        tags: ['외부', '병합'],
      );
      await repo.createWithModel(model);
      final found = await repo.getById('ghost-merge');
      expect(found!.isGhost, isTrue);
      expect(found.temperature, 4);
      expect(found.tags, containsAll(['외부', '병합']));
    });
  });

  // ── updateFromModel ───────────────────────────────────────────────────────

  group('updateFromModel', () {
    test('updateFromModel — 이름/닉네임 변경', () async {
      final node = await repo.create(name: '원래이름', positionX: 0, positionY: 0);
      final updated = node.copyWith(name: '바뀐이름', nickname: '닉');
      await repo.updateFromModel(updated);
      final found = await repo.getById(node.id);
      expect(found!.name, '바뀐이름');
      expect(found.nickname, '닉');
    });

    test('updateFromModel — temperature 업데이트', () async {
      final node = await repo.create(name: '테스트', positionX: 0, positionY: 0);
      await repo.updateFromModel(node.copyWith(temperature: 5));
      final found = await repo.getById(node.id);
      expect(found!.temperature, 5);
    });
  });

  // ── updatePosition / updateTemperature ───────────────────────────────────

  group('updatePosition', () {
    test('position 업데이트', () async {
      final node = await repo.create(name: '이동', positionX: 0, positionY: 0);
      await repo.updatePosition(node.id, 300.0, 400.0);
      final found = await repo.getById(node.id);
      expect(found!.positionX, 300.0);
      expect(found.positionY, 400.0);
    });

    test('존재하지 않는 id → 에러 없이 종료', () async {
      await repo.updatePosition('nonexistent', 1.0, 2.0);
    });
  });

  group('updateTemperature', () {
    test('temperature 업데이트', () async {
      final node = await repo.create(name: '온도', positionX: 0, positionY: 0);
      await repo.updateTemperature(node.id, 4);
      final found = await repo.getById(node.id);
      expect(found!.temperature, 4);
    });

    test('존재하지 않는 id → 에러 없이 종료', () async {
      await repo.updateTemperature('ghost_id', 3);
    });
  });

  // ── hasSpouse ─────────────────────────────────────────────────────────────

  group('hasSpouse', () {
    test('관계 없을 때 → false', () async {
      final node = await repo.create(name: '독신', positionX: 0, positionY: 0);
      expect(await repo.hasSpouse(node.id), isFalse);
    });

    test('spouse 관계 있을 때 → true', () async {
      final a = await repo.create(name: '남편', positionX: 0, positionY: 0);
      final b = await repo.create(name: '아내', positionX: 100, positionY: 0);
      await repo.addEdge(
        fromNodeId: a.id,
        toNodeId: b.id,
        relation: RelationType.spouse,
      );
      expect(await repo.hasSpouse(a.id), isTrue);
    });

    test('parent 관계만 있을 때 → false', () async {
      final a = await repo.create(name: '부모', positionX: 0, positionY: 0);
      final b = await repo.create(name: '자녀', positionX: 100, positionY: 0);
      await repo.addEdge(
        fromNodeId: a.id,
        toNodeId: b.id,
        relation: RelationType.parent,
      );
      expect(await repo.hasSpouse(a.id), isFalse);
    });
  });

  // ── searchNodes ───────────────────────────────────────────────────────────

  group('searchNodes', () {
    test('빈 쿼리 → 빈 리스트', () async {
      await repo.create(name: '홍길동', positionX: 0, positionY: 0);
      expect(await repo.searchNodes(''), isEmpty);
    });

    test('공백만 → 빈 리스트', () async {
      expect(await repo.searchNodes('   '), isEmpty);
    });

    test('이름 일치 → 결과 반환', () async {
      await repo.create(name: '홍길동', positionX: 0, positionY: 0);
      await repo.create(name: '김철수', positionX: 100, positionY: 0);
      final results = await repo.searchNodes('홍');
      expect(results.length, 1);
      expect(results.first.name, '홍길동');
    });
  });

  // ── addEdge / deleteEdge ──────────────────────────────────────────────────

  group('addEdge / deleteEdge', () {
    test('addEdge 후 getEdgesForNode 포함 확인', () async {
      final a = await repo.create(name: 'A', positionX: 0, positionY: 0);
      final b = await repo.create(name: 'B', positionX: 0, positionY: 0);
      final edge = await repo.addEdge(
        fromNodeId: a.id,
        toNodeId: b.id,
        relation: RelationType.sibling,
        label: '형제',
      );
      final edges = await repo.getEdgesForNode(a.id);
      expect(edges.any((e) => e.id == edge.id), isTrue);
      expect(edges.first.label, '형제');
    });

    test('deleteEdge 후 엣지 미포함', () async {
      final a = await repo.create(name: 'A', positionX: 0, positionY: 0);
      final b = await repo.create(name: 'B', positionX: 0, positionY: 0);
      final edge = await repo.addEdge(
        fromNodeId: a.id,
        toNodeId: b.id,
        relation: RelationType.child,
      );
      await repo.deleteEdge(edge.id);
      final edges = await repo.getEdgesForNode(a.id);
      expect(edges.any((e) => e.id == edge.id), isFalse);
    });

    test('addEdge — other 관계 → _edgeRowToModel orElse 경로', () async {
      final a = await repo.create(name: 'A', positionX: 0, positionY: 0);
      final b = await repo.create(name: 'B', positionX: 0, positionY: 0);
      final edge = await repo.addEdge(
        fromNodeId: a.id,
        toNodeId: b.id,
        relation: RelationType.other,
      );
      expect(edge.relation, RelationType.other);
    });
  });

  // ── count ─────────────────────────────────────────────────────────────────

  group('count', () {
    test('빈 DB → 0', () async {
      expect(await repo.count(), 0);
    });

    test('3개 생성 → 3', () async {
      for (int i = 0; i < 3; i++) {
        await repo.create(name: '노드$i', positionX: i * 10.0, positionY: 0);
      }
      expect(await repo.count(), 3);
    });
  });

  // ── delete ────────────────────────────────────────────────────────────────

  group('delete', () {
    test('생성 후 삭제 → getById=null', () async {
      final node = await repo.create(name: '삭제대상', positionX: 0, positionY: 0);
      await repo.delete(node.id);
      expect(await repo.getById(node.id), isNull);
    });
  });
}
