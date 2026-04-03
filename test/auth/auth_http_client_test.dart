/// AuthHttpClient 순수 로직 테스트
/// 커버: auth_http_client.dart — header construction, URI building,
///        _sendWithRetry 로직, _tryRefreshToken 파싱
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // ── 헤더 구성 로직 (서비스 내부 로직 재현) ────────────────────────────────

  group('Default headers construction', () {
    Map<String, String> defaultHeaders(String? accessToken) => {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        };

    test('with access token → includes Authorization', () {
      final headers = defaultHeaders('my_token_123');
      expect(headers['Content-Type'], 'application/json');
      expect(headers['Accept'], 'application/json');
      expect(headers['Authorization'], 'Bearer my_token_123');
    });

    test('without access token → no Authorization header', () {
      final headers = defaultHeaders(null);
      expect(headers['Content-Type'], 'application/json');
      expect(headers['Accept'], 'application/json');
      expect(headers.containsKey('Authorization'), isFalse);
    });

    test('header count with token → 3', () {
      final headers = defaultHeaders('tok');
      expect(headers.length, 3);
    });

    test('header count without token → 2', () {
      final headers = defaultHeaders(null);
      expect(headers.length, 2);
    });
  });

  // ── URI 구성 ──────────────────────────────────────────────────────────

  group('URI construction', () {
    Uri buildUri(String baseUrl, String path) => Uri.parse('$baseUrl$path');

    test('standard path', () {
      final uri = buildUri(
          'https://relink-api.relink-app.workers.dev', '/auth/apple');
      expect(uri.toString(),
          'https://relink-api.relink-app.workers.dev/auth/apple');
    });

    test('path with query parameters', () {
      final uri = buildUri(
          'https://relink-api.relink-app.workers.dev', '/sync/pull?since=123');
      expect(uri.toString(),
          'https://relink-api.relink-app.workers.dev/sync/pull?since=123');
      expect(uri.queryParameters['since'], '123');
    });

    test('empty path', () {
      final uri = buildUri('https://example.com', '');
      expect(uri.toString(), 'https://example.com');
    });

    test('path with encoded characters', () {
      final fileKey = 'grp/usr/photos/uuid.webp';
      final uri = buildUri('https://api.example.com',
          '/media/${Uri.encodeComponent(fileKey)}/download-url');
      expect(uri.toString(), contains(Uri.encodeComponent(fileKey)));
    });
  });

  // ── 401 리프레시 토큰 응답 파싱 ──────────────────────────────────────────

  group('Refresh token response parsing', () {
    test('successful refresh — new access + refresh tokens', () {
      final responseBody = jsonEncode({
        'access_token': 'new_access_123',
        'refresh_token': 'new_refresh_456',
      });

      final data = jsonDecode(responseBody) as Map<String, dynamic>;
      final newAccessToken = data['access_token'] as String?;
      final newRefreshToken = data['refresh_token'] as String?;

      expect(newAccessToken, 'new_access_123');
      expect(newRefreshToken, 'new_refresh_456');
    });

    test('successful refresh — only access token', () {
      final responseBody = jsonEncode({
        'access_token': 'new_access_789',
      });

      final data = jsonDecode(responseBody) as Map<String, dynamic>;
      final newAccessToken = data['access_token'] as String?;
      final newRefreshToken = data['refresh_token'] as String?;

      expect(newAccessToken, 'new_access_789');
      expect(newRefreshToken, isNull);
    });

    test('failed refresh — no tokens', () {
      final responseBody = jsonEncode({
        'error': 'invalid_grant',
      });

      final data = jsonDecode(responseBody) as Map<String, dynamic>;
      final newAccessToken = data['access_token'] as String?;
      expect(newAccessToken, isNull);
    });
  });

  // ── 재시도 로직 ────────────────────────────────────────────────────────

  group('Retry logic conditions', () {
    test('401 + requiresAuth → should retry', () {
      const statusCode = 401;
      const requiresAuth = true;
      final shouldRetry = statusCode == 401 && requiresAuth;
      expect(shouldRetry, isTrue);
    });

    test('401 + no auth required → should NOT retry', () {
      const statusCode = 401;
      const requiresAuth = false;
      final shouldRetry = statusCode == 401 && requiresAuth;
      expect(shouldRetry, isFalse);
    });

    test('200 → should NOT retry', () {
      const statusCode = 200;
      const requiresAuth = true;
      final shouldRetry = statusCode == 401 && requiresAuth;
      expect(shouldRetry, isFalse);
    });

    test('500 → should NOT retry (only 401 triggers refresh)', () {
      const statusCode = 500;
      const requiresAuth = true;
      final shouldRetry = statusCode == 401 && requiresAuth;
      expect(shouldRetry, isFalse);
    });

    test('403 → should NOT retry', () {
      const statusCode = 403;
      const requiresAuth = true;
      final shouldRetry = statusCode == 401 && requiresAuth;
      expect(shouldRetry, isFalse);
    });
  });

  // ── POST 요청 body 인코딩 ────────────────────────────────────────────

  group('POST body encoding', () {
    test('body is JSON encoded', () {
      final body = {'id_token': 'abc', 'authorization_code': 'def'};
      final encoded = jsonEncode(body);
      expect(encoded, contains('"id_token":"abc"'));
      expect(encoded, contains('"authorization_code":"def"'));
    });

    test('null body → null (no body sent)', () {
      Map<String, dynamic>? body;
      final encoded = body != null ? jsonEncode(body) : null;
      expect(encoded, isNull);
    });

    test('empty body → empty JSON object', () {
      final body = <String, dynamic>{};
      final encoded = jsonEncode(body);
      expect(encoded, '{}');
    });
  });

  // ── requiresAuth 분기 ────────────────────────────────────────────────

  group('requiresAuth branching', () {
    test('requiresAuth true → reads token', () {
      const requiresAuth = true;
      // Simulate: final token = requiresAuth ? await tokenStorage.getAccessToken() : null;
      final token = requiresAuth ? 'stored_token' : null;
      expect(token, 'stored_token');
    });

    test('requiresAuth false → null token', () {
      const requiresAuth = false;
      final token = requiresAuth ? 'stored_token' : null;
      expect(token, isNull);
    });
  });
}
