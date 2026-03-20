import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../../core/database/app_database.dart';
import 'db_provider.dart';
import 'package:drift/drift.dart';

part 'memorial_repository.g.dart';

@riverpod
MemorialRepository memorialRepository(Ref ref) =>
    MemorialRepository(ref.watch(appDatabaseProvider));

class MemorialRepository {
  MemorialRepository(this._db);
  final AppDatabase _db;
  static const _uuid = Uuid();

  Stream<List<MemorialMessagesTableData>> watchForNode(String nodeId) =>
      _db.watchMemorialMessagesForNode(nodeId);

  Future<List<MemorialMessagesTableData>> getForNode(String nodeId) =>
      _db.getMemorialMessagesForNode(nodeId);

  Future<String> create({
    required String nodeId,
    required String message,
    String? authorName,
  }) async {
    final id = _uuid.v4();
    await _db.upsertMemorialMessage(MemorialMessagesTableCompanion.insert(
      id: id,
      nodeId: nodeId,
      message: message,
      authorName: Value(authorName),
      date: DateTime.now(),
    ));
    return id;
  }

  Future<int> delete(String id) => _db.deleteMemorialMessage(id);
}
