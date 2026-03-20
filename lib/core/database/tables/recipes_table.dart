import 'package:drift/drift.dart';

/// 가족 레시피 북 (Family Recipe Book) 테이블
class RecipesTable extends Table {
  @override
  String get tableName => 'recipes';

  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get ingredients => text()(); // newline-separated
  TextColumn get instructions => text()(); // newline-separated steps
  TextColumn get photoPath => text().nullable()();
  TextColumn get nodeId => text().nullable()(); // linked family member
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
