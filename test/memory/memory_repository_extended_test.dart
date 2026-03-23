/// MemoryRepository 확장 테스트
/// 커버: memory_repository.dart — searchMemories, setPrivate
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:re_link/core/database/app_database.dart';
import 'package:re_link/shared/models/memory_model.dart';
import 'package:re_link/shared/repositories/memory_repository.dart';
import 'package:re_link/shared/repositories/node_repository.dart';
import '../helpers/test_helpers.dart';

void main() {
  late AppDatabase db;
  late MemoryRepository repo;
  late NodeRepository nodeRepo;
  late String testNodeId;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = MemoryRepository(db);
    nodeRepo = createTestNodeRepository(db);
    final node = await nodeRepo.create(name: '테스트', positionX: 0, positionY: 0);
    testNodeId = node.id;
  });

  tearDown(() => db.close());

  // ── searchMemories ────────────────────────────────────────────────────────

  group('MemoryRepository.searchMemories', () {
    test('빈 쿼리 → 빈 리스트', () async {
      await repo.create(nodeId: testNodeId, type: MemoryType.note, title: '제목');
      expect(await repo.searchMemories(''), isEmpty);
    });

    test('공백만 → 빈 리스트', () async {
      expect(await repo.searchMemories('   '), isEmpty);
    });

    test('제목 일치 → 결과 반환', () async {
      await repo.create(nodeId: testNodeId, type: MemoryType.note, title: '여름 사진');
      await repo.create(nodeId: testNodeId, type: MemoryType.note, title: '겨울 이야기');
      final results = await repo.searchMemories('여름');
      expect(results.length, 1);
      expect(results.first.title, '여름 사진');
    });

    test('description 일치 → 결과 반환', () async {
      await repo.create(
        nodeId: testNodeId,
        type: MemoryType.note,
        title: '메모',
        description: '일기 내용',
      );
      final results = await repo.searchMemories('일기');
      expect(results.length, 1);
    });

    test('매칭 없으면 빈 리스트', () async {
      await repo.create(nodeId: testNodeId, type: MemoryType.note, title: '메모');
      final results = await repo.searchMemories('없는검색어');
      expect(results, isEmpty);
    });
  });

  // ── setPrivate ────────────────────────────────────────────────────────────

  group('MemoryRepository.setPrivate', () {
    test('setPrivate(true) → isPrivate=true', () async {
      final m = await repo.create(
        nodeId: testNodeId, type: MemoryType.note, title: '비밀',
      );
      await repo.setPrivate(m.id, isPrivate: true);
      final found = await repo.getById(m.id);
      expect(found?.isPrivate, isTrue);
    });

    test('setPrivate(false) → isPrivate=false', () async {
      final m = await repo.create(
        nodeId: testNodeId, type: MemoryType.note, title: '공개',
      );
      await repo.setPrivate(m.id, isPrivate: true);
      await repo.setPrivate(m.id, isPrivate: false);
      final found = await repo.getById(m.id);
      expect(found?.isPrivate, isFalse);
    });
  });
}
