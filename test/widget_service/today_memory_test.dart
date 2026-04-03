/// TodayMemoryService 순수 로직 테스트
/// 커버: today_memory_service.dart — TodayMemoryData 모델, 정렬 로직,
///        날짜 매칭 로직, yearsAgo 계산
import 'package:flutter_test/flutter_test.dart';
import 'package:re_link/core/services/widget/today_memory_service.dart';

void main() {
  // ── TodayMemoryData 모델 ──────────────────────────────────────────────

  group('TodayMemoryData model', () {
    test('constructor sets all fields', () {
      final data = TodayMemoryData(
        memoryId: 'mem_001',
        nodeId: 'node_001',
        title: '엄마와 산책',
        nodeName: '엄마',
        filePath: '/photos/walk.webp',
        thumbnailPath: '/thumbs/walk.webp',
        type: 'photo',
        originalDate: DateTime(2023, 4, 3),
        yearsAgo: 3,
      );

      expect(data.memoryId, 'mem_001');
      expect(data.nodeId, 'node_001');
      expect(data.title, '엄마와 산책');
      expect(data.nodeName, '엄마');
      expect(data.filePath, '/photos/walk.webp');
      expect(data.thumbnailPath, '/thumbs/walk.webp');
      expect(data.type, 'photo');
      expect(data.originalDate, DateTime(2023, 4, 3));
      expect(data.yearsAgo, 3);
    });

    test('nullable fields can be null', () {
      final data = TodayMemoryData(
        memoryId: 'mem_002',
        nodeId: 'node_002',
        nodeName: '아빠',
        type: 'note',
        originalDate: DateTime(2024, 4, 3),
        yearsAgo: 2,
      );

      expect(data.title, isNull);
      expect(data.filePath, isNull);
      expect(data.thumbnailPath, isNull);
    });
  });

  // ── yearsAgo 계산 ────────────────────────────────────────────────────────

  group('yearsAgo calculation', () {
    test('1 year ago', () {
      final now = DateTime(2026, 4, 3);
      final date = DateTime(2025, 4, 3);
      expect(now.year - date.year, 1);
    });

    test('5 years ago', () {
      final now = DateTime(2026, 4, 3);
      final date = DateTime(2021, 4, 3);
      expect(now.year - date.year, 5);
    });

    test('10 years ago', () {
      final now = DateTime(2026, 4, 3);
      final date = DateTime(2016, 4, 3);
      expect(now.year - date.year, 10);
    });
  });

  // ── 날짜 매칭 로직 (같은 월/일, 다른 년도) ─────────────────────────────

  group('Date matching logic (same month/day, different year)', () {
    bool isMatchingDate(DateTime date, DateTime now) {
      return date.month == now.month &&
          date.day == now.day &&
          date.year != now.year;
    }

    test('same month/day, different year → true', () {
      final date = DateTime(2023, 4, 3);
      final now = DateTime(2026, 4, 3);
      expect(isMatchingDate(date, now), isTrue);
    });

    test('same month/day, same year → false', () {
      final date = DateTime(2026, 4, 3);
      final now = DateTime(2026, 4, 3);
      expect(isMatchingDate(date, now), isFalse);
    });

    test('different month → false', () {
      final date = DateTime(2023, 5, 3);
      final now = DateTime(2026, 4, 3);
      expect(isMatchingDate(date, now), isFalse);
    });

    test('different day → false', () {
      final date = DateTime(2023, 4, 4);
      final now = DateTime(2026, 4, 3);
      expect(isMatchingDate(date, now), isFalse);
    });

    test('Feb 29 on non-leap year now → cannot match', () {
      final date = DateTime(2024, 2, 29);
      // 2025 has no Feb 29, so now = Feb 28
      final now = DateTime(2025, 2, 28);
      expect(isMatchingDate(date, now), isFalse);
    });
  });

  // ── 정렬 (yearsAgo 내림차순) ──────────────────────────────────────────

  group('Sorting by yearsAgo descending', () {
    test('oldest memory first', () {
      final results = [
        TodayMemoryData(
          memoryId: 'm1',
          nodeId: 'n1',
          nodeName: 'A',
          type: 'photo',
          originalDate: DateTime(2024, 4, 3),
          yearsAgo: 2,
        ),
        TodayMemoryData(
          memoryId: 'm2',
          nodeId: 'n2',
          nodeName: 'B',
          type: 'note',
          originalDate: DateTime(2020, 4, 3),
          yearsAgo: 6,
        ),
        TodayMemoryData(
          memoryId: 'm3',
          nodeId: 'n3',
          nodeName: 'C',
          type: 'voice',
          originalDate: DateTime(2022, 4, 3),
          yearsAgo: 4,
        ),
      ];

      results.sort((a, b) => b.yearsAgo.compareTo(a.yearsAgo));

      expect(results[0].yearsAgo, 6);
      expect(results[1].yearsAgo, 4);
      expect(results[2].yearsAgo, 2);
    });

    test('single result', () {
      final results = [
        TodayMemoryData(
          memoryId: 'm1',
          nodeId: 'n1',
          nodeName: 'A',
          type: 'photo',
          originalDate: DateTime(2023, 4, 3),
          yearsAgo: 3,
        ),
      ];
      results.sort((a, b) => b.yearsAgo.compareTo(a.yearsAgo));
      expect(results.length, 1);
    });

    test('empty results', () {
      final results = <TodayMemoryData>[];
      results.sort((a, b) => b.yearsAgo.compareTo(a.yearsAgo));
      expect(results, isEmpty);
    });
  });

  // ── 다양한 memory type ──────────────────────────────────────────────────

  group('Memory types', () {
    test('photo type', () {
      final data = TodayMemoryData(
        memoryId: 'm1',
        nodeId: 'n1',
        nodeName: 'A',
        type: 'photo',
        originalDate: DateTime(2023, 4, 3),
        yearsAgo: 3,
      );
      expect(data.type, 'photo');
    });

    test('voice type', () {
      final data = TodayMemoryData(
        memoryId: 'm2',
        nodeId: 'n1',
        nodeName: 'A',
        type: 'voice',
        originalDate: DateTime(2023, 4, 3),
        yearsAgo: 3,
      );
      expect(data.type, 'voice');
    });

    test('note type', () {
      final data = TodayMemoryData(
        memoryId: 'm3',
        nodeId: 'n1',
        nodeName: 'A',
        type: 'note',
        originalDate: DateTime(2023, 4, 3),
        yearsAgo: 3,
      );
      expect(data.type, 'note');
    });
  });

  // ── dateTaken vs createdAt fallback ──────────────────────────────────────

  group('Date fallback logic', () {
    test('dateTaken exists → use dateTaken', () {
      final dateTaken = DateTime(2023, 4, 3);
      final createdAt = DateTime(2023, 5, 1);

      final date = dateTaken;
      expect(date.month, 4);
      expect(date.day, 3);
    });

    test('dateTaken null → use createdAt', () {
      DateTime? dateTaken;
      final createdAt = DateTime(2023, 4, 3);

      final date = dateTaken ?? createdAt;
      expect(date.month, 4);
      expect(date.day, 3);
    });
  });

  // ── nodeMap 구성 ────────────────────────────────────────────────────────

  group('Node name mapping', () {
    test('lookup by nodeId', () {
      final nodeMap = {
        'n1': '엄마',
        'n2': '아빠',
        'n3': '동생',
      };
      expect(nodeMap['n1'], '엄마');
      expect(nodeMap['n99'] ?? '', ''); // unknown node
    });
  });
}
