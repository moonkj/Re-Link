import 'package:drift/drift.dart';

/// 온도 일기 로그 테이블
class TemperatureLogsTable extends Table {
  @override
  String get tableName => 'temperature_logs';

  TextColumn get id => text()();
  TextColumn get nodeId => text()();
  IntColumn get temperature => integer()(); // 0-5
  TextColumn get emotionTag => text().nullable()(); // joy/longing/surprise/love/sadness
  DateTimeColumn get date => dateTime()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
