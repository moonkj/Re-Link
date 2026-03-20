import 'package:drift/drift.dart';

/// 가족 단어장 (Family Glossary) 테이블
class GlossaryTable extends Table {
  @override
  String get tableName => 'glossary';

  TextColumn get id => text()();
  TextColumn get word => text()();
  TextColumn get meaning => text()();
  TextColumn get example => text().nullable()();
  TextColumn get voicePath => text().nullable()();
  TextColumn get nodeId => text().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
