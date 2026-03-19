/// Re-Link 앱 전역 상수
abstract final class AppConstants {
  // ── 앱 정보 ───────────────────────────────────────────────────────────────
  static const String appName = 'Re-Link';
  static const String appTagline = '가족의 기억을 잇다';
  static const String packageName = 'com.relink';

  // ── 인앱 구매 상품 ID ─────────────────────────────────────────────────────
  static const String iapBasicId = 'com.relink.basic';
  static const String iapPremiumId = 'com.relink.premium';
  static const String iapUpgradeId = 'com.relink.upgrade_basic_to_premium';

  // ── 플랜별 제한 ───────────────────────────────────────────────────────────
  static const int freeMaxNodes = 30;
  static const int freeMaxPhotos = 50;
  static const int freeMaxAiCalls = 10; // 월
  static const int basicMaxNodes = 200;
  static const int basicMaxPhotos = 500;
  static const int basicMaxAiCalls = 100; // 월
  static const int basicMaxVoiceMinutes = 30;
  static const int premiumMaxVoiceMinutes = 300;

  // ── Supabase Realtime ─────────────────────────────────────────────────────
  static const String realtimeChannel = 'family_sync';

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
