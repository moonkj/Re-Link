import 'package:flutter/foundation.dart';
import 'dart:io';

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

  // ── AdMob 광고 유닛 ID ───────────────────────────────────────────────────
  // 프로덕션 ID는 --dart-define으로 주입, 미주입 시 테스트 ID 사용

  // 테스트 ID (Google 공식)
  static const String _testBannerIdIos =
      'ca-app-pub-3940256099942544/2934735716';
  static const String _testBannerIdAndroid =
      'ca-app-pub-3940256099942544/6300978111';
  static const String _testNativeIdIos =
      'ca-app-pub-3940256099942544/3986624511';
  static const String _testNativeIdAndroid =
      'ca-app-pub-3940256099942544/2247696110';

  // 프로덕션 ID (빌드 시 주입)
  static const String _prodBannerIdIos = String.fromEnvironment(
    'ADMOB_BANNER_ID_IOS',
    defaultValue: '', // 미주입 시 빈 문자열
  );
  static const String _prodBannerIdAndroid = String.fromEnvironment(
    'ADMOB_BANNER_ID_ANDROID',
    defaultValue: '',
  );
  static const String _prodNativeIdIos = String.fromEnvironment(
    'ADMOB_NATIVE_ID_IOS',
    defaultValue: '',
  );
  static const String _prodNativeIdAndroid = String.fromEnvironment(
    'ADMOB_NATIVE_ID_ANDROID',
    defaultValue: '',
  );

  /// 배너 광고 유닛 ID — kDebugMode면 항상 테스트 ID, 릴리스면 프로덕션 ID 사용
  static String get bannerAdUnitId {
    if (kDebugMode) {
      return Platform.isIOS ? _testBannerIdIos : _testBannerIdAndroid;
    }
    final prodId =
        Platform.isIOS ? _prodBannerIdIos : _prodBannerIdAndroid;
    // 프로덕션 ID 미설정 시 테스트 ID 폴백 (릴리스 빌드에서도 안전)
    if (prodId.isEmpty) {
      return Platform.isIOS ? _testBannerIdIos : _testBannerIdAndroid;
    }
    return prodId;
  }

  /// 네이티브 광고 유닛 ID — kDebugMode면 항상 테스트 ID
  static String get nativeAdUnitId {
    if (kDebugMode) {
      return Platform.isIOS ? _testNativeIdIos : _testNativeIdAndroid;
    }
    final prodId =
        Platform.isIOS ? _prodNativeIdIos : _prodNativeIdAndroid;
    if (prodId.isEmpty) {
      return Platform.isIOS ? _testNativeIdIos : _testNativeIdAndroid;
    }
    return prodId;
  }

  static bool get isApiConfigured => workersBaseUrl.isNotEmpty;
}
