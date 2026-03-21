/// Re-Link 앱 전역 상수
abstract final class AppConstants {
  // ── 앱 정보 ───────────────────────────────────────────────────────────────
  static const String appName = 'Re-Link';
  static const String appTagline = '가족의 기억을 잇다';
  static const String packageName = 'com.relink';

  // ── 인앱 구매 상품 ID (PlanProductIds 참조) ──────────────────────────────
  static const String iapPlusId = 'com.relink.plus';
  static const String iapFamilyMonthlyId = 'com.relink.family_monthly';
  static const String iapFamilyAnnualId = 'com.relink.family_annual';
  static const String iapFamilyPlusMonthlyId = 'com.relink.family_plus_monthly';
  static const String iapFamilyPlusAnnualId = 'com.relink.family_plus_annual';

  // ── 플랜별 제한 (UserPlan enum 참조) ────────────────────────────────────
  static const int freeMaxNodes = 15;
  static const int freeMaxPhotos = 50;
  static const int freeMaxVoiceMinutes = 5;

  // ── 캔버스 ────────────────────────────────────────────────────────────────
  static const double canvasDefaultScale = 1.0;
  static const double canvasMinScale = 0.3;
  static const double canvasMaxScale = 3.0;

  // ── 음성 ─────────────────────────────────────────────────────────────────
  static const int audioSampleRate = 48000;
  static const int audioBitRate = 24000; // Opus 24kbps
  static const String audioExtension = 'm4a'; // Opus in m4a container

  // ── 이미지 ────────────────────────────────────────────────────────────────
  static const int imageMaxWidth = 1920;
  static const int imageMaxHeight = 1920;
  static const int imageQuality = 85;
  static const int thumbnailSize = 300;
  static const int thumbnailQuality = 70;

  // ── Storage 버킷 ──────────────────────────────────────────────────────────
  static const String bucketPhotos = 'photos';
  static const String bucketVoice = 'voice';
  static const String bucketAvatars = 'avatars';

  // ── 캐시 ─────────────────────────────────────────────────────────────────
  static const Duration cacheExpiry = Duration(hours: 24);
  static const String hiveBoxNodes = 'nodes_cache';
  static const String hiveBoxMemories = 'memories_cache';
  static const String hiveBoxProfile = 'profile_cache';
}
