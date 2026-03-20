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
import 'tables/glossary_table.dart';
import 'tables/recipes_table.dart';
import 'tables/node_locations_table.dart';
import 'tables/voice_legacy_table.dart';

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
  GlossaryTable,
  RecipesTable,
  NodeLocationsTable,
  VoiceLegacyTable,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// 테스트용 in-memory DB
  AppDatabase.forTesting(super.executor);

  /// 병합 미리보기용 외부 파일 DB (읽기 전용)
  AppDatabase.forMerge(String path)
      : super(NativeDatabase(File(path)));

  @override
  int get schemaVersion => 5;

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
            await m.createTable(glossaryTable);
          }
          // v4 → v5: recipes + node_locations + voice_legacy
          if (from < 5) {
            await m.createTable(recipesTable);
            await m.createTable(nodeLocationsTable);
            await m.createTable(voiceLegacyTable);
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
      (select(memoriesTable)..where((t) => t.type.equals(type)))
          .get()
          .then((rows) => rows.length);

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

  // ── Glossary (Family Glossary) ──────────────────────────────────────────

  Future<void> upsertGlossaryEntry(GlossaryTableCompanion entry) =>
      into(glossaryTable).insertOnConflictUpdate(entry);

  Stream<List<GlossaryTableData>> watchAllGlossary() =>
      (select(glossaryTable)
            ..orderBy([(t) => OrderingTerm.asc(t.word)]))
          .watch();

  Future<List<GlossaryTableData>> searchGlossary(String query) =>
      (select(glossaryTable)
            ..where((t) =>
                t.word.like('%$query%') | t.meaning.like('%$query%'))
            ..orderBy([(t) => OrderingTerm.asc(t.word)]))
          .get();

  Future<int> deleteGlossaryEntry(String id) =>
      (delete(glossaryTable)..where((t) => t.id.equals(id))).go();

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
            ..where((t) => t.title.like('%$query%'))
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

  /// 용어집 항목 수
  Future<int> glossaryCount() => glossaryTable.count().getSingle();

  /// 추모 메시지 수
  Future<int> memorialMessageCount() =>
      memorialMessagesTable.count().getSingle();

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
  Future<List<NodesTableData>> searchNodes(String query) =>
      (select(nodesTable)
            ..where((t) => t.name.like('%$query%') | t.nickname.like('%$query%'))
            ..orderBy([(t) => OrderingTerm.asc(t.name)]))
          .get();

  /// 기억 제목/설명 LIKE 검색
  Future<List<MemoriesTableData>> searchMemories(String query) =>
      (select(memoriesTable)
            ..where((t) => t.title.like('%$query%') | t.description.like('%$query%'))
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .get();

  // ── 통계 ──────────────────────────────────────────────────────────────────

  Future<Map<String, int>> getStats() async {
    final nodes = await nodesTable.count().getSingle();
    final memories = await memoriesTable.count().getSingle();
    return {'nodes': nodes, 'memories': memories};
  }

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
}

/// DB 파일 연결 — LazyDatabase로 비동기 경로 해결 (background isolate 없음)
QueryExecutor _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'relink.db'));
    return NativeDatabase(file);
  });
}

/// 외부 DB 파일 경로 (백업/복원용)
/// _openConnection()과 동일한 경로를 반환해야 함
Future<String> getDatabasePath() async {
  final dir = await getApplicationDocumentsDirectory();
  return p.join(dir.path, 'relink.db');
}
