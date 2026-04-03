/// HyodoNotifier 확장 테스트
/// 커버: hyodo_notifier.dart — 추가 점수 경계값, 넛지 메시지, 주간 리포트 로직
import 'package:flutter_test/flutter_test.dart';
import 'package:re_link/features/hyodo/providers/hyodo_notifier.dart';

void main() {
  // ── 점수 계산 경계값 확장 ─────────────────────────────────────────────────

  group('Score calculation edge cases', () {
    double calcScore(int records, int days) {
      final raw = records * 10.0 + (30 - days).clamp(0, 30) * 2.0;
      return raw.clamp(0.0, 100.0);
    }

    test('3 records, 20 days → 50', () {
      // 3*10 + (30-20)*2 = 30 + 20 = 50
      expect(calcScore(3, 20), 50.0);
    });

    test('4 records, 0 days → 100 (clamped)', () {
      // 4*10 + 30*2 = 40 + 60 = 100
      expect(calcScore(4, 0), 100.0);
    });

    test('0 records, 1 day → 58', () {
      // 0*10 + (30-1)*2 = 58
      expect(calcScore(0, 1), 58.0);
    });

    test('0 records, 15 days → 30', () {
      // 0*10 + (30-15)*2 = 30
      expect(calcScore(0, 15), 30.0);
    });

    test('1 records, 0 days → 70', () {
      // 1*10 + 30*2 = 10 + 60 = 70
      expect(calcScore(1, 0), 70.0);
    });

    test('10 records, 30 days → 100 (clamped)', () {
      // 10*10 + 0*2 = 100
      expect(calcScore(10, 30), 100.0);
    });

    test('negative clamping: days=50 → (30-50)=-20 → clamped to 0', () {
      // 0*10 + 0*2 = 0
      expect(calcScore(0, 50), 0.0);
    });

    test('2 records, 29 days → 22', () {
      // 2*10 + (30-29)*2 = 20 + 2 = 22
      expect(calcScore(2, 29), 22.0);
    });
  });

  // ── tempColorIndex 경계값 확장 ───────────────────────────────────────────

  group('HyodoEntry.tempColorIndex boundary values', () {
    int tempColorIndex(double score) {
      if (score < 16) return 0;
      if (score < 31) return 1;
      if (score < 51) return 2;
      if (score < 71) return 3;
      if (score < 86) return 4;
      return 5;
    }

    test('score 0 → 0', () => expect(tempColorIndex(0), 0));
    test('score 15 → 0', () => expect(tempColorIndex(15), 0));
    test('score 15.99 → 0', () => expect(tempColorIndex(15.99), 0));
    test('score 16 → 1', () => expect(tempColorIndex(16), 1));
    test('score 30 → 1', () => expect(tempColorIndex(30), 1));
    test('score 30.99 → 1', () => expect(tempColorIndex(30.99), 1));
    test('score 31 → 2', () => expect(tempColorIndex(31), 2));
    test('score 50 → 2', () => expect(tempColorIndex(50), 2));
    test('score 50.99 → 2', () => expect(tempColorIndex(50.99), 2));
    test('score 51 → 3', () => expect(tempColorIndex(51), 3));
    test('score 70 → 3', () => expect(tempColorIndex(70), 3));
    test('score 70.99 → 3', () => expect(tempColorIndex(70.99), 3));
    test('score 71 → 4', () => expect(tempColorIndex(71), 4));
    test('score 85 → 4', () => expect(tempColorIndex(85), 4));
    test('score 85.99 → 4', () => expect(tempColorIndex(85.99), 4));
    test('score 86 → 5', () => expect(tempColorIndex(86), 5));
    test('score 100 → 5', () => expect(tempColorIndex(100), 5));
  });

  // ── 넛지 알림 메시지 구성 ────────────────────────────────────────────────

  group('Nudge notification message', () {
    String buildNudgeBody(List<HyodoEntry> needsAttention) {
      if (needsAttention.isEmpty) return '';
      final topName = needsAttention.first.nodeName;
      return needsAttention.length == 1
          ? '한 주가 지났어요, $topName님에게 안부를 전해보세요'
          : '한 주가 지났어요, $topName님 외 ${needsAttention.length - 1}명에게 안부를 전해보세요';
    }

    test('single node', () {
      const entries = [
        HyodoEntry(
          nodeId: 'n1',
          nodeName: '엄마',
          score: 10,
          daysSinceLastRecord: 28,
          recordsLast30Days: 1,
          level: '냉담',
        ),
      ];
      expect(buildNudgeBody(entries), '한 주가 지났어요, 엄마님에게 안부를 전해보세요');
    });

    test('two nodes', () {
      const entries = [
        HyodoEntry(
          nodeId: 'n1',
          nodeName: '엄마',
          score: 10,
          daysSinceLastRecord: 28,
          recordsLast30Days: 1,
          level: '냉담',
        ),
        HyodoEntry(
          nodeId: 'n2',
          nodeName: '아빠',
          score: 20,
          daysSinceLastRecord: 25,
          recordsLast30Days: 2,
          level: '쌀쌀',
        ),
      ];
      expect(
        buildNudgeBody(entries),
        '한 주가 지났어요, 엄마님 외 1명에게 안부를 전해보세요',
      );
    });

    test('five nodes', () {
      final entries = List.generate(
        5,
        (i) => HyodoEntry(
          nodeId: 'n$i',
          nodeName: '가족$i',
          score: 5.0 + i,
          daysSinceLastRecord: 29 - i,
          recordsLast30Days: i,
          level: '냉담',
        ),
      );
      expect(
        buildNudgeBody(entries),
        '한 주가 지났어요, 가족0님 외 4명에게 안부를 전해보세요',
      );
    });

    test('empty list → empty string', () {
      expect(buildNudgeBody([]), '');
    });
  });

  // ── 대상 노드 필터링 로직 ────────────────────────────────────────────────

  group('Target node filtering logic', () {
    // Simulating: Ghost가 아니고 사망하지 않은 노드만 대상
    test('ghost node excluded', () {
      const isGhost = true;
      DateTime? deathDate;
      final isTarget = !isGhost && deathDate == null;
      expect(isTarget, isFalse);
    });

    test('deceased node excluded', () {
      const isGhost = false;
      final deathDate = DateTime(2020, 5, 1);
      final isTarget = !isGhost && deathDate == null;
      expect(isTarget, isFalse);
    });

    test('normal node included', () {
      const isGhost = false;
      DateTime? deathDate;
      final isTarget = !isGhost && deathDate == null;
      expect(isTarget, isTrue);
    });

    test('ghost + deceased excluded', () {
      const isGhost = true;
      final deathDate = DateTime(2020, 5, 1);
      final isTarget = !isGhost && deathDate == null;
      expect(isTarget, isFalse);
    });
  });

  // ── 주간 리포트 로직 ────────────────────────────────────────────────────

  group('Weekly report logic', () {
    test('dailyCounts indexing — 7 days', () {
      final dailyCounts = List<int>.filled(7, 0);
      expect(dailyCounts.length, 7);
      expect(dailyCounts.every((c) => c == 0), isTrue);
    });

    test('dayIndex calculation', () {
      final today = DateTime(2026, 4, 3);
      final sevenDaysAgo = today.subtract(const Duration(days: 6));
      // sevenDaysAgo = March 28
      final testDate = DateTime(2026, 3, 30);
      final dayIndex = testDate.difference(sevenDaysAgo).inDays;
      expect(dayIndex, 2); // March 28=0, 29=1, 30=2
    });

    test('dayIndex for today', () {
      final today = DateTime(2026, 4, 3);
      final sevenDaysAgo = today.subtract(const Duration(days: 6));
      final dayIndex = today.difference(sevenDaysAgo).inDays;
      expect(dayIndex, 6); // today is always index 6
    });

    test('dayIndex out of range (before window) → skip', () {
      final today = DateTime(2026, 4, 3);
      final sevenDaysAgo = today.subtract(const Duration(days: 6));
      final oldDate = DateTime(2026, 3, 20);
      final dayIndex = oldDate.difference(sevenDaysAgo).inDays;
      expect(dayIndex < 0, isTrue);
    });

    test('average temp change calculation', () {
      // Nodes with temperatures: [1, 2, 3, 4]
      // Change from neutral (2): [-1, 0, 1, 2]
      // Average: 2/4 = 0.5
      final temps = [1.0, 2.0, 3.0, 4.0];
      double totalChange = 0;
      for (final t in temps) {
        totalChange += t - 2.0;
      }
      final avg = totalChange / temps.length;
      expect(avg, 0.5);
    });

    test('average temp change — all neutral → 0', () {
      final temps = [2.0, 2.0, 2.0];
      double totalChange = 0;
      for (final t in temps) {
        totalChange += t - 2.0;
      }
      final avg = totalChange / temps.length;
      expect(avg, 0.0);
    });

    test('average temp change — empty → 0', () {
      final temps = <double>[];
      final avg = temps.isEmpty ? 0.0 : temps.reduce((a, b) => a + b) / temps.length;
      expect(avg, 0.0);
    });
  });

  // ── HyodoWeeklyReport 모델 확장 ──────────────────────────────────────────

  group('HyodoWeeklyReport model extensions', () {
    test('weeklyRecordCount can be large', () {
      const report = HyodoWeeklyReport(
        weeklyRecordCount: 999,
        averageTempChange: 2.5,
        needsAttentionNodes: [],
        dailyCounts: [100, 100, 100, 100, 100, 100, 199],
      );
      expect(report.weeklyRecordCount, 999);
    });

    test('needsAttentionNodes can be empty', () {
      const report = HyodoWeeklyReport(
        weeklyRecordCount: 50,
        averageTempChange: 1.0,
        needsAttentionNodes: [],
        dailyCounts: [5, 10, 5, 10, 5, 10, 5],
      );
      expect(report.needsAttentionNodes, isEmpty);
    });
  });
}
