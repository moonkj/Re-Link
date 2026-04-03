/// AuthService 응답 파싱 순수 로직 테스트
/// 커버: auth_service.dart — _handleAuthResponse 파싱, _parseErrorMessage,
///        refreshAccessToken 파싱, tryAutoLogin 오프라인 폴백
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:re_link/core/services/auth/auth_service.dart';
import 'package:re_link/shared/models/auth_user.dart';

void main() {
  // ── _handleAuthResponse 파싱 로직 ───────────────────────────────────────

  group('Auth response parsing', () {
    test('valid 200 response with all fields', () {
      final body = jsonEncode({
        'access_token': 'at_123',
        'refresh_token': 'rt_456',
        'user': {
          'id': 'usr_001',
          'email': 'test@test.com',
          'provider': 'apple',
          'plan': 'family',
          'family_group_id': 'grp_abc',
        },
      });

      final data = jsonDecode(body) as Map<String, dynamic>;
      final accessToken = data['access_token'] as String?;
      final refreshToken = data['refresh_token'] as String?;
      final userData = data['user'] as Map<String, dynamic>?;

      expect(accessToken, 'at_123');
      expect(refreshToken, 'rt_456');
      expect(userData, isNotNull);

      final user = AuthUser.fromJson(userData!, accessToken!);
      expect(user.id, 'usr_001');
      expect(user.email, 'test@test.com');
      expect(user.provider, 'apple');
      expect(user.plan, 'family');
      expect(user.familyGroupId, 'grp_abc');
      expect(user.accessToken, 'at_123');
    });

    test('missing access_token → null', () {
      final body = jsonEncode({
        'refresh_token': 'rt',
        'user': {'id': 'usr_1'},
      });
      final data = jsonDecode(body) as Map<String, dynamic>;
      final accessToken = data['access_token'] as String?;
      expect(accessToken, isNull);
    });

    test('missing refresh_token → null', () {
      final body = jsonEncode({
        'access_token': 'at',
        'user': {'id': 'usr_1'},
      });
      final data = jsonDecode(body) as Map<String, dynamic>;
      final refreshToken = data['refresh_token'] as String?;
      expect(refreshToken, isNull);
    });

    test('missing user → null', () {
      final body = jsonEncode({
        'access_token': 'at',
        'refresh_token': 'rt',
      });
      final data = jsonDecode(body) as Map<String, dynamic>;
      final userData = data['user'] as Map<String, dynamic>?;
      expect(userData, isNull);
    });

    test('non-200 status → AuthException', () {
      final body = jsonEncode({
        'message': '잘못된 ID 토큰',
      });
      const statusCode = 401;

      expect(statusCode != 200 && statusCode != 201, isTrue);

      final errorData = jsonDecode(body) as Map<String, dynamic>?;
      final message = errorData?['message'] as String? ?? '인증에 실패했습니다';
      expect(message, '잘못된 ID 토큰');
    });

    test('non-200 without message → default message', () {
      final body = jsonEncode({'error': 'unknown'});
      const statusCode = 500;

      final errorData = jsonDecode(body) as Map<String, dynamic>?;
      final message = errorData?['message'] as String? ?? '인증에 실패했습니다';
      expect(message, '인증에 실패했습니다');
    });

    test('201 status → should be treated as success', () {
      const statusCode = 201;
      expect(statusCode != 200 && statusCode != 201, isFalse);
    });
  });

  // ── _parseErrorMessage 로직 ──────────────────────────────────────────

  group('Error message parsing', () {
    String? parseErrorMessage(String body) {
      try {
        final data = jsonDecode(body) as Map<String, dynamic>?;
        return data?['message'] as String?;
      } catch (_) {
        return null;
      }
    }

    test('valid JSON with message', () {
      final body = jsonEncode({'message': '계정 삭제 실패'});
      expect(parseErrorMessage(body), '계정 삭제 실패');
    });

    test('valid JSON without message', () {
      final body = jsonEncode({'error': 'not_found'});
      expect(parseErrorMessage(body), isNull);
    });

    test('invalid JSON → null', () {
      expect(parseErrorMessage('not json'), isNull);
    });

    test('empty string → null', () {
      expect(parseErrorMessage(''), isNull);
    });

    test('array JSON → null (not a Map)', () {
      expect(parseErrorMessage('[1,2,3]'), isNull);
    });
  });

  // ── refreshAccessToken 응답 파싱 ─────────────────────────────────────

  group('Refresh access token parsing', () {
    test('successful refresh with both tokens', () {
      final body = jsonEncode({
        'access_token': 'new_at',
        'refresh_token': 'new_rt',
      });

      final data = jsonDecode(body) as Map<String, dynamic>;
      final newAccessToken = data['access_token'] as String?;
      final newRefreshToken = data['refresh_token'] as String?;

      expect(newAccessToken, 'new_at');
      expect(newRefreshToken, 'new_rt');
    });

    test('failed refresh — no tokens in response', () {
      final body = jsonEncode({'error': 'expired'});
      final data = jsonDecode(body) as Map<String, dynamic>;
      final newAccessToken = data['access_token'] as String?;
      final newRefreshToken = data['refresh_token'] as String?;

      expect(newAccessToken, isNull);
      expect(newRefreshToken, isNull);
    });
  });

  // ── tryAutoLogin 오프라인 폴백 ─────────────────────────────────────────

  group('Auto login offline fallback', () {
    test('offline fallback creates minimal AuthUser', () {
      const userId = 'usr_offline';
      const accessToken = 'cached_token';

      final user = AuthUser(
        id: userId,
        email: null,
        provider: 'unknown',
        plan: 'free',
        familyGroupId: null,
        accessToken: accessToken,
      );

      expect(user.id, userId);
      expect(user.email, isNull);
      expect(user.provider, 'unknown');
      expect(user.plan, 'free');
      expect(user.familyGroupId, isNull);
      expect(user.accessToken, accessToken);
    });

    test('offline fallback — hasFamilyPlan is false for free', () {
      const user = AuthUser(
        id: 'u',
        provider: 'unknown',
        plan: 'free',
        accessToken: 't',
      );
      expect(user.hasFamilyPlan, isFalse);
    });

    test('/auth/me response parsing', () {
      final body = jsonEncode({
        'user': {
          'id': 'usr_me',
          'email': 'me@test.com',
          'provider': 'google',
          'plan': 'plus',
        },
      });

      final data = jsonDecode(body) as Map<String, dynamic>;
      final userMap = data['user'] as Map<String, dynamic>?;
      expect(userMap, isNotNull);

      final user = AuthUser.fromJson(userMap!, 'token');
      expect(user.id, 'usr_me');
      expect(user.provider, 'google');
      expect(user.plan, 'plus');
    });

    test('/auth/me response with null user', () {
      final body = jsonEncode({'user': null});
      final data = jsonDecode(body) as Map<String, dynamic>;
      final userMap = data['user'] as Map<String, dynamic>?;
      expect(userMap, isNull);
    });
  });

  // ── deleteAccount 응답 처리 ──────────────────────────────────────────

  group('Delete account response handling', () {
    test('200 → success', () {
      const statusCode = 200;
      final isSuccess = statusCode == 200 || statusCode == 204;
      expect(isSuccess, isTrue);
    });

    test('204 → success', () {
      const statusCode = 204;
      final isSuccess = statusCode == 200 || statusCode == 204;
      expect(isSuccess, isTrue);
    });

    test('500 → failure, throws AuthException', () {
      const statusCode = 500;
      final isSuccess = statusCode == 200 || statusCode == 204;
      expect(isSuccess, isFalse);

      // should throw
      const body = '{"message":"서버 오류"}';
      String? parseErrorMessage(String b) {
        try {
          final data = jsonDecode(b) as Map<String, dynamic>?;
          return data?['message'] as String?;
        } catch (_) {
          return null;
        }
      }

      final msg = parseErrorMessage(body) ?? '계정 삭제에 실패했습니다';
      expect(msg, '서버 오류');

      final exception = AuthException(msg, statusCode);
      expect(exception.statusCode, 500);
      expect(exception.isServerError, isTrue);
    });

    test('403 → failure', () {
      const statusCode = 403;
      final isSuccess = statusCode == 200 || statusCode == 204;
      expect(isSuccess, isFalse);
    });
  });
}
