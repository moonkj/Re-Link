import 'package:drift/drift.dart';

/// 내 프로필 (단일 row, id = 1 고정)
class ProfileTable extends Table {
  @override
  String get tableName => 'profile';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 50)();
  TextColumn get nickname => text().nullable()();
  TextColumn get photoPath => text().nullable()(); // 로컬 파일 경로
  DateTimeColumn get birthDate => dateTime().nullable()();
  TextColumn get bio => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
