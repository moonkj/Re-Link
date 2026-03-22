import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../../../shared/models/auth_user.dart';
import 'auth_http_client.dart';
import 'auth_token_storage.dart';
import 'kakao_auth_helper.dart';

part 'auth_service.g.dart';

/// Riverpod provider — AuthService
@riverpod
AuthService authService(Ref ref) {
  return AuthService(
    tokenStorage: ref.read(authTokenStorageProvider),
    httpClient: ref.read(authHttpClientProvider),
  );
}

/// Apple/Google 소셜 로그인 + Cloudflare Workers JWT 인증 서비스
class AuthService {
  AuthService({
    required this.tokenStorage,
    required this.httpClient,
    GoogleSignIn? googleSignIn,
  }) : _googleSignIn = googleSignIn ??
            GoogleSignIn(
              scopes: ['email', 'profile'],
            );

  final AuthTokenStorage tokenStorage;
  final AuthHttpClient httpClient;
  final GoogleSignIn _googleSignIn;

  // ── Apple Sign-In ──────────────────────────────────────────────────────

  /// Apple ID로 로그인
  /// 1. sign_in_with_apple → Apple ID 토큰 획득
  /// 2. POST /auth/apple → JWT 발급
  /// 3. 토큰 저장 + AuthUser 반환
  Future<AuthUser?> signInWithApple() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final idToken = credential.identityToken;
      if (idToken == null) return null;

      final response = await httpClient.post(
        '/auth/apple',
        body: {
          'id_token': idToken,
          if (credential.authorizationCode.isNotEmpty)
            'authorization_code': credential.authorizationCode,
          if (credential.givenName != null)
            'given_name': credential.givenName,
          if (credential.familyName != null)
            'family_name': credential.familyName,
        },
        requiresAuth: false,
      );

