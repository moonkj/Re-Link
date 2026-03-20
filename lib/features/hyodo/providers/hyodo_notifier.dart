import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../shared/repositories/db_provider.dart';
import '../../../core/database/app_database.dart';

part 'hyodo_notifier.g.dart';

// ── 모델 ──────────────────────────────────────────────────────────────────────

/// 개별 노드의 효도 점수 항목
class HyodoEntry {
  const HyodoEntry({
    required this.nodeId,
    required this.nodeName,
    this.photoPath,
    required this.score,
    required this.daysSinceLastRecord,
    required this.recordsLast30Days,
    required this.level,
  });

  final String nodeId;
  final String nodeName;
  final String? photoPath;

  /// 0.0 ~ 100.0
  final double score;

  /// 마지막 기록 후 경과 일수
  final int daysSinceLastRecord;

  /// 최근 30일 기록 수 (기억 + 온도 로그)
  final int recordsLast30Days;

  /// 냉담 / 쌀쌀 / 보통 / 따뜻 / 뜨거움 / 열정
  final String level;

  /// 점수 → 온도 레벨 인덱스 (0~5, AppColors.tempColor에 전달)
  int get tempColorIndex {
    if (score < 16) return 0;
    if (score < 31) return 1;
    if (score < 51) return 2;
    if (score < 71) return 3;
    if (score < 86) return 4;
    return 5;
  }
}

/// 효도 온도계 전체 상태
class HyodoState {
  const HyodoState({
    required this.entries,
    required this.averageScore,
    required this.needsAttention,
  });

  /// 모든 대상 노드의 효도 점수
  final List<HyodoEntry> entries;

  /// 전체 평균 점수
  final double averageScore;

  /// 관심이 필요한 노드 (score < 30)
  final List<HyodoEntry> needsAttention;

  static const empty = HyodoState(
    entries: [],
    averageScore: 0,
    needsAttention: [],
  );
}

// ── 유틸 ──────────────────────────────────────────────────────────────────────

String _levelFromScore(double score) {
  if (score < 16) return '냉담';
  if (score < 31) return '쌀쌀';
  if (score < 51) return '보통';
  if (score < 71) return '따뜻';
  if (score < 86) return '뜨거움';
  return '열정';
}

// ── 프로바이더 ────────────────────────────────────────────────────────────────

@riverpod
class HyodoNotifier extends _$HyodoNotifier {
  @override
  Future<HyodoState> build() async {
    final db = ref.watch(appDatabaseProvider);
    return _calculate(db);
  }

  /// 수동 새로고침
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() {
      final db = ref.read(appDatabaseProvider);
      return _calculate(db);
    });
  }

  Future<HyodoState> _calculate(AppDatabase db) async {
    final allNodes = await db.getAllNodes();
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));

    // Ghost가 아니고 사망하지 않은 모든 노드를 대상으로 함
    final targetNodes = allNodes.where((n) {
      if (n.isGhost) return false;
      if (n.deathDate != null) return false;
      return true;
    }).toList();

    if (targetNodes.isEmpty) {
      return HyodoState.empty;
    }

    final entries = <HyodoEntry>[];

    for (final node in targetNodes) {
      // 최근 30일 기억 수
      final memories = await db.getMemoriesForNode(node.id);
      final recentMemories = memories.where(
        (m) => m.createdAt.isAfter(thirtyDaysAgo),
      );
      final memoryCount = recentMemories.length;

      // 최근 30일 온도 로그 수
      final tempLogs = await db.getTemperatureLogsForNode(
        node.id,
        from: thirtyDaysAgo,
        to: now,
      );
      final tempLogCount = tempLogs.length;

      final recordsLast30Days = memoryCount + tempLogCount;

      // 마지막 기록 이후 경과 일수
      DateTime? lastRecord;
      if (memories.isNotEmpty) {
        lastRecord = memories
            .map((m) => m.createdAt)
            .reduce((a, b) => a.isAfter(b) ? a : b);
      }
      if (tempLogs.isNotEmpty) {
        final lastTemp = tempLogs
            .map((t) => t.date)
            .reduce((a, b) => a.isAfter(b) ? a : b);
        if (lastRecord == null || lastTemp.isAfter(lastRecord)) {
          lastRecord = lastTemp;
        }
      }

      final daysSinceLastRecord = lastRecord != null
          ? now.difference(lastRecord).inDays
          : 999; // 기록 없으면 매우 큰 값

      // 점수 계산:
      //   recordsLast30Days * 10  +  max(0, 30 - daysSinceLastRecord) * 2
      //   최대 100
      final rawScore =
          recordsLast30Days * 10.0 + (30 - daysSinceLastRecord).clamp(0, 30) * 2.0;
      final score = rawScore.clamp(0.0, 100.0);

      entries.add(HyodoEntry(
        nodeId: node.id,
        nodeName: node.nickname ?? node.name,
        photoPath: node.photoPath,
        score: score,
        daysSinceLastRecord: daysSinceLastRecord,
        recordsLast30Days: recordsLast30Days,
        level: _levelFromScore(score),
      ));
    }

    // 점수 낮은 순 정렬 (관심 필요한 노드가 위로)
    entries.sort((a, b) => a.score.compareTo(b.score));

    final averageScore = entries.isEmpty
        ? 0.0
        : entries.fold<double>(0, (sum, e) => sum + e.score) / entries.length;

    final needsAttention = entries.where((e) => e.score < 30).toList();

    return HyodoState(
      entries: entries,
      averageScore: averageScore,
      needsAttention: needsAttention,
    );
  }
}
