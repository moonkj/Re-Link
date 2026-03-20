import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../../core/database/app_database.dart';
import 'db_provider.dart';

part 'then_now_repository.g.dart';

@riverpod
ThenNowRepository thenNowRepository(Ref ref) =>
    ThenNowRepository(ref.watch(appDatabaseProvider));

/// Then & Now 페어 도메인 모델
class ThenNowPair {
  const ThenNowPair({
    required this.id,
    required this.memoryId1,
    required this.memoryId2,
    this.label,
    required this.createdAt,
  });

  final String id;
  final String memoryId1;
  final String memoryId2;
  final String? label;
  final DateTime createdAt;
}

class ThenNowRepository {
  ThenNowRepository(this._db);
  final AppDatabase _db;
  final _uuid = const Uuid();

  // ── 조회 ──────────────────────────────────────────────────────────────────

  Future<List<ThenNowPair>> getAll() async {
    final rows = await _db.getAllThenNow();
    return rows.map(_rowToModel).toList();
  }

  Future<ThenNowPair?> getById(String id) async {
    final row = await _db.getThenNow(id);
    return row == null ? null : _rowToModel(row);
  }

  Stream<List<ThenNowPair>> watchAll() =>
      _db.watchAllThenNow().map((rows) => rows.map(_rowToModel).toList());

  // ── 생성 ──────────────────────────────────────────────────────────────────

  Future<ThenNowPair> create({
    required String memoryId1,
    required String memoryId2,
    String? label,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now();
    await _db.upsertThenNow(ThenNowTableCompanion.insert(
      id: id,
      memoryId1: memoryId1,
      memoryId2: memoryId2,
      label: Value(label),
      createdAt: Value(now),
    ));
    return (await getById(id))!;
  }

  // ── 삭제 ──────────────────────────────────────────────────────────────────

  Future<void> delete(String id) => _db.deleteThenNow(id);

  // ── 변환 ──────────────────────────────────────────────────────────────────

  ThenNowPair _rowToModel(ThenNowTableData row) {
    return ThenNowPair(
      id: row.id,
      memoryId1: row.memoryId1,
      memoryId2: row.memoryId2,
      label: row.label,
      createdAt: row.createdAt,
    );
  }
}
