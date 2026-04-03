/// TodayMemoryService 실제 코드 테스트 (MockDatabase 사용)
/// 커버: today_memory_service.dart — getTodayMemories 전체 로직
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:re_link/core/database/app_database.dart';
import 'package:re_link/core/services/widget/today_memory_service.dart';

class MockAppDatabase extends Mock implements AppDatabase {}

void main() {
  late MockAppDatabase mockDb;
  late TodayMemoryService service;

  setUp(() {
    mockDb = MockAppDatabase();
    service = TodayMemoryService(mockDb);
  });

  NodesTableData makeNode(String id, String name) => NodesTableData(
        id: id,
        name: name,
        isGhost: false,
        temperature: 2,
        positionX: 0,
        positionY: 0,
        tagsJson: '[]',
        createdAt: DateTime(2020),
        updatedAt: DateTime(2020),
      );

  MemoriesTableData makeMemory({
    required String id,
    required String nodeId,
    required String type,
    DateTime? dateTaken,
    required DateTime createdAt,
  }) =>
      MemoriesTableData(
        id: id,
        nodeId: nodeId,
        type: type,
        dateTaken: dateTaken,
        createdAt: createdAt,
        tagsJson: '[]',
        isPrivate: false,
      );

  group('TodayMemoryService.getTodayMemories', () {
    test('returns empty when no nodes', () async {
      when(() => mockDb.getAllNodes()).thenAnswer((_) async => []);

      final result = await service.getTodayMemories();
      expect(result, isEmpty);
    });

    test('returns matching memories from past same-day', () async {
      final now = DateTime.now();
      final oneYearAgo = DateTime(now.year - 1, now.month, now.day);

      final node = makeNode('n1', 'Mom');
      when(() => mockDb.getAllNodes()).thenAnswer((_) async => [node]);
      when(() => mockDb.getMemoriesForNode('n1')).thenAnswer(
        (_) async => [
          makeMemory(
            id: 'm1',
            nodeId: 'n1',
            type: 'photo',
            dateTaken: oneYearAgo,
            createdAt: oneYearAgo,
          ),
        ],
      );

      final result = await service.getTodayMemories();
      expect(result.length, 1);
      expect(result.first.memoryId, 'm1');
      expect(result.first.nodeName, 'Mom');
      expect(result.first.yearsAgo, 1);
      expect(result.first.type, 'photo');
    });

    test('excludes memories from same year', () async {
      final now = DateTime.now();
      final todayThisYear = DateTime(now.year, now.month, now.day, 10, 0);

      final node = makeNode('n1', 'Dad');
      when(() => mockDb.getAllNodes()).thenAnswer((_) async => [node]);
      when(() => mockDb.getMemoriesForNode('n1')).thenAnswer(
        (_) async => [
          makeMemory(
            id: 'm1',
            nodeId: 'n1',
            type: 'note',
            dateTaken: todayThisYear,
            createdAt: todayThisYear,
          ),
        ],
      );

      final result = await service.getTodayMemories();
      expect(result, isEmpty);
    });

    test('excludes memories from different day', () async {
      final now = DateTime.now();
      final differentDay = DateTime(now.year - 1, now.month,
          now.day == 1 ? 2 : now.day - 1);

      final node = makeNode('n1', 'Sis');
      when(() => mockDb.getAllNodes()).thenAnswer((_) async => [node]);
      when(() => mockDb.getMemoriesForNode('n1')).thenAnswer(
        (_) async => [
          makeMemory(
            id: 'm1',
            nodeId: 'n1',
            type: 'voice',
            dateTaken: differentDay,
            createdAt: differentDay,
          ),
        ],
      );

      final result = await service.getTodayMemories();
      expect(result, isEmpty);
    });

    test('uses createdAt when dateTaken is null', () async {
      final now = DateTime.now();
      final twoYearsAgo = DateTime(now.year - 2, now.month, now.day);

      final node = makeNode('n1', 'Bro');
      when(() => mockDb.getAllNodes()).thenAnswer((_) async => [node]);
      when(() => mockDb.getMemoriesForNode('n1')).thenAnswer(
        (_) async => [
          makeMemory(
            id: 'm1',
            nodeId: 'n1',
            type: 'note',
            dateTaken: null,
            createdAt: twoYearsAgo,
          ),
        ],
      );

      final result = await service.getTodayMemories();
      expect(result.length, 1);
      expect(result.first.yearsAgo, 2);
    });

    test('results sorted by yearsAgo descending (oldest first)', () async {
      final now = DateTime.now();
      final oneYearAgo = DateTime(now.year - 1, now.month, now.day);
      final threeYearsAgo = DateTime(now.year - 3, now.month, now.day);

      final node = makeNode('n1', 'Family');
      when(() => mockDb.getAllNodes()).thenAnswer((_) async => [node]);
      when(() => mockDb.getMemoriesForNode('n1')).thenAnswer(
        (_) async => [
          makeMemory(
            id: 'm1',
            nodeId: 'n1',
            type: 'photo',
            dateTaken: oneYearAgo,
            createdAt: oneYearAgo,
          ),
          makeMemory(
            id: 'm2',
            nodeId: 'n1',
            type: 'photo',
            dateTaken: threeYearsAgo,
            createdAt: threeYearsAgo,
          ),
        ],
      );

      final result = await service.getTodayMemories();
      expect(result.length, 2);
      expect(result[0].yearsAgo, 3); // oldest first
      expect(result[1].yearsAgo, 1);
    });

    test('multiple nodes with matching memories', () async {
      final now = DateTime.now();
      final lastYear = DateTime(now.year - 1, now.month, now.day);

      final node1 = makeNode('n1', 'Mom');
      final node2 = makeNode('n2', 'Dad');

      when(() => mockDb.getAllNodes()).thenAnswer((_) async => [node1, node2]);
      when(() => mockDb.getMemoriesForNode('n1')).thenAnswer(
        (_) async => [
          makeMemory(
            id: 'm1', nodeId: 'n1', type: 'photo',
            dateTaken: lastYear, createdAt: lastYear,
          ),
        ],
      );
      when(() => mockDb.getMemoriesForNode('n2')).thenAnswer(
        (_) async => [
          makeMemory(
            id: 'm2', nodeId: 'n2', type: 'voice',
            dateTaken: lastYear, createdAt: lastYear,
          ),
        ],
      );

      final result = await service.getTodayMemories();
      expect(result.length, 2);
      final nodeNames = result.map((r) => r.nodeName).toSet();
      expect(nodeNames, containsAll(['Mom', 'Dad']));
    });
  });
}
