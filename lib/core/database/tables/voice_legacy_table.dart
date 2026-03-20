import 'package:drift/drift.dart';

/// 보이스 유언 (Voice Legacy) 테이블
/// 특정 가족 구성원에게 전하는 봉인된 음성 메시지
class VoiceLegacyTable extends Table {
  @override
  String get tableName => 'voice_legacy';

  TextColumn get id => text()();
  TextColumn get fromNodeId => text()(); // 녹음자 (보낸 사람)
  TextColumn get toNodeId => text()();   // 수신자 (받을 사람)
  TextColumn get title => text()();
  TextColumn get voicePath => text()();
  IntColumn get durationSeconds =>
      integer().withDefault(const Constant(0))();
  TextColumn get openCondition =>
      text().withDefault(const Constant('date'))(); // 'date' or 'manual'
  DateTimeColumn get openDate => dateTime().nullable()();
  BoolColumn get isOpened =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get openedAt => dateTime().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
