import 'package:drift/drift.dart';
import '../../../core/database/app_database.dart';

/// 연말 가족 리뷰 데이터 모델
class AnnualReviewData {
  const AnnualReviewData({
    required this.year,
    required this.totalMemories,
    required this.totalNodes,
    required this.newNodesThisYear,
    required this.newMemoriesThisYear,
    required this.totalBouquets,
    required this.streakBest,
    this.warmestNodeName,
    required this.warmestNodeMemories,
    this.mostActiveMonth,
    required this.memoryByMonth,
  });

  final int year;
  final int totalMemories;
  final int totalNodes;
  final int newNodesThisYear;
  final int newMemoriesThisYear;
  final int totalBouquets;
  final int streakBest;
  final String? warmestNodeName;
  final int warmestNodeMemories;
  final String? mostActiveMonth;
  final Map<String, int> memoryByMonth;

  static const List<String> _monthNames = [
    '1월', '2월', '3월', '4월', '5월', '6월',
    '7월', '8월', '9월', '10월', '11월', '12월',
  ];

  /// 월 인덱스(1~12)를 한국어 월 이름으로 변환
  static String monthName(int month) => _monthNames[month - 1];
}

/// 연간 통계를 DB에서 집계하는 서비스
class AnnualReviewService {
  const AnnualReviewService(this._db);

  final AppDatabase _db;

  Future<AnnualReviewData> generateReview(int year) async {
    final yearStart = DateTime(year);
    final yearEnd = DateTime(year + 1);

    // ── 전체 통계 ──────────────────────────────────────────────
    final stats = await _db.getStats();
    final totalNodes = stats['nodes'] ?? 0;
    final totalMemories = stats['memories'] ?? 0;

    // ── 올해 신규 노드 ─────────────────────────────────────────
    final nodesThisYear = await (
      _db.select(_db.nodesTable)
        ..where((t) =>
            t.createdAt.isBiggerOrEqualValue(yearStart) &
            t.createdAt.isSmallerThanValue(yearEnd))
    ).get();
    final newNodesThisYear = nodesThisYear.length;

    // ── 올해 신규 기억 ─────────────────────────────────────────
    final memoriesThisYear = await (
      _db.select(_db.memoriesTable)
        ..where((t) =>
            t.createdAt.isBiggerOrEqualValue(yearStart) &
            t.createdAt.isSmallerThanValue(yearEnd))
    ).get();
    final newMemoriesThisYear = memoriesThisYear.length;

    // ── 올해 꽃다발 ────────────────────────────────────────────
    final bouquets = await _db.getBouquetsThisYear();
    final totalBouquets = bouquets.length;

    // ── 가장 따뜻한 노드 (기억이 가장 많은 노드) ──────────────
    String? warmestNodeName;
    int warmestNodeMemories = 0;

    if (memoriesThisYear.isNotEmpty) {
      final nodeMemoryCount = <String, int>{};
      for (final memory in memoriesThisYear) {
        nodeMemoryCount[memory.nodeId] =
            (nodeMemoryCount[memory.nodeId] ?? 0) + 1;
      }
      final warmestNodeId = nodeMemoryCount.entries
          .reduce((a, b) => a.value >= b.value ? a : b)
          .key;
      warmestNodeMemories = nodeMemoryCount[warmestNodeId] ?? 0;
      final node = await _db.getNode(warmestNodeId);
      warmestNodeName = node?.name;
    }

    // ── 월별 기억 수 + 최활발 월 ───────────────────────────────
    final memoryByMonth = <String, int>{};
    for (int m = 1; m <= 12; m++) {
      memoryByMonth[AnnualReviewData.monthName(m)] = 0;
    }
    for (final memory in memoriesThisYear) {
      final month = memory.createdAt.month;
      final key = AnnualReviewData.monthName(month);
      memoryByMonth[key] = (memoryByMonth[key] ?? 0) + 1;
    }

    String? mostActiveMonth;
    int maxCount = 0;
    for (final entry in memoryByMonth.entries) {
      if (entry.value > maxCount) {
        maxCount = entry.value;
        mostActiveMonth = entry.key;
      }
    }

    // ── 최장 스트릭 (올해 기억 기반 연속 일수) ─────────────────
    int streakBest = 0;
    if (memoriesThisYear.isNotEmpty) {
      final days = memoriesThisYear
          .map((m) => DateTime(
              m.createdAt.year, m.createdAt.month, m.createdAt.day))
          .toSet()
          .toList()
        ..sort();

      int current = 1;
      int best = 1;
      for (int i = 1; i < days.length; i++) {
        if (days[i].difference(days[i - 1]).inDays == 1) {
          current++;
          if (current > best) best = current;
        } else {
          current = 1;
        }
      }
      streakBest = best;
    }

    return AnnualReviewData(
      year: year,
      totalMemories: totalMemories,
      totalNodes: totalNodes,
      newNodesThisYear: newNodesThisYear,
      newMemoriesThisYear: newMemoriesThisYear,
      totalBouquets: totalBouquets,
      streakBest: streakBest,
      warmestNodeName: warmestNodeName,
      warmestNodeMemories: warmestNodeMemories,
      mostActiveMonth: mostActiveMonth,
      memoryByMonth: memoryByMonth,
    );
  }
}