      return _handleAuthResponse(response.body, response.statusCode);
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        // 사용자가 직접 취소 — 에러 아님
        return null;
      }
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  // ── Google Sign-In ─────────────────────────────────────────────────────

  /// Google 계정으로 로그인
  /// 1. google_sign_in → Google ID 토큰 획득
  /// 2. POST /auth/google → JWT 발급
  /// 3. 토큰 저장 + AuthUser 반환
  Future<AuthUser?> signInWithGoogle() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) return null; // 사용자 취소

      final auth = await account.authentication;
      final idToken = auth.idToken;
      if (idToken == null) return null;

      final response = await httpClient.post(
        '/auth/google',
        body: {'id_token': idToken},
        requiresAuth: false,
      );

      return _handleAuthResponse(response.body, response.statusCode);
    } catch (_) {
      rethrow;
    }
  }

  // ── Kakao Sign-In ─────────────────────────────────────────────────────

  /// 카카오 계정으로 로그인 (REST 기반)
  /// 1. 카카오 SDK → 카카오 액세스 토큰 획득
  /// 2. POST /auth/kakao → JWT 발급
  /// 3. 토큰 저장 + AuthUser 반환
  ///
  /// TODO: 카카오 네이티브 SDK 연동 필요
  /// - pubspec.yaml에 kakao_flutter_sdk 추가
  /// - iOS: Info.plist에 KAKAO_APP_KEY, URL Scheme 등록
  /// - Android: AndroidManifest.xml에 kakao redirect scheme 추가
  /// - Kakao Developers 콘솔에서 앱 등록 및 플랫폼 설정
  /// 현재는 카카오 토큰을 받아 서버에 전달하는 구조만 구현
  Future<AuthUser?> signInWithKakao({required String kakaoAccessToken}) async {
    try {
      final response = await httpClient.post(
        '/auth/kakao',
        body: {'access_token': kakaoAccessToken},
        requiresAuth: false,
      );

      return _handleAuthResponse(response.body, response.statusCode);
    } catch (_) {
      rethrow;
    }
  }

  // ── 토큰 갱신 ──────────────────────────────────────────────────────────

  /// 저장된 리프레시 토큰으로 새 액세스 토큰 발급
  /// AuthHttpClient 내부에서도 자동 갱신하지만 수동 호출도 가능
  Future<String?> refreshAccessToken() async {
    final refreshToken = await tokenStorage.getRefreshToken();
    if (refreshToken == null) return null;

    final response = await httpClient.post(
      '/auth/refresh',
      body: {'refresh_token': refreshToken},
      requiresAuth: false,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final newAccessToken = data['access_token'] as String?;
      final newRefreshToken = data['refresh_token'] as String?;

      if (newAccessToken != null && newRefreshToken != null) {
        await tokenStorage.saveTokens(
          accessToken: newAccessToken,
          refreshToken: newRefreshToken,
        );
        return newAccessToken;
      }
    }
    return null;
  }

  // ── 로그아웃 ───────────────────────────────────────────────────────────

  /// 로그아웃 (서버 세션 무효화 + 로컬 토큰 삭제)
  Future<void> signOut() async {
    try {
      // 서버 세션 무효화 시도 (실패해도 로컬 정리 진행)
      await httpClient.post('/auth/signout', body: {});
    } catch (_) {
      // 네트워크 오류 무시
    }

    // Google 로그아웃 (연결된 경우)
    try {
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }
    } catch (_) {
      // Google 로그아웃 실패 무시
    }

    // 카카오 로그아웃 (연결된 경우)
    await KakaoAuthHelper.logout();

    // 로컬 토큰 삭제
    await tokenStorage.clearTokens();
  }

  // ── 계정 삭제 ──────────────────────────────────────────────────────────

  /// 계정 완전 삭제 (GDPR / AppStore 정책 준수)
  /// 서버 삭제 성공 시에만 로컬 토큰 정리
  Future<void> deleteAccount() async {
    // 서버에 계정 삭제 요청
    final response = await httpClient.delete('/auth/account');

    // 서버 삭제 실패 시 로컬 토큰 유지 + 예외 throw
    if (response.statusCode != 200 && response.statusCode != 204) {
      final message = _parseErrorMessage(response.body) ?? '계정 삭제에 실패했습니다';
      throw AuthException(message, response.statusCode);
    }

    // 서버 삭제 성공 → 로컬 토큰 삭제
    await tokenStorage.clearTokens();

    // Apple Sign-In 자격 증명 취소 (AppStore 심사 필수)
    try {
      // Apple은 서버사이드 토큰 폐기가 필요 — authorization_code 전달
      // 서버에서 Apple REST API /auth/revoke 호출 처리
    } catch (_) {
      // Apple 자격 증명 취소 실패는 무시 (이미 서버 삭제 완료)
    }

    // Google 로그아웃 (연결된 경우)
    try {
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.disconnect(); // disconnect()로 앱 권한도 해제
      }
    } catch (_) {
      // Google 로그아웃 실패 무시 (이미 서버 삭제 완료)
    }

    // 카카오 연결 해제 (계정과 앱 간 연결 완전 해제)
    await KakaoAuthHelper.unlink();
  }

  /// 서버 에러 응답에서 메시지 추출
  String? _parseErrorMessage(String body) {
    try {
      final data = jsonDecode(body) as Map<String, dynamic>?;
      return data?['message'] as String?;
    } catch (_) {
      return null;
    }
  }

  // ── 자동 로그인 ────────────────────────────────────────────────────────

  /// 앱 시작 시 저장된 토큰으로 자동 로그인 시도
  /// 성공 시 AuthUser 반환, 실패 시 null 반환
  Future<AuthUser?> tryAutoLogin() async {
    try {
      final accessToken = await tokenStorage.getAccessToken();
      if (accessToken == null) return null;

      // 저장된 액세스 토큰으로 /auth/me 호출
      final response = await httpClient.get('/auth/me');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final user = data['user'] as Map<String, dynamic>?;
        if (user == null) return null;

        // 최신 토큰 다시 읽기 (401 자동 갱신이 발생했을 수 있음)
        final latestToken = await tokenStorage.getAccessToken();
        return AuthUser.fromJson(user, latestToken ?? accessToken);
      }

      return null;
    } catch (_) {
      return null;
    }
  }

  // ── 내부 헬퍼 ─────────────────────────────────────────────────────────

  /// 서버 응답 본문을 파싱하여 토큰 저장 + AuthUser 생성
  Future<AuthUser?> _handleAuthResponse(String body, int statusCode) async {
    if (statusCode != 200 && statusCode != 201) {
      final errorData = jsonDecode(body) as Map<String, dynamic>?;
      final message = errorData?['message'] as String? ?? '인증에 실패했습니다';
      throw AuthException(message, statusCode);
    }

    final data = jsonDecode(body) as Map<String, dynamic>;

    final accessToken = data['access_token'] as String?;
    final refreshToken = data['refresh_token'] as String?;
    final userData = data['user'] as Map<String, dynamic>?;

    if (accessToken == null || refreshToken == null || userData == null) {
      throw const AuthException('서버 응답 형식이 올바르지 않습니다', 500);
    }

    final user = AuthUser.fromJson(userData, accessToken);

    await tokenStorage.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
      userId: user.id,
    );

    return user;
  }
}

/// 인증 관련 예외
class AuthException implements Exception {
  const AuthException(this.message, this.statusCode);

  final String message;
  final int statusCode;

  bool get isNetworkError => statusCode == 0;
  bool get isServerError => statusCode >= 500;
  bool get isClientError => statusCode >= 400 && statusCode < 500;

  @override
  String toString() => 'AuthException($statusCode): $message';
}
