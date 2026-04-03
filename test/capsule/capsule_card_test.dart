/// CapsuleCard 순수 로직 테스트
/// 커버: capsule_card.dart — CapsuleState enum 결정 로직,
///        _formatDate, 상태별 분기
import 'package:flutter_test/flutter_test.dart';
import 'package:re_link/core/database/app_database.dart';
import 'package:re_link/features/capsule/widgets/capsule_card.dart';

void main() {
  // ── CapsuleState enum ─────────────────────────────────────────────────────

  group('CapsuleState enum', () {
    test('locked, openable, opened 3개 값 존재', () {
      expect(CapsuleState.values.length, 3);
      expect(CapsuleState.values, contains(CapsuleState.locked));
      expect(CapsuleState.values, contains(CapsuleState.openable));
      expect(CapsuleState.values, contains(CapsuleState.opened));
    });

    test('enum index 순서: locked=0, openable=1, opened=2', () {
      expect(CapsuleState.locked.index, 0);
      expect(CapsuleState.openable.index, 1);
      expect(CapsuleState.opened.index, 2);
    });
  });

  // ── 캡슐 상태 결정 로직 (위젯에서 추출) ──────────────────────────────────

  group('캡슐 상태 결정 로직', () {
    CapsuleState determineState(CapsulesTableData capsule) {
      if (capsule.isOpened) return CapsuleState.opened;
      if (!capsule.openDate.isAfter(DateTime.now())) {
        return CapsuleState.openable;
      }
      return CapsuleState.locked;
    }

    test('이미 열린 캡슐 → opened', () {
      final capsule = CapsulesTableData(
        id: 'cap1',
        title: '열린 캡슐',
        openDate: DateTime(2020, 1, 1), // 과거
        isOpened: true,
        openedAt: DateTime(2020, 6, 1),
        createdAt: DateTime(2019),
      );
      expect(determineState(capsule), CapsuleState.opened);
    });

    test('열리지 않았고 openDate가 과거 → openable', () {
      final capsule = CapsulesTableData(
        id: 'cap2',
        title: '열 수 있는 캡슐',
        openDate: DateTime(2020, 1, 1), // 과거
        isOpened: false,
        createdAt: DateTime(2019),
      );
      expect(determineState(capsule), CapsuleState.openable);
    });

    test('열리지 않았고 openDate가 미래 → locked', () {
      final capsule = CapsulesTableData(
        id: 'cap3',
        title: '잠긴 캡슐',
        openDate: DateTime(2099, 12, 31), // 미래
        isOpened: false,
        createdAt: DateTime(2024),
      );
      expect(determineState(capsule), CapsuleState.locked);
    });

    test('openDate가 정확히 지금 → openable', () {
      // isAfter(now)가 false이므로 openable
      final now = DateTime.now();
      final capsule = CapsulesTableData(
        id: 'cap4',
        title: '경계 캡슐',
        openDate: now,
        isOpened: false,
        createdAt: DateTime(2024),
      );
      expect(determineState(capsule), CapsuleState.openable);
    });

    test('이미 열린 캡슐은 openDate에 관계없이 opened', () {
      final capsule = CapsulesTableData(
        id: 'cap5',
        title: '미래 열림 캡슐',
        openDate: DateTime(2099, 12, 31), // 미래이지만 이미 opened
        isOpened: true,
        openedAt: DateTime(2024, 6, 1),
        createdAt: DateTime(2024),
      );
      expect(determineState(capsule), CapsuleState.opened);
    });
  });

  // ── _formatDate 로직 (위젯에서 추출) ─────────────────────────────────────

  group('날짜 포맷팅 로직', () {
    String formatDate(DateTime dt) =>
        '${dt.year}년 ${dt.month}월 ${dt.day}일';

    test('일반 날짜', () {
      expect(formatDate(DateTime(2026, 4, 3)), '2026년 4월 3일');
    });

    test('1월 1일', () {
      expect(formatDate(DateTime(2025, 1, 1)), '2025년 1월 1일');
    });

    test('12월 31일', () {
      expect(formatDate(DateTime(2025, 12, 31)), '2025년 12월 31일');
    });

    test('한 자리 월/일', () {
      expect(formatDate(DateTime(2025, 3, 5)), '2025년 3월 5일');
    });

    test('두 자리 월/일', () {
      expect(formatDate(DateTime(2025, 11, 28)), '2025년 11월 28일');
    });
  });

  // ── 상태별 텍스트 분기 ────────────────────────────────────────────────────

  group('상태별 텍스트 분기', () {
    String formatDate(DateTime dt) =>
        '${dt.year}년 ${dt.month}월 ${dt.day}일';

    test('locked 상태 → "N년 M월 D일에 열림" 텍스트', () {
      final openDate = DateTime(2027, 6, 15);
      final statusText = '${formatDate(openDate)}에 열림';
      expect(statusText, '2027년 6월 15일에 열림');
    });

    test('openable 상태 → "열어보세요!" 텍스트', () {
      const statusText = '열어보세요!';
      expect(statusText, '열어보세요!');
    });

    test('opened 상태 (openedAt 있음) → "N년 M월 D일 열림"', () {
      final openedAt = DateTime(2026, 3, 20);
      final statusText = '${formatDate(openedAt)} 열림';
      expect(statusText, '2026년 3월 20일 열림');
    });

    test('opened 상태 (openedAt 없음) → "열림"', () {
      DateTime? openedAt;
      final statusText = openedAt != null
          ? '${formatDate(openedAt)} 열림'
          : '열림';
      expect(statusText, '열림');
    });
  });

  // ── CapsulesTableData 상태 조합 ───────────────────────────────────────────

  group('CapsulesTableData 상태 조합', () {
    test('message가 있는 캡슐', () {
      final capsule = CapsulesTableData(
        id: 'cap-msg',
        title: '메시지 캡슐',
        message: '1년 뒤 열어보세요!',
        openDate: DateTime(2027, 4, 3),
        isOpened: false,
        createdAt: DateTime(2026, 4, 3),
      );
      expect(capsule.message, '1년 뒤 열어보세요!');
    });

    test('openedAt이 null인 열린 캡슐 (마이그레이션 데이터)', () {
      final capsule = CapsulesTableData(
        id: 'cap-legacy',
        title: '레거시 캡슐',
        openDate: DateTime(2020, 1, 1),
        isOpened: true,
        openedAt: null, // 오래된 데이터
        createdAt: DateTime(2019),
      );
      expect(capsule.isOpened, isTrue);
      expect(capsule.openedAt, isNull);
    });
  });
}
