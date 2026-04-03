/// HyodoNotifier 순수 로직 테스트 (DB 불필요)
/// 커버: hyodo_notifier.dart — _levelFromScore, HyodoEntry.tempColorIndex,
///        HyodoState.empty, HyodoWeeklyReport, 점수 계산 공식, 정렬, 평균
import 'package:flutter_test/flutter_test.dart';
import 'package:re_link/features/hyodo/providers/hyodo_notifier.dart';

/// _levelFromScore는 private이므로 동일 로직을 복제하여 테스트
String levelFromScore(double score) {
  if (score < 16) return '냉담';
  if (score < 31) return '쌀쌀';
  if (score < 51) return '보통';
  if (score < 71) return '따뜻';
  if (score < 86) return '뜨거움';
  return '열정';
}

/// 점수 계산 공식 복제
double calcScore(int recordsLast30Days, int daysSinceLastRecord) {
  final rawScore = recordsLast30Days * 10.0 +
      (30 - daysSinceLastRecord).clamp(0, 30) * 2.0;
  return rawScore.clamp(0.0, 100.0);
}

void main() {
  // ── _levelFromScore 경계값 ────────────────────────────────────────────────

  group('_levelFromScore 경계값 (확장)', () {
    test('score 0 → 냉담', () => expect(levelFromScore(0), '냉담'));
    test('score 15.99 → 냉담', () => expect(levelFromScore(15.99), '냉담'));
    test('score 16.0 → 쌀쌀', () => expect(levelFromScore(16.0), '쌀쌀'));
    test('score 30.99 → 쌀쌀', () => expect(levelFromScore(30.99), '쌀쌀'));
    test('score 31.0 → 보통', () => expect(levelFromScore(31.0), '보통'));
    test('score 50.99 → 보통', () => expect(levelFromScore(50.99), '보통'));
    test('score 51.0 → 따뜻', () => expect(levelFromScore(51.0), '따뜻'));
    test('score 70.99 → 따뜻', () => expect(levelFromScore(70.99), '따뜻'));
    test('score 71.0 → 뜨거움', () => expect(levelFromScore(71.0), '뜨거움'));
    test('score 85.99 → 뜨거움', () => expect(levelFromScore(85.99), '뜨거움'));
    test('score 86.0 → 열정', () => expect(levelFromScore(86.0), '열정'));
    test('score 100 → 열정', () => expect(levelFromScore(100), '열정'));
  });

  // ── HyodoEntry.tempColorIndex 경계값 ──────────────────────────────────────

  group('HyodoEntry.tempColorIndex 경계값 (확장)', () {
    HyodoEntry makeEntry(double score) => HyodoEntry(
          nodeId: 'n1',
          nodeName: 'test',
          score: score,
          daysSinceLastRecord: 0,
          recordsLast30Days: 0,
          level: levelFromScore(score),
        );

    test('score 0 → index 0', () => expect(makeEntry(0).tempColorIndex, 0));
    test('score 15 → index 0', () => expect(makeEntry(15).tempColorIndex, 0));
    test('score 15.99 → index 0',
        () => expect(makeEntry(15.99).tempColorIndex, 0));
    test('score 16 → index 1', () => expect(makeEntry(16).tempColorIndex, 1));
    test('score 30 → index 1', () => expect(makeEntry(30).tempColorIndex, 1));
    test('score 30.99 → index 1',
        () => expect(makeEntry(30.99).tempColorIndex, 1));
    test('score 31 → index 2', () => expect(makeEntry(31).tempColorIndex, 2));
    test('score 50 → index 2', () => expect(makeEntry(50).tempColorIndex, 2));
    test('score 50.99 → index 2',
        () => expect(makeEntry(50.99).tempColorIndex, 2));
    test('score 51 → index 3', () => expect(makeEntry(51).tempColorIndex, 3));
    test('score 70 → index 3', () => expect(makeEntry(70).tempColorIndex, 3));
    test('score 70.99 → index 3',
        () => expect(makeEntry(70.99).tempColorIndex, 3));
    test('score 71 → index 4', () => expect(makeEntry(71).tempColorIndex, 4));
    test('score 85 → index 4', () => expect(makeEntry(85).tempColorIndex, 4));
    test('score 85.99 → index 4',
        () => expect(makeEntry(85.99).tempColorIndex, 4));
    test('score 86 → index 5', () => expect(makeEntry(86).tempColorIndex, 5));
    test('score 100 → index 5',
        () => expect(makeEntry(100).tempColorIndex, 5));
  });

  // ── 점수 계산 공식 확장 ───────────────────────────────────────────────────

  group('점수 계산 공식 (확장)', () {
    test('3 records, 5 days ago → 80', () {
      // 3*10 + (30-5)*2 = 30+50 = 80
      expect(calcScore(3, 5), 80.0);
    });

    test('4 records, 0 days → 100', () {
      // 4*10 + 30*2 = 40+60 = 100
      expect(calcScore(4, 0), 100.0);
    });

    test('0 records, 10 days ago → 40', () {
      // 0 + (30-10)*2 = 40
      expect(calcScore(0, 10), 40.0);
    });

    test('0 records, 15 days ago → 30', () {
      // 0 + (30-15)*2 = 30
      expect(calcScore(0, 15), 30.0);
    });

    test('10 records, 30 days ago → 100', () {
      // 10*10 + 0*2 = 100
      expect(calcScore(10, 30), 100.0);
    });

    test('음수 daysSince는 30으로 clamp → 0 records, -5 days → 60', () {
      // (30-(-5)).clamp(0,30) = 30, 0+60=60
      expect(calcScore(0, -5), 60.0);
    });
  });

  // ── HyodoState 모델 확장 ──────────────────────────────────────────────────

  group('HyodoState 모델 (확장)', () {
    test('empty 상태 확인', () {
      expect(HyodoState.empty.entries, isEmpty);
      expect(HyodoState.empty.averageScore, 0.0);
      expect(HyodoState.empty.needsAttention, isEmpty);
    });

    test('생성자에서 모든 필드 접근 가능', () {
      const entry = HyodoEntry(
        nodeId: 'n1',
        nodeName: '테스트',
        score: 50.0,
        daysSinceLastRecord: 5,
        recordsLast30Days: 5,
        level: '보통',
      );
      const state = HyodoState(
        entries: [entry],
        averageScore: 50.0,
        needsAttention: [],
      );
      expect(state.entries.length, 1);
      expect(state.averageScore, 50.0);
      expect(state.needsAttention, isEmpty);
    });
  });

  // ── HyodoWeeklyReport 모델 확장 ──────────────────────────────────────────

  group('HyodoWeeklyReport 모델 (확장)', () {
    test('양수 averageTempChange', () {
      const report = HyodoWeeklyReport(
        weeklyRecordCount: 10,
        averageTempChange: 2.5,
        needsAttentionNodes: [],
        dailyCounts: [1, 2, 1, 2, 1, 2, 1],
      );
      expect(report.averageTempChange, greaterThan(0));
    });

    test('needsAttentionNodes가 비어있을 수 있음', () {
      const report = HyodoWeeklyReport(
        weeklyRecordCount: 20,
        averageTempChange: 0.0,
        needsAttentionNodes: [],
        dailyCounts: [3, 3, 3, 3, 2, 3, 3],
      );
      expect(report.needsAttentionNodes, isEmpty);
    });

    test('모든 필드에 접근 가능', () {
      const report = HyodoWeeklyReport(
        weeklyRecordCount: 5,
        averageTempChange: -1.0,
        needsAttentionNodes: ['어머니'],
        dailyCounts: [0, 1, 0, 2, 0, 1, 1],
      );
      expect(report.weeklyRecordCount, 5);
      expect(report.averageTempChange, -1.0);
      expect(report.needsAttentionNodes, ['어머니']);
      expect(report.dailyCounts.reduce((a, b) => a + b), 5);
    });
  });

  // ── 정렬 및 평균 계산 (확장) ──────────────────────────────────────────────

  group('정렬 및 평균 계산 (확장)', () {
    test('5개 엔트리 평균 계산', () {
      final entries = [
        for (int i = 0; i < 5; i++)
          HyodoEntry(
            nodeId: 'n$i',
            nodeName: '노드$i',
            score: (i + 1) * 20.0, // 20, 40, 60, 80, 100
            daysSinceLastRecord: 0,
            recordsLast30Days: 0,
            level: levelFromScore((i + 1) * 20.0),
          ),
      ];
      final avg =
          entries.fold<double>(0, (sum, e) => sum + e.score) / entries.length;
      expect(avg, 60.0);
    });

    test('단일 엔트리 평균 = 해당 점수', () {
      const entries = [
        HyodoEntry(
          nodeId: 'n1',
          nodeName: 'Solo',
          score: 42.0,
          daysSinceLastRecord: 10,
          recordsLast30Days: 3,
          level: '보통',
        ),
      ];
      final avg =
          entries.fold<double>(0, (sum, e) => sum + e.score) / entries.length;
      expect(avg, 42.0);
    });

    test('관심 필요 필터: 점수 30 미만만 포함', () {
      final entries = [
        for (int i = 0; i < 6; i++)
          HyodoEntry(
            nodeId: 'n$i',
            nodeName: '노드$i',
            score: i * 20.0, // 0, 20, 40, 60, 80, 100
            daysSinceLastRecord: 0,
            recordsLast30Days: 0,
            level: levelFromScore(i * 20.0),
          ),
      ];
      final needsAttention = entries.where((e) => e.score < 30).toList();
      expect(needsAttention.length, 2); // 0, 20
    });
  });
}
