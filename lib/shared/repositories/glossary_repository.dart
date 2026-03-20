import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../../core/database/app_database.dart';
import 'db_provider.dart';

part 'glossary_repository.g.dart';

@riverpod
GlossaryRepository glossaryRepository(Ref ref) =>
    GlossaryRepository(ref.watch(appDatabaseProvider));

class GlossaryRepository {
  GlossaryRepository(this._db);
  final AppDatabase _db;
  static const _uuid = Uuid();

  /// 전체 단어장 스트림 (가나다순 정렬)
  Stream<List<GlossaryTableData>> watchAll() => _db.watchAllGlossary();

  /// 단어/뜻 LIKE 검색
  Future<List<GlossaryTableData>> search(String query) =>
      _db.searchGlossary(query);

  /// 단어 등록 (새 ID 생성 후 반환)
  Future<String> create({
    required String word,
    required String meaning,
    String? example,
    String? voicePath,
    String? nodeId,
  }) async {
    final id = _uuid.v4();
    await _db.upsertGlossaryEntry(GlossaryTableCompanion.insert(
      id: id,
      word: word,
      meaning: meaning,
      example: Value(example),
      voicePath: Value(voicePath),
      nodeId: Value(nodeId),
    ));
    return id;
  }

  /// 단어 삭제
  Future<int> delete(String id) => _db.deleteGlossaryEntry(id);
}
