/// AuthException / AuthUser 순수 로직 테스트
/// 커버: auth_service.dart — AuthException 클래스 (isNetworkError, isServerError, etc.)
///        auth_user.dart — AuthUser 모델 (fromJson, toJson, copyWith, hasFamilyPlan, etc.)
import 'package:flutter_test/flutter_test.dart';
import 'package:re_link/core/services/auth/auth_service.dart';
import 'package:re_link/shared/models/auth_user.dart';

void main() {
  // ── AuthException ────────────────────────────────────────────────────────

  group('AuthException', () {
    test('constructor sets message and statusCode', () {
      const e = AuthException('테스트 에러', 401);
      expect(e.message, '테스트 에러');
      expect(e.statusCode, 401);
    });

    test('toString format', () {
      const e = AuthException('Unauthorized', 401);
      expect(e.toString(), 'AuthException(401): Unauthorized');
    });

    test('isNetworkError — statusCode 0', () {
      const e = AuthException('Network error', 0);
      expect(e.isNetworkError, isTrue);
      expect(e.isServerError, isFalse);
      expect(e.isClientError, isFalse);
    });

    test('isServerError — statusCode 500', () {
      const e = AuthException('Internal server error', 500);
      expect(e.isNetworkError, isFalse);
      expect(e.isServerError, isTrue);
      expect(e.isClientError, isFalse);
    });

    test('isServerError — statusCode 503', () {
      const e = AuthException('Service unavailable', 503);
      expect(e.isServerError, isTrue);
    });

    test('isClientError — statusCode 400', () {
      const e = AuthException('Bad request', 400);
      expect(e.isNetworkError, isFalse);
      expect(e.isServerError, isFalse);
      expect(e.isClientError, isTrue);
    });

    test('isClientError — statusCode 403', () {
      const e = AuthException('Forbidden', 403);
      expect(e.isClientError, isTrue);
    });

    test('isClientError — statusCode 404', () {
      const e = AuthException('Not found', 404);
      expect(e.isClientError, isTrue);
    });

    test('isClientError — statusCode 499', () {
      const e = AuthException('Client closed', 499);
      expect(e.isClientError, isTrue);
    });

    test('statusCode 200 — none of the error flags', () {
      const e = AuthException('OK', 200);
      expect(e.isNetworkError, isFalse);
      expect(e.isServerError, isFalse);
      expect(e.isClientError, isFalse);
    });

    test('statusCode 301 — none of the error flags', () {
      const e = AuthException('Redirect', 301);
      expect(e.isNetworkError, isFalse);
      expect(e.isServerError, isFalse);
      expect(e.isClientError, isFalse);
    });

    test('implements Exception', () {
      const e = AuthException('test', 500);
      expect(e, isA<Exception>());
    });
  });

  // ── AuthUser model ──────────────────────────────────────────────────────

  group('AuthUser model', () {
    test('constructor sets all fields', () {
      const user = AuthUser(
        id: 'usr_abc123',
        email: 'test@test.com',
        provider: 'apple',
        plan: 'family',
        familyGroupId: 'grp_xyz',
        accessToken: 'token123',
      );

      expect(user.id, 'usr_abc123');
      expect(user.email, 'test@test.com');
      expect(user.provider, 'apple');
      expect(user.plan, 'family');
      expect(user.familyGroupId, 'grp_xyz');
      expect(user.accessToken, 'token123');
    });

    test('email and familyGroupId are optional', () {
      const user = AuthUser(
        id: 'usr_1',
        provider: 'google',
        plan: 'free',
        accessToken: 'tok',
      );
      expect(user.email, isNull);
      expect(user.familyGroupId, isNull);
    });
  });

  group('AuthUser.fromJson', () {
    test('full JSON', () {
      final user = AuthUser.fromJson({
        'id': 'usr_001',
        'email': 'user@example.com',
        'provider': 'google',
        'plan': 'familyPlus',
        'family_group_id': 'grp_abc',
      }, 'access_token_123');

      expect(user.id, 'usr_001');
      expect(user.email, 'user@example.com');
      expect(user.provider, 'google');
      expect(user.plan, 'familyPlus');
      expect(user.familyGroupId, 'grp_abc');
      expect(user.accessToken, 'access_token_123');
    });

    test('minimal JSON — defaults', () {
      final user = AuthUser.fromJson({
        'id': 'usr_002',
      }, 'tok');

      expect(user.id, 'usr_002');
      expect(user.email, isNull);
      expect(user.provider, 'apple'); // default
      expect(user.plan, 'free'); // default
      expect(user.familyGroupId, isNull);
    });

    test('provider defaults to apple when null', () {
      final user = AuthUser.fromJson({
        'id': 'usr_003',
        'provider': null,
      }, 'tok');
      expect(user.provider, 'apple');
    });

    test('plan defaults to free when null', () {
      final user = AuthUser.fromJson({
        'id': 'usr_004',
        'plan': null,
      }, 'tok');
      expect(user.plan, 'free');
    });
  });

  group('AuthUser.toJson', () {
    test('serializes all fields except accessToken', () {
      const user = AuthUser(
        id: 'usr_1',
        email: 'a@b.com',
        provider: 'kakao',
        plan: 'plus',
        familyGroupId: 'grp_1',
        accessToken: 'secret_token',
      );
      final json = user.toJson();

      expect(json['id'], 'usr_1');
      expect(json['email'], 'a@b.com');
      expect(json['provider'], 'kakao');
      expect(json['plan'], 'plus');
      expect(json['family_group_id'], 'grp_1');
      // accessToken should NOT be in toJson (security)
      expect(json.containsKey('access_token'), isFalse);
    });

    test('null email serializes as null', () {
      const user = AuthUser(
        id: 'usr_2',
        provider: 'apple',
        plan: 'free',
        accessToken: 'tok',
      );
      final json = user.toJson();
      expect(json['email'], isNull);
    });
  });

  group('AuthUser.copyWith', () {
    const original = AuthUser(
      id: 'usr_orig',
      email: 'orig@test.com',
      provider: 'apple',
      plan: 'free',
      familyGroupId: null,
      accessToken: 'tok_orig',
    );

    test('copies with new id', () {
      final copy = original.copyWith(id: 'usr_new');
      expect(copy.id, 'usr_new');
      expect(copy.email, original.email);
      expect(copy.provider, original.provider);
    });

    test('copies with new plan', () {
      final copy = original.copyWith(plan: 'family');
      expect(copy.plan, 'family');
      expect(copy.id, original.id);
    });

    test('copies with new familyGroupId', () {
      final copy = original.copyWith(familyGroupId: 'grp_new');
      expect(copy.familyGroupId, 'grp_new');
    });

    test('copies with new accessToken', () {
      final copy = original.copyWith(accessToken: 'tok_new');
      expect(copy.accessToken, 'tok_new');
      expect(copy.id, original.id);
    });

    test('no arguments returns equivalent copy', () {
      final copy = original.copyWith();
      expect(copy.id, original.id);
      expect(copy.email, original.email);
      expect(copy.provider, original.provider);
      expect(copy.plan, original.plan);
      expect(copy.familyGroupId, original.familyGroupId);
      expect(copy.accessToken, original.accessToken);
    });
  });

  group('AuthUser plan helpers', () {
    test('hasFamilyPlan — free = false', () {
      const user = AuthUser(
          id: 'u', provider: 'a', plan: 'free', accessToken: 't');
      expect(user.hasFamilyPlan, isFalse);
    });

    test('hasFamilyPlan — plus = false', () {
      const user = AuthUser(
          id: 'u', provider: 'a', plan: 'plus', accessToken: 't');
      expect(user.hasFamilyPlan, isFalse);
    });

    test('hasFamilyPlan — family = true', () {
      const user = AuthUser(
          id: 'u', provider: 'a', plan: 'family', accessToken: 't');
      expect(user.hasFamilyPlan, isTrue);
    });

    test('hasFamilyPlan — familyPlus = true', () {
      const user = AuthUser(
          id: 'u', provider: 'a', plan: 'familyPlus', accessToken: 't');
      expect(user.hasFamilyPlan, isTrue);
    });

    test('isAdFree — free = false', () {
      const user = AuthUser(
          id: 'u', provider: 'a', plan: 'free', accessToken: 't');
      expect(user.isAdFree, isFalse);
    });

    test('isAdFree — plus = true', () {
      const user = AuthUser(
          id: 'u', provider: 'a', plan: 'plus', accessToken: 't');
      expect(user.isAdFree, isTrue);
    });

    test('isAdFree — family = true', () {
      const user = AuthUser(
          id: 'u', provider: 'a', plan: 'family', accessToken: 't');
      expect(user.isAdFree, isTrue);
    });

    test('isAdFree — familyPlus = true', () {
      const user = AuthUser(
          id: 'u', provider: 'a', plan: 'familyPlus', accessToken: 't');
      expect(user.isAdFree, isTrue);
    });
  });

  group('AuthUser equality', () {
    test('same id + provider → equal', () {
      const u1 = AuthUser(
          id: 'usr_1', provider: 'apple', plan: 'free', accessToken: 'a');
      const u2 = AuthUser(
          id: 'usr_1', provider: 'apple', plan: 'plus', accessToken: 'b');
      expect(u1 == u2, isTrue);
      expect(u1.hashCode, u2.hashCode);
    });

    test('different id → not equal', () {
      const u1 = AuthUser(
          id: 'usr_1', provider: 'apple', plan: 'free', accessToken: 'a');
      const u2 = AuthUser(
          id: 'usr_2', provider: 'apple', plan: 'free', accessToken: 'a');
      expect(u1 == u2, isFalse);
    });

    test('different provider → not equal', () {
      const u1 = AuthUser(
          id: 'usr_1', provider: 'apple', plan: 'free', accessToken: 'a');
      const u2 = AuthUser(
          id: 'usr_1', provider: 'google', plan: 'free', accessToken: 'a');
      expect(u1 == u2, isFalse);
    });

    test('toString format', () {
      const user = AuthUser(
        id: 'usr_1',
        email: 'e@e.com',
        provider: 'google',
        plan: 'plus',
        accessToken: 'tok',
      );
      expect(
        user.toString(),
        'AuthUser(id: usr_1, email: e@e.com, provider: google, plan: plus)',
      );
    });
  });
}
