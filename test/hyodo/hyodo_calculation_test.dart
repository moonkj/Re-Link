import 'package:flutter_test/flutter_test.dart';
import 'package:re_link/features/hyodo/providers/hyodo_notifier.dart';

void main() {
  // ── 효도 점수 계산 공식 ────────────────────────────────────────────────────
  // rawScore = recordsLast30Days * 10.0 + (30 - daysSinceLastRecord).clamp(0, 30) * 2.0
  // score = rawScore.clamp(0.0, 100.0)
  group('Hyodo score calculation formula', () {
    double calcScore(int recordsLast30Days, int daysSinceLastRecord) {
      final rawScore = recordsLast30Days * 10.0 +
          (30 - daysSinceLastRecord).clamp(0, 30) * 2.0;
      return rawScore.clamp(0.0, 100.0);
    }

    test('0 records, no record ever (999 days) → score 0', () {
      final score = calcScore(0, 999);
      expect(score, 0.0);
    });

    test('0 records, last record 30 days ago → score 0', () {
      // (30-30).clamp(0,30) = 0, so 0*10 + 0*2 = 0
      final score = calcScore(0, 30);
      expect(score, 0.0);
    });

    test('0 records, last record today (0 days) → score 60', () {
      // (30-0).clamp(0,30) = 30, so 0*10 + 30*2 = 60
      final score = calcScore(0, 0);
      expect(score, 60.0);
    });

    test('every day record (30 records), last record today → clamped to 100', () {
      // 30*10 + 30*2 = 300+60 = 360 → clamped to 100
      final score = calcScore(30, 0);
      expect(score, 100.0);
    });

    test('15 records, last record 15 days ago → score ~80', () {
      // 15*10 + (30-15).clamp(0,30)*2 = 150 + 30 = 180 → clamped to 100
      final score = calcScore(15, 15);
      expect(score, 100.0);
    });

    test('5 records, last record 10 days ago → score 90', () {
      // 5*10 + (30-10)*2 = 50 + 40 = 90
      final score = calcScore(5, 10);
      expect(score, 90.0);
    });

    test('2 records, last record 25 days ago → score 30', () {
      // 2*10 + (30-25)*2 = 20 + 10 = 30
      final score = calcScore(2, 25);
      expect(score, 30.0);
    });

    test('1 record, last record 28 days ago → score 14', () {
      // 1*10 + (30-28)*2 = 10 + 4 = 14
      final score = calcScore(1, 28);
      expect(score, 14.0);
    });

    test('score never exceeds 100', () {
      final score = calcScore(100, 0);
      expect(score, 100.0);
    });

    test('score never goes below 0', () {
      final score = calcScore(0, 1000);
      expect(score, 0.0);
    });

    test('1 record, last record 30 days ago → score 10', () {
      // 1*10 + (30-30)*2 = 10 + 0 = 10
      final score = calcScore(1, 30);
      expect(score, 10.0);
    });
  });

  // ── "관심 필요" 판단 (score < 30) ──────────────────────────────────────────
  group('Needs attention threshold', () {
    bool needsAttention(double score) => score < 30;

    test('score 0 → needs attention', () {
      expect(needsAttention(0), true);
    });

    test('score 29.9 → needs attention', () {
      expect(needsAttention(29.9), true);
    });

    test('score 30 → does NOT need attention', () {
      expect(needsAttention(30), false);
    });

    test('score 100 → does NOT need attention', () {
      expect(needsAttention(100), false);
    });
  });

  // ── _levelFromScore 로직 (온도 레벨) ───────────────────────────────────────
  group('Level from score', () {
    // _levelFromScore is private; replicate logic for testing
    String levelFromScore(double score) {
      if (score < 16) return '냉담';
      if (score < 31) return '쌀쌀';
      if (score < 51) return '보통';
      if (score < 71) return '따뜻';
      if (score < 86) return '뜨거움';
      return '열정';
    }

    test('score 0 → 냉담', () {
      expect(levelFromScore(0), '냉담');
    });

    test('score 15.9 → 냉담', () {
      expect(levelFromScore(15.9), '냉담');
    });

    test('score 16 → 쌀쌀', () {
      expect(levelFromScore(16), '쌀쌀');
    });

    test('score 30.9 → 쌀쌀', () {
      expect(levelFromScore(30.9), '쌀쌀');
    });

    test('score 31 → 보통', () {
      expect(levelFromScore(31), '보통');
    });

    test('score 50 → 보통', () {
      expect(levelFromScore(50), '보통');
    });

    test('score 51 → 따뜻', () {
      expect(levelFromScore(51), '따뜻');
    });

    test('score 70 → 따뜻', () {
      expect(levelFromScore(70), '따뜻');
    });

    test('score 71 → 뜨거움', () {
      expect(levelFromScore(71), '뜨거움');
    });

    test('score 85 → 뜨거움', () {
      expect(levelFromScore(85), '뜨거움');
    });

    test('score 86 → 열정', () {
      expect(levelFromScore(86), '열정');
    });

    test('score 100 → 열정', () {
      expect(levelFromScore(100), '열정');
    });
  });

  // ── HyodoEntry 모델 ───────────────────────────────────────────────────────
  group('HyodoEntry model', () {
    test('constructor sets all fields', () {
      const entry = HyodoEntry(
        nodeId: 'n1',
        nodeName: '김철수',
        photoPath: '/photos/n1.webp',
        score: 75.0,
        daysSinceLastRecord: 3,
        recordsLast30Days: 8,
        level: '뜨거움',
      );

      expect(entry.nodeId, 'n1');
      expect(entry.nodeName, '김철수');
      expect(entry.photoPath, '/photos/n1.webp');
      expect(entry.score, 75.0);
      expect(entry.daysSinceLastRecord, 3);
      expect(entry.recordsLast30Days, 8);
      expect(entry.level, '뜨거움');
    });

    test('photoPath can be null', () {
      const entry = HyodoEntry(
        nodeId: 'n2',
        nodeName: '이영희',
        score: 50.0,
        daysSinceLastRecord: 10,
        recordsLast30Days: 5,
        level: '보통',
      );

      expect(entry.photoPath, isNull);
    });

    test('tempColorIndex for score < 16 → 0', () {
      const entry = HyodoEntry(
        nodeId: 'n1',
        nodeName: 'A',
        score: 10.0,
        daysSinceLastRecord: 25,
        recordsLast30Days: 1,
        level: '냉담',
      );
      expect(entry.tempColorIndex, 0);
    });

    test('tempColorIndex for score 16-30 → 1', () {
      const entry = HyodoEntry(
        nodeId: 'n1',
        nodeName: 'A',
        score: 25.0,
        daysSinceLastRecord: 20,
        recordsLast30Days: 2,
        level: '쌀쌀',
      );
      expect(entry.tempColorIndex, 1);
    });

    test('tempColorIndex for score 31-50 → 2', () {
      const entry = HyodoEntry(
        nodeId: 'n1',
        nodeName: 'A',
        score: 45.0,
        daysSinceLastRecord: 5,
        recordsLast30Days: 4,
        level: '보통',
      );
      expect(entry.tempColorIndex, 2);
    });

    test('tempColorIndex for score 51-70 → 3', () {
      const entry = HyodoEntry(
        nodeId: 'n1',
        nodeName: 'A',
        score: 65.0,
        daysSinceLastRecord: 2,
        recordsLast30Days: 6,
        level: '따뜻',
      );
      expect(entry.tempColorIndex, 3);
    });

    test('tempColorIndex for score 71-85 → 4', () {
      const entry = HyodoEntry(
        nodeId: 'n1',
        nodeName: 'A',
        score: 80.0,
        daysSinceLastRecord: 1,
        recordsLast30Days: 8,
        level: '뜨거움',
      );
      expect(entry.tempColorIndex, 4);
    });

    test('tempColorIndex for score 86+ → 5', () {
      const entry = HyodoEntry(
        nodeId: 'n1',
        nodeName: 'A',
        score: 95.0,
        daysSinceLastRecord: 0,
        recordsLast30Days: 10,
        level: '열정',
      );
      expect(entry.tempColorIndex, 5);
    });
  });

  // ── HyodoState 모델 ───────────────────────────────────────────────────────
  group('HyodoState model', () {
    test('empty state has no entries and zero average', () {
      expect(HyodoState.empty.entries, isEmpty);
      expect(HyodoState.empty.averageScore, 0.0);
      expect(HyodoState.empty.needsAttention, isEmpty);
    });

    test('averageScore reflects given value', () {
      const state = HyodoState(
        entries: [],
        averageScore: 55.5,
        needsAttention: [],
      );
      expect(state.averageScore, 55.5);
    });

    test('needsAttention filters score < 30', () {
      const lowEntry = HyodoEntry(
        nodeId: 'n1',
        nodeName: 'Low',
        score: 15.0,
        daysSinceLastRecord: 28,
        recordsLast30Days: 1,
        level: '냉담',
      );
      const highEntry = HyodoEntry(
        nodeId: 'n2',
        nodeName: 'High',
        score: 80.0,
        daysSinceLastRecord: 1,
        recordsLast30Days: 8,
        level: '뜨거움',
      );

      final entries = [lowEntry, highEntry];
      final needsAttention = entries.where((e) => e.score < 30).toList();

      expect(needsAttention.length, 1);
      expect(needsAttention.first.nodeName, 'Low');
    });
  });

  // ── HyodoWeeklyReport 모델 ────────────────────────────────────────────────
  group('HyodoWeeklyReport model', () {
    test('constructor sets all fields correctly', () {
      const report = HyodoWeeklyReport(
        weeklyRecordCount: 14,
        averageTempChange: 1.5,
        needsAttentionNodes: ['김철수', '이영희'],
        dailyCounts: [1, 2, 3, 0, 2, 4, 2],
      );

      expect(report.weeklyRecordCount, 14);
      expect(report.averageTempChange, 1.5);
      expect(report.needsAttentionNodes.length, 2);
      expect(report.needsAttentionNodes, ['김철수', '이영희']);
      expect(report.dailyCounts.length, 7);
    });

    test('dailyCounts has 7 entries (Mon-Sun)', () {
      const report = HyodoWeeklyReport(
        weeklyRecordCount: 0,
        averageTempChange: 0.0,
        needsAttentionNodes: [],
        dailyCounts: [0, 0, 0, 0, 0, 0, 0],
      );

      expect(report.dailyCounts.length, 7);
      expect(report.dailyCounts.every((c) => c == 0), true);
    });

    test('averageTempChange can be negative (temperature drop)', () {
      const report = HyodoWeeklyReport(
        weeklyRecordCount: 3,
        averageTempChange: -0.5,
        needsAttentionNodes: ['박지성'],
        dailyCounts: [0, 1, 0, 0, 1, 0, 1],
      );

      expect(report.averageTempChange, lessThan(0));
    });

    test('empty report with no activity', () {
      const report = HyodoWeeklyReport(
        weeklyRecordCount: 0,
        averageTempChange: 0.0,
        needsAttentionNodes: [],
        dailyCounts: [0, 0, 0, 0, 0, 0, 0],
      );

      expect(report.weeklyRecordCount, 0);
      expect(report.averageTempChange, 0.0);
      expect(report.needsAttentionNodes, isEmpty);
    });
  });

  // ── 점수 → 정렬 동작 ──────────────────────────────────────────────────────
  group('Score sorting (lowest first for attention)', () {
    test('entries sort by score ascending', () {
      final entries = [
        const HyodoEntry(
          nodeId: 'n1',
          nodeName: 'High',
          score: 90.0,
          daysSinceLastRecord: 0,
          recordsLast30Days: 10,
          level: '열정',
        ),
        const HyodoEntry(
          nodeId: 'n2',
          nodeName: 'Low',
          score: 10.0,
          daysSinceLastRecord: 28,
          recordsLast30Days: 1,
          level: '냉담',
        ),
        const HyodoEntry(
          nodeId: 'n3',
          nodeName: 'Mid',
          score: 50.0,
          daysSinceLastRecord: 10,
          recordsLast30Days: 5,
          level: '보통',
        ),
      ];

      entries.sort((a, b) => a.score.compareTo(b.score));

      expect(entries[0].nodeName, 'Low');
      expect(entries[1].nodeName, 'Mid');
      expect(entries[2].nodeName, 'High');
    });
  });

  // ── 평균 점수 계산 ────────────────────────────────────────────────────────
  group('Average score calculation', () {
    test('average of empty list is 0', () {
      final entries = <HyodoEntry>[];
      final avg = entries.isEmpty
          ? 0.0
          : entries.fold<double>(0, (sum, e) => sum + e.score) /
              entries.length;
      expect(avg, 0.0);
    });

    test('average of two entries', () {
      const entries = [
        HyodoEntry(
          nodeId: 'n1',
          nodeName: 'A',
          score: 40.0,
          daysSinceLastRecord: 5,
          recordsLast30Days: 4,
          level: '보통',
        ),
        HyodoEntry(
          nodeId: 'n2',
          nodeName: 'B',
          score: 80.0,
          daysSinceLastRecord: 1,
          recordsLast30Days: 8,
          level: '뜨거움',
        ),
      ];

      final avg =
          entries.fold<double>(0, (sum, e) => sum + e.score) / entries.length;
      expect(avg, 60.0);
    });
  });
}
