import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
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

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          // 기본 설정값 삽입
          await _insertDefaultSettings();
        },
        onUpgrade: (m, from, to) async {
          // 향후 마이그레이션 여기에 추가
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

  Future<int> deleteEdge(String id) =>
      (delete(nodeEdgesTable)..where((t) => t.id.equals(id))).go();

  // ── Memories ───────────────────────────────────────────────────────────────

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

  Future<void> upsertMemory(MemoriesTableCompanion memory) =>
      into(memoriesTable).insertOnConflictUpdate(memory);

  Future<int> deleteMemory(String id) =>
      (delete(memoriesTable)..where((t) => t.id.equals(id))).go();

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

  // ── 통계 ──────────────────────────────────────────────────────────────────

  Future<Map<String, int>> getStats() async {
    final nodes = await nodesTable.count().getSingle();
    final memories = await memoriesTable.count().getSingle();
    return {'nodes': nodes, 'memories': memories};
  }
}

/// DB 파일 연결
QueryExecutor _openConnection() {
  return driftDatabase(name: 'relink');
}

/// 외부 DB 파일 경로 (백업/복원용)
Future<String> getDatabasePath() async {
  final dir = await getApplicationDocumentsDirectory();
  return p.join(dir.path, 'drift', 'relink.db');
}
