import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../../core/database/app_database.dart';
import '../models/bouquet_model.dart';
import 'db_provider.dart';

part 'bouquet_repository.g.dart';

@riverpod
BouquetRepository bouquetRepository(Ref ref) =>
    BouquetRepository(ref.watch(appDatabaseProvider));

class BouquetRepository {
  BouquetRepository(this._db);
  final AppDatabase _db;
  final _uuid = const Uuid();

  // ── 생성 ──────────────────────────────────────────────────────────────────

  Future<Bouquet> sendFlower({
    required String fromNodeId,
    required String toNodeId,
    required FlowerType flowerType,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now();
    await _db.upsertBouquet(BouquetsTableCompanion.insert(
      id: id,
      fromNodeId: fromNodeId,
      toNodeId: toNodeId,
      flowerType: flowerType.dbValue,
      date: now,
      createdAt: Value(now),
    ));
    return Bouquet(
      id: id,
      fromNodeId: fromNodeId,
      toNodeId: toNodeId,
      flowerType: flowerType,
      date: now,
      createdAt: now,
    );
  }

  // ── 조회 ──────────────────────────────────────────────────────────────────

  /// 특정 노드에 보내진 모든 꽃
  Future<List<Bouquet>> getForNode(String toNodeId) async {
    final rows = await _db.getBouquetsForNode(toNodeId);
    return rows.map(_rowToModel).toList();
  }

  /// 이번 주(7일) 동안 특정 노드에 보내진 꽃
  Future<List<Bouquet>> getThisWeek(String toNodeId) async {
    final rows = await _db.getBouquetsThisWeek(toNodeId);
    return rows.map(_rowToModel).toList();
  }

  /// 올해 전체 꽃 (연간 리포트용)
  Future<List<Bouquet>> getThisYear() async {
    final rows = await _db.getBouquetsThisYear();
    return rows.map(_rowToModel).toList();
  }

  // ── 받은 마음 조회 ──────────────────────────────────────────────────────

  /// 내가 받은 모든 마음 (받은 마음 목록)
  Future<List<Bouquet>> getReceivedBouquets(String toNodeId) async {
    final rows = await _db.getReceivedBouquets(toNodeId);
    return rows.map(_rowToModel).toList();
  }

  /// 읽지 않은 마음 수
  Future<int> getUnreadCount(String toNodeId) =>
      _db.getUnreadBouquetCount(toNodeId);

  /// 받은 마음 모두 읽음 처리
  Future<void> markAllAsRead(String toNodeId) =>
      _db.markBouquetsAsRead(toNodeId);

  // ── 삭제 ──────────────────────────────────────────────────────────────────

  Future<void> delete(String id) => _db.deleteBouquet(id);

  // ── 변환 ──────────────────────────────────────────────────────────────────

  Bouquet _rowToModel(BouquetsTableData row) => Bouquet(
        id: row.id,
        fromNodeId: row.fromNodeId,
        toNodeId: row.toNodeId,
        flowerType: FlowerType.fromDb(row.flowerType),
        date: row.date,
        createdAt: row.createdAt,
        isRead: row.isRead,
      );
}
