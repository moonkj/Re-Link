import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../../core/database/app_database.dart';
import '../models/memory_model.dart';
import 'db_provider.dart';

part 'memory_repository.g.dart';

@riverpod
MemoryRepository memoryRepository(Ref ref) =>
    MemoryRepository(ref.watch(appDatabaseProvider));

class MemoryRepository {
  MemoryRepository(this._db);
  final AppDatabase _db;
  final _uuid = const Uuid();

  // ── 조회 ──────────────────────────────────────────────────────────────────

  Stream<List<MemoryModel>> watchForNode(String nodeId) =>
      _db.watchMemoriesForNode(nodeId).map((rows) => rows.map(_rowToModel).toList());

  Future<List<MemoryModel>> getForNode(String nodeId) async {
    final rows = await _db.getMemoriesForNode(nodeId);
    return rows.map(_rowToModel).toList();
  }

  Future<MemoryModel?> getById(String id) async {
    final row = await _db.getMemory(id);
    return row == null ? null : _rowToModel(row);
  }

  Future<List<MemoryModel>> searchMemories(String query) async {
    if (query.trim().isEmpty) return [];
    final rows = await _db.searchMemories(query);
    return rows.map(_rowToModel).toList();
  }

  // ── 생성 ──────────────────────────────────────────────────────────────────

  Future<MemoryModel> create({
    required String nodeId,
    required MemoryType type,
    String? title,
    String? description,
    String? filePath,
    String? thumbnailPath,
    int? durationSeconds,
    DateTime? dateTaken,
    List<String> tags = const [],
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now();
    await _db.upsertMemory(MemoriesTableCompanion.insert(
      id: id,
      nodeId: nodeId,
      type: type.name,
      title: Value(title),
      description: Value(description),
      filePath: Value(filePath),
      thumbnailPath: Value(thumbnailPath),
      durationSeconds: Value(durationSeconds),
      dateTaken: Value(dateTaken),
      tagsJson: Value(jsonEncode(tags)),
      createdAt: Value(now),
    ));
    return (await getById(id))!;
  }

  // ── 삭제 ──────────────────────────────────────────────────────────────────

  Future<void> delete(String id) => _db.deleteMemory(id);

  // ── 플랜 제한 체크용 ──────────────────────────────────────────────────────

  Future<int> totalPhotoCount() => _db.countMemoriesByType('photo');

  /// 전체 음성 길이 합 (분 단위)
  Future<int> totalVoiceMinutes() async {
    final seconds = await _db.sumVoiceDuration();
    return (seconds / 60).ceil();
  }

  // ── 변환 ──────────────────────────────────────────────────────────────────

  MemoryModel _rowToModel(MemoriesTableData row) {
    final tags = (jsonDecode(row.tagsJson) as List<dynamic>)
        .map((e) => e as String)
        .toList();
    return MemoryModel(
      id: row.id,
      nodeId: row.nodeId,
      type: MemoryType.values.firstWhere(
        (t) => t.name == row.type,
        orElse: () => MemoryType.note,
      ),
      title: row.title,
      description: row.description,
      filePath: row.filePath,
      thumbnailPath: row.thumbnailPath,
      durationSeconds: row.durationSeconds,
      dateTaken: row.dateTaken,
      tags: tags,
      createdAt: row.createdAt,
    );
  }
}
