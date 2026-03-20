import 'package:drift/drift.dart';

/// 추모 메시지 (The Last Page) 테이블
class MemorialMessagesTable extends Table {
  @override
  String get tableName => 'memorial_messages';

  TextColumn get id => text()();
  TextColumn get nodeId => text()();
  TextColumn get message => text()();
  TextColumn get authorName => text().nullable()();
  DateTimeColumn get date => dateTime()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
