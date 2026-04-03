/// AuthHttpClient 실제 코드 테스트 (MockClient 사용)
/// 커버: auth_http_client.dart — get, post, delete, _sendWithRetry, _tryRefreshToken
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:re_link/core/services/auth/auth_http_client.dart';
import 'package:re_link/core/services/auth/auth_token_storage.dart';

/// 테스트용 토큰 저장소 — 메모리 기반 (flutter_secure_storage 대체)
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

  // ── GET 요청 ──────────────────────────────────────────────────────────

  group('AuthHttpClient.get', () {
    test('200 response with auth header', () async {
      await tokenStorage.saveTokens(
        accessToken: 'test_token',
        refreshToken: 'ref_tok',
      );

      final mockClient = MockClient((request) async {
        expect(request.headers['Authorization'], 'Bearer test_token');
        expect(request.headers['Accept'], 'application/json');
        return http.Response('{"ok":true}', 200);
      });

      final client = AuthHttpClient(
        tokenStorage: tokenStorage,
        baseUrl: 'https://api.test.com',
        httpClient: mockClient,
      );

      final response = await client.get('/test');
      expect(response.statusCode, 200);
      expect(response.body, '{"ok":true}');
    });

    test('GET without stored token — no auth header', () async {
      final mockClient = MockClient((request) async {
        // Token is null, so Authorization should not be present
        expect(request.headers.containsKey('Authorization'), isFalse);
        return http.Response('{}', 200);
      });

      final client = AuthHttpClient(
        tokenStorage: tokenStorage,
        baseUrl: 'https://api.test.com',
        httpClient: mockClient,
      );

      final response = await client.get('/no-auth');
      expect(response.statusCode, 200);
    });
  });

  // ── POST 요청 ─────────────────────────────────────────────────────────

  group('AuthHttpClient.post', () {
    test('POST with body', () async {
      await tokenStorage.saveTokens(
        accessToken: 'at',
        refreshToken: 'rt',
      );

      final mockClient = MockClient((request) async {
        expect(request.method, 'POST');
        final body = jsonDecode(request.body);
        expect(body['key'], 'value');
        return http.Response('{"result":"ok"}', 200);
      });

      final client = AuthHttpClient(
        tokenStorage: tokenStorage,
        baseUrl: 'https://api.test.com',
        httpClient: mockClient,
      );

      final response = await client.post(
        '/create',
        body: {'key': 'value'},
      );
      expect(response.statusCode, 200);
    });

    test('POST requiresAuth=false — no token header', () async {
      await tokenStorage.saveTokens(
        accessToken: 'should_not_be_sent',
        refreshToken: 'rt',
      );

      final mockClient = MockClient((request) async {
        expect(request.headers.containsKey('Authorization'), isFalse);
        return http.Response('{}', 200);
      });

      final client = AuthHttpClient(
        tokenStorage: tokenStorage,
        baseUrl: 'https://api.test.com',
        httpClient: mockClient,
      );

      final response = await client.post(
        '/auth/login',
        body: {'id_token': 'xyz'},
        requiresAuth: false,
      );
      expect(response.statusCode, 200);
    });

    test('POST with null body', () async {
      final mockClient = MockClient((request) async {
        return http.Response('{}', 200);
      });

      final client = AuthHttpClient(
        tokenStorage: tokenStorage,
        baseUrl: 'https://api.test.com',
        httpClient: mockClient,
      );

      final response = await client.post('/ping');
      expect(response.statusCode, 200);
    });
  });

  // ── DELETE 요청 ────────────────────────────────────────────────────────

  group('AuthHttpClient.delete', () {
    test('DELETE request', () async {
      await tokenStorage.saveTokens(
        accessToken: 'at',
        refreshToken: 'rt',
      );

      final mockClient = MockClient((request) async {
        expect(request.method, 'DELETE');
        expect(request.headers['Authorization'], 'Bearer at');
        return http.Response('', 204);
      });

      final client = AuthHttpClient(
        tokenStorage: tokenStorage,
        baseUrl: 'https://api.test.com',
        httpClient: mockClient,
      );

      final response = await client.delete('/item/123');
      expect(response.statusCode, 204);
    });
  });

  // ── 401 + 토큰 갱신 ─────────────────────────────────────────────────────

  group('AuthHttpClient 401 token refresh', () {
    test('401 → refresh succeeds → retries request', () async {
      await tokenStorage.saveTokens(
        accessToken: 'old_token',
        refreshToken: 'valid_refresh',
      );

      var callCount = 0;

      final mockClient = MockClient((request) async {
        callCount++;
        if (request.url.path == '/auth/refresh') {
          // Refresh endpoint
          return http.Response(
            jsonEncode({
              'access_token': 'new_token',
              'refresh_token': 'new_refresh',
            }),
            200,
          );
        }
        if (callCount == 1) {
          // First call: 401
          return http.Response('{"error":"unauthorized"}', 401);
        }
        // Second call (after refresh): success
        return http.Response('{"data":"ok"}', 200);
      });

      final client = AuthHttpClient(
        tokenStorage: tokenStorage,
        baseUrl: 'https://api.test.com',
        httpClient: mockClient,
      );

      final response = await client.get('/protected');
      expect(response.statusCode, 200);

      // Check that tokens were updated
      final newToken = await tokenStorage.getAccessToken();
      expect(newToken, 'new_token');
    });

    test('401 → refresh fails → calls onUnauthorized', () async {
      await tokenStorage.saveTokens(
        accessToken: 'old_token',
        refreshToken: 'expired_refresh',
      );

      var unauthorizedCalled = false;

      final mockClient = MockClient((request) async {
        if (request.url.path == '/auth/refresh') {
          return http.Response('{"error":"invalid_grant"}', 401);
        }
        return http.Response('{}', 401);
      });

      final client = AuthHttpClient(
        tokenStorage: tokenStorage,
        baseUrl: 'https://api.test.com',
        httpClient: mockClient,
        onUnauthorized: () async {
          unauthorizedCalled = true;
        },
      );

      final response = await client.get('/protected');
      expect(response.statusCode, 401);
      expect(unauthorizedCalled, isTrue);
    });

    test('401 → no refresh token → calls onUnauthorized', () async {
      await tokenStorage.saveTokens(
        accessToken: 'old_token',
        refreshToken: 'rf',
      );
      // Clear refresh token
      tokenStorage._refreshToken = null;

      var unauthorizedCalled = false;

      final mockClient = MockClient((request) async {
        return http.Response('{}', 401);
      });

      final client = AuthHttpClient(
        tokenStorage: tokenStorage,
        baseUrl: 'https://api.test.com',
        httpClient: mockClient,
        onUnauthorized: () async {
          unauthorizedCalled = true;
        },
      );

      final response = await client.get('/protected');
      expect(response.statusCode, 401);
      expect(unauthorizedCalled, isTrue);
    });

    test('401 on requiresAuth=false → no refresh attempt', () async {
      final mockClient = MockClient((request) async {
        return http.Response('{"error":"bad"}', 401);
      });

      final client = AuthHttpClient(
        tokenStorage: tokenStorage,
        baseUrl: 'https://api.test.com',
        httpClient: mockClient,
      );

      final response = await client.post(
        '/auth/public',
        body: {},
        requiresAuth: false,
      );
      // Should return 401 without trying to refresh
      expect(response.statusCode, 401);
    });
  });

  // ── 토큰 갱신 — 새 리프레시 토큰 없는 경우 ──────────────────────────────

  group('Token refresh edge cases', () {
    test('refresh returns only access token → updates access only', () async {
      await tokenStorage.saveTokens(
        accessToken: 'old_at',
        refreshToken: 'old_rt',
      );

      var callCount = 0;
      final mockClient = MockClient((request) async {
        callCount++;
        if (request.url.path == '/auth/refresh') {
          return http.Response(
            jsonEncode({'access_token': 'new_at_only'}),
            200,
          );
        }
        if (callCount == 1) return http.Response('{}', 401);
        return http.Response('{"ok":true}', 200);
      });

      final client = AuthHttpClient(
        tokenStorage: tokenStorage,
        baseUrl: 'https://api.test.com',
        httpClient: mockClient,
      );

      await client.get('/test');

      final at = await tokenStorage.getAccessToken();
      final rt = await tokenStorage.getRefreshToken();
      expect(at, 'new_at_only');
      expect(rt, 'old_rt'); // refresh token unchanged
    });
  });

  // ── 500 에러 → 갱신 시도 없이 반환 ──────────────────────────────────────

  group('Non-401 errors', () {
    test('500 → returned directly without refresh', () async {
      await tokenStorage.saveTokens(
        accessToken: 'at',
        refreshToken: 'rt',
      );

      final mockClient = MockClient((request) async {
        return http.Response('{"error":"server"}', 500);
      });

      final client = AuthHttpClient(
        tokenStorage: tokenStorage,
        baseUrl: 'https://api.test.com',
        httpClient: mockClient,
      );

      final response = await client.get('/broken');
      expect(response.statusCode, 500);
    });
  });

  // ── URI 구성 확인 ────────────────────────────────────────────────────────

  group('URI construction in client', () {
    test('baseUrl + path concatenation', () async {
      final mockClient = MockClient((request) async {
        expect(
          request.url.toString(),
          'https://api.test.com/v1/data',
        );
        return http.Response('{}', 200);
      });

      final client = AuthHttpClient(
        tokenStorage: tokenStorage,
        baseUrl: 'https://api.test.com',
        httpClient: mockClient,
      );

      await client.get('/v1/data');
    });
  });
}
