import 'package:drift/drift.dart';
import 'nodes_table.dart';

/// 기억 (사진 / 음성 / 메모 / AI)
class MemoriesTable extends Table {
  @override
  String get tableName => 'memories';

  TextColumn get id => text()(); // UUID
  TextColumn get nodeId =>
      text().references(NodesTable, #id, onDelete: KeyAction.cascade)();

  /// 타입: photo, voice, note, ai
  TextColumn get type => text()();

  TextColumn get title => text().nullable()();
  TextColumn get description => text().nullable()();

  /// 로컬 파일 경로 (사진/음성)
  TextColumn get filePath => text().nullable()();
  TextColumn get thumbnailPath => text().nullable()();

  /// 음성 길이 (초)
  IntColumn get durationSeconds => integer().nullable()();

  DateTimeColumn get dateTaken => dateTime().nullable()();
  TextColumn get tagsJson => text().withDefault(const Constant('[]'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  /// Privacy Layer: 개인 메모 잠금 여부
  BoolColumn get isPrivate => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
