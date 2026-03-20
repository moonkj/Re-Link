import 'package:flutter_test/flutter_test.dart';
import 'package:re_link/core/services/widget/today_memory_service.dart';

void main() {
  group('TodayMemoryData', () {
    test('creates valid instance', () {
      final data = TodayMemoryData(
        memoryId: 'm1',
        nodeId: 'n1',
        title: '가족 사진',
        nodeName: '김철수',
        filePath: '/path/to/photo.webp',
        type: 'photo',
        originalDate: DateTime(2023, 3, 20),
        yearsAgo: 3,
      );

      expect(data.memoryId, 'm1');
      expect(data.yearsAgo, 3);
      expect(data.nodeName, '김철수');
      expect(data.type, 'photo');
    });

    test('nullable fields accept null', () {
      final data = TodayMemoryData(
        memoryId: 'm2',
        nodeId: 'n2',
        nodeName: '이영희',
        type: 'note',
        originalDate: DateTime(2024, 3, 20),
        yearsAgo: 2,
      );

      expect(data.title, isNull);
      expect(data.filePath, isNull);
      expect(data.thumbnailPath, isNull);
    });
  });

  group('Today memory matching logic', () {
    test('same month and day, different year matches', () {
      final now = DateTime(2026, 3, 20);
      final date = DateTime(2023, 3, 20);

      final matches = date.month == now.month &&
          date.day == now.day &&
          date.year != now.year;

      expect(matches, true);
    });

    test('same year does not match', () {
      final now = DateTime(2026, 3, 20);
      final date = DateTime(2026, 3, 20);

      final matches = date.month == now.month &&
          date.day == now.day &&
          date.year != now.year;

      expect(matches, false);
    });

    test('different day does not match', () {
      final now = DateTime(2026, 3, 20);
      final date = DateTime(2023, 3, 21);

      final matches = date.month == now.month &&
          date.day == now.day &&
          date.year != now.year;

      expect(matches, false);
    });

    test('results sort by yearsAgo descending', () {
      final results = [
        TodayMemoryData(
          memoryId: 'm1',
          nodeId: 'n1',
          nodeName: 'A',
          type: 'photo',
          originalDate: DateTime(2025, 3, 20),
          yearsAgo: 1,
        ),
        TodayMemoryData(
          memoryId: 'm2',
          nodeId: 'n2',
          nodeName: 'B',
          type: 'note',
          originalDate: DateTime(2020, 3, 20),
          yearsAgo: 6,
        ),
        TodayMemoryData(
          memoryId: 'm3',
          nodeId: 'n3',
          nodeName: 'C',
          type: 'voice',
          originalDate: DateTime(2023, 3, 20),
          yearsAgo: 3,
        ),
      ];

      results.sort((a, b) => b.yearsAgo.compareTo(a.yearsAgo));

      expect(results[0].yearsAgo, 6); // oldest
      expect(results[1].yearsAgo, 3);
      expect(results[2].yearsAgo, 1); // newest
    });
  });
}
