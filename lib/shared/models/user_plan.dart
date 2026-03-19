/// 사용자 플랜 (1회성 구매)
enum UserPlan {
  free,
  basic,
  premium;

  String get displayName => switch (this) {
        free => 'Free',
        basic => 'Basic',
        premium => 'Premium',
      };

  String get price => switch (this) {
        free => '무료',
        basic => '₩4,900',
        premium => '₩14,900',
      };

  int get maxNodes => switch (this) {
        free => 30,
        basic => 200,
        premium => 999999, // 무제한
      };

  int get maxPhotos => switch (this) {
        free => 50,
        basic => 500,
        premium => 999999, // 무제한
      };

  int get maxVoiceMinutes => switch (this) {
        free => 0, // 음성 미지원
        basic => 30,
        premium => 300,
      };

  bool get hasVoice => this != free;
  bool get hasAds => this != premium;
  bool get isUnlimited => this == premium;
}
