/// 사용자 요금제
/// - free / plus: 1회성 구매
/// - family / familyPlus: 구독 (월/연)
enum UserPlan {
  free,
  plus,
  family,
  familyPlus;

  String get displayName => switch (this) {
        free => '무료',
        plus => '플러스',
        family => '패밀리',
        familyPlus => '패밀리플러스',
      };

  String get price => switch (this) {
        free => '무료',
        plus => '₩4,900',
        family => '₩3,900/월',
        familyPlus => '₩6,900/월',
      };

  int get maxNodes => switch (this) {
        free => 15,
        plus => 999999, // 무제한
        family => 999999,
        familyPlus => 999999,
      };

  int get maxPhotos => switch (this) {
        free => 50,
        plus => 999999, // 무제한
        family => 999999,
        familyPlus => 999999,
      };

  int get maxVoiceMinutes => switch (this) {
        free => 5,
        plus => 999999, // 무제한
        family => 999999,
        familyPlus => 999999,
      };

  bool get hasVoice => true; // 모든 플랜 음성 지원 (free는 5분 제한)
  bool get hasAds => this == free;
  bool get isUnlimited => this != free;

  // ── 영상 ──────────────────────────────────────────────────────────────────

  bool get hasVideo => this != free;

  /// 영상 1개당 최대 촬영 시간 (초)
  int get maxVideoSeconds => switch (this) {
        free => 0,
        plus => 30,
        family => 180,
        familyPlus => 600,
      };

  /// 영상 최대 저장 개수
  int get maxVideoCount => switch (this) {
        free => 0,
        plus => 10,
        family => 999999, // 무제한
        familyPlus => 999999,
      };

  // ── 클라우드 ──────────────────────────────────────────────────────────────

  bool get hasCloud => this == family || this == familyPlus;

  /// 클라우드 저장 용량 (GB)
  int get cloudStorageGB => switch (this) {
        free => 0,
        plus => 0,
        family => 20,
        familyPlus => 100,
      };

  // ── 가족 공유 ─────────────────────────────────────────────────────────────

  /// 가족 공유 최대 인원
  int get maxFamilyMembers => switch (this) {
        free => 0,
        plus => 0,
        family => 6,
        familyPlus => 999, // 사실상 무제한
      };

  // ── 구독 여부 ─────────────────────────────────────────────────────────────

  /// family / familyPlus만 구독 (월/연)
  bool get isSubscription => this == family || this == familyPlus;
}
