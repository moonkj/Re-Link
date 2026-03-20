import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../shared/repositories/db_provider.dart';
import '../../../shared/repositories/settings_repository.dart';
import '../../../core/database/tables/settings_table.dart';

part 'tree_growth_notifier.g.dart';

/// 나무 성장 단계 (5단계)
enum GrowthStage { sprout, sapling, smallTree, bigTree, grandTree }

/// 계절 (캐노피 색상 결정)
enum Season { spring, summer, autumn, winter }

/// 나무 성장 상태
@immutable
class TreeGrowthState {
  const TreeGrowthState({
    this.stage = GrowthStage.sprout,
    this.season = Season.spring,
    this.score = 0,
  });

  final GrowthStage stage;
  final Season season;
  final int score;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TreeGrowthState &&
          runtimeType == other.runtimeType &&
          stage == other.stage &&
          season == other.season &&
          score == other.score;

  @override
  int get hashCode => Object.hash(stage, season, score);
}

/// 가족 나무 성장 노티파이어
///
/// 노드 수, 기억 수, 스트릭 카운트를 기반으로 성장 점수를 계산하고
/// 해당하는 성장 단계와 현재 계절을 반환한다.
@riverpod
class TreeGrowthNotifier extends _$TreeGrowthNotifier {
  @override
  Future<TreeGrowthState> build() async {
    final db = ref.watch(appDatabaseProvider);
    final stats = await db.getStats(); // {nodes: int, memories: int}
    final settings = ref.watch(settingsRepositoryProvider);
    final streakCountStr = await settings.get(SettingsKey.streakCount);
    final streakCount = int.tryParse(streakCountStr ?? '0') ?? 0;

    // 성장 점수: 노드×2 + 기억×1 + 스트릭×0.5
    final score = (stats['nodes'] ?? 0) * 2 +
        (stats['memories'] ?? 0) * 1 +
        (streakCount * 0.5).round();

    // 성장 단계 결정
    final GrowthStage stage;
    if (score <= 10) {
      stage = GrowthStage.sprout;
    } else if (score <= 30) {
      stage = GrowthStage.sapling;
    } else if (score <= 80) {
      stage = GrowthStage.smallTree;
    } else if (score <= 200) {
      stage = GrowthStage.bigTree;
    } else {
      stage = GrowthStage.grandTree;
    }

    // 계절 결정 (월 기반)
    final month = DateTime.now().month;
    final Season season;
    if (month >= 3 && month <= 5) {
      season = Season.spring;
    } else if (month >= 6 && month <= 8) {
      season = Season.summer;
    } else if (month >= 9 && month <= 11) {
      season = Season.autumn;
    } else {
      season = Season.winter;
    }

    // 현재 단계를 설정에 저장 (다른 곳에서 참조 가능)
    await settings.set(SettingsKey.treeGrowthStage, stage.name);

    return TreeGrowthState(stage: stage, season: season, score: score);
  }
}
