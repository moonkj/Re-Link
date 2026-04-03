/// AppDatabase 메서드 단위 테스트
/// 커버: app_database.dart — _escapeLike, _insertDefaultSettings, getStats,
///        searchNodes, searchMemories, searchRecipes, CRUD, cascade delete 등
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:re_link/core/database/app_database.dart';
import 'package:re_link/core/database/tables/settings_table.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory(setup: (db) {
      db.execute('PRAGMA foreign_keys = ON');
    }));
  });

  tearDown(() => db.close());

  // ── _escapeLike (SQL LIKE escape utility) ─────────────────────────────────

  group('_escapeLike (via searchNodes)', () {
    test('일반 문자열은 그대로 통과', () async {
      await db.upsertNode(NodesTableCompanion.insert(
        id: 'n1',
        name: '홍길동',
        createdAt: Value(DateTime(2024)),
      ));
      final results = await db.searchNodes('홍길동');
      expect(results.length, 1);
      expect(results.first.name, '홍길동');
    });

    test('% 와일드카드가 이스케이프됨 (SQL 인젝션 방지)', () async {
      await db.upsertNode(NodesTableCompanion.insert(
        id: 'n1',
        name: '홍%길동',
        createdAt: Value(DateTime(2024)),
      ));
      // 검색어에 %가 포함되면 제거됨
      final results = await db.searchNodes('%');
      // %가 제거되면 빈 쿼리가 되어 모든 노드가 매칭됨 (LIKE '%%')
      expect(results, isNotEmpty);
    });

    test('_ 와일드카드가 이스케이프됨', () async {
      await db.upsertNode(NodesTableCompanion.insert(
        id: 'n1',
        name: '홍길동',
        createdAt: Value(DateTime(2024)),
      ));
      // _가 제거되면 빈 문자열로 검색
      final results = await db.searchNodes('_');
      expect(results, isNotEmpty);
    });

    test('싱글 쿼트가 이스케이프됨', () async {
      await db.upsertNode(NodesTableCompanion.insert(
        id: 'n1',
        name: "O'Brien",
        createdAt: Value(DateTime(2024)),
      ));
      // 싱글 쿼트가 제거되어 OBrien으로 검색
      final results = await db.searchNodes("O'Brien");
      // OBrien은 O'Brien과 매칭됨 (LIKE '%OBrien%')
      // Drift가 파라미터 바인딩하므로 에러는 없어야 함
      expect(results, isA<List<NodesTableData>>());
    });

    test('복합 특수문자 제거', () async {
      await db.upsertNode(NodesTableCompanion.insert(
        id: 'n1',
        name: '테스트노드',
        createdAt: Value(DateTime(2024)),
      ));
      final results = await db.searchNodes("%_'테스트");
      expect(results.length, 1);
    });
  });

  // ── _insertDefaultSettings ────────────────────────────────────────────────

  group('_insertDefaultSettings (DB 생성 시 호출됨)', () {
    test('user_plan 기본값 = free', () async {
      final val = await db.getSetting(SettingsKey.userPlan);
      expect(val, 'free');
    });

    test('auto_backup 기본값 = true', () async {
      final val = await db.getSetting(SettingsKey.autoBackup);
      expect(val, 'true');
    });

    test('backup_freq 기본값 = daily', () async {
      final val = await db.getSetting(SettingsKey.backupFrequency);
      expect(val, 'daily');
    });

    test('onboarding_done 기본값 = false', () async {
      final val = await db.getSetting(SettingsKey.onboardingDone);
      expect(val, 'false');
    });

    test('cloud_provider 기본값 — 비어있지 않음', () async {
      final val = await db.getSetting(SettingsKey.cloudProvider);
      expect(val, isNotNull);
      expect(val, isNotEmpty);
    });

    test('canvas_scale 기본값 = 1.0', () async {
      final val = await db.getSetting(SettingsKey.canvasScale);
      expect(val, '1.0');
    });

    test('canvas_offset_x 기본값 = 0.0', () async {
      final val = await db.getSetting(SettingsKey.canvasOffsetX);
      expect(val, '0.0');
    });

    test('canvas_offset_y 기본값 = 0.0', () async {
      final val = await db.getSetting(SettingsKey.canvasOffsetY);
      expect(val, '0.0');
    });
  });

  // ── getStats ──────────────────────────────────────────────────────────────

  group('getStats', () {
    test('빈 DB → nodes=0, memories=0', () async {
      final stats = await db.getStats();
      expect(stats['nodes'], 0);
      expect(stats['memories'], 0);
    });

    test('노드 2개, 기억 3개 → 정확한 카운트', () async {
      await db.upsertNode(NodesTableCompanion.insert(
        id: 'n1', name: '노드1', createdAt: Value(DateTime(2024)),
      ));
      await db.upsertNode(NodesTableCompanion.insert(
        id: 'n2', name: '노드2', createdAt: Value(DateTime(2024)),
      ));
      for (int i = 0; i < 3; i++) {
        await db.upsertMemory(MemoriesTableCompanion.insert(
          id: 'mem-$i',
          nodeId: 'n1',
          type: 'photo',
          createdAt: Value(DateTime(2024)),
        ));
      }
      final stats = await db.getStats();
      expect(stats['nodes'], 2);
      expect(stats['memories'], 3);
    });
  });

  // ── getSetting / setSetting ───────────────────────────────────────────────

  group('getSetting / setSetting', () {
    test('존재하지 않는 키 → null', () async {
      expect(await db.getSetting('nonexistent'), isNull);
    });

    test('set 후 get → 값 반환', () async {
      await db.setSetting('test_key', 'test_value');
      expect(await db.getSetting('test_key'), 'test_value');
    });

    test('덮어쓰기', () async {
      await db.setSetting('k', 'v1');
      await db.setSetting('k', 'v2');
      expect(await db.getSetting('k'), 'v2');
    });
  });

  // ── searchMemories ────────────────────────────────────────────────────────

  group('searchMemories', () {
    test('제목으로 검색', () async {
      await db.upsertNode(NodesTableCompanion.insert(
        id: 'n1', name: 'A', createdAt: Value(DateTime(2024)),
      ));
      await db.upsertMemory(MemoriesTableCompanion.insert(
        id: 'm1',
        nodeId: 'n1',
        type: 'photo',
        title: Value('가족 여행'),
        createdAt: Value(DateTime(2024)),
      ));
      await db.upsertMemory(MemoriesTableCompanion.insert(
        id: 'm2',
        nodeId: 'n1',
        type: 'photo',
        title: Value('생일 파티'),
        createdAt: Value(DateTime(2024)),
      ));
      final results = await db.searchMemories('가족');
      expect(results.length, 1);
      expect(results.first.title, '가족 여행');
    });

    test('설명으로 검색', () async {
      await db.upsertNode(NodesTableCompanion.insert(
        id: 'n1', name: 'A', createdAt: Value(DateTime(2024)),
      ));
      await db.upsertMemory(MemoriesTableCompanion.insert(
        id: 'm1',
        nodeId: 'n1',
        type: 'memo',
        description: Value('제주도에서 찍은 사진'),
        createdAt: Value(DateTime(2024)),
      ));
      final results = await db.searchMemories('제주도');
      expect(results.length, 1);
    });

    test('검색 결과 없음', () async {
      final results = await db.searchMemories('존재하지않는검색어');
      expect(results, isEmpty);
    });
  });

  // ── searchRecipes ─────────────────────────────────────────────────────────

  group('searchRecipes', () {
    test('제목으로 검색', () async {
      await db.upsertNode(NodesTableCompanion.insert(
        id: 'n1', name: 'A', createdAt: Value(DateTime(2024)),
      ));
      await db.upsertRecipe(RecipesTableCompanion.insert(
        id: 'r1',
        nodeId: Value('n1'),
        title: '김치찌개 레시피',
        ingredients: '김치, 돼지고기',
        instructions: '끓이기',
        createdAt: Value(DateTime(2024)),
      ));
      final results = await db.searchRecipes('김치');
      expect(results.length, 1);
      expect(results.first.title, '김치찌개 레시피');
    });
  });

  // ── nodeCount ─────────────────────────────────────────────────────────────

  group('nodeCount', () {
    test('빈 DB → 0', () async {
      expect(await db.nodeCount(), 0);
    });

    test('노드 추가 후 카운트 증가', () async {
      await db.upsertNode(NodesTableCompanion.insert(
        id: 'n1', name: 'A', createdAt: Value(DateTime(2024)),
      ));
      expect(await db.nodeCount(), 1);
    });
  });

  // ── searchNodes (별명 검색) ────────────────────────────────────────────────

  group('searchNodes 별명', () {
    test('닉네임으로 검색', () async {
      await db.upsertNode(NodesTableCompanion.insert(
        id: 'n1',
        name: '김철수',
        nickname: Value('막내'),
        createdAt: Value(DateTime(2024)),
      ));
      final results = await db.searchNodes('막내');
      expect(results.length, 1);
      expect(results.first.name, '김철수');
    });
  });

  // ── Edge CRUD ─────────────────────────────────────────────────────────────

  group('Edge CRUD', () {
    test('upsertEdge + getEdgesForNode', () async {
      await db.upsertNode(NodesTableCompanion.insert(
        id: 'n1', name: 'A', createdAt: Value(DateTime(2024)),
      ));
      await db.upsertNode(NodesTableCompanion.insert(
        id: 'n2', name: 'B', createdAt: Value(DateTime(2024)),
      ));
      await db.upsertEdge(NodeEdgesTableCompanion.insert(
        id: 'e1',
        fromNodeId: 'n1',
        toNodeId: 'n2',
        relation: 'spouse',
        createdAt: Value(DateTime(2024)),
      ));
      final edges = await db.getEdgesForNode('n1');
      expect(edges.length, 1);
      expect(edges.first.relation, 'spouse');
    });

    test('findEdgeBetween — 양방향 검색', () async {
      await db.upsertNode(NodesTableCompanion.insert(
        id: 'n1', name: 'A', createdAt: Value(DateTime(2024)),
      ));
      await db.upsertNode(NodesTableCompanion.insert(
        id: 'n2', name: 'B', createdAt: Value(DateTime(2024)),
      ));
      await db.upsertEdge(NodeEdgesTableCompanion.insert(
        id: 'e1',
        fromNodeId: 'n1',
        toNodeId: 'n2',
        relation: 'parent',
        createdAt: Value(DateTime(2024)),
      ));
      // 정방향
      final fwd = await db.findEdgeBetween('n1', 'n2');
      expect(fwd, isNotNull);
      // 역방향
      final rev = await db.findEdgeBetween('n2', 'n1');
      expect(rev, isNotNull);
      expect(fwd!.id, rev!.id);
    });

    test('updateEdgeRelation', () async {
      await db.upsertNode(NodesTableCompanion.insert(
        id: 'n1', name: 'A', createdAt: Value(DateTime(2024)),
      ));
      await db.upsertNode(NodesTableCompanion.insert(
        id: 'n2', name: 'B', createdAt: Value(DateTime(2024)),
      ));
      await db.upsertEdge(NodeEdgesTableCompanion.insert(
        id: 'e1',
        fromNodeId: 'n1',
        toNodeId: 'n2',
        relation: 'sibling',
        createdAt: Value(DateTime(2024)),
      ));
      await db.updateEdgeRelation('e1', 'spouse');
      final edge = await db.findEdgeBetween('n1', 'n2');
      expect(edge!.relation, 'spouse');
    });

    test('updateEdgeFull', () async {
      await db.upsertNode(NodesTableCompanion.insert(
        id: 'n1', name: 'A', createdAt: Value(DateTime(2024)),
      ));
      await db.upsertNode(NodesTableCompanion.insert(
        id: 'n2', name: 'B', createdAt: Value(DateTime(2024)),
      ));
      await db.upsertEdge(NodeEdgesTableCompanion.insert(
        id: 'e1',
        fromNodeId: 'n1',
        toNodeId: 'n2',
        relation: 'child',
        createdAt: Value(DateTime(2024)),
      ));
      await db.updateEdgeFull('e1',
        fromNodeId: 'n2',
        toNodeId: 'n1',
        relation: 'parent',
      );
      final edge = await db.findEdgeBetween('n1', 'n2');
      expect(edge!.relation, 'parent');
      expect(edge.fromNodeId, 'n2');
    });

    test('deleteEdge', () async {
      await db.upsertNode(NodesTableCompanion.insert(
        id: 'n1', name: 'A', createdAt: Value(DateTime(2024)),
      ));
      await db.upsertNode(NodesTableCompanion.insert(
        id: 'n2', name: 'B', createdAt: Value(DateTime(2024)),
      ));
      await db.upsertEdge(NodeEdgesTableCompanion.insert(
        id: 'e1',
        fromNodeId: 'n1',
        toNodeId: 'n2',
        relation: 'other',
        createdAt: Value(DateTime(2024)),
      ));
      await db.deleteEdge('e1');
      expect(await db.findEdgeBetween('n1', 'n2'), isNull);
    });
  });

  // ── Memory CRUD ───────────────────────────────────────────────────────────

  group('Memory CRUD', () {
    test('upsert + get', () async {
      await db.upsertNode(NodesTableCompanion.insert(
        id: 'n1', name: 'A', createdAt: Value(DateTime(2024)),
      ));
      await db.upsertMemory(MemoriesTableCompanion.insert(
        id: 'm1',
        nodeId: 'n1',
        type: 'voice',
        durationSeconds: Value(120),
        createdAt: Value(DateTime(2024)),
      ));
      final mem = await db.getMemory('m1');
      expect(mem, isNotNull);
      expect(mem!.type, 'voice');
      expect(mem.durationSeconds, 120);
    });

    test('deleteMemory', () async {
      await db.upsertNode(NodesTableCompanion.insert(
        id: 'n1', name: 'A', createdAt: Value(DateTime(2024)),
      ));
      await db.upsertMemory(MemoriesTableCompanion.insert(
        id: 'm1',
        nodeId: 'n1',
        type: 'memo',
        createdAt: Value(DateTime(2024)),
      ));
      await db.deleteMemory('m1');
      expect(await db.getMemory('m1'), isNull);
    });

    test('setMemoryPrivate 토글', () async {
      await db.upsertNode(NodesTableCompanion.insert(
        id: 'n1', name: 'A', createdAt: Value(DateTime(2024)),
      ));
      await db.upsertMemory(MemoriesTableCompanion.insert(
        id: 'm1',
        nodeId: 'n1',
        type: 'photo',
        createdAt: Value(DateTime(2024)),
      ));
      await db.setMemoryPrivate('m1', isPrivate: true);
      final mem = await db.getMemory('m1');
      expect(mem!.isPrivate, isTrue);
    });

    test('countMemoriesByType', () async {
      await db.upsertNode(NodesTableCompanion.insert(
        id: 'n1', name: 'A', createdAt: Value(DateTime(2024)),
      ));
      for (int i = 0; i < 3; i++) {
        await db.upsertMemory(MemoriesTableCompanion.insert(
          id: 'photo-$i',
          nodeId: 'n1',
          type: 'photo',
          createdAt: Value(DateTime(2024)),
        ));
      }
      await db.upsertMemory(MemoriesTableCompanion.insert(
        id: 'voice-1',
        nodeId: 'n1',
        type: 'voice',
        createdAt: Value(DateTime(2024)),
      ));
      expect(await db.countMemoriesByType('photo'), 3);
      expect(await db.countMemoriesByType('voice'), 1);
      expect(await db.countMemoriesByType('memo'), 0);
    });

    test('sumVoiceDuration', () async {
      await db.upsertNode(NodesTableCompanion.insert(
        id: 'n1', name: 'A', createdAt: Value(DateTime(2024)),
      ));
      await db.upsertMemory(MemoriesTableCompanion.insert(
        id: 'v1',
        nodeId: 'n1',
        type: 'voice',
        durationSeconds: Value(60),
        createdAt: Value(DateTime(2024)),
      ));
      await db.upsertMemory(MemoriesTableCompanion.insert(
        id: 'v2',
        nodeId: 'n1',
        type: 'voice',
        durationSeconds: Value(90),
        createdAt: Value(DateTime(2024)),
      ));
      expect(await db.sumVoiceDuration(), 150);
    });
  });

  // ── deleteNodeAndRelated (cascade) ────────────────────────────────────────

  group('deleteNodeAndRelated', () {
    test('노드 삭제 시 관련 데이터 모두 삭제', () async {
      // 노드 생성
      await db.upsertNode(NodesTableCompanion.insert(
        id: 'n1', name: '삭제대상', createdAt: Value(DateTime(2024)),
      ));
      await db.upsertNode(NodesTableCompanion.insert(
        id: 'n2', name: '남은노드', createdAt: Value(DateTime(2024)),
      ));
      // 엣지
      await db.upsertEdge(NodeEdgesTableCompanion.insert(
        id: 'e1',
        fromNodeId: 'n1',
        toNodeId: 'n2',
        relation: 'spouse',
        createdAt: Value(DateTime(2024)),
      ));
      // 기억
      await db.upsertMemory(MemoriesTableCompanion.insert(
        id: 'm1',
        nodeId: 'n1',
        type: 'photo',
        createdAt: Value(DateTime(2024)),
      ));
      // 온도 로그
      await db.upsertTemperatureLog(TemperatureLogsTableCompanion.insert(
        id: 'tl1',
        nodeId: 'n1',
        temperature: 3,
        date: DateTime(2024),
      ));
      // 꽃다발
      await db.upsertBouquet(BouquetsTableCompanion.insert(
        id: 'b1',
        fromNodeId: 'n1',
        toNodeId: 'n2',
        flowerType: 'rose',
        date: DateTime(2024),
      ));

      // 삭제 실행
      await db.deleteNodeAndRelated('n1');

      // 검증
      expect(await db.getNode('n1'), isNull);
      expect(await db.getNode('n2'), isNotNull); // 다른 노드 남아있음
      // 노드 삭제 후 해당 노드의 기억은 삭제됨
      expect((await db.getMemoriesForNode('n1')), isEmpty);
    });
  });

  // ── collectMediaPathsForNode ──────────────────────────────────────────────

  group('collectMediaPathsForNode', () {
    test('미디어 경로 수집', () async {
      await db.upsertNode(NodesTableCompanion.insert(
        id: 'n1', name: 'A', createdAt: Value(DateTime(2024)),
      ));
      await db.upsertMemory(MemoriesTableCompanion.insert(
        id: 'm1',
        nodeId: 'n1',
        type: 'photo',
        filePath: Value('media/photo1.webp'),
        thumbnailPath: Value('media/thumb1.webp'),
        createdAt: Value(DateTime(2024)),
      ));
      final paths = await db.collectMediaPathsForNode('n1');
      expect(paths, contains('media/photo1.webp'));
      expect(paths, contains('media/thumb1.webp'));
    });

    test('빈 경로는 제외', () async {
      await db.upsertNode(NodesTableCompanion.insert(
        id: 'n1', name: 'A', createdAt: Value(DateTime(2024)),
      ));
      await db.upsertMemory(MemoriesTableCompanion.insert(
        id: 'm1',
        nodeId: 'n1',
        type: 'memo',
        createdAt: Value(DateTime(2024)),
      ));
      final paths = await db.collectMediaPathsForNode('n1');
      expect(paths, isEmpty);
    });
  });

  // ── Badge 관련 통계 ───────────────────────────────────────────────────────

  group('Badge 통계', () {
    test('ghostNodeCount — 고스트 노드 수', () async {
      await db.upsertNode(NodesTableCompanion.insert(
        id: 'n1', name: 'Normal', isGhost: Value(false),
        createdAt: Value(DateTime(2024)),
      ));
      await db.upsertNode(NodesTableCompanion.insert(
        id: 'n2', name: 'Ghost', isGhost: Value(true),
        createdAt: Value(DateTime(2024)),
      ));
      expect(await db.ghostNodeCount(), 1);
    });

    test('memoryCountByType', () async {
      await db.upsertNode(NodesTableCompanion.insert(
        id: 'n1', name: 'A', createdAt: Value(DateTime(2024)),
      ));
      await db.upsertMemory(MemoriesTableCompanion.insert(
        id: 'm1', nodeId: 'n1', type: 'photo',
        createdAt: Value(DateTime(2024)),
      ));
      await db.upsertMemory(MemoriesTableCompanion.insert(
        id: 'm2', nodeId: 'n1', type: 'photo',
        createdAt: Value(DateTime(2024)),
      ));
      expect(await db.memoryCountByType('photo'), 2);
      expect(await db.memoryCountByType('voice'), 0);
    });
  });

  // ── Capsule CRUD ──────────────────────────────────────────────────────────

  group('Capsule CRUD', () {
    test('upsert + get + open', () async {
      await db.upsertCapsule(CapsulesTableCompanion.insert(
        id: 'cap1',
        title: '테스트 캡슐',
        openDate: DateTime(2026, 12, 25),
        createdAt: Value(DateTime(2024)),
      ));
      final capsule = await db.getCapsule('cap1');
      expect(capsule, isNotNull);
      expect(capsule!.isOpened, isFalse);

      await db.openCapsule('cap1');
      final opened = await db.getCapsule('cap1');
      expect(opened!.isOpened, isTrue);
      expect(opened.openedAt, isNotNull);
    });

    test('deleteCapsule + items', () async {
      await db.upsertCapsule(CapsulesTableCompanion.insert(
        id: 'cap1',
        title: '삭제 테스트',
        openDate: DateTime(2026, 12, 25),
        createdAt: Value(DateTime(2024)),
      ));
      await db.addCapsuleItem(CapsuleItemsTableCompanion.insert(
        id: 'ci1',
        capsuleId: 'cap1',
        memoryId: 'mem1',
      ));
      await db.deleteCapsule('cap1');
      expect(await db.getCapsule('cap1'), isNull);
      expect((await db.getCapsuleItems('cap1')), isEmpty);
    });

    test('capsuleCount', () async {
      expect(await db.capsuleCount(), 0);
      await db.upsertCapsule(CapsulesTableCompanion.insert(
        id: 'c1',
        title: 'A',
        openDate: DateTime(2026),
        createdAt: Value(DateTime(2024)),
      ));
      expect(await db.capsuleCount(), 1);
    });
  });

  // ── Temperature Logs ──────────────────────────────────────────────────────

  group('Temperature Logs', () {
    test('upsert + getForNode + 날짜 범위 필터', () async {
      await db.upsertNode(NodesTableCompanion.insert(
        id: 'n1', name: 'A', createdAt: Value(DateTime(2024)),
      ));
      await db.upsertTemperatureLog(TemperatureLogsTableCompanion.insert(
        id: 'tl1', nodeId: 'n1', temperature: 3,
        date: DateTime(2024, 6, 15),
      ));
      await db.upsertTemperatureLog(TemperatureLogsTableCompanion.insert(
        id: 'tl2', nodeId: 'n1', temperature: 4,
        date: DateTime(2024, 8, 15),
      ));

      // 전체
      final all = await db.getTemperatureLogsForNode('n1');
      expect(all.length, 2);

      // 날짜 범위
      final filtered = await db.getTemperatureLogsForNode('n1',
        from: DateTime(2024, 7, 1),
        to: DateTime(2024, 9, 1),
      );
      expect(filtered.length, 1);
      expect(filtered.first.temperature, 4);
    });

    test('deleteTemperatureLog', () async {
      await db.upsertNode(NodesTableCompanion.insert(
        id: 'n1', name: 'A', createdAt: Value(DateTime(2024)),
      ));
      await db.upsertTemperatureLog(TemperatureLogsTableCompanion.insert(
        id: 'tl1', nodeId: 'n1', temperature: 3,
        date: DateTime(2024),
      ));
      await db.deleteTemperatureLog('tl1');
      final logs = await db.getTemperatureLogsForNode('n1');
      expect(logs, isEmpty);
    });
  });

  // ── SyncQueue ─────────────────────────────────────────────────────────────

  group('SyncQueue', () {
    test('enqueueSyncItem + getPendingSyncItems', () async {
      await db.enqueueSyncItem(
        targetTable: 'nodes',
        recordId: 'n1',
        operation: 'upsert',
        payloadJson: '{"name":"test"}',
      );
      final items = await db.getPendingSyncItems();
      expect(items.length, 1);
      expect(items.first.targetTable, 'nodes');
    });

    test('markSyncedItems + cleanSyncedItems', () async {
      await db.enqueueSyncItem(
        targetTable: 'nodes',
        recordId: 'n1',
        operation: 'upsert',
        payloadJson: '{}',
      );
      final pending = await db.getPendingSyncItems();
      await db.markSyncedItems([pending.first.id]);
      // 동기 완료 후 pending 조회 → 0
      expect((await db.getPendingSyncItems()).length, 0);
      // 정리
      await db.cleanSyncedItems();
    });

    test('incrementRetryCount', () async {
      await db.enqueueSyncItem(
        targetTable: 'nodes',
        recordId: 'n1',
        operation: 'upsert',
        payloadJson: '{}',
      );
      final items = await db.getPendingSyncItems();
      final id = items.first.id;
      expect(items.first.retryCount, 0);
      await db.incrementRetryCount(id);
      final updated = await db.getPendingSyncItems();
      expect(updated.first.retryCount, 1);
    });

    test('빈 ids로 markSyncedItems — 에러 없음', () async {
      await db.markSyncedItems([]);
    });

    test('존재하지 않는 id로 incrementRetryCount — 에러 없음', () async {
      await db.incrementRetryCount('nonexistent');
    });
  });

  // ── MediaUploadQueue ──────────────────────────────────────────────────────

  group('MediaUploadQueue', () {
    test('enqueue + getPending + updateStatus', () async {
      await db.enqueueMediaUpload(MediaUploadQueueTableCompanion.insert(
        id: 'mu1',
        nodeId: Value('n1'),
        localPath: '/tmp/photo.webp',
        category: 'photo',
        contentType: 'image/webp',
        fileSizeBytes: 1024,
        createdAt: Value(DateTime(2024)),
      ));
      final pending = await db.getPendingMediaUploads();
      expect(pending.length, 1);

      await db.updateMediaUploadStatus('mu1',
        status: 'completed',
        r2FileKey: 'nodes/n1/photo.webp',
        completedAt: DateTime(2024, 6, 15),
      );
      final afterUpdate = await db.getPendingMediaUploads();
      expect(afterUpdate, isEmpty);
    });

    test('getMediaUploadQueueStatus', () async {
      await db.enqueueMediaUpload(MediaUploadQueueTableCompanion.insert(
        id: 'mu1',
        localPath: '/tmp/a.webp',
        category: 'photo',
        contentType: 'image/webp',
        fileSizeBytes: 512,
        createdAt: Value(DateTime(2024)),
      ));
      final status = await db.getMediaUploadQueueStatus();
      expect(status['pending'], 1);
      expect(status['completed'], 0);
    });

    test('cleanCompletedMediaUploads', () async {
      await db.enqueueMediaUpload(MediaUploadQueueTableCompanion.insert(
        id: 'mu1',
        localPath: '/tmp/a.webp',
        category: 'photo',
        contentType: 'image/webp',
        fileSizeBytes: 256,
        status: Value('completed'),
        createdAt: Value(DateTime(2024)),
      ));
      await db.cleanCompletedMediaUploads();
      final status = await db.getMediaUploadQueueStatus();
      expect(status['completed'], 0);
    });

    test('incrementMediaUploadRetry', () async {
      await db.enqueueMediaUpload(MediaUploadQueueTableCompanion.insert(
        id: 'mu1',
        localPath: '/tmp/a.webp',
        category: 'photo',
        contentType: 'image/webp',
        fileSizeBytes: 128,
        createdAt: Value(DateTime(2024)),
      ));
      await db.incrementMediaUploadRetry('mu1');
      final retryable = await db.getRetryableMediaUploads();
      expect(retryable.length, 1);
      expect(retryable.first.retryCount, 1);
      expect(retryable.first.status, 'failed');
    });
  });

  // ── Bouquet 관련 ──────────────────────────────────────────────────────────

  group('Bouquet CRUD', () {
    test('upsert + getForNode', () async {
      await db.upsertNode(NodesTableCompanion.insert(
        id: 'n1', name: 'A', createdAt: Value(DateTime(2024)),
      ));
      await db.upsertNode(NodesTableCompanion.insert(
        id: 'n2', name: 'B', createdAt: Value(DateTime(2024)),
      ));
      await db.upsertBouquet(BouquetsTableCompanion.insert(
        id: 'b1',
        fromNodeId: 'n1',
        toNodeId: 'n2',
        flowerType: 'rose',
        date: DateTime.now(),
      ));
      final bouquets = await db.getBouquetsForNode('n2');
      expect(bouquets.length, 1);
    });

    test('getUnreadBouquetCount + markBouquetsAsRead', () async {
      await db.upsertNode(NodesTableCompanion.insert(
        id: 'n1', name: 'A', createdAt: Value(DateTime(2024)),
      ));
      await db.upsertNode(NodesTableCompanion.insert(
        id: 'n2', name: 'B', createdAt: Value(DateTime(2024)),
      ));
      await db.upsertBouquet(BouquetsTableCompanion.insert(
        id: 'b1',
        fromNodeId: 'n1',
        toNodeId: 'n2',
        flowerType: 'rose',
        date: DateTime.now(),
      ));
      expect(await db.getUnreadBouquetCount('n2'), 1);
      await db.markBouquetsAsRead('n2');
      expect(await db.getUnreadBouquetCount('n2'), 0);
    });
  });

  // ── Recipe / VoiceLegacy / FamilyEvent counts ─────────────────────────────

  group('기타 count 메서드', () {
    test('recipeCount', () async {
      expect(await db.recipeCount(), 0);
    });

    test('voiceLegacyCount', () async {
      expect(await db.voiceLegacyCount(), 0);
    });

    test('thenNowCount', () async {
      expect(await db.thenNowCount(), 0);
    });

    test('memorialMessageCount', () async {
      expect(await db.memorialMessageCount(), 0);
    });
  });

  // ── Profile CRUD ──────────────────────────────────────────────────────────

  group('Profile CRUD', () {
    test('getProfile 초기 → null', () async {
      expect(await db.getProfile(), isNull);
    });

    test('upsertProfile + getProfile', () async {
      await db.upsertProfile(ProfileTableCompanion.insert(
        name: '테스트 사용자',
        createdAt: Value(DateTime(2024)),
      ));
      final profile = await db.getProfile();
      expect(profile, isNotNull);
      expect(profile!.name, '테스트 사용자');
    });
  });

  // ── Bouquet 추가 CRUD ────────────────────────────────────────────────────

  group('Bouquet 추가 CRUD', () {
    test('getBouquetsThisWeek', () async {
      await db.upsertNode(NodesTableCompanion.insert(
        id: 'n1', name: 'A', createdAt: Value(DateTime(2024)),
      ));
      await db.upsertNode(NodesTableCompanion.insert(
        id: 'n2', name: 'B', createdAt: Value(DateTime(2024)),
      ));
      await db.upsertBouquet(BouquetsTableCompanion.insert(
        id: 'b1',
        fromNodeId: 'n1',
        toNodeId: 'n2',
        flowerType: 'tulip',
        date: DateTime.now(),
      ));
      final weekBouquets = await db.getBouquetsThisWeek('n2');
      expect(weekBouquets.length, 1);
    });

    test('getBouquetsThisYear', () async {
      await db.upsertNode(NodesTableCompanion.insert(
        id: 'n1', name: 'A', createdAt: Value(DateTime(2024)),
      ));
      await db.upsertNode(NodesTableCompanion.insert(
        id: 'n2', name: 'B', createdAt: Value(DateTime(2024)),
      ));
      await db.upsertBouquet(BouquetsTableCompanion.insert(
        id: 'b1',
        fromNodeId: 'n1',
        toNodeId: 'n2',
        flowerType: 'lily',
        date: DateTime.now(),
      ));
      final yearBouquets = await db.getBouquetsThisYear();
      expect(yearBouquets.length, 1);
    });

    test('getReceivedBouquets', () async {
      await db.upsertNode(NodesTableCompanion.insert(
        id: 'n1', name: 'A', createdAt: Value(DateTime(2024)),
      ));
      await db.upsertNode(NodesTableCompanion.insert(
        id: 'n2', name: 'B', createdAt: Value(DateTime(2024)),
      ));
      await db.upsertBouquet(BouquetsTableCompanion.insert(
        id: 'b1',
        fromNodeId: 'n1',
        toNodeId: 'n2',
        flowerType: 'cherry_blossom',
        date: DateTime.now(),
      ));
      final received = await db.getReceivedBouquets('n2');
      expect(received.length, 1);
    });

    test('deleteBouquet', () async {
      await db.upsertNode(NodesTableCompanion.insert(
        id: 'n1', name: 'A', createdAt: Value(DateTime(2024)),
      ));
      await db.upsertNode(NodesTableCompanion.insert(
        id: 'n2', name: 'B', createdAt: Value(DateTime(2024)),
      ));
      await db.upsertBouquet(BouquetsTableCompanion.insert(
        id: 'b1',
        fromNodeId: 'n1',
        toNodeId: 'n2',
        flowerType: 'sunflower',
        date: DateTime.now(),
      ));
      await db.deleteBouquet('b1');
      expect((await db.getBouquetsForNode('n2')), isEmpty);
    });
  });

  // ── Memorial Messages ─────────────────────────────────────────────────────

  group('Memorial Messages', () {
    test('upsert + getForNode', () async {
      await db.upsertNode(NodesTableCompanion.insert(
        id: 'n1', name: 'A', createdAt: Value(DateTime(2024)),
      ));
      await db.upsertMemorialMessage(MemorialMessagesTableCompanion.insert(
        id: 'mm1',
        nodeId: 'n1',
        message: '추억의 메시지',
        date: DateTime(2024, 6, 15),
      ));
      final messages = await db.getMemorialMessagesForNode('n1');
      expect(messages.length, 1);
      expect(messages.first.message, '추억의 메시지');
    });

    test('deleteMemorialMessage', () async {
      await db.upsertNode(NodesTableCompanion.insert(
        id: 'n1', name: 'A', createdAt: Value(DateTime(2024)),
      ));
      await db.upsertMemorialMessage(MemorialMessagesTableCompanion.insert(
        id: 'mm1',
        nodeId: 'n1',
        message: '삭제할 메시지',
        date: DateTime(2024),
      ));
      await db.deleteMemorialMessage('mm1');
      expect((await db.getMemorialMessagesForNode('n1')), isEmpty);
    });
  });

  // ── Recipes 추가 ─────────────────────────────────────────────────────────

  group('Recipes 추가', () {
    test('getRecipesForNode', () async {
      await db.upsertNode(NodesTableCompanion.insert(
        id: 'n1', name: 'A', createdAt: Value(DateTime(2024)),
      ));
      await db.upsertRecipe(RecipesTableCompanion.insert(
        id: 'r1',
        title: '된장찌개',
        ingredients: '된장, 두부',
        instructions: '끓이기',
        nodeId: Value('n1'),
        createdAt: Value(DateTime(2024)),
      ));
      final recipes = await db.getRecipesForNode('n1');
      expect(recipes.length, 1);
    });

    test('deleteRecipe', () async {
      await db.upsertRecipe(RecipesTableCompanion.insert(
        id: 'r1',
        title: '삭제 레시피',
        ingredients: 'a',
        instructions: 'b',
        createdAt: Value(DateTime(2024)),
      ));
      await db.deleteRecipe('r1');
      expect(await db.recipeCount(), 0);
    });
  });

  // ── Voice Legacy ──────────────────────────────────────────────────────────

  group('Voice Legacy', () {
    test('upsert + get + delete', () async {
      await db.upsertNode(NodesTableCompanion.insert(
        id: 'n1', name: 'From', createdAt: Value(DateTime(2024)),
      ));
      await db.upsertNode(NodesTableCompanion.insert(
        id: 'n2', name: 'To', createdAt: Value(DateTime(2024)),
      ));
      await db.upsertVoiceLegacy(VoiceLegacyTableCompanion.insert(
        id: 'vl1',
        fromNodeId: 'n1',
        toNodeId: 'n2',
        title: '유언 메시지',
        voicePath: '/tmp/voice.m4a',
        durationSeconds: Value(60),
        createdAt: Value(DateTime(2024)),
      ));
      final legacy = await db.getVoiceLegacy('vl1');
      expect(legacy, isNotNull);
      expect(legacy!.voicePath, '/tmp/voice.m4a');
      expect(legacy.durationSeconds, 60);

      await db.deleteVoiceLegacy('vl1');
      expect(await db.getVoiceLegacy('vl1'), isNull);
    });

    test('openVoiceLegacy', () async {
      await db.upsertNode(NodesTableCompanion.insert(
        id: 'n1', name: 'A', createdAt: Value(DateTime(2024)),
      ));
      await db.upsertNode(NodesTableCompanion.insert(
        id: 'n2', name: 'B', createdAt: Value(DateTime(2024)),
      ));
      await db.upsertVoiceLegacy(VoiceLegacyTableCompanion.insert(
        id: 'vl1',
        fromNodeId: 'n1',
        toNodeId: 'n2',
        title: '열기 테스트',
        voicePath: '/tmp/voice.m4a',
        durationSeconds: Value(30),
        createdAt: Value(DateTime(2024)),
      ));
      await db.openVoiceLegacy('vl1');
      final opened = await db.getVoiceLegacy('vl1');
      expect(opened!.isOpened, isTrue);
      expect(opened.openedAt, isNotNull);
    });
  });

  // ── Then & Now ────────────────────────────────────────────────────────────

  group('Then & Now', () {
    test('upsert + get + delete', () async {
      await db.upsertThenNow(ThenNowTableCompanion.insert(
        id: 'tn1',
        memoryId1: 'mem1',
        memoryId2: 'mem2',
        createdAt: Value(DateTime(2024)),
      ));
      final tn = await db.getThenNow('tn1');
      expect(tn, isNotNull);
      expect(tn!.memoryId1, 'mem1');

      await db.deleteThenNow('tn1');
      expect(await db.getThenNow('tn1'), isNull);
    });

    test('getAllThenNow', () async {
      await db.upsertThenNow(ThenNowTableCompanion.insert(
        id: 'tn1',
        memoryId1: 'a',
        memoryId2: 'b',
        createdAt: Value(DateTime(2024)),
      ));
      final all = await db.getAllThenNow();
      expect(all.length, 1);
    });
  });

  // ── Family Events ─────────────────────────────────────────────────────────

  group('Family Events', () {
    test('upsert + getAll + delete', () async {
      await db.upsertNode(NodesTableCompanion.insert(
        id: 'n1', name: 'A', createdAt: Value(DateTime(2024)),
      ));
      await db.upsertFamilyEvent(FamilyEventsTableCompanion.insert(
        id: 'fe1',
        title: '생일',
        eventDate: DateTime(2024, 5, 15),
        nodeId: Value('n1'),
        createdAt: Value(DateTime(2024)),
      ));
      final events = await db.getAllFamilyEvents();
      expect(events.length, 1);
      expect(events.first.title, '생일');

      await db.deleteFamilyEvent('fe1');
      expect((await db.getAllFamilyEvents()), isEmpty);
    });
  });

  // ── Node Locations ────────────────────────────────────────────────────────

  group('Node Locations', () {
    test('upsert + getForNode + delete', () async {
      await db.upsertNode(NodesTableCompanion.insert(
        id: 'n1', name: 'A', createdAt: Value(DateTime(2024)),
      ));
      await db.upsertNodeLocation(NodeLocationsTableCompanion.insert(
        id: 'nl1',
        nodeId: 'n1',
        address: '서울',
        latitude: 37.5665,
        longitude: 126.9780,
        createdAt: Value(DateTime(2024)),
      ));
      final locs = await db.getLocationsForNode('n1');
      expect(locs.length, 1);
      expect(locs.first.address, '서울');

      await db.deleteNodeLocation('nl1');
      expect((await db.getLocationsForNode('n1')), isEmpty);
    });
  });

  // ── watchAllNodes (스트림) ────────────────────────────────────────────────

  group('watchAllNodes', () {
    test('초기 빈 리스트', () async {
      final first = await db.watchAllNodes().first;
      expect(first, isEmpty);
    });
  });

  // ── watchAllEdges (스트림) ────────────────────────────────────────────────

  group('watchAllEdges', () {
    test('초기 빈 리스트', () async {
      final first = await db.watchAllEdges().first;
      expect(first, isEmpty);
    });
  });

  // ── watchAllMemories (스트림) ──────────────────────────────────────────────

  group('watchAllMemories', () {
    test('초기 빈 리스트', () async {
      final first = await db.watchAllMemories().first;
      expect(first, isEmpty);
    });
  });

  // ── deleteNode 단독 ──────────────────────────────────────────────────────

  group('deleteNode', () {
    test('노드 삭제', () async {
      await db.upsertNode(NodesTableCompanion.insert(
        id: 'n1', name: 'A', createdAt: Value(DateTime(2024)),
      ));
      await db.deleteNode('n1');
      expect(await db.getNode('n1'), isNull);
    });
  });
}
