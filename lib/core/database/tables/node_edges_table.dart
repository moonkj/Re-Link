import 'package:drift/drift.dart';
import 'nodes_table.dart';

/// 노드 간 관계 (Adjacency List)
class NodeEdgesTable extends Table {
  @override
  String get tableName => 'node_edges';

  TextColumn get id => text()(); // UUID
  TextColumn get fromNodeId =>
      text().references(NodesTable, #id, onDelete: KeyAction.cascade)();
  TextColumn get toNodeId =>
      text().references(NodesTable, #id, onDelete: KeyAction.cascade)();

  /// 관계 타입: parent, child, spouse, sibling, other
  TextColumn get relation => text()();

  TextColumn get label => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
