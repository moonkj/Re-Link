import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:flutter/foundation.dart';

/// 카카오 SDK 래퍼 -- 로그인 후 accessToken 반환
///
/// 카카오 개발자 콘솔 설정 필요:
/// 1. https://developers.kakao.com 에서 앱 등록
/// 2. 플랫폼 등록:
///    - Android: com.relink.re_link (키해시 등록)
///    - iOS: com.relink.reLink (번들 ID 등록)
/// 3. 카카오 로그인 활성화 (동의항목 설정)
/// 4. 발급받은 네이티브 앱 키를 아래 위치에 설정:
///    - main.dart: KakaoSdk.init(nativeAppKey: ...)
///    - iOS Info.plist: kakao{NATIVE_APP_KEY} URL Scheme
///    - Android AndroidManifest.xml: kakao{NATIVE_APP_KEY} scheme
class KakaoAuthHelper {
  /// 카카오 로그인 (카카오톡 앱 -> 카카오 계정 폴백)
  ///
  /// 카카오톡이 설치된 경우 카카오톡 앱으로 로그인 시도,
  /// 설치되지 않았거나 실패한 경우 카카오 계정(웹) 로그인으로 폴백
  static Future<String> login() async {
    OAuthToken token;
    if (await isKakaoTalkInstalled()) {
      try {
        token = await UserApi.instance.loginWithKakaoTalk();
      } catch (e) {
        debugPrint('[KakaoAuth] 카카오톡 로그인 실패, 계정 로그인 시도: $e');
        token = await UserApi.instance.loginWithKakaoAccount();
      }
    } else {
      token = await UserApi.instance.loginWithKakaoAccount();
    }
    return token.accessToken;
  }

  /// 카카오 로그아웃
  static Future<void> logout() async {
    try {
      await UserApi.instance.logout();
    } catch (_) {
      // 카카오 로그아웃 실패 무시 (이미 서버 로그아웃 처리됨)
    }
  }

  /// 카카오 연결 해제 (계정 삭제 시)
  /// 카카오 계정과 앱 간의 연결을 완전히 해제합니다.
  static Future<void> unlink() async {
    try {
      await UserApi.instance.unlink();
    } catch (_) {
      // 카카오 연결 해제 실패 무시 (이미 서버 삭제 처리됨)
    }
  }
}
