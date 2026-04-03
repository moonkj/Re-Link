/// AuthService 실제 코드 테스트 (MockClient + FakeTokenStorage)
/// 커버: auth_service.dart — _handleAuthResponse, _parseErrorMessage,
///        refreshAccessToken, signInWithKakao, signOut, deleteAccount
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:re_link/core/services/auth/auth_http_client.dart';
import 'package:re_link/core/services/auth/auth_service.dart';
import 'package:re_link/core/services/auth/auth_token_storage.dart';

/// 테스트용 토큰 저장소
class FakeTokenStorage implements AuthTokenStorage {
  String? _accessToken;
  String? _refreshToken;
  String? _userId;

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    String? userId,
  }) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    if (userId != null) _userId = userId;
  }

  @override
  Future<String?> getAccessToken() async => _accessToken;

  @override
  Future<String?> getRefreshToken() async => _refreshToken;

  @override
  Future<String?> getUserId() async => _userId;

  @override
  Future<void> clearTokens() async {
    _accessToken = null;
    _refreshToken = null;
    _userId = null;
  }

  @override
  Future<void> updateAccessToken(String accessToken) async {
    _accessToken = accessToken;
  }
}

void main() {
  late FakeTokenStorage tokenStorage;

  setUp(() {
    tokenStorage = FakeTokenStorage();
  });

  // ── signInWithKakao ────────────────────────────────────────────────────

  group('AuthService.signInWithKakao', () {
    test('successful login → saves tokens + returns AuthUser', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path == '/auth/kakao') {
          final body = jsonDecode(request.body);
          expect(body['access_token'], 'kakao_token_123');
          return http.Response(
            jsonEncode({
              'access_token': 'jwt_at',
              'refresh_token': 'jwt_rt',
              'user': {
                'id': 'usr_kakao_1',
                'email': 'kakao@test.com',
                'provider': 'kakao',
                'plan': 'free',
              },
            }),
            200,
          );
        }
        return http.Response('{}', 404);
      });

      final httpClient = AuthHttpClient(
        tokenStorage: tokenStorage,
        baseUrl: 'https://api.test.com',
        httpClient: mockClient,
      );

      final authService = AuthService(
        tokenStorage: tokenStorage,
        httpClient: httpClient,
      );

      final user = await authService.signInWithKakao(
        kakaoAccessToken: 'kakao_token_123',
      );

      expect(user, isNotNull);
      expect(user!.id, 'usr_kakao_1');
      expect(user.email, 'kakao@test.com');
      expect(user.provider, 'kakao');
      expect(user.accessToken, 'jwt_at');

      // Verify tokens saved
      expect(await tokenStorage.getAccessToken(), 'jwt_at');
      expect(await tokenStorage.getRefreshToken(), 'jwt_rt');
    });

    test('server error → throws AuthException', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({'message': 'auth_failed'}),
          401,
        );
      });

      final httpClient = AuthHttpClient(
        tokenStorage: tokenStorage,
        baseUrl: 'https://api.test.com',
        httpClient: mockClient,
      );

      final authService = AuthService(
        tokenStorage: tokenStorage,
        httpClient: httpClient,
      );

      expect(
        () => authService.signInWithKakao(kakaoAccessToken: 'bad_token'),
        throwsA(isA<AuthException>()),
      );
    });

    test('missing response fields → throws AuthException', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'access_token': 'at',
            // missing refresh_token and user
          }),
          200,
        );
      });

      final httpClient = AuthHttpClient(
        tokenStorage: tokenStorage,
        baseUrl: 'https://api.test.com',
        httpClient: mockClient,
      );

      final authService = AuthService(
        tokenStorage: tokenStorage,
        httpClient: httpClient,
      );

      expect(
        () => authService.signInWithKakao(kakaoAccessToken: 'tok'),
        throwsA(isA<AuthException>()),
      );
    });
  });

  // ── refreshAccessToken ────────────────────────────────────────────────

  group('AuthService.refreshAccessToken', () {
    test('successful refresh → returns new access token', () async {
      await tokenStorage.saveTokens(
        accessToken: 'old_at',
        refreshToken: 'valid_rt',
      );

      final mockClient = MockClient((request) async {
        if (request.url.path == '/auth/refresh') {
          return http.Response(
            jsonEncode({
              'access_token': 'new_at',
              'refresh_token': 'new_rt',
            }),
            200,
          );
        }
        return http.Response('{}', 404);
      });

      final httpClient = AuthHttpClient(
        tokenStorage: tokenStorage,
        baseUrl: 'https://api.test.com',
        httpClient: mockClient,
      );

      final authService = AuthService(
        tokenStorage: tokenStorage,
        httpClient: httpClient,
      );

      final newToken = await authService.refreshAccessToken();
      expect(newToken, 'new_at');

      // Verify tokens updated
      expect(await tokenStorage.getAccessToken(), 'new_at');
      expect(await tokenStorage.getRefreshToken(), 'new_rt');
    });

    test('no refresh token → returns null', () async {
      // No tokens stored
      final mockClient = MockClient((request) async {
        return http.Response('{}', 200);
      });

      final httpClient = AuthHttpClient(
        tokenStorage: tokenStorage,
        baseUrl: 'https://api.test.com',
        httpClient: mockClient,
      );

      final authService = AuthService(
        tokenStorage: tokenStorage,
        httpClient: httpClient,
      );

      final result = await authService.refreshAccessToken();
      expect(result, isNull);
    });

    test('server rejects refresh → returns null', () async {
      await tokenStorage.saveTokens(
        accessToken: 'at',
        refreshToken: 'expired_rt',
      );

      final mockClient = MockClient((request) async {
        return http.Response('{"error":"expired"}', 401);
      });

      final httpClient = AuthHttpClient(
        tokenStorage: tokenStorage,
        baseUrl: 'https://api.test.com',
        httpClient: mockClient,
      );

      final authService = AuthService(
        tokenStorage: tokenStorage,
        httpClient: httpClient,
      );

      final result = await authService.refreshAccessToken();
      expect(result, isNull);
    });
  });

  // NOTE: signOut and deleteAccount tests are skipped because they
  // internally call GoogleSignIn.isSignedIn() and KakaoAuthHelper.logout()/unlink()
  // which require platform channels not available in unit tests.
  // These are better tested as integration tests.

  // ── _parseErrorMessage (tested indirectly via deleteAccount error path) ─

  group('AuthService error handling', () {
    test('server error 500 with message → AuthException thrown', () async {
      await tokenStorage.saveTokens(
        accessToken: 'at',
        refreshToken: 'rt',
      );

      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({'message': 'internal_server_error'}),
          500,
        );
      });

      final httpClient = AuthHttpClient(
        tokenStorage: tokenStorage,
        baseUrl: 'https://api.test.com',
        httpClient: mockClient,
      );

      final authService = AuthService(
        tokenStorage: tokenStorage,
        httpClient: httpClient,
      );

      // signInWithKakao triggers _handleAuthResponse for error cases
      try {
        await authService.signInWithKakao(kakaoAccessToken: 'tok');
        fail('Should have thrown');
      } on AuthException catch (e) {
        expect(e.statusCode, 500);
        expect(e.message, 'internal_server_error');
        expect(e.isServerError, isTrue);
      }
    });

    test('server 201 response → treated as success', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'access_token': 'at201',
            'refresh_token': 'rt201',
            'user': {
              'id': 'usr_201',
              'provider': 'kakao',
              'plan': 'plus',
            },
          }),
          201,
        );
      });

      final httpClient = AuthHttpClient(
        tokenStorage: tokenStorage,
        baseUrl: 'https://api.test.com',
        httpClient: mockClient,
      );

      final authService = AuthService(
        tokenStorage: tokenStorage,
        httpClient: httpClient,
      );

      final user = await authService.signInWithKakao(
        kakaoAccessToken: 'tok',
      );
      expect(user, isNotNull);
      expect(user!.id, 'usr_201');
    });

    test('error response without message field → default message', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({'error': 'unknown'}),
          400,
        );
      });

      final httpClient = AuthHttpClient(
        tokenStorage: tokenStorage,
        baseUrl: 'https://api.test.com',
        httpClient: mockClient,
      );

      final authService = AuthService(
        tokenStorage: tokenStorage,
        httpClient: httpClient,
      );

      try {
        await authService.signInWithKakao(kakaoAccessToken: 'tok');
        fail('Should have thrown');
      } on AuthException catch (e) {
        expect(e.message, '인증에 실패했습니다');
      }
    });
  });

  // ── tryAutoLogin ──────────────────────────────────────────────────────

  group('AuthService.tryAutoLogin', () {
    test('no stored token → returns null', () async {
      final mockClient = MockClient((request) async {
        return http.Response('{}', 200);
      });

      final httpClient = AuthHttpClient(
        tokenStorage: tokenStorage,
        baseUrl: 'https://api.test.com',
        httpClient: mockClient,
      );

      final authService = AuthService(
        tokenStorage: tokenStorage,
        httpClient: httpClient,
      );

      final result = await authService.tryAutoLogin();
      expect(result, isNull);
    });

    test('stored token but no userId → returns null', () async {
      tokenStorage._accessToken = 'at';
      // No userId stored

      final mockClient = MockClient((request) async {
        return http.Response('{}', 200);
      });

      final httpClient = AuthHttpClient(
        tokenStorage: tokenStorage,
        baseUrl: 'https://api.test.com',
        httpClient: mockClient,
      );

      final authService = AuthService(
        tokenStorage: tokenStorage,
        httpClient: httpClient,
      );

      final result = await authService.tryAutoLogin();
      expect(result, isNull);
    });

    test('stored token + userId, server offline → offline fallback', () async {
      tokenStorage._accessToken = 'cached_at';
      tokenStorage._userId = 'usr_cached';

      // Server call will throw (simulating offline)
      final mockClient = MockClient((request) async {
        throw Exception('Network error');
      });

      final httpClient = AuthHttpClient(
        tokenStorage: tokenStorage,
        baseUrl: 'https://api.test.com',
        httpClient: mockClient,
      );

      final authService = AuthService(
        tokenStorage: tokenStorage,
        httpClient: httpClient,
      );

      final result = await authService.tryAutoLogin();
      // Offline fallback returns minimal AuthUser
      expect(result, isNotNull);
      expect(result!.id, 'usr_cached');
      expect(result.provider, 'unknown');
      expect(result.plan, 'free');
    });
  });
}
