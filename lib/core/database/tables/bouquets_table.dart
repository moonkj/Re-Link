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

  /// 수신자가 확인했는지 여부 (읽음 처리)
  BoolColumn get isRead => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
