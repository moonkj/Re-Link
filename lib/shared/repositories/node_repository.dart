import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../../core/database/app_database.dart';
import '../../shared/models/node_model.dart';
import 'db_provider.dart';

part 'node_repository.g.dart';

@riverpod
NodeRepository nodeRepository(Ref ref) =>
    NodeRepository(ref.watch(appDatabaseProvider));

class NodeRepository {
  NodeRepository(this._db);
  final AppDatabase _db;
  final _uuid = const Uuid();

  // ── 조회 ──────────────────────────────────────────────────────────────────

  Stream<List<NodeModel>> watchAll() =>
      _db.watchAllNodes().map((rows) => rows.map(_rowToModel).toList());

  Future<NodeModel?> getById(String id) async {
    final row = await _db.getNode(id);
    return row == null ? null : _rowToModel(row);
  }

  Future<int> count() => _db.nodeCount();

  // ── 생성 ──────────────────────────────────────────────────────────────────

  Future<NodeModel> create({
    required String name,
    String? nickname,
    String? photoPath,
    String? bio,
    DateTime? birthDate,
    DateTime? deathDate,
    bool isGhost = false,
    int temperature = 2,
    double positionX = 0.0,
    double positionY = 0.0,
    List<String> tags = const [],
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now();
    await _db.upsertNode(NodesTableCompanion.insert(
      id: id,
      name: name,
      nickname: Value(nickname),
      photoPath: Value(photoPath),
      bio: Value(bio),
      birthDate: Value(birthDate),
      deathDate: Value(deathDate),
      isGhost: Value(isGhost),
      temperature: Value(temperature),
      positionX: Value(positionX),
      positionY: Value(positionY),
      tagsJson: Value(jsonEncode(tags)),
      createdAt: Value(now),
      updatedAt: Value(now),
    ));
    return (await getById(id))!;
  }

  // ── 수정 ──────────────────────────────────────────────────────────────────

  Future<void> update(NodeModel node) async {
    await _db.upsertNode(NodesTableCompanion.insert(
      id: node.id,
      name: node.name,
      nickname: Value(node.nickname),
      photoPath: Value(node.photoPath),
      bio: Value(node.bio),
      birthDate: Value(node.birthDate),
      deathDate: Value(node.deathDate),
      isGhost: Value(node.isGhost),
      temperature: Value(node.temperature),
      positionX: Value(node.positionX),
      positionY: Value(node.positionY),
      tagsJson: Value(jsonEncode(node.tags)),
      createdAt: Value(node.createdAt),
      updatedAt: Value(DateTime.now()),
    ));
  }

  Future<void> updatePosition(String id, double x, double y) async {
    final node = await getById(id);
    if (node == null) return;
    await update(node.copyWith(positionX: x, positionY: y));
  }

  Future<void> updateTemperature(String id, int level) async {
    final node = await getById(id);
    if (node == null) return;
    await update(node.copyWith(temperature: level));
  }

  // ── 삭제 ──────────────────────────────────────────────────────────────────

  Future<void> delete(String id) => _db.deleteNode(id);

  // ── 엣지 ──────────────────────────────────────────────────────────────────

  Stream<List<NodeEdge>> watchAllEdges() =>
      _db.watchAllEdges().map((rows) => rows.map(_edgeRowToModel).toList());

  Future<List<NodeEdge>> getEdgesForNode(String nodeId) async {
    final rows = await _db.getEdgesForNode(nodeId);
    return rows.map(_edgeRowToModel).toList();
  }

  Future<NodeEdge> addEdge({
    required String fromNodeId,
    required String toNodeId,
    required RelationType relation,
    String? label,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now();
    await _db.upsertEdge(NodeEdgesTableCompanion.insert(
      id: id,
      fromNodeId: fromNodeId,
      toNodeId: toNodeId,
      relation: relation.name,
      label: Value(label),
      createdAt: Value(now),
    ));
    return NodeEdge(
      id: id,
      fromNodeId: fromNodeId,
      toNodeId: toNodeId,
      relation: relation,
      label: label,
      createdAt: now,
    );
  }

  Future<void> deleteEdge(String id) => _db.deleteEdge(id);

  // ── 변환 ──────────────────────────────────────────────────────────────────

  NodeModel _rowToModel(NodesTableData row) {
    final tags = (jsonDecode(row.tagsJson) as List<dynamic>)
        .map((e) => e as String)
        .toList();
    return NodeModel(
      id: row.id,
      name: row.name,
      nickname: row.nickname,
      photoPath: row.photoPath,
      bio: row.bio,
      birthDate: row.birthDate,
      deathDate: row.deathDate,
      isGhost: row.isGhost,
      temperature: row.temperature,
      positionX: row.positionX,
      positionY: row.positionY,
      tags: tags,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  NodeEdge _edgeRowToModel(NodeEdgesTableData row) => NodeEdge(
        id: row.id,
        fromNodeId: row.fromNodeId,
        toNodeId: row.toNodeId,
        relation: RelationType.values.firstWhere(
          (e) => e.name == row.relation,
          orElse: () => RelationType.other,
        ),
        label: row.label,
        createdAt: row.createdAt,
      );
}
