import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart';
import '../../core/database/app_database.dart';
import '../models/family_event_model.dart';
import 'db_provider.dart';

part 'family_event_repository.g.dart';

@riverpod
FamilyEventRepository familyEventRepository(Ref ref) =>
    FamilyEventRepository(ref.watch(appDatabaseProvider));

class FamilyEventRepository {
  FamilyEventRepository(this._db);
  final AppDatabase _db;
  static const _uuid = Uuid();

  /// 전체 일정 스트림
  Stream<List<FamilyEventModel>> watchAll() =>
      _db.watchAllFamilyEvents().map(
          (rows) => rows.map(_rowToModel).toList());

  /// 전체 일정 조회
  Future<List<FamilyEventModel>> getAll() async {
    final rows = await _db.getAllFamilyEvents();
    return rows.map(_rowToModel).toList();
  }

  /// 일정 생성
  Future<String> create({
    required String title,
    String? description,
    required DateTime eventDate,
    bool isYearly = false,
    Color color = const Color(0xFF8B5CF6),
    String? nodeId,
  }) async {
    final id = _uuid.v4();
    await _db.upsertFamilyEvent(FamilyEventsTableCompanion.insert(
      id: id,
      title: title,
      description: Value(description),
      eventDate: eventDate,
      isYearly: Value(isYearly),
      colorHex: Value(FamilyEventModel.colorToHex(color)),
      nodeId: Value(nodeId),
    ));
    return id;
  }

  /// 일정 수정
  Future<void> update(FamilyEventModel event) async {
    await _db.upsertFamilyEvent(FamilyEventsTableCompanion(
      id: Value(event.id),
      title: Value(event.title),
      description: Value(event.description),
      eventDate: Value(event.eventDate),
      isYearly: Value(event.isYearly),
      colorHex: Value(FamilyEventModel.colorToHex(event.color)),
      nodeId: Value(event.nodeId),
    ));
  }

  /// 일정 삭제
  Future<int> delete(String id) => _db.deleteFamilyEvent(id);

  /// DB row → 도메인 모델 변환
  FamilyEventModel _rowToModel(FamilyEventsTableData row) {
    return FamilyEventModel(
      id: row.id,
      title: row.title,
      description: row.description,
      eventDate: row.eventDate,
      isYearly: row.isYearly,
      color: FamilyEventModel.colorFromHex(row.colorHex),
      nodeId: row.nodeId,
      createdAt: row.createdAt,
    );
  }
}
