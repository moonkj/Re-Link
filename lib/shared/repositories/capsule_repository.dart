import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../../core/database/app_database.dart';
import 'db_provider.dart';
import 'package:drift/drift.dart';

part 'capsule_repository.g.dart';

@riverpod
CapsuleRepository capsuleRepository(Ref ref) =>
    CapsuleRepository(ref.watch(appDatabaseProvider));

class CapsuleRepository {
  CapsuleRepository(this._db);
  final AppDatabase _db;
  static const _uuid = Uuid();

  /// 전체 캡슐 스트림 (openDate 오름차순)
  Stream<List<CapsulesTableData>> watchAll() => _db.watchAllCapsules();

  /// 단일 캡슐 조회
  Future<CapsulesTableData?> get(String id) => _db.getCapsule(id);

  /// 캡슐 생성 + 기억 연결
  Future<String> create({
    required String title,
    String? message,
    required DateTime openDate,
    required List<String> memoryIds,
  }) async {
    final id = _uuid.v4();
    await _db.upsertCapsule(CapsulesTableCompanion.insert(
      id: id,
      title: title,
      message: Value(message),
      openDate: openDate,
    ));
    for (final memId in memoryIds) {
      await _db.addCapsuleItem(CapsuleItemsTableCompanion.insert(
        id: _uuid.v4(),
        capsuleId: id,
        memoryId: memId,
      ));
    }
    return id;
  }

  /// 캡슐 열기 (isOpened → true, openedAt → now)
  Future<void> open(String id) => _db.openCapsule(id);

  /// 캡슐 삭제 (아이템도 함께)
  Future<int> delete(String id) => _db.deleteCapsule(id);

  /// 캡슐에 포함된 기억 아이템 조회
  Future<List<CapsuleItemsTableData>> getItems(String capsuleId) =>
      _db.getCapsuleItems(capsuleId);

  /// 전체 캡슐 수
  Future<int> count() => _db.capsuleCount();
}
