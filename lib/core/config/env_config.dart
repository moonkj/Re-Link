/// 환경변수 설정
/// 실제 값은 .env 또는 빌드 시 --dart-define으로 주입
abstract final class EnvConfig {
  // ── Cloudflare Workers API ─────────────────────────────────────────────
  static const String workersBaseUrl = String.fromEnvironment(
    'WORKERS_BASE_URL',
    defaultValue: 'https://api.relink.app',
  );

  static const String r2BucketUrl = String.fromEnvironment(
    'R2_BUCKET_URL',
    defaultValue: '',
  );

  // ── AdMob 앱 ID ────────────────────────────────────────────────────────
  static const String admobAppIdIos = String.fromEnvironment(
    'ADMOB_APP_ID_IOS',
    defaultValue: 'ca-app-pub-3940256099942544~1458002511', // 테스트 ID
  );

  static const String admobAppIdAndroid = String.fromEnvironment(
    'ADMOB_APP_ID_ANDROID',
    defaultValue: 'ca-app-pub-3940256099942544~3347511713', // 테스트 ID
  );

  // ── AdMob 광고 유닛 ID (테스트) ──────────────────────────────────────────
  static const String bannerAdUnitIdIos =
      'ca-app-pub-3940256099942544/2934735716';
  static const String bannerAdUnitIdAndroid =
      'ca-app-pub-3940256099942544/6300978111';
  static const String nativeAdUnitIdIos =
      'ca-app-pub-3940256099942544/3986624511';
  static const String nativeAdUnitIdAndroid =
      'ca-app-pub-3940256099942544/2247696110';

  static bool get isApiConfigured => workersBaseUrl.isNotEmpty;
}
