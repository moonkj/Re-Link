import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/tables/settings_table.dart';
import '../../../shared/repositories/db_provider.dart';
import '../../../shared/repositories/settings_repository.dart';
import '../models/badge_definition.dart';

part 'badge_notifier.g.dart';

/// 배지 시스템 상태 관리
@riverpod
class BadgeNotifier extends _$BadgeNotifier {
  @override
  Future<List<BadgeDefinition>> build() async {
    final settings = ref.read(settingsRepositoryProvider);
    final earnedStr = await settings.get(SettingsKey.earnedBadges) ?? '';
    final earnedIds =
        earnedStr.isEmpty ? <String>{} : earnedStr.split(',').toSet();

    return BadgeDefinition.values
        .where((b) => earnedIds.contains(b.id))
        .toList();
  }

  /// 모든 배지 조건을 검사하고 새로 획득한 배지 목록을 반환
  Future<List<BadgeDefinition>> checkAndAward() async {
    final db = ref.read(appDatabaseProvider);
    final settings = ref.read(settingsRepositoryProvider);

    // 통계 수집
    final stats = await db.getStats();
    final nodeCount = stats['nodes'] ?? 0;
    final memoryCount = stats['memories'] ?? 0;
    final streakCount = await settings.getStreakCount();
    final capsuleCount = await db.capsuleCount();
    final memorialCount = await db.memorialMessageCount();
    final ghostCount = await db.ghostNodeCount();
    final photoCount = await db.memoryCountByType('photo');
    final voiceCount = await db.memoryCountByType('voice');

    // 3세대 연결 체크
    final has3Gen = await _checkThreeGenerations(db);

    // 현재 획득 배지 로드
    final earnedStr = await settings.get(SettingsKey.earnedBadges) ?? '';
    final earned =
        earnedStr.isEmpty ? <String>{} : earnedStr.split(',').toSet();
    final newlyEarned = <BadgeDefinition>[];

    void award(BadgeDefinition badge, bool condition) {
      if (condition && !earned.contains(badge.id)) {
        earned.add(badge.id);
        newlyEarned.add(badge);
      }
    }

    // 노드 배지
    award(BadgeDefinition.firstNode, nodeCount >= 1);
    award(BadgeDefinition.family5, nodeCount >= 5);
    award(BadgeDefinition.family10, nodeCount >= 10);
    award(BadgeDefinition.family30, nodeCount >= 30);
    award(BadgeDefinition.family100, nodeCount >= 100);

    // 기억 배지
    award(BadgeDefinition.firstMemory, memoryCount >= 1);
    award(BadgeDefinition.memory10, memoryCount >= 10);
    award(BadgeDefinition.memory50, memoryCount >= 50);
    award(BadgeDefinition.memory100, memoryCount >= 100);

    // 스트릭 배지
    award(BadgeDefinition.streak7, streakCount >= 7);
    award(BadgeDefinition.streak30, streakCount >= 30);
    award(BadgeDefinition.streak100, streakCount >= 100);
    award(BadgeDefinition.streak365, streakCount >= 365);

    // 특수 활동 배지
    award(BadgeDefinition.firstCapsule, capsuleCount >= 1);
    award(BadgeDefinition.firstMemorial, memorialCount >= 1);

    // 탐험 배지
    award(BadgeDefinition.threeGen, has3Gen);
    award(BadgeDefinition.ghostHunter, ghostCount >= 5);
    award(BadgeDefinition.photoCollector, photoCount >= 30);
    award(BadgeDefinition.voiceKeeper, voiceCount >= 10);

    // 공동 제작자 배지 — changelog.json의 contributors에 등록된 사용자
    final isCoCreator = await _checkCoCreator(settings);
    award(BadgeDefinition.coCreator, isCoCreator);

    if (newlyEarned.isNotEmpty) {
      await settings.set(SettingsKey.earnedBadges, earned.join(','));
      ref.invalidateSelf();
    }

    return newlyEarned;
  }

  /// 3세대 연결 여부 확인 (parent/child 관계 체인이 3단계 이상)
  Future<bool> _checkThreeGenerations(AppDatabase db) async {
    try {
      final edges = await db.select(db.nodeEdgesTable).get();
      // parent/child 관계만 필터
      final parentEdges = edges
          .where((e) => e.relation == 'parent' || e.relation == 'child')
          .toList();

      if (parentEdges.isEmpty) return false;

      // 부모→자식 그래프 구축 (from=parent, to=child for 'parent' relation)
      final childrenOf = <String, Set<String>>{};
      for (final edge in parentEdges) {
        if (edge.relation == 'parent') {
          // parent 관계: toNode이 fromNode의 부모 → toNode의 자녀 = fromNode
          childrenOf.putIfAbsent(edge.toNodeId, () => <String>{});
          childrenOf[edge.toNodeId]!.add(edge.fromNodeId);
        } else {
          // child 관계: fromNode이 toNode의 부모 → fromNode의 자녀 = toNode
          childrenOf.putIfAbsent(edge.fromNodeId, () => <String>{});
          childrenOf[edge.fromNodeId]!.add(edge.toNodeId);
        }
      }

      // DFS로 최대 깊이 탐색
      int maxDepth(String nodeId, Set<String> visited) {
        if (visited.contains(nodeId)) return 0;
        visited.add(nodeId);
        final children = childrenOf[nodeId];
        if (children == null || children.isEmpty) return 1;
        int best = 1;
        for (final child in children) {
          final d = 1 + maxDepth(child, visited);
          if (d > best) best = d;
        }
        return best;
      }

      // 모든 루트 노드에서 시작하여 최대 깊이 확인
      for (final nodeId in childrenOf.keys) {
        if (maxDepth(nodeId, <String>{}) >= 3) return true;
      }
    } catch (_) {
      // DB 에러 시 false
    }
    return false;
  }

  /// 공동 제작자 여부 확인
  ///
  /// changelog.json의 모든 엔트리 contributors에서
  /// 현재 사용자의 노드 ID가 포함되어 있는지 확인
  Future<bool> _checkCoCreator(SettingsRepository settings) async {
    try {
      final db = ref.read(appDatabaseProvider);
      final jsonStr =
          await rootBundle.loadString('assets/data/changelog.json');
      final data = json.decode(jsonStr) as Map<String, dynamic>;
      final entries = data['entries'] as List<dynamic>? ?? [];

      // 모든 contributor의 nodeId 수집
      final contributorNodeIds = <String>{};
      for (final entry in entries) {
        final contributors =
            (entry as Map<String, dynamic>)['contributors'] as List<dynamic>? ??
                [];
        for (final c in contributors) {
          final nodeId = (c as Map<String, dynamic>)['nodeId'] as String?;
          if (nodeId != null && nodeId.isNotEmpty) {
            contributorNodeIds.add(nodeId);
          }
        }
      }

      if (contributorNodeIds.isEmpty) return false;

      // 현재 DB의 모든 노드 ID와 대조
      final allNodes = await db.select(db.nodesTable).get();
      for (final node in allNodes) {
        if (contributorNodeIds.contains(node.id)) return true;
      }
    } catch (_) {
      // JSON 로드 실패 시 무시
    }
    return false;
  }

  /// 획득 배지 ID 집합
  Future<Set<String>> getEarnedIds() async {
    final settings = ref.read(settingsRepositoryProvider);
    final earnedStr = await settings.get(SettingsKey.earnedBadges) ?? '';
    return earnedStr.isEmpty ? <String>{} : earnedStr.split(',').toSet();
  }
}
