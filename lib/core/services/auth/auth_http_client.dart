import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../config/env_config.dart';
import '../../../features/auth/providers/auth_notifier.dart';
import 'auth_token_storage.dart';

part 'auth_http_client.g.dart';

/// Riverpod provider — AuthHttpClient
@riverpod
AuthHttpClient authHttpClient(Ref ref) {
  return AuthHttpClient(
    tokenStorage: ref.read(authTokenStorageProvider),
    onUnauthorized: () async {
      // 리프레시 토큰 갱신 실패 → 인증 상태 초기화 (로그아웃 처리)
      ref.invalidate(authNotifierProvider);
    },
  );
}

/// JWT 인증 헤더를 자동 주입하는 HTTP 클라이언트
/// - Authorization: Bearer {accessToken} 헤더 자동 추가
/// - 401 응답 시 refresh token으로 재시도
/// - refresh 실패 시 onUnauthorized 콜백 호출
class AuthHttpClient {
  AuthHttpClient({
    required this.tokenStorage,
    this.onUnauthorized,
    this.baseUrl = EnvConfig.workersBaseUrl,
    http.Client? httpClient,
  }) : _client = httpClient ?? http.Client();

  final AuthTokenStorage tokenStorage;
  final Future<void> Function()? onUnauthorized;
  final String baseUrl;
  final http.Client _client;

  Map<String, String> _defaultHeaders(String? accessToken) => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (accessToken != null) 'Authorization': 'Bearer $accessToken',
      };

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  /// GET 요청 (인증 헤더 자동 주입, 15초 타임아웃)
  Future<http.Response> get(String path) async {
    return _sendWithRetry(
      () async {
        final token = await tokenStorage.getAccessToken();
        return _client
            .get(_uri(path), headers: _defaultHeaders(token))
            .timeout(const Duration(seconds: 15));
      },
    );
  }

  /// POST 요청 (인증 헤더 자동 주입)
  Future<http.Response> post(
    String path, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) async {
    debugPrint('[AuthHttp] POST $baseUrl$path (requiresAuth=$requiresAuth)');
    if (body != null) {
      debugPrint('[AuthHttp] body keys: ${body.keys.toList()}');
    }
    return _sendWithRetry(
      () async {
        final token = requiresAuth ? await tokenStorage.getAccessToken() : null;
        final uri = _uri(path);
        debugPrint('[AuthHttp] → sending POST to $uri');
        final response = await _client.post(
          uri,
          headers: _defaultHeaders(token),
          body: body != null ? jsonEncode(body) : null,
        ).timeout(
          const Duration(seconds: 15),
          onTimeout: () {
            debugPrint('[AuthHttp] ⚠ POST $path timed out after 15s');
            throw TimeoutException('POST $path timed out after 15s');
          },
        );
        debugPrint('[AuthHttp] ← POST $path responded: ${response.statusCode}');
        return response;
      },
      requiresAuth: requiresAuth,
    );
  }

  /// DELETE 요청 (인증 헤더 자동 주입)
  Future<http.Response> delete(String path) async {
    return _sendWithRetry(
      () async {
        final token = await tokenStorage.getAccessToken();
        return _client
            .delete(_uri(path), headers: _defaultHeaders(token))
            .timeout(const Duration(seconds: 15));
      },
    );
  }

  /// 401 응답 시 리프레시 토큰으로 1회 재시도
  Future<http.Response> _sendWithRetry(
    Future<http.Response> Function() request, {
    bool requiresAuth = true,
  }) async {
    http.Response response;
    try {
      response = await request();
    } catch (e, st) {
      debugPrint('[AuthHttp] ❌ HTTP request failed: $e');
      debugPrint('[AuthHttp] Stack trace: $st');
      rethrow;
    }

    if (response.statusCode == 401 && requiresAuth) {
      debugPrint('[AuthHttp] 401 received, attempting token refresh...');
      // 리프레시 토큰으로 액세스 토큰 갱신 시도
      final newToken = await _tryRefreshToken();
      if (newToken != null) {
        debugPrint('[AuthHttp] Token refreshed, retrying request...');
        // 새 토큰으로 1회 재시도
        return request();
      } else {
        debugPrint('[AuthHttp] Token refresh failed, triggering unauthorized');
        // 갱신 실패 → 로그아웃 처리
        await onUnauthorized?.call();
      }
    }

    return response;
  }

  /// 리프레시 토큰을 사용하여 새 액세스 토큰 발급
  /// 성공 시 새 액세스 토큰 반환, 실패 시 null 반환
  Future<String?> _tryRefreshToken() async {
    try {
      final refreshToken = await tokenStorage.getRefreshToken();
      if (refreshToken == null) return null;

      final response = await _client.post(
        _uri('/auth/refresh'),
        headers: _defaultHeaders(null),
        body: jsonEncode({'refresh_token': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final newAccessToken = data['access_token'] as String?;
        final newRefreshToken = data['refresh_token'] as String?;

        if (newAccessToken != null) {
          if (newRefreshToken != null) {
            await tokenStorage.saveTokens(
              accessToken: newAccessToken,
              refreshToken: newRefreshToken,
            );
          } else {
            await tokenStorage.updateAccessToken(newAccessToken);
          }
          return newAccessToken;
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
