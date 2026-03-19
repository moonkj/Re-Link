import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:re_link/core/database/app_database.dart';
import 'package:re_link/shared/models/memory_model.dart';
import 'package:re_link/shared/repositories/memory_repository.dart';
import 'package:re_link/shared/repositories/node_repository.dart';

void main() {
  late AppDatabase db;
  late MemoryRepository repo;
  late NodeRepository nodeRepo;
  late String testNodeId;

  setUp(() async {
    db = AppDatabase.forTesting(
      NativeDatabase.memory(setup: (rawDb) {
        rawDb.execute('PRAGMA foreign_keys = ON');
      }),
    );
    repo = MemoryRepository(db);
    nodeRepo = NodeRepository(db);
    // 테스트용 노드 생성
    final node = await nodeRepo.create(name: '테스트 인물');
    testNodeId = node.id;
  });

  tearDown(() async {
    await db.close();
  });

  group('MemoryRepository CRUD', () {
    test('create photo — 사진 기억을 생성한다', () async {
      final memory = await repo.create(
        nodeId: testNodeId,
        type: MemoryType.photo,
        title: '첫 사진',
        filePath: '/path/to/photo.webp',
        thumbnailPath: '/path/to/thumb.webp',
        dateTaken: DateTime(2024, 1, 15),
      );

      expect(memory.type, MemoryType.photo);
      expect(memory.title, '첫 사진');
      expect(memory.filePath, '/path/to/photo.webp');
      expect(memory.thumbnailPath, '/path/to/thumb.webp');
      expect(memory.nodeId, testNodeId);
      expect(memory.id, isNotEmpty);
    });

    test('create voice — 음성 기억을 생성한다', () async {
      final memory = await repo.create(
        nodeId: testNodeId,
        type: MemoryType.voice,
        title: '할머니 목소리',
        filePath: '/path/to/voice.m4a',
        durationSeconds: 90,
      );

      expect(memory.type, MemoryType.voice);
      expect(memory.durationSeconds, 90);
      expect(memory.formattedDuration, '01:30');
    });

    test('create note — 메모 기억을 생성한다', () async {
      final memory = await repo.create(
        nodeId: testNodeId,
        type: MemoryType.note,
        title: '메모 제목',
        description: '메모 내용입니다.',
      );

      expect(memory.type, MemoryType.note);
      expect(memory.description, '메모 내용입니다.');
    });

    test('getById — ID로 기억을 조회한다', () async {
      final created = await repo.create(nodeId: testNodeId, type: MemoryType.note, description: '내용');
      final found = await repo.getById(created.id);

      expect(found, isNotNull);
      expect(found!.id, created.id);
    });

    test('getById — 없는 ID는 null 반환', () async {
      final found = await repo.getById('nonexistent');
      expect(found, isNull);
    });

    test('getForNode — 노드에 속한 기억 목록을 반환한다', () async {
      await repo.create(nodeId: testNodeId, type: MemoryType.photo);
      await repo.create(nodeId: testNodeId, type: MemoryType.note, description: '메모');
      await repo.create(nodeId: testNodeId, type: MemoryType.voice, durationSeconds: 30);

      final memories = await repo.getForNode(testNodeId);
      expect(memories.length, 3);
    });

    test('getForNode — 다른 노드의 기억은 포함하지 않는다', () async {
      final otherNode = await nodeRepo.create(name: '다른 인물');
      await repo.create(nodeId: testNodeId, type: MemoryType.note, description: '내 메모');
      await repo.create(nodeId: otherNode.id, type: MemoryType.note, description: '다른 메모');

      final memories = await repo.getForNode(testNodeId);
      expect(memories.length, 1);
      expect(memories.first.description, '내 메모');
    });

    test('delete — 기억을 삭제한다', () async {
      final memory = await repo.create(nodeId: testNodeId, type: MemoryType.note, description: '삭제될 메모');
      await repo.delete(memory.id);

      final found = await repo.getById(memory.id);
      expect(found, isNull);
    });

    test('delete node — 노드 삭제 시 기억도 cascade 삭제', () async {
      final node2 = await nodeRepo.create(name: '삭제될 인물');
      await repo.create(nodeId: node2.id, type: MemoryType.note, description: '기억');

      await nodeRepo.delete(node2.id);

      final memories = await repo.getForNode(node2.id);
      expect(memories, isEmpty);
    });

    test('watchForNode — 스트림이 기억 추가를 emit한다', () async {
      final stream = repo.watchForNode(testNodeId);
      expect(await stream.first, isEmpty);

      await repo.create(nodeId: testNodeId, type: MemoryType.note, description: '스트림 테스트');
      final after = await stream.first;
      expect(after.length, 1);
    });
  });

  group('MemoryRepository 플랜 제한', () {
    test('totalPhotoCount — 사진 수를 반환한다', () async {
      expect(await repo.totalPhotoCount(), 0);
      await repo.create(nodeId: testNodeId, type: MemoryType.photo);
      await repo.create(nodeId: testNodeId, type: MemoryType.photo);
      await repo.create(nodeId: testNodeId, type: MemoryType.note);
      expect(await repo.totalPhotoCount(), 2);
    });

    test('totalVoiceMinutes — 음성 시간 합을 분 단위로 반환한다', () async {
      expect(await repo.totalVoiceMinutes(), 0);
      await repo.create(nodeId: testNodeId, type: MemoryType.voice, durationSeconds: 90);  // 2분
      await repo.create(nodeId: testNodeId, type: MemoryType.voice, durationSeconds: 60);  // 1분
      expect(await repo.totalVoiceMinutes(), 3); // 150초 → ceil(2.5) = 3분
    });
  });

  group('MemoryModel', () {
    test('formattedDuration — 초를 mm:ss 형식으로 반환', () {
      final m = MemoryModel(
        id: 'id', nodeId: 'n', type: MemoryType.voice,
        durationSeconds: 125, tags: const [], createdAt: DateTime(2024),
      );
      expect(m.formattedDuration, '02:05');
    });

    test('formattedDuration — durationSeconds가 null이면 null 반환', () {
      final m = MemoryModel(
        id: 'id', nodeId: 'n', type: MemoryType.note,
        tags: const [], createdAt: DateTime(2024),
      );
      expect(m.formattedDuration, isNull);
    });

    test('copyWith — 지정 필드만 변경', () {
      final m = MemoryModel(
        id: 'id', nodeId: 'n', type: MemoryType.note,
        title: '원본', tags: const [], createdAt: DateTime(2024),
      );
      final copy = m.copyWith(title: '변경', description: '새 내용');
      expect(copy.title, '변경');
      expect(copy.description, '새 내용');
      expect(copy.id, m.id); // 변경 안 됨
      expect(copy.nodeId, m.nodeId); // 변경 안 됨
    });

    test('equality — id 기반 동등 비교', () {
      final a = MemoryModel(id: 'same', nodeId: 'n', type: MemoryType.note, tags: const [], createdAt: DateTime(2024));
      final b = MemoryModel(id: 'same', nodeId: 'n2', type: MemoryType.photo, tags: const [], createdAt: DateTime(2025));
      final c = MemoryModel(id: 'different', nodeId: 'n', type: MemoryType.note, tags: const [], createdAt: DateTime(2024));
      expect(a, equals(b)); // 같은 id
      expect(a, isNot(equals(c))); // 다른 id
    });
  });
}
