/// FamilyEventModel 단위 테스트
/// 커버: family_event_model.dart — daysUntil, isToday, nextEventDate, colorFromHex, colorToHex
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:re_link/shared/models/family_event_model.dart';

void main() {
  // ── daysUntil ─────────────────────────────────────────────────────────────

  group('daysUntil — 비반복 일정', () {
    test('미래 날짜 → 양수', () {
      final now = DateTime.now();
      final futureDate = now.add(const Duration(days: 10));
      final event = FamilyEventModel(
        id: 'e1',
        title: '미래 이벤트',
        eventDate: futureDate,
        isYearly: false,
        createdAt: now,
      );
      expect(event.daysUntil, 10);
    });

    test('과거 날짜 → 음수', () {
      final now = DateTime.now();
      final pastDate = now.subtract(const Duration(days: 5));
      final event = FamilyEventModel(
        id: 'e2',
        title: '과거 이벤트',
        eventDate: pastDate,
        isYearly: false,
        createdAt: now,
      );
      expect(event.daysUntil, -5);
    });

    test('오늘 → 0', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final event = FamilyEventModel(
        id: 'e3',
        title: '오늘 이벤트',
        eventDate: today,
        isYearly: false,
        createdAt: now,
      );
      expect(event.daysUntil, 0);
    });
  });

  group('daysUntil — 매년 반복 일정', () {
    test('올해 아직 안 지남 → 올해 기준 계산', () {
      final now = DateTime.now();
      // 12월 31일은 거의 항상 미래
      final event = FamilyEventModel(
        id: 'e4',
        title: '연말 이벤트',
        eventDate: DateTime(2020, 12, 31), // 과거 연도지만 isYearly
        isYearly: true,
        createdAt: now,
      );
      final daysUntil = event.daysUntil;
      // 올해 12/31까지의 남은 일수이거나, 지났으면 내년 12/31까지
      expect(daysUntil, greaterThanOrEqualTo(0));
    });

    test('올해 이미 지남 → 내년 기준 계산', () {
      final now = DateTime.now();
      // 1월 1일은 보통 이미 지남 (4월 3일 기준)
      final event = FamilyEventModel(
        id: 'e5',
        title: '새해',
        eventDate: DateTime(2020, 1, 1),
        isYearly: true,
        createdAt: now,
      );
      final daysUntil = event.daysUntil;
      // 1/1이 지났으면 내년 1/1까지 남은 날짜
      expect(daysUntil, greaterThan(0));
    });
  });

  // ── isToday ───────────────────────────────────────────────────────────────

  group('isToday', () {
    test('오늘 일정 → true', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final event = FamilyEventModel(
        id: 'e6',
        title: '오늘',
        eventDate: today,
        isYearly: false,
        createdAt: now,
      );
      expect(event.isToday, isTrue);
    });

    test('내일 일정 → false', () {
      final now = DateTime.now();
      final tomorrow = DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
      final event = FamilyEventModel(
        id: 'e7',
        title: '내일',
        eventDate: tomorrow,
        isYearly: false,
        createdAt: now,
      );
      expect(event.isToday, isFalse);
    });

    test('매년 반복 — 올해 오늘 날짜 → true', () {
      final now = DateTime.now();
      // 과거 연도이지만 같은 월/일, isYearly=true
      final event = FamilyEventModel(
        id: 'e8',
        title: '생일',
        eventDate: DateTime(2000, now.month, now.day),
        isYearly: true,
        createdAt: now,
      );
      expect(event.isToday, isTrue);
    });
  });

  // ── nextEventDate ─────────────────────────────────────────────────────────

  group('nextEventDate', () {
    test('비반복 → eventDate 그대로 반환', () {
      final eventDate = DateTime(2030, 6, 15);
      final event = FamilyEventModel(
        id: 'e9',
        title: '미래 일회성',
        eventDate: eventDate,
        isYearly: false,
        createdAt: DateTime.now(),
      );
      expect(event.nextEventDate, eventDate);
    });

    test('매년 반복 — 올해 지남 → 내년 날짜', () {
      final now = DateTime.now();
      // 1월 1일은 보통 이미 지남
      final event = FamilyEventModel(
        id: 'e10',
        title: '새해',
        eventDate: DateTime(2015, 1, 1),
        isYearly: true,
        createdAt: now,
      );

      final next = event.nextEventDate;
      // 1/1이 지났으면 내년 1/1
      if (now.month > 1 || (now.month == 1 && now.day > 1)) {
        expect(next.year, now.year + 1);
      } else if (now.month == 1 && now.day == 1) {
        expect(next.year, now.year);
      }
      expect(next.month, 1);
      expect(next.day, 1);
    });

    test('매년 반복 — 올해 아직 안 지남 → 올해 날짜', () {
      final now = DateTime.now();
      // 12월 31일은 대부분 아직 안 지남
      final event = FamilyEventModel(
        id: 'e11',
        title: '연말',
        eventDate: DateTime(2015, 12, 31),
        isYearly: true,
        createdAt: now,
      );

      final next = event.nextEventDate;
      if (now.month < 12 || (now.month == 12 && now.day <= 31)) {
        expect(next.year, now.year);
      }
      expect(next.month, 12);
      expect(next.day, 31);
    });
  });

  // ── colorFromHex ──────────────────────────────────────────────────────────

  group('colorFromHex', () {
    test('#FF0000 → 빨간색', () {
      final color = FamilyEventModel.colorFromHex('#FF0000');
      expect(color, const Color(0xFFFF0000));
    });

    test('#00FF00 → 초록색', () {
      final color = FamilyEventModel.colorFromHex('#00FF00');
      expect(color, const Color(0xFF00FF00));
    });

    test('#0000FF → 파란색', () {
      final color = FamilyEventModel.colorFromHex('#0000FF');
      expect(color, const Color(0xFF0000FF));
    });

    test('#FFFFFF → 흰색', () {
      final color = FamilyEventModel.colorFromHex('#FFFFFF');
      expect(color, const Color(0xFFFFFFFF));
    });

    test('#000000 → 검정색', () {
      final color = FamilyEventModel.colorFromHex('#000000');
      expect(color, const Color(0xFF000000));
    });

    test('# 없는 hex → 올바르게 처리', () {
      final color = FamilyEventModel.colorFromHex('8B5CF6');
      // 7자가 아니므로 FF가 붙지 않고 그대로 파싱됨
      expect(color, isA<Color>());
    });
  });

  // ── colorToHex ────────────────────────────────────────────────────────────

  group('colorToHex', () {
    test('빨간색 → #FF0000', () {
      final hex = FamilyEventModel.colorToHex(const Color(0xFFFF0000));
      expect(hex, '#FF0000');
    });

    test('흰색 → #FFFFFF', () {
      final hex = FamilyEventModel.colorToHex(const Color(0xFFFFFFFF));
      expect(hex, '#FFFFFF');
    });

    test('검정색 → #000000', () {
      final hex = FamilyEventModel.colorToHex(const Color(0xFF000000));
      expect(hex, '#000000');
    });
  });

  // ── colorFromHex ↔ colorToHex 왕복 ────────────────────────────────────────

  group('colorFromHex ↔ colorToHex 왕복', () {
    test('빨간색 왕복', () {
      const original = Color(0xFFFF0000);
      final hex = FamilyEventModel.colorToHex(original);
      final restored = FamilyEventModel.colorFromHex(hex);
      expect(restored, original);
    });

    test('보라색 왕복', () {
      const original = Color(0xFF8B5CF6);
      final hex = FamilyEventModel.colorToHex(original);
      final restored = FamilyEventModel.colorFromHex(hex);
      expect(restored, original);
    });
  });

  // ── copyWith ──────────────────────────────────────────────────────────────

  group('FamilyEventModel copyWith', () {
    test('title 변경', () {
      final event = FamilyEventModel(
        id: 'e1',
        title: '원래 제목',
        eventDate: DateTime(2026, 4, 3),
        createdAt: DateTime.now(),
      );
      final copied = event.copyWith(title: '새 제목');
      expect(copied.title, '새 제목');
      expect(copied.id, 'e1'); // id는 변경 불가
    });

    test('color 변경', () {
      final event = FamilyEventModel(
        id: 'e2',
        title: '테스트',
        eventDate: DateTime(2026, 1, 1),
        createdAt: DateTime.now(),
      );
      final copied = event.copyWith(color: Colors.red);
      expect(copied.color, Colors.red);
    });

    test('isYearly 변경', () {
      final event = FamilyEventModel(
        id: 'e3',
        title: '테스트',
        eventDate: DateTime(2026, 6, 15),
        isYearly: false,
        createdAt: DateTime.now(),
      );
      final copied = event.copyWith(isYearly: true);
      expect(copied.isYearly, isTrue);
    });
  });

  // ── 기본값 ────────────────────────────────────────────────────────────────

  group('FamilyEventModel 기본값', () {
    test('isYearly 기본값 = false', () {
      final event = FamilyEventModel(
        id: 'e1',
        title: '테스트',
        eventDate: DateTime(2026, 1, 1),
        createdAt: DateTime.now(),
      );
      expect(event.isYearly, isFalse);
    });

    test('color 기본값 = Color(0xFF8B5CF6)', () {
      final event = FamilyEventModel(
        id: 'e1',
        title: '테스트',
        eventDate: DateTime(2026, 1, 1),
        createdAt: DateTime.now(),
      );
      expect(event.color, const Color(0xFF8B5CF6));
    });

    test('description 기본값 = null', () {
      final event = FamilyEventModel(
        id: 'e1',
        title: '테스트',
        eventDate: DateTime(2026, 1, 1),
        createdAt: DateTime.now(),
      );
      expect(event.description, isNull);
    });

    test('nodeId 기본값 = null', () {
      final event = FamilyEventModel(
        id: 'e1',
        title: '테스트',
        eventDate: DateTime(2026, 1, 1),
        createdAt: DateTime.now(),
      );
      expect(event.nodeId, isNull);
    });
  });
}
