import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../../core/database/app_database.dart';
import 'db_provider.dart';

part 'voice_legacy_repository.g.dart';

@riverpod
VoiceLegacyRepository voiceLegacyRepository(Ref ref) =>
    VoiceLegacyRepository(ref.watch(appDatabaseProvider));

class VoiceLegacyRepository {
  VoiceLegacyRepository(this._db);
  final AppDatabase _db;
  static const _uuid = Uuid();

  /// 전체 보이스 유언 스트림 (createdAt 내림차순)
  Stream<List<VoiceLegacyTableData>> watchAll() =>
      _db.watchAllVoiceLegacies();

  /// 특정 수신 노드의 보이스 유언 스트림
  Stream<List<VoiceLegacyTableData>> watchForNode(String toNodeId) =>
      _db.watchVoiceLegaciesForNode(toNodeId);

  /// 단일 조회
  Future<VoiceLegacyTableData?> get(String id) => _db.getVoiceLegacy(id);

  /// 보이스 유언 생성
  Future<String> create({
    required String fromNodeId,
    required String toNodeId,
    required String title,
    required String voicePath,
    required int durationSeconds,
    required String openCondition,
    DateTime? openDate,
  }) async {
    final id = _uuid.v4();
    await _db.upsertVoiceLegacy(VoiceLegacyTableCompanion.insert(
      id: id,
      fromNodeId: fromNodeId,
      toNodeId: toNodeId,
      title: title,
      voicePath: voicePath,
      durationSeconds: Value(durationSeconds),
      openCondition: Value(openCondition),
      openDate: Value(openDate),
    ));
    return id;
  }

  /// 봉인 해제 (isOpened = true, openedAt = now)
  Future<void> open(String id) => _db.openVoiceLegacy(id);

  /// 삭제
  Future<int> delete(String id) => _db.deleteVoiceLegacy(id);

  /// 전체 수
  Future<int> count() => _db.voiceLegacyCount();
}
