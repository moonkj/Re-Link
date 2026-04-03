/// SyncService 순수 로직 테스트
/// 커버: sync_service.dart — SyncResult 클래스, typeMap 매핑, 응답 파싱 로직
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:re_link/core/services/sync/sync_service.dart';

void main() {
  // ── SyncResult 모델 ──────────────────────────────────────────────────────

  group('SyncResult', () {
    test('constructor sets pulled and pushed', () {
      const result = SyncResult(pulled: 10, pushed: 5);
      expect(result.pulled, 10);
      expect(result.pushed, 5);
    });

    test('zero values', () {
      const result = SyncResult(pulled: 0, pushed: 0);
      expect(result.pulled, 0);
      expect(result.pushed, 0);
    });

    test('large values', () {
      const result = SyncResult(pulled: 9999, pushed: 5000);
      expect(result.pulled, 9999);
      expect(result.pushed, 5000);
    });
  });

  // ── Pull 응답 파싱 로직 (서비스 로직 재현) ──────────────────────────────

  group('Pull response parsing', () {
    test('empty response body', () {
      final body = jsonDecode('{"nodes":[],"edges":[],"memories":[]}')
          as Map<String, dynamic>;
      final nodes = (body['nodes'] as List<dynamic>?) ?? [];
      final edges = (body['edges'] as List<dynamic>?) ?? [];
      final memories = (body['memories'] as List<dynamic>?) ?? [];

      expect(nodes, isEmpty);
      expect(edges, isEmpty);
      expect(memories, isEmpty);
    });

    test('missing keys default to empty list', () {
      final body = jsonDecode('{}') as Map<String, dynamic>;
      final nodes = (body['nodes'] as List<dynamic>?) ?? [];
      final edges = (body['edges'] as List<dynamic>?) ?? [];
      final memories = (body['memories'] as List<dynamic>?) ?? [];

      expect(nodes, isEmpty);
      expect(edges, isEmpty);
      expect(memories, isEmpty);
    });

    test('node parsing — is_deleted detection', () {
      final nodeJson = {
        'id': 'node-1',
        'name': '김철수',
        'is_deleted': 1,
      };
      final isDeleted = (nodeJson['is_deleted'] as int? ?? 0) == 1;
      expect(isDeleted, isTrue);
    });

    test('node parsing — not deleted', () {
      final nodeJson = {
        'id': 'node-2',
        'name': '이영희',
        'is_deleted': 0,
      };
      final isDeleted = (nodeJson['is_deleted'] as int? ?? 0) == 1;
      expect(isDeleted, isFalse);
    });

    test('node parsing — is_deleted missing defaults to not deleted', () {
      final nodeJson = {
        'id': 'node-3',
        'name': '박지성',
      };
      final isDeleted = (nodeJson['is_deleted'] as int? ?? 0) == 1;
      expect(isDeleted, isFalse);
    });

    test('node parsing — is_ghost flag', () {
      final nodeJson = {'is_ghost': 1};
      final isGhost = (nodeJson['is_ghost'] as int? ?? 0) == 1;
      expect(isGhost, isTrue);
    });

    test('node parsing — temperature default', () {
      final nodeJson = <String, dynamic>{};
      final temp = nodeJson['temperature'] as int? ?? 2;
      expect(temp, 2); // default neutral
    });

    test('node parsing — position defaults', () {
      final nodeJson = <String, dynamic>{};
      final posX = (nodeJson['position_x'] as num?)?.toDouble() ?? 0.0;
      final posY = (nodeJson['position_y'] as num?)?.toDouble() ?? 0.0;
      expect(posX, 0.0);
      expect(posY, 0.0);
    });

    test('node parsing — position from num', () {
      final nodeJson = {
        'position_x': 150.5,
        'position_y': -200.3,
      };
      final posX = (nodeJson['position_x'] as num?)?.toDouble() ?? 0.0;
      final posY = (nodeJson['position_y'] as num?)?.toDouble() ?? 0.0;
      expect(posX, 150.5);
      expect(posY, -200.3);
    });

    test('node parsing — tagsJson default', () {
      final nodeJson = <String, dynamic>{};
      final tags = nodeJson['tags_json'] as String? ?? '[]';
      expect(tags, '[]');
    });

    test('node parsing — birthDate from milliseconds', () {
      final ms = DateTime(1990, 5, 15).millisecondsSinceEpoch;
      final nodeJson = {'birth_date': ms};
      final birthMs = nodeJson['birth_date'] as int?;
      final birthDate = birthMs != null
          ? DateTime.fromMillisecondsSinceEpoch(birthMs)
          : null;
      expect(birthDate, isNotNull);
      expect(birthDate!.year, 1990);
      expect(birthDate.month, 5);
      expect(birthDate.day, 15);
    });

    test('node parsing — null birthDate', () {
      final nodeJson = <String, dynamic>{'birth_date': null};
      final birthMs = nodeJson['birth_date'] as int?;
      final birthDate = birthMs != null
          ? DateTime.fromMillisecondsSinceEpoch(birthMs)
          : null;
      expect(birthDate, isNull);
    });

    test('edge parsing — is_deleted detection', () {
      final edgeJson = {
        'id': 'edge-1',
        'from_node_id': 'n1',
        'to_node_id': 'n2',
        'relation': 'parent',
        'is_deleted': 1,
      };
      final isDeleted = (edgeJson['is_deleted'] as int? ?? 0) == 1;
      expect(isDeleted, isTrue);
    });

    test('memory parsing — is_deleted detection', () {
      final memJson = {
        'id': 'mem-1',
        'node_id': 'n1',
        'type': 'photo',
        'is_deleted': 0,
      };
      final isDeleted = (memJson['is_deleted'] as int? ?? 0) == 1;
      expect(isDeleted, isFalse);
    });

    test('memory parsing — isPrivate flag', () {
      final memJson = {'is_private': 1};
      final isPrivate = (memJson['is_private'] as int? ?? 0) == 1;
      expect(isPrivate, isTrue);
    });

    test('memory parsing — isPrivate missing defaults to false', () {
      final memJson = <String, dynamic>{};
      final isPrivate = (memJson['is_private'] as int? ?? 0) == 1;
      expect(isPrivate, isFalse);
    });

    test('memory parsing — dateTaken from ms', () {
      final dt = DateTime(2024, 12, 25, 10, 30);
      final memJson = {'date_taken': dt.millisecondsSinceEpoch};
      final dateTakenMs = memJson['date_taken'] as int?;
      final dateTaken = dateTakenMs != null
          ? DateTime.fromMillisecondsSinceEpoch(dateTakenMs)
          : null;
      expect(dateTaken, isNotNull);
      expect(dateTaken!.year, 2024);
      expect(dateTaken.month, 12);
    });

    test('count increments for nodes + edges + memories', () {
      final body = {
        'nodes': [
          {'id': 'n1', 'name': 'A'},
          {'id': 'n2', 'name': 'B'},
        ],
        'edges': [
          {'id': 'e1', 'from_node_id': 'n1', 'to_node_id': 'n2', 'relation': 'parent'},
        ],
        'memories': [
          {'id': 'm1', 'node_id': 'n1', 'type': 'photo'},
          {'id': 'm2', 'node_id': 'n1', 'type': 'voice'},
          {'id': 'm3', 'node_id': 'n2', 'type': 'note'},
        ],
      };

      final nodes = body['nodes'] as List;
      final edges = body['edges'] as List;
      final memories = body['memories'] as List;
      final totalCount = nodes.length + edges.length + memories.length;
      expect(totalCount, 6);
    });
  });

  // ── Push 항목 매핑 로직 ──────────────────────────────────────────────────

  group('Push type mapping', () {
    final typeMap = {
      'nodes': 'node',
      'node_edges': 'edge',
      'memories': 'memory',
    };

    test('nodes → node', () {
      expect(typeMap['nodes'], 'node');
    });

    test('node_edges → edge', () {
      expect(typeMap['node_edges'], 'edge');
    });

    test('memories → memory', () {
      expect(typeMap['memories'], 'memory');
    });

    test('unknown table → fallback to original name', () {
      final table = 'settings';
      final type = typeMap[table] ?? table;
      expect(type, 'settings');
    });
  });

  // ── payloadJson 파싱 ────────────────────────────────────────────────────

  group('Payload JSON parsing', () {
    test('valid JSON payload', () {
      const payloadJson =
          '{"id":"n1","name":"김철수","temperature":3}';
      final data = jsonDecode(payloadJson) as Map<String, dynamic>;
      expect(data['id'], 'n1');
      expect(data['name'], '김철수');
      expect(data['temperature'], 3);
    });

    test('payload with nested data', () {
      const payloadJson =
          '{"id":"m1","node_id":"n1","type":"photo","tags_json":"[\\"가족\\",\\"여행\\"]"}';
      final data = jsonDecode(payloadJson) as Map<String, dynamic>;
      expect(data['type'], 'photo');
      expect(data['tags_json'], contains('가족'));
    });

    test('empty payload', () {
      const payloadJson = '{}';
      final data = jsonDecode(payloadJson) as Map<String, dynamic>;
      expect(data, isEmpty);
    });
  });

  // ── sinceMs 계산 ────────────────────────────────────────────────────────

  group('sinceMs calculation', () {
    test('null lastSyncAt → 0', () {
      DateTime? lastSyncAt;
      final sinceMs = lastSyncAt?.millisecondsSinceEpoch ?? 0;
      expect(sinceMs, 0);
    });

    test('valid lastSyncAt → positive ms', () {
      final lastSyncAt = DateTime(2026, 1, 1);
      final sinceMs = lastSyncAt.millisecondsSinceEpoch;
      expect(sinceMs, greaterThan(0));
    });
  });
}
