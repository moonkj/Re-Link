import 'package:flutter_test/flutter_test.dart';
import 'package:re_link/core/database/app_database.dart';

void main() {
  group('CapsulesTableData creation', () {
    test('required fields are set correctly', () {
      final now = DateTime(2026, 3, 21);
      final openDate = DateTime(2026, 6, 1);
      final capsule = CapsulesTableData(
        id: 'cap-001',
        title: '졸업 기념 캡슐',
        openDate: openDate,
        isOpened: false,
        createdAt: now,
      );

      expect(capsule.id, 'cap-001');
      expect(capsule.title, '졸업 기념 캡슐');
      expect(capsule.openDate, openDate);
      expect(capsule.isOpened, false);
      expect(capsule.createdAt, now);
    });

    test('nullable fields default to null', () {
      final capsule = CapsulesTableData(
        id: 'cap-002',
        title: '테스트 캡슐',
        openDate: DateTime(2026, 12, 25),
        isOpened: false,
        createdAt: DateTime(2026, 3, 21),
      );

      expect(capsule.message, isNull);
      expect(capsule.openedAt, isNull);
    });

    test('message can be set', () {
      final capsule = CapsulesTableData(
        id: 'cap-003',
        title: '메시지 있는 캡슐',
        message: '1년 뒤에 열어보세요!',
        openDate: DateTime(2027, 3, 21),
        isOpened: false,
        createdAt: DateTime(2026, 3, 21),
      );

      expect(capsule.message, '1년 뒤에 열어보세요!');
    });

    test('opened capsule has isOpened true and openedAt set', () {
      final openedAt = DateTime(2026, 6, 1, 10, 30);
      final capsule = CapsulesTableData(
        id: 'cap-004',
        title: '열린 캡슐',
        openDate: DateTime(2026, 6, 1),
        isOpened: true,
        openedAt: openedAt,
        createdAt: DateTime(2026, 1, 1),
      );

      expect(capsule.isOpened, true);
      expect(capsule.openedAt, openedAt);
    });
  });

  group('CapsulesTableData copyWith', () {
    final original = CapsulesTableData(
      id: 'cap-010',
      title: '원본 캡슐',
      openDate: DateTime(2026, 12, 25),
      isOpened: false,
      createdAt: DateTime(2026, 3, 21),
    );

    test('copyWith preserves fields when not overridden', () {
      final copy = original.copyWith();

      expect(copy.id, original.id);
      expect(copy.title, original.title);
      expect(copy.openDate, original.openDate);
      expect(copy.isOpened, original.isOpened);
      expect(copy.createdAt, original.createdAt);
    });

    test('copyWith changes isOpened', () {
      final opened = original.copyWith(isOpened: true);

      expect(opened.isOpened, true);
      expect(opened.id, original.id);
      expect(opened.title, original.title);
    });

    test('copyWith changes title', () {
      final renamed = original.copyWith(title: '수정된 캡슐');

      expect(renamed.title, '수정된 캡슐');
      expect(renamed.id, original.id);
    });
  });

  group('CapsuleItemsTableData', () {
    test('creation with all required fields', () {
      final item = CapsuleItemsTableData(
        id: 'ci-001',
        capsuleId: 'cap-001',
        memoryId: 'mem-100',
      );

      expect(item.id, 'ci-001');
      expect(item.capsuleId, 'cap-001');
      expect(item.memoryId, 'mem-100');
    });

    test('multiple items can reference same capsuleId', () {
      final items = [
        const CapsuleItemsTableData(
          id: 'ci-001',
          capsuleId: 'cap-001',
          memoryId: 'mem-100',
        ),
        const CapsuleItemsTableData(
          id: 'ci-002',
          capsuleId: 'cap-001',
          memoryId: 'mem-101',
        ),
        const CapsuleItemsTableData(
          id: 'ci-003',
          capsuleId: 'cap-001',
          memoryId: 'mem-102',
        ),
      ];

      final capsuleIds = items.map((i) => i.capsuleId).toSet();
      expect(capsuleIds.length, 1);
      expect(capsuleIds.first, 'cap-001');

      final memoryIds = items.map((i) => i.memoryId).toList();
      expect(memoryIds, ['mem-100', 'mem-101', 'mem-102']);
    });

    test('each item has unique id', () {
      final items = [
        const CapsuleItemsTableData(
          id: 'ci-001',
          capsuleId: 'cap-001',
          memoryId: 'mem-100',
        ),
        const CapsuleItemsTableData(
          id: 'ci-002',
          capsuleId: 'cap-001',
          memoryId: 'mem-101',
        ),
      ];

      final ids = items.map((i) => i.id).toSet();
      expect(ids.length, items.length);
    });
  });

  group('CapsulesTableData JSON serialization', () {
    test('toJson produces correct keys', () {
      final capsule = CapsulesTableData(
        id: 'cap-json-1',
        title: 'JSON 테스트',
        message: '메시지',
        openDate: DateTime(2026, 6, 1),
        isOpened: false,
        createdAt: DateTime(2026, 3, 21),
      );

      final json = capsule.toJson();
      expect(json.containsKey('id'), true);
      expect(json.containsKey('title'), true);
      expect(json.containsKey('message'), true);
      expect(json.containsKey('openDate'), true);
      expect(json.containsKey('isOpened'), true);
      expect(json.containsKey('createdAt'), true);
    });

    test('toJson round-trips via fromJson', () {
      final original = CapsulesTableData(
        id: 'cap-rt-1',
        title: '왕복 테스트',
        openDate: DateTime(2026, 6, 1),
        isOpened: true,
        openedAt: DateTime(2026, 6, 1, 12, 0),
        createdAt: DateTime(2026, 3, 21),
      );

      final json = original.toJson();
      final restored = CapsulesTableData.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.title, original.title);
      expect(restored.openDate, original.openDate);
      expect(restored.isOpened, original.isOpened);
      expect(restored.openedAt, original.openedAt);
      expect(restored.createdAt, original.createdAt);
    });

    test('fromJson handles null message', () {
      final json = {
        'id': 'cap-null',
        'title': '널 메시지',
        'message': null,
        'openDate': DateTime(2026, 6, 1).toIso8601String(),
        'isOpened': false,
        'openedAt': null,
        'createdAt': DateTime(2026, 3, 21).toIso8601String(),
      };

      final capsule = CapsulesTableData.fromJson(json);
      expect(capsule.message, isNull);
      expect(capsule.openedAt, isNull);
    });
  });

  group('CapsulesTableData equality', () {
    test('two capsules with same fields are equal', () {
      final a = CapsulesTableData(
        id: 'cap-eq',
        title: '동일 캡슐',
        openDate: DateTime(2026, 6, 1),
        isOpened: false,
        createdAt: DateTime(2026, 3, 21),
      );
      final b = CapsulesTableData(
        id: 'cap-eq',
        title: '동일 캡슐',
        openDate: DateTime(2026, 6, 1),
        isOpened: false,
        createdAt: DateTime(2026, 3, 21),
      );

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('two capsules with different ids are not equal', () {
      final a = CapsulesTableData(
        id: 'cap-a',
        title: '같은 제목',
        openDate: DateTime(2026, 6, 1),
        isOpened: false,
        createdAt: DateTime(2026, 3, 21),
      );
      final b = CapsulesTableData(
        id: 'cap-b',
        title: '같은 제목',
        openDate: DateTime(2026, 6, 1),
        isOpened: false,
        createdAt: DateTime(2026, 3, 21),
      );

      expect(a, isNot(equals(b)));
    });
  });
}
