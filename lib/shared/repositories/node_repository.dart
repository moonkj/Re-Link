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

  Future<List<NodeModel>> searchNodes(String query) async {
    if (query.trim().isEmpty) return [];
    final rows = await _db.searchNodes(query);
    return rows.map(_rowToModel).toList();
  }

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

  /// 두 노드 사이의 기존 엣지 조회 (방향 무관, 관계 타입 무관)
  Future<NodeEdge?> findEdge({
    required String fromNodeId,
    required String toNodeId,
  }) async {
    final row = await _db.findEdgeBetween(fromNodeId, toNodeId);
    return row == null ? null : _edgeRowToModel(row);
  }

  /// 두 노드 사이에 이미 동일 관계가 존재하는지 확인
  Future<bool> hasDuplicateEdge({
    required String fromNodeId,
    required String toNodeId,
    required RelationType relation,
  }) async {
    final edges = await getEdgesForNode(fromNodeId);
    return edges.any((e) =>
        e.relation == relation &&
        ((e.fromNodeId == fromNodeId && e.toNodeId == toNodeId) ||
         (e.fromNodeId == toNodeId && e.toNodeId == fromNodeId)));
  }

  Future<NodeEdge> addEdge({
    required String fromNodeId,
    required String toNodeId,
    required RelationType relation,
    String? label,
  }) async {
    // 두 노드 사이에 이미 엣지가 존재하면 관계 타입 업데이트
    final existing = await findEdge(
      fromNodeId: fromNodeId,
      toNodeId: toNodeId,
    );
    if (existing != null) {
      if (existing.relation == relation) {
        throw Exception('이미 동일한 관계가 존재합니다.');
      }
      // 기존 엣지의 관계 타입만 업데이트
      await updateEdgeRelation(existing.id, relation);
      return NodeEdge(
        id: existing.id,
        fromNodeId: existing.fromNodeId,
        toNodeId: existing.toNodeId,
        relation: relation,
        label: existing.label,
        createdAt: existing.createdAt,
      );
    }

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

  /// 엣지의 관계 타입 업데이트
  Future<void> updateEdgeRelation(
      String edgeId, RelationType newRelation) =>
      _db.updateEdgeRelation(edgeId, newRelation.name);

  Future<void> deleteEdge(String id) => _db.deleteEdge(id);

  // ── 병합 헬퍼 ─────────────────────────────────────────────────────────────

  /// 전체 노드 목록 (병합 미리보기용)
  Future<List<NodeModel>> getAll() async {
    final rows = await _db.getAllNodes();
    return rows.map(_rowToModel).toList();
  }

  /// 모델을 그대로 DB에 삽입 (병합 — 외부 .rlink 노드)
  Future<void> createWithModel(NodeModel node) async {
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
      positionX: Value(node.positionX + 20), // 위치 약간 오프셋
      positionY: Value(node.positionY + 20),
      tagsJson: Value(jsonEncode(node.tags)),
      createdAt: Value(node.createdAt),
      updatedAt: Value(DateTime.now()),
    ));
  }

  /// 상대방 버전으로 노드 덮어쓰기 (충돌 해결 — theirs)
  Future<void> updateFromModel(NodeModel node) => update(node);

  /// [nodeId] 노드에 배우자(spouse) 관계가 하나라도 있는지 확인합니다.
  Future<bool> hasSpouse(String nodeId) async {
    final edges = await getEdgesForNode(nodeId);
    return edges.any((e) => e.relation == RelationType.spouse);
  }

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
