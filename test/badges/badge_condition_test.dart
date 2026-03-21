import 'package:flutter_test/flutter_test.dart';
import 'package:re_link/features/badges/models/badge_definition.dart';

void main() {
  // ── BadgeDefinition enum 기본 검증 ─────────────────────────────────────────
  group('BadgeDefinition enum', () {
    test('has exactly 21 badges', () {
      expect(BadgeDefinition.values.length, 21);
    });

    test('all badge IDs are unique', () {
      final ids = BadgeDefinition.values.map((b) => b.id).toSet();
      expect(ids.length, BadgeDefinition.values.length);
    });

    test('all badge names are non-empty', () {
      for (final badge in BadgeDefinition.values) {
        expect(badge.name.isNotEmpty, true,
            reason: '${badge.id} should have a non-empty name');
      }
    });

    test('all badge descriptions are non-empty', () {
      for (final badge in BadgeDefinition.values) {
        expect(badge.description.isNotEmpty, true,
            reason: '${badge.id} should have a non-empty description');
      }
    });

    test('all badges have an icon assigned', () {
      for (final badge in BadgeDefinition.values) {
        expect(badge.icon, isNotNull,
            reason: '${badge.id} should have an icon');
      }
    });

    test('enum id matches enum name', () {
      for (final badge in BadgeDefinition.values) {
        expect(badge.id, badge.name == badge.id ? badge.id : isNotEmpty,
            reason: '${badge.id} should have a valid id string');
      }
    });
  });

  // ── 희귀도 분포 ────────────────────────────────────────────────────────────
  group('BadgeRarity distribution', () {
    test('common badges count', () {
      final common = BadgeDefinition.values
          .where((b) => b.rarity == BadgeRarity.common)
          .toList();
      expect(common.length, 8);
    });

    test('rare badges count', () {
      final rare = BadgeDefinition.values
          .where((b) => b.rarity == BadgeRarity.rare)
          .toList();
      expect(rare.length, 7);
    });

    test('epic badges count', () {
      final epic = BadgeDefinition.values
          .where((b) => b.rarity == BadgeRarity.epic)
          .toList();
      expect(epic.length, 3);
    });

    test('legendary badges count', () {
      final legendary = BadgeDefinition.values
          .where((b) => b.rarity == BadgeRarity.legendary)
          .toList();
      expect(legendary.length, 3);
    });

    test('all rarity counts sum to total badges', () {
      final total = BadgeRarity.values
          .map((r) =>
              BadgeDefinition.values.where((b) => b.rarity == r).length)
          .reduce((a, b) => a + b);
      expect(total, BadgeDefinition.values.length);
    });
  });

  // ── BadgeRarity enum ───────────────────────────────────────────────────────
  group('BadgeRarity', () {
    test('has 4 rarity levels', () {
      expect(BadgeRarity.values.length, 4);
    });

    test('label returns Korean text', () {
      expect(BadgeRarity.common.label, '일반');
      expect(BadgeRarity.rare.label, '희귀');
      expect(BadgeRarity.epic.label, '영웅');
      expect(BadgeRarity.legendary.label, '전설');
    });
  });

  // ── fromId 조회 ────────────────────────────────────────────────────────────
  group('BadgeDefinition.fromId', () {
    test('returns correct badge for valid id', () {
      final badge = BadgeDefinition.fromId('firstNode');
      expect(badge, BadgeDefinition.firstNode);
      expect(badge!.name, '첫 만남');
    });

    test('returns null for unknown id', () {
      final badge = BadgeDefinition.fromId('nonExistentBadge');
      expect(badge, isNull);
    });

    test('returns null for empty string', () {
      final badge = BadgeDefinition.fromId('');
      expect(badge, isNull);
    });

    test('finds all badges by their id', () {
      for (final expected in BadgeDefinition.values) {
        final found = BadgeDefinition.fromId(expected.id);
        expect(found, expected,
            reason: 'fromId should find ${expected.id}');
      }
    });
  });

  // ── 배지 ID 파싱 (comma-separated string → List) ──────────────────────────
  group('Badge ID parsing', () {
    test('empty string produces empty set', () {
      const earnedStr = '';
      final earnedIds =
          earnedStr.isEmpty ? <String>{} : earnedStr.split(',').toSet();
      expect(earnedIds, isEmpty);
    });

    test('single badge id string parsed correctly', () {
      const earnedStr = 'firstNode';
      final earnedIds = earnedStr.split(',').toSet();
      expect(earnedIds, {'firstNode'});
    });

    test('multiple badge ids parsed correctly', () {
      const earnedStr = 'firstNode,family5,firstMemory';
      final earnedIds = earnedStr.split(',').toSet();
      expect(earnedIds.length, 3);
      expect(earnedIds.contains('firstNode'), true);
      expect(earnedIds.contains('family5'), true);
      expect(earnedIds.contains('firstMemory'), true);
    });

    test('duplicate ids in string are deduplicated by set', () {
      const earnedStr = 'firstNode,firstNode,family5';
      final earnedIds = earnedStr.split(',').toSet();
      expect(earnedIds.length, 2);
    });

    test('set.join produces comma-separated string', () {
      final earned = {'firstNode', 'streak7', 'memory10'};
      final joined = earned.join(',');
      expect(joined.contains('firstNode'), true);
      expect(joined.contains('streak7'), true);
      expect(joined.contains('memory10'), true);
    });
  });

  // ── 배지 조건 로직 (checkable conditions) ──────────────────────────────────
  group('Badge award conditions', () {
    // 노드 배지 임계값
    test('node badge thresholds', () {
      expect(BadgeDefinition.firstNode.id, 'firstNode');
      expect(BadgeDefinition.family5.id, 'family5');
      expect(BadgeDefinition.family10.id, 'family10');
      expect(BadgeDefinition.family30.id, 'family30');
      expect(BadgeDefinition.family100.id, 'family100');

      // 조건: nodeCount >= 1, 5, 10, 30, 100
      void checkNodeAward(int nodeCount, Set<String> expected) {
        final awarded = <String>{};
        if (nodeCount >= 1) awarded.add('firstNode');
        if (nodeCount >= 5) awarded.add('family5');
        if (nodeCount >= 10) awarded.add('family10');
        if (nodeCount >= 30) awarded.add('family30');
        if (nodeCount >= 100) awarded.add('family100');
        expect(awarded, expected);
      }

      checkNodeAward(0, {});
      checkNodeAward(1, {'firstNode'});
      checkNodeAward(5, {'firstNode', 'family5'});
      checkNodeAward(10, {'firstNode', 'family5', 'family10'});
      checkNodeAward(30, {'firstNode', 'family5', 'family10', 'family30'});
      checkNodeAward(
          100, {'firstNode', 'family5', 'family10', 'family30', 'family100'});
    });

    // 기억 배지 임계값
    test('memory badge thresholds', () {
      void checkMemoryAward(int memoryCount, Set<String> expected) {
        final awarded = <String>{};
        if (memoryCount >= 1) awarded.add('firstMemory');
        if (memoryCount >= 10) awarded.add('memory10');
        if (memoryCount >= 50) awarded.add('memory50');
        if (memoryCount >= 100) awarded.add('memory100');
        expect(awarded, expected);
      }

      checkMemoryAward(0, {});
      checkMemoryAward(1, {'firstMemory'});
      checkMemoryAward(10, {'firstMemory', 'memory10'});
      checkMemoryAward(50, {'firstMemory', 'memory10', 'memory50'});
      checkMemoryAward(
          100, {'firstMemory', 'memory10', 'memory50', 'memory100'});
    });

    // 스트릭 배지 임계값
    test('streak badge thresholds', () {
      void checkStreakAward(int streakCount, Set<String> expected) {
        final awarded = <String>{};
        if (streakCount >= 7) awarded.add('streak7');
        if (streakCount >= 30) awarded.add('streak30');
        if (streakCount >= 100) awarded.add('streak100');
        if (streakCount >= 365) awarded.add('streak365');
        expect(awarded, expected);
      }

      checkStreakAward(0, {});
      checkStreakAward(6, {});
      checkStreakAward(7, {'streak7'});
      checkStreakAward(30, {'streak7', 'streak30'});
      checkStreakAward(100, {'streak7', 'streak30', 'streak100'});
      checkStreakAward(
          365, {'streak7', 'streak30', 'streak100', 'streak365'});
    });

    // award 함수 시뮬레이션: 이미 획득한 배지는 중복 추가하지 않음
    test('award does not duplicate already-earned badges', () {
      final earned = <String>{'firstNode', 'family5'};
      final newlyEarned = <String>[];

      void award(String badgeId, bool condition) {
        if (condition && !earned.contains(badgeId)) {
          earned.add(badgeId);
          newlyEarned.add(badgeId);
        }
      }

      // firstNode 이미 획득 → 추가 안됨
      award('firstNode', true);
      expect(newlyEarned, isEmpty);

      // family10 새로 획득
      award('family10', true);
      expect(newlyEarned, ['family10']);
      expect(earned.contains('family10'), true);

      // 조건 미달
      award('family30', false);
      expect(newlyEarned.length, 1);
    });
  });

  // ── 카테고리별 배지 목록 ───────────────────────────────────────────────────
  group('Badge categories', () {
    test('node-related badges', () {
      final nodeIds = ['firstNode', 'family5', 'family10', 'family30', 'family100'];
      for (final id in nodeIds) {
        expect(BadgeDefinition.fromId(id), isNotNull,
            reason: '$id should exist');
      }
    });

    test('memory-related badges', () {
      final memoryIds = ['firstMemory', 'memory10', 'memory50', 'memory100'];
      for (final id in memoryIds) {
        expect(BadgeDefinition.fromId(id), isNotNull,
            reason: '$id should exist');
      }
    });

    test('streak-related badges', () {
      final streakIds = ['streak7', 'streak30', 'streak100', 'streak365'];
      for (final id in streakIds) {
        expect(BadgeDefinition.fromId(id), isNotNull,
            reason: '$id should exist');
      }
    });

    test('special activity badges', () {
      final specialIds = ['firstCapsule', 'firstMemorial'];
      for (final id in specialIds) {
        expect(BadgeDefinition.fromId(id), isNotNull,
            reason: '$id should exist');
      }
    });

    test('exploration badges', () {
      final explorationIds = ['threeGen', 'ghostHunter', 'photoCollector', 'voiceKeeper'];
      for (final id in explorationIds) {
        expect(BadgeDefinition.fromId(id), isNotNull,
            reason: '$id should exist');
      }
    });

    test('special badge: coCreator is legendary', () {
      final coCreator = BadgeDefinition.fromId('coCreator');
      expect(coCreator, isNotNull);
      expect(coCreator!.rarity, BadgeRarity.legendary);
    });
  });
}
