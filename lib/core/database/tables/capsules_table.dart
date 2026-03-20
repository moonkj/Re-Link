import 'package:drift/drift.dart';

/// 기억 캡슐 (Memory Capsule) 테이블
class CapsulesTable extends Table {
  @override
  String get tableName => 'capsules';

  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get message => text().nullable()();
  DateTimeColumn get openDate => dateTime()();
  BoolColumn get isOpened => boolean().withDefault(const Constant(false))();
  DateTimeColumn get openedAt => dateTime().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// 캡슐 아이템 (캡슐에 포함된 기억) 테이블
class CapsuleItemsTable extends Table {
  @override
  String get tableName => 'capsule_items';

  TextColumn get id => text()();
  TextColumn get capsuleId => text()();
  TextColumn get memoryId => text()();

  @override
  Set<Column> get primaryKey => {id};
}
