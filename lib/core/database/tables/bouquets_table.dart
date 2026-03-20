import 'package:drift/drift.dart';

/// Memory Bouquet (꽃 보내기) 테이블
class BouquetsTable extends Table {
  @override
  String get tableName => 'bouquets';

  TextColumn get id => text()();
  TextColumn get fromNodeId => text()();
  TextColumn get toNodeId => text()();
  TextColumn get flowerType =>
      text()(); // rose/tulip/sunflower/lily/cherry_blossom
  DateTimeColumn get date => dateTime()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
