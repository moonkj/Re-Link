import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:re_link/core/database/app_database.dart';
import 'package:re_link/features/capsule/widgets/capsule_card.dart';

/// 캡슐 열림 가능 여부 판정 로직을 순수 데이터로 테스트.
///
/// CapsuleCard 에서 사용하는 CapsuleState 열거형 판정:
///   - opened  : isOpened == true
///   - openable: openDate <= now && !isOpened
///   - locked  : openDate > now && !isOpened
///
/// 여기서는 위젯 없이 동일한 판정 함수를 순수 함수로 재구현하여 테스트한다.
CapsuleState determineCapsuleState(CapsulesTableData capsule,
    {DateTime? now}) {
  final reference = now ?? DateTime.now();
  if (capsule.isOpened) return CapsuleState.opened;
  if (!capsule.openDate.isAfter(reference)) return CapsuleState.openable;
  return CapsuleState.locked;
}

void main() {
  group('Capsule open logic — past openDate', () {
    test('past openDate + not opened => openable', () {
      final capsule = CapsulesTableData(
        id: 'cap-past',
        title: '과거 캡슐',
        openDate: DateTime(2025, 1, 1),
        isOpened: false,
        createdAt: DateTime(2024, 12, 1),
      );

      final state = determineCapsuleState(capsule,
          now: DateTime(2026, 3, 21));
      expect(state, CapsuleState.openable);
    });

    test('past openDate + already opened => opened', () {
      final capsule = CapsulesTableData(
        id: 'cap-past-opened',
        title: '이미 열린 과거 캡슐',
        openDate: DateTime(2025, 1, 1),
        isOpened: true,
        openedAt: DateTime(2025, 1, 2),
        createdAt: DateTime(2024, 12, 1),
      );

      final state = determineCapsuleState(capsule,
          now: DateTime(2026, 3, 21));
      expect(state, CapsuleState.opened);
    });
  });

  group('Capsule open logic — future openDate', () {
    test('future openDate + not opened => locked', () {
      final capsule = CapsulesTableData(
        id: 'cap-future',
        title: '미래 캡슐',
        openDate: DateTime(2027, 12, 25),
        isOpened: false,
        createdAt: DateTime(2026, 3, 21),
      );

      final state = determineCapsuleState(capsule,
          now: DateTime(2026, 3, 21));
      expect(state, CapsuleState.locked);
    });

    test('future openDate + forced opened => opened (edge case)', () {
      // isOpened가 true면 openDate 무관하게 opened
      final capsule = CapsulesTableData(
        id: 'cap-future-forced',
        title: '강제 열린 미래 캡슐',
        openDate: DateTime(2027, 12, 25),
        isOpened: true,
        openedAt: DateTime(2026, 3, 21),
        createdAt: DateTime(2026, 3, 21),
      );

      final state = determineCapsuleState(capsule,
          now: DateTime(2026, 3, 21));
      expect(state, CapsuleState.opened);
    });
  });

  group('Capsule open logic — boundary: today', () {
    test('openDate equals now exactly => openable', () {
      final exactNow = DateTime(2026, 3, 21, 12, 0, 0);
      final capsule = CapsulesTableData(
        id: 'cap-exact',
        title: '정확히 지금 캡슐',
        openDate: exactNow,
        isOpened: false,
        createdAt: DateTime(2026, 1, 1),
      );

      final state = determineCapsuleState(capsule, now: exactNow);
      expect(state, CapsuleState.openable);
    });

    test('openDate one second after now => locked', () {
      final now = DateTime(2026, 3, 21, 12, 0, 0);
      final capsule = CapsulesTableData(
        id: 'cap-1sec',
        title: '1초 후 캡슐',
        openDate: DateTime(2026, 3, 21, 12, 0, 1),
        isOpened: false,
        createdAt: DateTime(2026, 1, 1),
      );

      final state = determineCapsuleState(capsule, now: now);
      expect(state, CapsuleState.locked);
    });

    test('openDate one second before now => openable', () {
      final now = DateTime(2026, 3, 21, 12, 0, 1);
      final capsule = CapsulesTableData(
        id: 'cap-1sec-before',
        title: '1초 전 캡슐',
        openDate: DateTime(2026, 3, 21, 12, 0, 0),
        isOpened: false,
        createdAt: DateTime(2026, 1, 1),
      );

      final state = determineCapsuleState(capsule, now: now);
      expect(state, CapsuleState.openable);
    });
  });

  group('Capsule open logic — re-open prevention', () {
    test('already opened capsule cannot be re-opened (state stays opened)', () {
      final capsule = CapsulesTableData(
        id: 'cap-reopen',
        title: '재열림 방지 캡슐',
        openDate: DateTime(2025, 6, 1),
        isOpened: true,
        openedAt: DateTime(2025, 6, 1, 10, 0),
        createdAt: DateTime(2025, 1, 1),
      );

      // 과거 어느 시점에서든 opened로 유지
      final state1 = determineCapsuleState(capsule,
          now: DateTime(2025, 6, 1));
      final state2 = determineCapsuleState(capsule,
          now: DateTime(2026, 12, 31));
      final state3 = determineCapsuleState(capsule,
          now: DateTime(2024, 1, 1)); // openDate 이전 시점

      expect(state1, CapsuleState.opened);
      expect(state2, CapsuleState.opened);
      expect(state3, CapsuleState.opened);
    });
  });

  group('CapsuleState enum values', () {
    test('enum has exactly 3 values', () {
      expect(CapsuleState.values.length, 3);
    });

    test('enum values are locked, openable, opened', () {
      expect(CapsuleState.values, contains(CapsuleState.locked));
      expect(CapsuleState.values, contains(CapsuleState.openable));
      expect(CapsuleState.values, contains(CapsuleState.opened));
    });
  });

  group('Capsule state transitions', () {
    test('locked -> openable via copyWith isOpened stays false, openDate passes', () {
      final now = DateTime(2026, 3, 21);
      final capsule = CapsulesTableData(
        id: 'cap-transition',
        title: '전환 테스트',
        openDate: DateTime(2026, 3, 22), // 내일
        isOpened: false,
        createdAt: DateTime(2026, 1, 1),
      );

      // 오늘: locked
      expect(determineCapsuleState(capsule, now: now), CapsuleState.locked);

      // 내일: openable (같은 캡슐, 시간만 다름)
      final tomorrow = DateTime(2026, 3, 22);
      expect(
          determineCapsuleState(capsule, now: tomorrow), CapsuleState.openable);
    });

    test('openable -> opened via copyWith isOpened=true', () {
      final now = DateTime(2026, 3, 21);
      final capsule = CapsulesTableData(
        id: 'cap-open-transition',
        title: '열림 전환',
        openDate: DateTime(2026, 3, 20), // 어제
        isOpened: false,
        createdAt: DateTime(2026, 1, 1),
      );

      expect(
          determineCapsuleState(capsule, now: now), CapsuleState.openable);

      // 열림 처리
      final openedCapsule = capsule.copyWith(
        isOpened: true,
        openedAt: Value(now),
      );

      expect(
          determineCapsuleState(openedCapsule, now: now), CapsuleState.opened);
    });
  });
}
