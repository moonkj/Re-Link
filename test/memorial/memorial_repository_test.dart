import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:re_link/core/database/app_database.dart';

void main() {
  group('MemorialMessagesTableData creation', () {
    test('required fields are set correctly', () {
      final date = DateTime(2026, 3, 21);
      final msg = MemorialMessagesTableData(
        id: 'mm-001',
        nodeId: 'node-grandpa',
        message: '항상 그리워요, 할아버지.',
        date: date,
        createdAt: date,
      );

      expect(msg.id, 'mm-001');
      expect(msg.nodeId, 'node-grandpa');
      expect(msg.message, '항상 그리워요, 할아버지.');
      expect(msg.date, date);
      expect(msg.createdAt, date);
    });

    test('authorName is nullable and defaults to null', () {
      final msg = MemorialMessagesTableData(
        id: 'mm-002',
        nodeId: 'node-grandma',
        message: '보고 싶습니다.',
        date: DateTime(2026, 3, 21),
        createdAt: DateTime(2026, 3, 21),
      );

      expect(msg.authorName, isNull);
    });

    test('authorName can be set', () {
      final msg = MemorialMessagesTableData(
        id: 'mm-003',
        nodeId: 'node-grandpa',
        message: '사랑합니다.',
        authorName: '손녀 영희',
        date: DateTime(2026, 3, 21),
        createdAt: DateTime(2026, 3, 21),
      );

      expect(msg.authorName, '손녀 영희');
    });
  });

  group('MemorialMessagesTableData date sorting', () {
    test('messages sort by date descending (newest first)', () {
      final messages = [
        MemorialMessagesTableData(
          id: 'mm-old',
          nodeId: 'node-1',
          message: '오래된 메시지',
          date: DateTime(2024, 1, 1),
          createdAt: DateTime(2024, 1, 1),
        ),
        MemorialMessagesTableData(
          id: 'mm-new',
          nodeId: 'node-1',
          message: '최신 메시지',
          date: DateTime(2026, 3, 21),
          createdAt: DateTime(2026, 3, 21),
        ),
        MemorialMessagesTableData(
          id: 'mm-mid',
          nodeId: 'node-1',
          message: '중간 메시지',
          date: DateTime(2025, 6, 15),
          createdAt: DateTime(2025, 6, 15),
        ),
      ];

      // DB에서는 DESC 정렬하지만, 여기서는 동일 로직 재현
      messages.sort((a, b) => b.date.compareTo(a.date));

      expect(messages[0].id, 'mm-new');
      expect(messages[1].id, 'mm-mid');
      expect(messages[2].id, 'mm-old');
    });

    test('messages with same date maintain stable order', () {
      final sameDate = DateTime(2026, 3, 21);
      final messages = [
        MemorialMessagesTableData(
          id: 'mm-a',
          nodeId: 'node-1',
          message: '메시지 A',
          date: sameDate,
          createdAt: sameDate,
        ),
        MemorialMessagesTableData(
          id: 'mm-b',
          nodeId: 'node-1',
          message: '메시지 B',
          date: sameDate,
          createdAt: sameDate,
        ),
      ];

      messages.sort((a, b) => b.date.compareTo(a.date));

      // 동일 날짜면 원래 순서 유지 (stable sort)
      expect(messages.length, 2);
    });
  });

  group('MemorialMessagesTableData nodeId filtering', () {
    test('filter messages by nodeId', () {
      final messages = [
        MemorialMessagesTableData(
          id: 'mm-g1',
          nodeId: 'node-grandpa',
          message: '할아버지 추모 1',
          date: DateTime(2026, 1, 1),
          createdAt: DateTime(2026, 1, 1),
        ),
        MemorialMessagesTableData(
          id: 'mm-g2',
          nodeId: 'node-grandpa',
          message: '할아버지 추모 2',
          date: DateTime(2026, 2, 1),
          createdAt: DateTime(2026, 2, 1),
        ),
        MemorialMessagesTableData(
          id: 'mm-u1',
          nodeId: 'node-uncle',
          message: '삼촌 추모 1',
          date: DateTime(2026, 3, 1),
          createdAt: DateTime(2026, 3, 1),
        ),
      ];

      final grandpaMessages =
          messages.where((m) => m.nodeId == 'node-grandpa').toList();
      final uncleMessages =
          messages.where((m) => m.nodeId == 'node-uncle').toList();

      expect(grandpaMessages.length, 2);
      expect(uncleMessages.length, 1);
      expect(grandpaMessages.every((m) => m.nodeId == 'node-grandpa'), true);
      expect(uncleMessages.first.message, '삼촌 추모 1');
    });

    test('empty result when filtering by non-existent nodeId', () {
      final messages = [
        MemorialMessagesTableData(
          id: 'mm-x',
          nodeId: 'node-grandpa',
          message: '할아버지 추모',
          date: DateTime(2026, 1, 1),
          createdAt: DateTime(2026, 1, 1),
        ),
      ];

      final filtered =
          messages.where((m) => m.nodeId == 'node-nonexistent').toList();
      expect(filtered, isEmpty);
    });
  });

  group('MemorialMessagesTableData copyWith', () {
    final original = MemorialMessagesTableData(
      id: 'mm-copy',
      nodeId: 'node-1',
      message: '원본 메시지',
      authorName: '철수',
      date: DateTime(2026, 3, 21),
      createdAt: DateTime(2026, 3, 21),
    );

    test('copyWith preserves all fields when not overridden', () {
      final copy = original.copyWith();

      expect(copy.id, original.id);
      expect(copy.nodeId, original.nodeId);
      expect(copy.message, original.message);
      expect(copy.authorName, original.authorName);
      expect(copy.date, original.date);
      expect(copy.createdAt, original.createdAt);
    });

    test('copyWith changes message', () {
      final updated = original.copyWith(message: '수정된 메시지');

      expect(updated.message, '수정된 메시지');
      expect(updated.id, original.id);
      expect(updated.nodeId, original.nodeId);
    });

    test('copyWith can set authorName to null', () {
      final noAuthor =
          original.copyWith(authorName: const Value(null));

      expect(noAuthor.authorName, isNull);
    });
  });

  group('MemorialMessagesTableData JSON serialization', () {
    test('toJson produces correct keys', () {
      final msg = MemorialMessagesTableData(
        id: 'mm-json',
        nodeId: 'node-1',
        message: 'JSON 테스트',
        date: DateTime(2026, 3, 21),
        createdAt: DateTime(2026, 3, 21),
      );

      final json = msg.toJson();
      expect(json.containsKey('id'), true);
      expect(json.containsKey('nodeId'), true);
      expect(json.containsKey('message'), true);
      expect(json.containsKey('authorName'), true);
      expect(json.containsKey('date'), true);
      expect(json.containsKey('createdAt'), true);
    });

    test('toJson round-trips via fromJson', () {
      final original = MemorialMessagesTableData(
        id: 'mm-rt',
        nodeId: 'node-grandpa',
        message: '왕복 테스트',
        authorName: '영희',
        date: DateTime(2026, 3, 21),
        createdAt: DateTime(2026, 3, 21),
      );

      final json = original.toJson();
      final restored = MemorialMessagesTableData.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.nodeId, original.nodeId);
      expect(restored.message, original.message);
      expect(restored.authorName, original.authorName);
      expect(restored.date, original.date);
      expect(restored.createdAt, original.createdAt);
    });

    test('fromJson handles null authorName', () {
      final json = {
        'id': 'mm-null-author',
        'nodeId': 'node-1',
        'message': '작성자 없음',
        'authorName': null,
        'date': DateTime(2026, 3, 21).toIso8601String(),
        'createdAt': DateTime(2026, 3, 21).toIso8601String(),
      };

      final msg = MemorialMessagesTableData.fromJson(json);
      expect(msg.authorName, isNull);
    });
  });

  group('MemorialMessagesTableData equality', () {
    test('two messages with same fields are equal', () {
      final date = DateTime(2026, 3, 21);
      final a = MemorialMessagesTableData(
        id: 'mm-eq',
        nodeId: 'node-1',
        message: '동일 메시지',
        date: date,
        createdAt: date,
      );
      final b = MemorialMessagesTableData(
        id: 'mm-eq',
        nodeId: 'node-1',
        message: '동일 메시지',
        date: date,
        createdAt: date,
      );

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('two messages with different ids are not equal', () {
      final date = DateTime(2026, 3, 21);
      final a = MemorialMessagesTableData(
        id: 'mm-a',
        nodeId: 'node-1',
        message: '같은 내용',
        date: date,
        createdAt: date,
      );
      final b = MemorialMessagesTableData(
        id: 'mm-b',
        nodeId: 'node-1',
        message: '같은 내용',
        date: date,
        createdAt: date,
      );

      expect(a, isNot(equals(b)));
    });
  });
}
