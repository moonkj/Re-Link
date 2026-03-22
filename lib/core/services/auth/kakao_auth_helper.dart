import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';

import '../../config/env_config.dart';

/// 카카오 로그인 — 인앱 WebView 방식
/// Apple 심사 가이드라인 준수 (외부 Safari 미사용)
/// iOS 26 beta ASWebAuthenticationSession 호환성 문제 우회
class KakaoAuthHelper {
  // REST API 키 (OAuth 인증 페이지 + 토큰 교환 모두 이 키 사용)
  // ⚠️ 빌드 시 --dart-define=KAKAO_REST_API_KEY=... 로 주입
  static String get _restApiKey {
    assert(EnvConfig.kakaoRestApiKey.isNotEmpty,
        'KAKAO_REST_API_KEY가 설정되지 않았습니다. --dart-define으로 주입하세요.');
    return EnvConfig.kakaoRestApiKey;
  }

  // 네이티브 앱 키 (URL Scheme 등록용 — 토큰 교환에 사용하지 않음)
  // ⚠️ 빌드 시 --dart-define=KAKAO_NATIVE_APP_KEY=... 로 주입
  static String get _nativeAppKey => EnvConfig.kakaoNativeAppKey;

  // 클라이언트 시크릿
  // ⚠️ 빌드 시 --dart-define=KAKAO_CLIENT_SECRET=... 로 주입
  static String get _clientSecret {
    assert(EnvConfig.kakaoClientSecret.isNotEmpty,
        'KAKAO_CLIENT_SECRET이 설정되지 않았습니다. --dart-define으로 주입하세요.');
    return EnvConfig.kakaoClientSecret;
  }

  // 카카오 OAuth 리디렉트: Workers 콜백 엔드포인트
  static const _redirectUri = 'https://relink-api.relink-app.workers.dev/auth/kakao/callback';

  /// 카카오 로그인 — 인앱 WebView 바텀시트
  static Future<String> login(BuildContext context) async {
    final authUrl =
        'https://kauth.kakao.com/oauth/authorize'
        '?response_type=code'
        '&client_id=$_restApiKey'
        '&redirect_uri=${Uri.encodeComponent(_redirectUri)}'
        '&prompt=login';

    // 인앱 WebView 바텀시트로 카카오 로그인 표시
    final code = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _KakaoWebViewSheet(authUrl: authUrl),
    );

    if (code == null || code.isEmpty) {
      throw Exception('카카오 로그인이 취소되었습니다');
    }

    // 인증 코드 → access_token 교환
    // ⚠️ client_id는 반드시 REST API 키를 사용해야 함
    // OAuth 인가 요청(authorize)과 토큰 교환(token) 모두 동일한 키 타입 필요
    final tokenResponse = await http.post(
      Uri.parse('https://kauth.kakao.com/oauth/token'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'grant_type': 'authorization_code',
        'client_id': _restApiKey,
        'redirect_uri': _redirectUri,
        'code': code,
        'client_secret': _clientSecret,
      },
    );

    if (tokenResponse.statusCode != 200) {
      debugPrint('[KakaoAuth] 토큰 교환 실패: ${tokenResponse.body}');
      final errorBody = jsonDecode(tokenResponse.body) as Map<String, dynamic>;
      final errorCode = errorBody['error'] ?? '';
      final errorDesc = errorBody['error_description'] ?? '토큰 교환 실패';
      throw Exception('$errorCode: $errorDesc');
    }

    final tokenData = jsonDecode(tokenResponse.body) as Map<String, dynamic>;
    final accessToken = tokenData['access_token'] as String?;

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('카카오 액세스 토큰을 받지 못했습니다');
    }

    debugPrint('[KakaoAuth] 로그인 성공');
    return accessToken;
  }

  static Future<void> logout() async {}
  static Future<void> unlink() async {}
}

/// 카카오 로그인 WebView 바텀시트
class _KakaoWebViewSheet extends StatefulWidget {
  const _KakaoWebViewSheet({required this.authUrl});
  final String authUrl;

  @override
  State<_KakaoWebViewSheet> createState() => _KakaoWebViewSheetState();
}

class _KakaoWebViewSheetState extends State<_KakaoWebViewSheet> {
  late final WebViewController _webCtrl;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _webCtrl = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (_) {
          if (mounted) setState(() => _isLoading = true);
        },
        onPageFinished: (_) {
          if (mounted) setState(() => _isLoading = false);
        },
        onNavigationRequest: (request) {
          final url = request.url;
          // 리디렉트 URL에서 인증 코드 가로채기
          if (url.startsWith(KakaoAuthHelper._redirectUri)) {
            final uri = Uri.parse(url);
            final code = uri.queryParameters['code'];
            if (code != null && code.isNotEmpty) {
              Navigator.of(context).pop(code);
              return NavigationDecision.prevent;
            }
            // 에러 케이스
            final error = uri.queryParameters['error'];
            if (error != null) {
              Navigator.of(context).pop(null);
              return NavigationDecision.prevent;
            }
          }
          return NavigationDecision.navigate;
        },
      ))
      ..loadRequest(Uri.parse(widget.authUrl));
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.85;

    return Container(
      height: height,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // 핸들 바 + 닫기
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const SizedBox(width: 40),
                const Spacer(),
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Icon(Icons.close, size: 24, color: Colors.grey),
                ),
              ],
            ),
          ),
          // 로딩 인디케이터
          if (_isLoading)
            const LinearProgressIndicator(
              color: Color(0xFFFEE500),
              backgroundColor: Color(0xFFF5F5F5),
            ),
          // WebView
          Expanded(
            child: WebViewWidget(controller: _webCtrl),
          ),
        ],
      ),
    );
  }
}
