import 'package:drift/drift.dart';

/// 가족 지도 — 노드별 위치 기록 테이블
class NodeLocationsTable extends Table {
  @override
  String get tableName => 'node_locations';

  TextColumn get id => text()();
  TextColumn get nodeId => text()();
  TextColumn get address => text()(); // display name: "서울 종로구" etc.
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  IntColumn get startYear => integer().nullable()();
  IntColumn get endYear => integer().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
