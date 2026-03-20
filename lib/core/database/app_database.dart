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

part 'app_database.g.dart';

@DriftDatabase(tables: [
  ProfileTable,
  NodesTable,
  NodeEdgesTable,
  MemoriesTable,
  SettingsTable,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// 테스트용 in-memory DB
  AppDatabase.forTesting(super.executor);

  /// 병합 미리보기용 외부 파일 DB (읽기 전용)
  AppDatabase.forMerge(String path)
      : super(NativeDatabase(File(path)));

  @override
  int get schemaVersion => 2;

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
