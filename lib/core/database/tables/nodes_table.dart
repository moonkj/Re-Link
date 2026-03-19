import 'package:drift/drift.dart';

/// 인물 노드
class NodesTable extends Table {
  @override
  String get tableName => 'nodes';

  TextColumn get id => text()(); // UUID
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get nickname => text().nullable()();
  TextColumn get photoPath => text().nullable()(); // 로컬 파일 경로
  TextColumn get bio => text().nullable()();
  DateTimeColumn get birthDate => dateTime().nullable()();
  DateTimeColumn get deathDate => dateTime().nullable()();

  /// Ghost Node: 실제 인물 미확인 조상
  BoolColumn get isGhost => boolean().withDefault(const Constant(false))();

  /// 온도 레벨 0(icy) ~ 5(fire), 기본 2(neutral)
  IntColumn get temperature => integer().withDefault(const Constant(2))();

  /// 캔버스 좌표
  RealColumn get positionX => real().withDefault(const Constant(0.0))();
  RealColumn get positionY => real().withDefault(const Constant(0.0))();

  /// 태그 (JSON 배열 문자열)
  TextColumn get tagsJson => text().withDefault(const Constant('[]'))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
