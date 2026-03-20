import 'package:drift/drift.dart';

/// Then & Now 비교 페어 테이블
class ThenNowTable extends Table {
  @override
  String get tableName => 'then_now';

  TextColumn get id => text()(); // UUID
  TextColumn get memoryId1 => text()(); // 과거 사진 memory ID
  TextColumn get memoryId2 => text()(); // 현재 사진 memory ID
  TextColumn get label => text().nullable()(); // 사용자 라벨 (예: "우리집 앞")
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
