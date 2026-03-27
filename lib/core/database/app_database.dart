import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'tables/profile_table.dart';
import 'tables/nodes_table.dart';
import 'tables/node_edges_table.dart';
import 'tables/memories_table.dart';
import 'tables/settings_table.dart';
import 'tables/temperature_logs_table.dart';
import 'tables/bouquets_table.dart';
import 'tables/capsules_table.dart';
import 'tables/memorial_messages_table.dart';
import 'tables/recipes_table.dart';
import 'tables/node_locations_table.dart';
import 'tables/voice_legacy_table.dart';
import 'tables/then_now_table.dart';
import 'tables/family_events_table.dart';
import 'tables/sync_queue_table.dart';
import 'tables/media_upload_queue_table.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  ProfileTable,
  NodesTable,
  NodeEdgesTable,
  MemoriesTable,
  SettingsTable,
  TemperatureLogsTable,
  BouquetsTable,
  CapsulesTable,
  CapsuleItemsTable,
  MemorialMessagesTable,
  RecipesTable,
  NodeLocationsTable,
  VoiceLegacyTable,
  ThenNowTable,
  FamilyEventsTable,
  SyncQueueTable,
  MediaUploadQueueTable,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// LIKE 쿼리용 특수문자 제거 (Drift는 escape 파라미터 미지원)
  String _escapeLike(String query) =>
      query.replaceAll('%', '').replaceAll('_', '').replaceAll("'", '');

  /// 테스트용 in-memory DB
  AppDatabase.forTesting(super.executor);

  /// 병합 미리보기용 외부 파일 DB (읽기 전용)
  AppDatabase.forMerge(String path)
      : super(NativeDatabase(File(path)));

  @override
  int get schemaVersion => 10;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await _insertDefaultSettings();
        },
        onUpgrade: (m, from, to) async {
          // v1 → v2: memories.isPrivate 컬럼 추가 (Privacy Layer)
          if (from < 2) {
            await m.addColumn(memoriesTable, memoriesTable.isPrivate);
          }
          // v2 → v3: temperature_logs + bouquets 테이블 생성
          if (from < 3) {
            await m.createTable(temperatureLogsTable);
            await m.createTable(bouquetsTable);
          }
          // v3 → v4: capsules + capsule_items + memorial_messages + glossary
          if (from < 4) {
            await m.createTable(capsulesTable);
            await m.createTable(capsuleItemsTable);
            await m.createTable(memorialMessagesTable);
            // glossary table removed from app but kept in migration for existing DBs
            await customStatement('''
              CREATE TABLE IF NOT EXISTS glossary (
                id TEXT NOT NULL PRIMARY KEY,
                word TEXT NOT NULL,
                meaning TEXT NOT NULL,
                example TEXT,
                voice_path TEXT,
                node_id TEXT,
                created_at INTEGER NOT NULL DEFAULT (strftime('%s','now'))
              )
            ''');
          }
          // v4 → v5: recipes + node_locations + voice_legacy
          if (from < 5) {
            await m.createTable(recipesTable);
            await m.createTable(nodeLocationsTable);
            await m.createTable(voiceLegacyTable);
          }
          // v5 → v6: then_now (Then & Now 비교 페어)
          if (from < 6) {
            await m.createTable(thenNowTable);
          }
          // v6 → v7: family_events (가족 일정)
          if (from < 7) {
            await m.createTable(familyEventsTable);
          }
          // v7 → v8: sync_queue (클라우드 동기화 대기열)
          if (from < 8) {
            await m.createTable(syncQueueTable);
          }
          // v8 → v9: bouquets.is_read 컬럼 추가 (받은 마음 읽음 처리)
          if (from < 9) {
            await m.addColumn(bouquetsTable, bouquetsTable.isRead);
          }
          // v9 → v10: R2 미디어 키 컬럼 + 업로드 큐 테이블
          if (from < 10) {
            await m.addColumn(memoriesTable, memoriesTable.r2FileKey);
            await m.addColumn(memoriesTable, memoriesTable.r2ThumbnailKey);
            await m.addColumn(nodesTable, nodesTable.r2PhotoKey);
            await m.createTable(mediaUploadQueueTable);
          }
        },
      );

  Future<void> _insertDefaultSettings() async {
    final defaults = {
      SettingsKey.userPlan: 'free',
      SettingsKey.autoBackup: 'true',
      SettingsKey.backupFrequency: 'daily',
      SettingsKey.onboardingDone: 'false',
      SettingsKey.cloudProvider: Platform.isIOS ? 'icloud' : 'google',
      SettingsKey.canvasScale: '1.0',
      SettingsKey.canvasOffsetX: '0.0',
      SettingsKey.canvasOffsetY: '0.0',
    };
    for (final entry in defaults.entries) {
      await into(settingsTable).insertOnConflictUpdate(
        SettingsTableCompanion.insert(key: entry.key, value: entry.value),
      );
    }
  }

  // ── Profile ────────────────────────────────────────────────────────────────

  Future<ProfileTableData?> getProfile() =>
      (select(profileTable)..limit(1)).getSingleOrNull();

  Future<int> upsertProfile(ProfileTableCompanion profile) =>
      into(profileTable).insertOnConflictUpdate(profile);

  // ── Nodes ──────────────────────────────────────────────────────────────────

  Stream<List<NodesTableData>> watchAllNodes() =>
      (select(nodesTable)..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
          .watch();

  Future<List<NodesTableData>> getAllNodes() => select(nodesTable).get();

  Future<NodesTableData?> getNode(String id) =>
      (select(nodesTable)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<void> upsertNode(NodesTableCompanion node) =>
      into(nodesTable).insertOnConflictUpdate(node);

  Future<int> deleteNode(String id) =>
      (delete(nodesTable)..where((t) => t.id.equals(id))).go();

  /// 노드 삭제 전, 관련 미디어 파일 경로를 모두 수집합니다.
  /// (DB 레코드 삭제 전에 호출해야 합니다)
  Future<List<String>> collectMediaPathsForNode(String nodeId) async {
    final paths = <String?>[];

    // memories 미디어 (사진/음성/영상)
    final memories = await getMemoriesForNode(nodeId);
    for (final m in memories) {
      paths.add(m.filePath);
      paths.add(m.thumbnailPath);
    }

    // voice_legacy 음성 파일
    final legacies = await (select(voiceLegacyTable)
          ..where(
              (t) => t.fromNodeId.equals(nodeId) | t.toNodeId.equals(nodeId)))
        .get();
    for (final v in legacies) {
      paths.add(v.voicePath);
    }

    // recipes 사진
    final recipes = await (select(recipesTable)
          ..where((t) => t.nodeId.equals(nodeId)))
        .get();
    for (final r in recipes) {
      paths.add(r.photoPath);
    }

    return paths
        .where((p) => p != null && p.isNotEmpty)
        .cast<String>()
        .toList();
  }

  /// 노드와 관련된 모든 테이블의 데이터를 원자적으로 삭제합니다.
  /// CASCADE FK가 설정된 memories, node_edges 외에도
  /// nodeId를 텍스트로 참조하는 8개 테이블을 함께 정리합니다.
  Future<void> deleteNodeAndRelated(String id) => transaction(() async {
        // 1. temperature_logs (nodeId)
        await (delete(temperatureLogsTable)
              ..where((t) => t.nodeId.equals(id)))
            .go();

        // 2. bouquets (fromNodeId OR toNodeId)
        await (delete(bouquetsTable)
              ..where((t) =>
                  t.fromNodeId.equals(id) | t.toNodeId.equals(id)))
            .go();

        // 3. memorial_messages (nodeId)
        await (delete(memorialMessagesTable)
              ..where((t) => t.nodeId.equals(id)))
            .go();

        // 4. recipes (nodeId)
        await (delete(recipesTable)
              ..where((t) => t.nodeId.equals(id)))
            .go();

        // 5. node_locations (nodeId)
        await (delete(nodeLocationsTable)
              ..where((t) => t.nodeId.equals(id)))
            .go();

        // 6. voice_legacy (fromNodeId OR toNodeId)
        await (delete(voiceLegacyTable)
              ..where((t) =>
                  t.fromNodeId.equals(id) | t.toNodeId.equals(id)))
            .go();

        // 7. family_events (nodeId)
        await (delete(familyEventsTable)
              ..where((t) => t.nodeId.equals(id)))
            .go();

        // 8. media_upload_queue (nodeId)
        await (delete(mediaUploadQueueTable)
              ..where((t) => t.nodeId.equals(id)))
            .go();

        // 9. nodes (CASCADE handles memories + node_edges)
        await (delete(nodesTable)..where((t) => t.id.equals(id))).go();
      });

  Future<int> nodeCount() =>
      nodesTable.count().getSingle();

  // ── Edges ──────────────────────────────────────────────────────────────────

  Future<List<NodeEdgesTableData>> getEdgesForNode(String nodeId) =>
      (select(nodeEdgesTable)
            ..where((t) =>
                t.fromNodeId.equals(nodeId) | t.toNodeId.equals(nodeId)))
          .get();

  Stream<List<NodeEdgesTableData>> watchAllEdges() =>
      select(nodeEdgesTable).watch();

  Future<void> upsertEdge(NodeEdgesTableCompanion edge) =>
      into(nodeEdgesTable).insertOnConflictUpdate(edge);

  /// 두 노드 사이의 기존 엣지 조회 (방향 무관)
  Future<NodeEdgesTableData?> findEdgeBetween(
      String nodeIdA, String nodeIdB) =>
      (select(nodeEdgesTable)
            ..where((t) =>
                (t.fromNodeId.equals(nodeIdA) & t.toNodeId.equals(nodeIdB)) |
                (t.fromNodeId.equals(nodeIdB) & t.toNodeId.equals(nodeIdA))))
          .getSingleOrNull();

  /// 엣지의 관계 타입 업데이트
  Future<void> updateEdgeRelation(String edgeId, String relation) async {
    await (update(nodeEdgesTable)..where((t) => t.id.equals(edgeId)))
        .write(NodeEdgesTableCompanion(relation: Value(relation)));
  }

  /// 엣지의 관계 타입 + 방향(from/to) 전체 업데이트
  Future<void> updateEdgeFull(
    String edgeId, {
    required String fromNodeId,
    required String toNodeId,
    required String relation,
  }) async {
    await (update(nodeEdgesTable)..where((t) => t.id.equals(edgeId))).write(
      NodeEdgesTableCompanion(
        fromNodeId: Value(fromNodeId),
        toNodeId: Value(toNodeId),
        relation: Value(relation),
      ),
    );
  }

  Future<int> deleteEdge(String id) =>
      (delete(nodeEdgesTable)..where((t) => t.id.equals(id))).go();

  // ── Memories ───────────────────────────────────────────────────────────────

  /// 전체 기억 스트림 (Story Feed / Archive용)
  Stream<List<MemoriesTableData>> watchAllMemories() =>
      (select(memoriesTable)
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .watch();

  Stream<List<MemoriesTableData>> watchMemoriesForNode(String nodeId) =>
      (select(memoriesTable)
            ..where((t) => t.nodeId.equals(nodeId))
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .watch();

  Future<List<MemoriesTableData>> getMemoriesForNode(String nodeId) =>
      (select(memoriesTable)
            ..where((t) => t.nodeId.equals(nodeId))
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .get();

  Future<MemoriesTableData?> getMemory(String id) =>
      (select(memoriesTable)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<void> upsertMemory(MemoriesTableCompanion memory) =>
      into(memoriesTable).insertOnConflictUpdate(memory);

  Future<int> deleteMemory(String id) =>
      (delete(memoriesTable)..where((t) => t.id.equals(id))).go();

  /// Privacy Layer: isPrivate 토글
  Future<void> setMemoryPrivate(String id, {required bool isPrivate}) async {
    await (update(memoriesTable)..where((t) => t.id.equals(id)))
        .write(MemoriesTableCompanion(isPrivate: Value(isPrivate)));
  }

  /// 타입별 기억 수 (플랜 제한 체크용)
  Future<int> countMemoriesByType(String type) =>
      customSelect(
        'SELECT COUNT(*) AS c FROM memories WHERE type = ?',
        variables: [Variable(type)],
      ).map((row) => row.read<int>('c')).getSingle();

  /// 전체 음성 길이 합 (초, 플랜 제한용)
  Future<int> sumVoiceDuration() async {
    final rows = await (select(memoriesTable)
          ..where((t) => t.type.equals('voice')))
        .get();
    return rows.fold<int>(0, (sum, r) => sum + (r.durationSeconds ?? 0));
  }

  // ── Temperature Logs ──────────────────────────────────────────────────────

  Future<void> upsertTemperatureLog(TemperatureLogsTableCompanion log) =>
      into(temperatureLogsTable).insertOnConflictUpdate(log);

  Future<List<TemperatureLogsTableData>> getTemperatureLogsForNode(
    String nodeId, {
    DateTime? from,
    DateTime? to,
  }) {
    final query = select(temperatureLogsTable)
      ..where((t) => t.nodeId.equals(nodeId))
      ..orderBy([(t) => OrderingTerm.desc(t.date)]);
    if (from != null) {
      query.where((t) => t.date.isBiggerOrEqualValue(from));
    }
    if (to != null) {
      query.where((t) => t.date.isSmallerOrEqualValue(to));
    }
    return query.get();
  }

  Stream<List<TemperatureLogsTableData>> watchTemperatureLogsForNode(
      String nodeId) =>
      (select(temperatureLogsTable)
            ..where((t) => t.nodeId.equals(nodeId))
            ..orderBy([(t) => OrderingTerm.desc(t.date)]))
          .watch();

  Future<int> deleteTemperatureLog(String id) =>
      (delete(temperatureLogsTable)..where((t) => t.id.equals(id))).go();

  // ── Bouquets (Memory Bouquet) ─────────────────────────────────────────────

  Future<void> upsertBouquet(BouquetsTableCompanion bouquet) =>
      into(bouquetsTable).insertOnConflictUpdate(bouquet);

  Future<List<BouquetsTableData>> getBouquetsForNode(String toNodeId) =>
      (select(bouquetsTable)
            ..where((t) => t.toNodeId.equals(toNodeId))
            ..orderBy([(t) => OrderingTerm.desc(t.date)]))
          .get();

  /// 이번 주(7일) 동안 특정 노드에 보내진 꽃
  Future<List<BouquetsTableData>> getBouquetsThisWeek(String toNodeId) {
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    return (select(bouquetsTable)
          ..where((t) =>
              t.toNodeId.equals(toNodeId) &
              t.date.isBiggerOrEqualValue(weekAgo))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .get();
  }

  /// 올해 전체 꽃 (연간 리포트용)
  Future<List<BouquetsTableData>> getBouquetsThisYear() {
    final yearStart = DateTime(DateTime.now().year);
    return (select(bouquetsTable)
          ..where((t) => t.date.isBiggerOrEqualValue(yearStart))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .get();
  }

  Future<int> deleteBouquet(String id) =>
      (delete(bouquetsTable)..where((t) => t.id.equals(id))).go();

  /// 특정 노드가 받은 모든 꽃 (받은 마음 목록)
  Future<List<BouquetsTableData>> getReceivedBouquets(String toNodeId) =>
      (select(bouquetsTable)
            ..where((t) => t.toNodeId.equals(toNodeId))
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .get();

  /// 특정 노드가 받은 읽지 않은 꽃 수
  Future<int> getUnreadBouquetCount(String toNodeId) async {
    final rows = await (select(bouquetsTable)
          ..where(
              (t) => t.toNodeId.equals(toNodeId) & t.isRead.equals(false)))
        .get();
    return rows.length;
  }

  /// 특정 노드가 받은 모든 꽃을 읽음 처리
  Future<void> markBouquetsAsRead(String toNodeId) =>
      (update(bouquetsTable)..where((t) => t.toNodeId.equals(toNodeId)))
          .write(const BouquetsTableCompanion(isRead: Value(true)));

  // ── Capsules (Memory Capsule) ─────────────────────────────────────────────

  Future<void> upsertCapsule(CapsulesTableCompanion capsule) =>
      into(capsulesTable).insertOnConflictUpdate(capsule);

  Stream<List<CapsulesTableData>> watchAllCapsules() =>
      (select(capsulesTable)
            ..orderBy([(t) => OrderingTerm.asc(t.openDate)]))
          .watch();

  Future<CapsulesTableData?> getCapsule(String id) =>
      (select(capsulesTable)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<void> openCapsule(String id) async {
    await (update(capsulesTable)..where((t) => t.id.equals(id))).write(
      CapsulesTableCompanion(
        isOpened: const Value(true),
        openedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<int> deleteCapsule(String id) async {
    await (delete(capsuleItemsTable)
          ..where((t) => t.capsuleId.equals(id)))
        .go();
    return (delete(capsulesTable)..where((t) => t.id.equals(id))).go();
  }

  Future<void> addCapsuleItem(CapsuleItemsTableCompanion item) =>
      into(capsuleItemsTable).insertOnConflictUpdate(item);

  Future<List<CapsuleItemsTableData>> getCapsuleItems(String capsuleId) =>
      (select(capsuleItemsTable)
            ..where((t) => t.capsuleId.equals(capsuleId)))
          .get();

  Future<int> capsuleCount() => capsulesTable.count().getSingle();

  // ── Memorial Messages (The Last Page) ───────────────────────────────────

  Future<void> upsertMemorialMessage(MemorialMessagesTableCompanion msg) =>
      into(memorialMessagesTable).insertOnConflictUpdate(msg);

  Stream<List<MemorialMessagesTableData>> watchMemorialMessagesForNode(
      String nodeId) =>
      (select(memorialMessagesTable)
            ..where((t) => t.nodeId.equals(nodeId))
            ..orderBy([(t) => OrderingTerm.desc(t.date)]))
          .watch();

  Future<List<MemorialMessagesTableData>> getMemorialMessagesForNode(
      String nodeId) =>
      (select(memorialMessagesTable)
            ..where((t) => t.nodeId.equals(nodeId))
            ..orderBy([(t) => OrderingTerm.desc(t.date)]))
          .get();

  Future<int> deleteMemorialMessage(String id) =>
      (delete(memorialMessagesTable)..where((t) => t.id.equals(id))).go();

  // ── Recipes (Family Recipe Book) ──────────────────────────────────────────

  Future<void> upsertRecipe(RecipesTableCompanion recipe) =>
      into(recipesTable).insertOnConflictUpdate(recipe);

  Stream<List<RecipesTableData>> watchAllRecipes() =>
      (select(recipesTable)
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .watch();

  Future<List<RecipesTableData>> getRecipesForNode(String nodeId) =>
      (select(recipesTable)
            ..where((t) => t.nodeId.equals(nodeId))
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .get();

  Future<List<RecipesTableData>> searchRecipes(String query) =>
      (select(recipesTable)
            ..where((t) => t.title.like('%${_escapeLike(query)}%'))
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .get();

  Future<int> deleteRecipe(String id) =>
      (delete(recipesTable)..where((t) => t.id.equals(id))).go();

  Future<int> recipeCount() => recipesTable.count().getSingle();

  // ── Voice Legacy (보이스 유언) ────────────────────────────────────────────

  Future<void> upsertVoiceLegacy(VoiceLegacyTableCompanion entry) =>
      into(voiceLegacyTable).insertOnConflictUpdate(entry);

  Stream<List<VoiceLegacyTableData>> watchVoiceLegaciesForNode(
      String toNodeId) =>
      (select(voiceLegacyTable)
            ..where((t) => t.toNodeId.equals(toNodeId))
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .watch();

  Stream<List<VoiceLegacyTableData>> watchAllVoiceLegacies() =>
      (select(voiceLegacyTable)
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .watch();

  Future<VoiceLegacyTableData?> getVoiceLegacy(String id) =>
      (select(voiceLegacyTable)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  Future<void> openVoiceLegacy(String id) async {
    await (update(voiceLegacyTable)..where((t) => t.id.equals(id))).write(
      VoiceLegacyTableCompanion(
        isOpened: const Value(true),
        openedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<int> deleteVoiceLegacy(String id) =>
      (delete(voiceLegacyTable)..where((t) => t.id.equals(id))).go();

  Future<int> voiceLegacyCount() => voiceLegacyTable.count().getSingle();

  // ── Badge 관련 통계 ───────────────────────────────────────────────────────

  /// Ghost 노드 수
  Future<int> ghostNodeCount() async {
    final rows = await (select(nodesTable)
          ..where((t) => t.isGhost.equals(true)))
        .get();
    return rows.length;
  }

  /// 타입별 기억 수 카운트 (photo / voice / memo)
  Future<int> memoryCountByType(String type) async {
    final rows = await (select(memoriesTable)
          ..where((t) => t.type.equals(type)))
        .get();
    return rows.length;
  }

  /// 추모 메시지 수
  Future<int> memorialMessageCount() =>
      memorialMessagesTable.count().getSingle();

  // ── Then & Now ────────────────────────────────────────────────────────────

  Future<void> upsertThenNow(ThenNowTableCompanion entry) =>
      into(thenNowTable).insertOnConflictUpdate(entry);

  Future<List<ThenNowTableData>> getAllThenNow() =>
      (select(thenNowTable)
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .get();

  Stream<List<ThenNowTableData>> watchAllThenNow() =>
      (select(thenNowTable)
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .watch();

  Future<ThenNowTableData?> getThenNow(String id) =>
      (select(thenNowTable)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<int> deleteThenNow(String id) =>
      (delete(thenNowTable)..where((t) => t.id.equals(id))).go();

  Future<int> thenNowCount() => thenNowTable.count().getSingle();

  // ── Family Events (가족 일정) ─────────────────────────────────────────────

  Future<void> upsertFamilyEvent(FamilyEventsTableCompanion event) =>
      into(familyEventsTable).insertOnConflictUpdate(event);

  Stream<List<FamilyEventsTableData>> watchAllFamilyEvents() =>
      (select(familyEventsTable)
            ..orderBy([(t) => OrderingTerm.asc(t.eventDate)]))
          .watch();

  Future<List<FamilyEventsTableData>> getAllFamilyEvents() =>
      (select(familyEventsTable)
            ..orderBy([(t) => OrderingTerm.asc(t.eventDate)]))
          .get();

  Future<int> deleteFamilyEvent(String id) =>
      (delete(familyEventsTable)..where((t) => t.id.equals(id))).go();

  // ── Settings ───────────────────────────────────────────────────────────────

  Future<String?> getSetting(String key) async {
    final row = await (select(settingsTable)
          ..where((t) => t.key.equals(key)))
        .getSingleOrNull();
    return row?.value;
  }

  Future<void> setSetting(String key, String value) =>
      into(settingsTable).insertOnConflictUpdate(
        SettingsTableCompanion.insert(key: key, value: value),
      );

  // ── 검색 ──────────────────────────────────────────────────────────────────

  /// 노드 이름/별명 LIKE 검색
  Future<List<NodesTableData>> searchNodes(String query) {
    final escaped = _escapeLike(query);
    return (select(nodesTable)
          ..where((t) =>
              t.name.like('%$escaped%') |
              t.nickname.like('%$escaped%'))
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .get();
  }

  /// 기억 제목/설명 LIKE 검색
  Future<List<MemoriesTableData>> searchMemories(String query) {
    final escaped = _escapeLike(query);
    return (select(memoriesTable)
          ..where((t) =>
              t.title.like('%$escaped%') |
              t.description.like('%$escaped%'))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  // ── 통계 ──────────────────────────────────────────────────────────────────

  Future<Map<String, int>> getStats() async {
    final nodes = await nodesTable.count().getSingle();
    final memories = await memoriesTable.count().getSingle();
    return {'nodes': nodes, 'memories': memories};
  }

  // ── SyncQueue (클라우드 동기화 대기열) ────────────────────────────────────

  /// 미전송 항목 조회 (최대 limit개, createdAtMs 오름차순)
  Future<List<SyncQueueEntry>> getPendingSyncItems({int limit = 50}) =>
      (select(syncQueueTable)
            ..where((t) => t.isSynced.equals(false))
            ..orderBy([(t) => OrderingTerm.asc(t.createdAtMs)])
            ..limit(limit))
          .get();

  /// 항목 삽입
  Future<void> enqueueSyncItem({
    required String targetTable,
    required String recordId,
    required String operation,
    required String payloadJson,
  }) async {
    final id = DateTime.now().microsecondsSinceEpoch.toString() +
        '_' +
        recordId.replaceAll('-', '').padRight(8, '0').substring(0, 8);
    await into(syncQueueTable).insertOnConflictUpdate(
      SyncQueueTableCompanion.insert(
        id: id,
        targetTable: targetTable,
        recordId: recordId,
        operation: operation,
        payloadJson: payloadJson,
        createdAtMs: DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  /// 전송 완료 표시 (isSynced = true)
  Future<void> markSyncedItems(List<String> ids) async {
    if (ids.isEmpty) return;
    await (update(syncQueueTable)
          ..where((t) => t.id.isIn(ids)))
        .write(const SyncQueueTableCompanion(isSynced: Value(true)));
  }

  /// 재시도 횟수 1 증가
  Future<void> incrementRetryCount(String id) async {
    final entry = await (select(syncQueueTable)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    if (entry == null) return;
    await (update(syncQueueTable)..where((t) => t.id.equals(id))).write(
      SyncQueueTableCompanion(retryCount: Value(entry.retryCount + 1)),
    );
  }

  /// 완료 항목 정리 (isSynced = true 인 항목 삭제)
  Future<void> cleanSyncedItems() =>
      (delete(syncQueueTable)..where((t) => t.isSynced.equals(true))).go();

  // ── Node Locations (가족 지도) ──────────────────────────────────────────────

  Future<void> upsertNodeLocation(NodeLocationsTableCompanion loc) =>
      into(nodeLocationsTable).insertOnConflictUpdate(loc);

  Future<List<NodeLocationsTableData>> getLocationsForNode(String nodeId) =>
      (select(nodeLocationsTable)
            ..where((t) => t.nodeId.equals(nodeId))
            ..orderBy([(t) => OrderingTerm.asc(t.startYear)]))
          .get();

  Stream<List<NodeLocationsTableData>> watchAllLocations() =>
      (select(nodeLocationsTable)
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .watch();

  Future<int> deleteNodeLocation(String id) =>
      (delete(nodeLocationsTable)..where((t) => t.id.equals(id))).go();

  // ── MediaUploadQueue (R2 미디어 업로드 대기열) ──────────────────────────────

  /// 업로드 큐에 항목 추가
  Future<void> enqueueMediaUpload(MediaUploadQueueTableCompanion entry) =>
      into(mediaUploadQueueTable).insertOnConflictUpdate(entry);

  /// pending 상태 항목 조회 (createdAt 오름차순, 최대 limit개)
  Future<List<MediaUploadQueueEntry>> getPendingMediaUploads({
    int limit = 10,
  }) =>
      (select(mediaUploadQueueTable)
            ..where((t) => t.status.equals('pending'))
            ..orderBy([(t) => OrderingTerm.asc(t.createdAt)])
            ..limit(limit))
          .get();

  /// failed 상태 중 재시도 가능한 항목 조회 (retryCount < maxRetry)
  Future<List<MediaUploadQueueEntry>> getRetryableMediaUploads({
    int maxRetry = 5,
    int limit = 10,
  }) =>
      (select(mediaUploadQueueTable)
            ..where((t) =>
                t.status.equals('failed') &
                t.retryCount.isSmallerThanValue(maxRetry))
            ..orderBy([(t) => OrderingTerm.asc(t.createdAt)])
            ..limit(limit))
          .get();

  /// 업로드 상태 업데이트
  Future<void> updateMediaUploadStatus(
    String id, {
    required String status,
    String? r2FileKey,
    DateTime? completedAt,
  }) async {
    final companion = MediaUploadQueueTableCompanion(
      status: Value(status),
      r2FileKey: r2FileKey != null ? Value(r2FileKey) : const Value.absent(),
      completedAt:
          completedAt != null ? Value(completedAt) : const Value.absent(),
    );
    await (update(mediaUploadQueueTable)..where((t) => t.id.equals(id)))
        .write(companion);
  }

  /// 업로드 재시도 횟수 증가 + failed 상태로 변경
  Future<void> incrementMediaUploadRetry(String id) async {
    final entry = await (select(mediaUploadQueueTable)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    if (entry == null) return;
    await (update(mediaUploadQueueTable)..where((t) => t.id.equals(id))).write(
      MediaUploadQueueTableCompanion(
        retryCount: Value(entry.retryCount + 1),
        status: const Value('failed'),
      ),
    );
  }

  /// 특정 memory의 업로드 큐 항목 조회
  Future<List<MediaUploadQueueEntry>> getMediaUploadsByMemoryId(
      String memoryId) =>
      (select(mediaUploadQueueTable)
            ..where((t) => t.memoryId.equals(memoryId)))
          .get();

  /// 특정 node의 업로드 큐 항목 조회
  Future<List<MediaUploadQueueEntry>> getMediaUploadsByNodeId(
      String nodeId) =>
      (select(mediaUploadQueueTable)
            ..where((t) => t.nodeId.equals(nodeId)))
          .get();

  /// 상태별 카운트 조회
  Future<Map<String, int>> getMediaUploadQueueStatus() async {
    final all = await select(mediaUploadQueueTable).get();
    final result = <String, int>{
      'pending': 0,
      'uploading': 0,
      'completed': 0,
      'failed': 0,
    };
    for (final entry in all) {
      result[entry.status] = (result[entry.status] ?? 0) + 1;
    }
    return result;
  }

  /// 완료된 항목 정리
  Future<void> cleanCompletedMediaUploads() =>
      (delete(mediaUploadQueueTable)
            ..where((t) => t.status.equals('completed')))
          .go();

  /// 특정 항목 삭제
  Future<int> deleteMediaUpload(String id) =>
      (delete(mediaUploadQueueTable)..where((t) => t.id.equals(id))).go();
}

/// DB 파일 연결 — LazyDatabase로 비동기 경로 해결 (background isolate 없음)
QueryExecutor _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'relink.db'));
    return NativeDatabase(file, setup: (db) {
      db.execute('PRAGMA foreign_keys = ON');
    });
  });
}

/// 외부 DB 파일 경로 (백업/복원용)
/// _openConnection()과 동일한 경로를 반환해야 함
Future<String> getDatabasePath() async {
  final dir = await getApplicationDocumentsDirectory();
  return p.join(dir.path, 'relink.db');
}
