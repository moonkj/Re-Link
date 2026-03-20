import 'package:flutter_test/flutter_test.dart';
import 'package:re_link/features/birthday/providers/birthday_notifier.dart';

void main() {
  group('BirthdayEntry', () {
    test('isToday is true when daysUntil is 0', () {
      final entry = BirthdayEntry(
        nodeId: 'n1',
        nodeName: '김철수',
        birthDate: DateTime(1990, 3, 20),
        nextBirthday: DateTime(2026, 3, 20),
        daysUntil: 0,
        turningAge: 36,
        isToday: true,
      );

      expect(entry.isToday, true);
      expect(entry.daysUntil, 0);
      expect(entry.turningAge, 36);
    });

    test('upcoming birthday has positive daysUntil', () {
      final entry = BirthdayEntry(
        nodeId: 'n2',
        nodeName: '이영희',
        birthDate: DateTime(1985, 7, 15),
        nextBirthday: DateTime(2026, 7, 15),
        daysUntil: 117,
        turningAge: 41,
        isToday: false,
      );

      expect(entry.isToday, false);
      expect(entry.daysUntil, 117);
    });

    test('entries sort by daysUntil ascending', () {
      final entries = [
        BirthdayEntry(
          nodeId: 'n1',
          nodeName: 'A',
          birthDate: DateTime(1990, 12, 1),
          nextBirthday: DateTime(2026, 12, 1),
          daysUntil: 256,
          turningAge: 36,
          isToday: false,
        ),
        BirthdayEntry(
          nodeId: 'n2',
          nodeName: 'B',
          birthDate: DateTime(1990, 4, 1),
          nextBirthday: DateTime(2026, 4, 1),
          daysUntil: 12,
          turningAge: 36,
          isToday: false,
        ),
        BirthdayEntry(
          nodeId: 'n3',
          nodeName: 'C',
          birthDate: DateTime(1990, 3, 20),
          nextBirthday: DateTime(2026, 3, 20),
          daysUntil: 0,
          turningAge: 36,
          isToday: true,
        ),
      ];

      entries.sort((a, b) => a.daysUntil.compareTo(b.daysUntil));

      expect(entries[0].nodeName, 'C'); // today
      expect(entries[1].nodeName, 'B'); // 12 days
      expect(entries[2].nodeName, 'A'); // 256 days
    });
  });

  group('Birthday date calculation', () {
    test('next birthday wraps to next year if passed', () {
      final now = DateTime(2026, 3, 20);
      final today = DateTime(now.year, now.month, now.day);
      final birthDate = DateTime(1990, 1, 15); // Jan 15

      var nextBday = DateTime(now.year, birthDate.month, birthDate.day);
      if (nextBday.isBefore(today)) {
        nextBday = DateTime(now.year + 1, birthDate.month, birthDate.day);
      }

      expect(nextBday.year, 2027);
      expect(nextBday.month, 1);
      expect(nextBday.day, 15);
    });

    test('next birthday is this year if not yet passed', () {
      final now = DateTime(2026, 3, 20);
      final today = DateTime(now.year, now.month, now.day);
      final birthDate = DateTime(1990, 8, 10); // Aug 10

      var nextBday = DateTime(now.year, birthDate.month, birthDate.day);
      if (nextBday.isBefore(today)) {
        nextBday = DateTime(now.year + 1, birthDate.month, birthDate.day);
      }

      expect(nextBday.year, 2026);
      expect(nextBday.month, 8);
      expect(nextBday.day, 10);
    });

    test('turningAge calculation is correct', () {
      final birthDate = DateTime(1990, 3, 20);
      final nextBday = DateTime(2026, 3, 20);
      final turningAge = nextBday.year - birthDate.year;

      expect(turningAge, 36);
    });
  });
}
