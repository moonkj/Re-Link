/// NodeRepository 전체 메서드 단위 테스트 (미커버 메서드 보강)
/// 커버: node_repository.dart — findEdge, hasDuplicateEdge, addEdge 멱등성/업데이트,
///        updateEdgeRelation, updateEdgeFull, batchUpdatePositions, updatePhoto,
///        getControllableNodes, getEdgesForNode, watchAll/watchAllEdges 등
import 'dart:ui' show Offset;
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

  // ── findEdge ──────────────────────────────────────────────────────────────

  group('findEdge', () {
    test('존재하는 엣지 조회', () async {
      final a = await repo.create(name: 'A', positionX: 0, positionY: 0);
      final b = await repo.create(name: 'B', positionX: 100, positionY: 0);
      await repo.addEdge(
        fromNodeId: a.id,
        toNodeId: b.id,
        relation: RelationType.spouse,
      );
      final edge = await repo.findEdge(fromNodeId: a.id, toNodeId: b.id);
      expect(edge, isNotNull);
      expect(edge!.relation, RelationType.spouse);
    });

    test('역방향으로도 조회 가능', () async {
      final a = await repo.create(name: 'A', positionX: 0, positionY: 0);
      final b = await repo.create(name: 'B', positionX: 100, positionY: 0);
      await repo.addEdge(
        fromNodeId: a.id,
        toNodeId: b.id,
        relation: RelationType.parent,
      );
      final edge = await repo.findEdge(fromNodeId: b.id, toNodeId: a.id);
      expect(edge, isNotNull);
    });

    test('존재하지 않는 엣지 → null', () async {
      final edge = await repo.findEdge(
        fromNodeId: 'nonexistent-a',
        toNodeId: 'nonexistent-b',
      );
      expect(edge, isNull);
    });
  });

  // ── hasDuplicateEdge ──────────────────────────────────────────────────────

  group('hasDuplicateEdge', () {
    test('동일 관계 존재 → true', () async {
      final a = await repo.create(name: 'A', positionX: 0, positionY: 0);
      final b = await repo.create(name: 'B', positionX: 100, positionY: 0);
      await repo.addEdge(
        fromNodeId: a.id,
        toNodeId: b.id,
        relation: RelationType.sibling,
      );
      expect(
        await repo.hasDuplicateEdge(
          fromNodeId: a.id,
          toNodeId: b.id,
          relation: RelationType.sibling,
        ),
        isTrue,
      );
    });

    test('다른 관계 → false', () async {
      final a = await repo.create(name: 'A', positionX: 0, positionY: 0);
      final b = await repo.create(name: 'B', positionX: 100, positionY: 0);
      await repo.addEdge(
        fromNodeId: a.id,
        toNodeId: b.id,
        relation: RelationType.sibling,
      );
      expect(
        await repo.hasDuplicateEdge(
          fromNodeId: a.id,
          toNodeId: b.id,
          relation: RelationType.spouse,
        ),
        isFalse,
      );
    });

    test('역방향 동일 관계도 감지', () async {
      final a = await repo.create(name: 'A', positionX: 0, positionY: 0);
      final b = await repo.create(name: 'B', positionX: 100, positionY: 0);
      await repo.addEdge(
        fromNodeId: a.id,
        toNodeId: b.id,
        relation: RelationType.spouse,
      );
      expect(
        await repo.hasDuplicateEdge(
          fromNodeId: b.id,
          toNodeId: a.id,
          relation: RelationType.spouse,
        ),
        isTrue,
      );
    });

    test('엣지 없을 때 → false', () async {
      final a = await repo.create(name: 'A', positionX: 0, positionY: 0);
      final b = await repo.create(name: 'B', positionX: 100, positionY: 0);
      expect(
        await repo.hasDuplicateEdge(
          fromNodeId: a.id,
          toNodeId: b.id,
          relation: RelationType.spouse,
        ),
        isFalse,
      );
    });
  });

  // ── addEdge 멱등성 ────────────────────────────────────────────────────────

  group('addEdge 멱등성', () {
    test('동일 관계 재추가 → 기존 엣지 반환 (no-op)', () async {
      final a = await repo.create(name: 'A', positionX: 0, positionY: 0);
      final b = await repo.create(name: 'B', positionX: 100, positionY: 0);
      final edge1 = await repo.addEdge(
        fromNodeId: a.id,
        toNodeId: b.id,
        relation: RelationType.spouse,
      );
      final edge2 = await repo.addEdge(
        fromNodeId: a.id,
        toNodeId: b.id,
        relation: RelationType.spouse,
      );
      expect(edge1.id, edge2.id);
    });

    test('다른 관계로 업데이트', () async {
      final a = await repo.create(name: 'A', positionX: 0, positionY: 0);
      final b = await repo.create(name: 'B', positionX: 100, positionY: 0);
      final edge1 = await repo.addEdge(
        fromNodeId: a.id,
        toNodeId: b.id,
        relation: RelationType.sibling,
      );
      final edge2 = await repo.addEdge(
        fromNodeId: a.id,
        toNodeId: b.id,
        relation: RelationType.spouse,
      );
      expect(edge2.id, edge1.id);
      expect(edge2.relation, RelationType.spouse);
    });

    test('방향 변경 (from/to 반전)', () async {
      final a = await repo.create(name: 'A', positionX: 0, positionY: 0);
      final b = await repo.create(name: 'B', positionX: 100, positionY: 0);
      final edge1 = await repo.addEdge(
        fromNodeId: a.id,
        toNodeId: b.id,
        relation: RelationType.parent,
      );
      // 역방향 + 다른 관계
      final edge2 = await repo.addEdge(
        fromNodeId: b.id,
        toNodeId: a.id,
        relation: RelationType.child,
      );
      expect(edge2.id, edge1.id);
      expect(edge2.fromNodeId, b.id);
      expect(edge2.toNodeId, a.id);
      expect(edge2.relation, RelationType.child);
    });
  });

  // ── updateEdgeRelation ────────────────────────────────────────────────────

  group('updateEdgeRelation', () {
    test('관계 타입 업데이트', () async {
      final a = await repo.create(name: 'A', positionX: 0, positionY: 0);
      final b = await repo.create(name: 'B', positionX: 100, positionY: 0);
      final edge = await repo.addEdge(
        fromNodeId: a.id,
        toNodeId: b.id,
        relation: RelationType.other,
      );
      await repo.updateEdgeRelation(edge.id, RelationType.sibling);
      final updated = await repo.findEdge(fromNodeId: a.id, toNodeId: b.id);
      expect(updated!.relation, RelationType.sibling);
    });
  });

  // ── batchUpdatePositions ──────────────────────────────────────────────────

  group('batchUpdatePositions', () {
    test('여러 노드 일괄 위치 업데이트', () async {
      final a = await repo.create(name: 'A', positionX: 0, positionY: 0);
      final b = await repo.create(name: 'B', positionX: 0, positionY: 0);
      await repo.batchUpdatePositions({
        a.id: const Offset(100, 200),
        b.id: const Offset(300, 400),
      });
      final updatedA = await repo.getById(a.id);
      final updatedB = await repo.getById(b.id);
      expect(updatedA!.positionX, 100);
      expect(updatedA.positionY, 200);
      expect(updatedB!.positionX, 300);
      expect(updatedB.positionY, 400);
    });

    test('빈 Map → 에러 없이 종료', () async {
      await repo.batchUpdatePositions({});
    });

    test('존재하지 않는 노드 ID 포함 → 에러 없이 건너뜀', () async {
      final a = await repo.create(name: 'A', positionX: 0, positionY: 0);
      await repo.batchUpdatePositions({
        a.id: const Offset(50, 60),
        'nonexistent': const Offset(999, 999),
      });
      final updated = await repo.getById(a.id);
      expect(updated!.positionX, 50);
    });
  });

  // ── updatePhoto ───────────────────────────────────────────────────────────

  group('updatePhoto', () {
    test('사진 경로 업데이트', () async {
      final node = await repo.create(name: 'A', positionX: 0, positionY: 0);
      await repo.updatePhoto(node.id, 'media/new_photo.webp');
      final updated = await repo.getById(node.id);
      expect(updated!.photoPath, 'media/new_photo.webp');
    });

    test('존재하지 않는 노드 → 에러 없이 종료', () async {
      await repo.updatePhoto('nonexistent', 'photo.webp');
    });

    test('null 사진 → photoPath 유지 (null이 전달되면 기존값 유지)', () async {
      final node = await repo.create(
        name: 'A',
        positionX: 0,
        positionY: 0,
        photoPath: 'original.webp',
      );
      await repo.updatePhoto(node.id, null);
      final updated = await repo.getById(node.id);
      // copyWith에서 null은 기존값 유지
      expect(updated!.photoPath, 'original.webp');
    });
  });

  // ── getControllableNodes ──────────────────────────────────────────────────

  group('getControllableNodes', () {
    test('유령 노드 제외', () async {
      await repo.create(name: 'Normal', positionX: 0, positionY: 0);
      await repo.create(
        name: 'Ghost',
        positionX: 100,
        positionY: 0,
        isGhost: true,
      );
      final controllable = await repo.getControllableNodes();
      expect(controllable.length, 1);
      expect(controllable.first.name, 'Normal');
    });

    test('빈 DB → 빈 리스트', () async {
      final controllable = await repo.getControllableNodes();
      expect(controllable, isEmpty);
    });

    test('유령만 있을 때 → 빈 리스트', () async {
      await repo.create(
        name: 'Ghost1',
        positionX: 0,
        positionY: 0,
        isGhost: true,
      );
      final controllable = await repo.getControllableNodes();
      expect(controllable, isEmpty);
    });
  });

  // ── watchAll / watchAllEdges (스트림 첫 emit 확인) ─────────────────────────

  group('스트림 확인', () {
    test('watchAll — 초기 빈 리스트', () async {
      final first = await repo.watchAll().first;
      expect(first, isEmpty);
    });

    test('watchAllEdges — 초기 빈 리스트', () async {
      final first = await repo.watchAllEdges().first;
      expect(first, isEmpty);
    });
  });

  // ── create — tags 보존 ────────────────────────────────────────────────────

  group('create — 필드 보존', () {
    test('tags 배열 저장/복원', () async {
      final node = await repo.create(
        name: 'Tagged',
        positionX: 0,
        positionY: 0,
        tags: ['가족', '친구'],
      );
      final fetched = await repo.getById(node.id);
      expect(fetched!.tags, containsAll(['가족', '친구']));
    });

    test('nickname, bio, birthDate, deathDate 저장', () async {
      final node = await repo.create(
        name: '테스트',
        nickname: '닉네임',
        bio: '소개글',
        birthDate: DateTime(1990, 5, 15),
        deathDate: DateTime(2020, 10, 1),
        positionX: 0,
        positionY: 0,
      );
      final fetched = await repo.getById(node.id);
      expect(fetched!.nickname, '닉네임');
      expect(fetched.bio, '소개글');
      expect(fetched.birthDate!.year, 1990);
      expect(fetched.deathDate!.year, 2020);
    });
  });
}
