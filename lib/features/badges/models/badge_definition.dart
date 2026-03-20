import 'package:flutter/material.dart';

/// 배지 희귀도
enum BadgeRarity {
  common,
  rare,
  epic,
  legendary;

  String get label => switch (this) {
        common => '일반',
        rare => '희귀',
        epic => '영웅',
        legendary => '전설',
      };
}

/// Re-Link 배지 정의 (20종)
enum BadgeDefinition {
  // ── 노드 관련 ─────────────────────────────────────────────────────────────
  firstNode(
    id: 'firstNode',
    name: '첫 만남',
    description: '첫 번째 가족 구성원 등록',
    icon: Icons.person_add,
    rarity: BadgeRarity.common,
  ),
  family5(
    id: 'family5',
    name: '다섯 식구',
    description: '가족 5명 등록',
    icon: Icons.group,
    rarity: BadgeRarity.common,
  ),
  family10(
    id: 'family10',
    name: '대가족',
    description: '가족 10명 등록',
    icon: Icons.groups,
    rarity: BadgeRarity.rare,
  ),
  family30(
    id: 'family30',
    name: '일가친척',
    description: '가족 30명 등록',
    icon: Icons.diversity_3,
    rarity: BadgeRarity.epic,
  ),
  family100(
    id: 'family100',
    name: '족보 완성',
    description: '가족 100명 등록',
    icon: Icons.account_tree,
    rarity: BadgeRarity.legendary,
  ),

  // ── 기억 관련 ─────────────────────────────────────────────────────────────
  firstMemory(
    id: 'firstMemory',
    name: '첫 기억',
    description: '첫 번째 기억 저장',
    icon: Icons.auto_awesome,
    rarity: BadgeRarity.common,
  ),
  memory10(
    id: 'memory10',
    name: '기억 수집가',
    description: '기억 10개 저장',
    icon: Icons.collections,
    rarity: BadgeRarity.common,
  ),
  memory50(
    id: 'memory50',
    name: '추억 보관함',
    description: '기억 50개 저장',
    icon: Icons.inventory,
    rarity: BadgeRarity.rare,
  ),
  memory100(
    id: 'memory100',
    name: '기억의 전당',
    description: '기억 100개 저장',
    icon: Icons.museum,
    rarity: BadgeRarity.epic,
  ),

  // ── 스트릭 관련 ───────────────────────────────────────────────────────────
  streak7(
    id: 'streak7',
    name: '일주일 연속',
    description: '7일 연속 기록',
    icon: Icons.local_fire_department,
    rarity: BadgeRarity.common,
  ),
  streak30(
    id: 'streak30',
    name: '한 달 연속',
    description: '30일 연속 기록',
    icon: Icons.whatshot,
    rarity: BadgeRarity.rare,
  ),
  streak100(
    id: 'streak100',
    name: '백일 수호자',
    description: '100일 연속 기록',
    icon: Icons.diamond,
    rarity: BadgeRarity.epic,
  ),
  streak365(
    id: 'streak365',
    name: '1년 수호자',
    description: '365일 연속 기록',
    icon: Icons.emoji_events,
    rarity: BadgeRarity.legendary,
  ),

  // ── 특수 활동 ─────────────────────────────────────────────────────────────
  firstCapsule(
    id: 'firstCapsule',
    name: '시간 여행자',
    description: '첫 기억 캡슐 생성',
    icon: Icons.lock_clock,
    rarity: BadgeRarity.common,
  ),
  firstGlossary(
    id: 'firstGlossary',
    name: '언어학자',
    description: '첫 가족 단어 등록',
    icon: Icons.menu_book,
    rarity: BadgeRarity.common,
  ),
  firstMemorial(
    id: 'firstMemorial',
    name: '추모자',
    description: '첫 추모 메시지 남기기',
    icon: Icons.sentiment_very_satisfied,
    rarity: BadgeRarity.common,
  ),

  // ── 탐험 관련 ─────────────────────────────────────────────────────────────
  threeGen(
    id: 'threeGen',
    name: '3대 연결',
    description: '3세대 이상 연결',
    icon: Icons.timeline,
    rarity: BadgeRarity.rare,
  ),
  ghostHunter(
    id: 'ghostHunter',
    name: '고스트 헌터',
    description: 'Ghost 노드 5개 이상',
    icon: Icons.visibility,
    rarity: BadgeRarity.rare,
  ),
  photoCollector(
    id: 'photoCollector',
    name: '사진 수집가',
    description: '사진 기억 30개 이상',
    icon: Icons.photo_library,
    rarity: BadgeRarity.rare,
  ),
  voiceKeeper(
    id: 'voiceKeeper',
    name: '목소리 지킴이',
    description: '음성 기억 10개 이상',
    icon: Icons.mic,
    rarity: BadgeRarity.rare,
  ),

  // ── 특별 배지 ───────────────────────────────────────────────────────────
  coCreator(
    id: 'coCreator',
    name: '공동 제작자',
    description: '앱 개발에 기여한 특별한 분',
    icon: Icons.workspace_premium,
    rarity: BadgeRarity.legendary,
  );

  const BadgeDefinition({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.rarity,
  });

  final String id;
  final String name;
  final String description;
  final IconData icon;
  final BadgeRarity rarity;

  /// ID로 배지 찾기
  static BadgeDefinition? fromId(String id) {
    for (final badge in values) {
      if (badge.id == id) return badge;
    }
    return null;
  }
}
