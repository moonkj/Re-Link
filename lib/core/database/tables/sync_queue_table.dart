import 'package:drift/drift.dart';

/// 서버로 전송 대기 중인 로컬 변경 사항 큐
@DataClassName('SyncQueueEntry')
class SyncQueueTable extends Table {
  TextColumn get id => text()();                         // UUID
  TextColumn get targetTable => text()();                // 'nodes' | 'edges' | 'memories'
  TextColumn get recordId => text()();                   // 대상 레코드 UUID
  TextColumn get operation => text()();                  // 'upsert' | 'delete'
  TextColumn get payloadJson => text()();                // JSON 직렬화된 변경 데이터
  IntColumn get createdAtMs => integer()();              // Unix ms
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}
