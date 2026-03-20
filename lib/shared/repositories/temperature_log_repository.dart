import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../../core/database/app_database.dart';
import '../models/temperature_log_model.dart';
import 'db_provider.dart';

part 'temperature_log_repository.g.dart';

@riverpod
TemperatureLogRepository temperatureLogRepository(Ref ref) =>
    TemperatureLogRepository(ref.watch(appDatabaseProvider));

class TemperatureLogRepository {
  TemperatureLogRepository(this._db);
  final AppDatabase _db;
  final _uuid = const Uuid();

  // ── 생성 ──────────────────────────────────────────────────────────────────

  Future<TemperatureLog> create({
    required String nodeId,
    required int temperature,
    String? emotionTag,
    DateTime? date,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now();
    final logDate = date ?? now;
    await _db.upsertTemperatureLog(TemperatureLogsTableCompanion.insert(
      id: id,
      nodeId: nodeId,
      temperature: temperature,
      emotionTag: Value(emotionTag),
      date: logDate,
      createdAt: Value(now),
    ));
    return TemperatureLog(
      id: id,
      nodeId: nodeId,
      temperature: temperature,
      emotionTag: emotionTag,
      date: logDate,
      createdAt: now,
    );
  }

  // ── 조회 ──────────────────────────────────────────────────────────────────

  /// 노드별 온도 로그 조회 (기본 최근 30일)
  Future<List<TemperatureLog>> getForNode(
    String nodeId, {
    DateTime? from,
    DateTime? to,
  }) async {
    final effectiveFrom =
        from ?? DateTime.now().subtract(const Duration(days: 30));
    final rows = await _db.getTemperatureLogsForNode(
      nodeId,
      from: effectiveFrom,
      to: to,
    );
    return rows.map(_rowToModel).toList();
  }

  /// 노드별 온도 로그 스트림 (전체)
  Stream<List<TemperatureLog>> watchForNode(String nodeId) =>
      _db.watchTemperatureLogsForNode(nodeId).map(
        (rows) => rows.map(_rowToModel).toList(),
      );

  // ── 삭제 ──────────────────────────────────────────────────────────────────

  Future<void> delete(String id) => _db.deleteTemperatureLog(id);

  // ── 변환 ──────────────────────────────────────────────────────────────────

  TemperatureLog _rowToModel(TemperatureLogsTableData row) => TemperatureLog(
        id: row.id,
        nodeId: row.nodeId,
        temperature: row.temperature,
        emotionTag: row.emotionTag,
        date: row.date,
        createdAt: row.createdAt,
      );
}
