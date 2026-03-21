import 'package:drift/drift.dart';

/// 가족 일정 테이블
class FamilyEventsTable extends Table {
  @override
  String get tableName => 'family_events';

  TextColumn get id => text()();
  TextColumn get title => text().withLength(min: 1, max: 200)();
  TextColumn get description => text().nullable()();
  DateTimeColumn get eventDate => dateTime()();
  BoolColumn get isYearly =>
      boolean().withDefault(const Constant(false))();
  TextColumn get colorHex =>
      text().withDefault(const Constant('#8B5CF6'))(); // primary violet
  TextColumn get nodeId => text().nullable()(); // 연관 가족 노드 (선택)
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
