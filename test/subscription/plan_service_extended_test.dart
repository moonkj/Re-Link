/// PlanService 확장 단위 테스트
/// 커버: plan_service.dart — PlanProductIds, PurchaseResult 모델,
///        PendingReceipt JSON, ReceiptVerificationResult, isSubscription 등
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:re_link/core/services/plan/plan_service.dart';
import 'package:re_link/shared/models/user_plan.dart';

void main() {
  // ── PlanProductIds 상수 ───────────────────────────────────────────────────

  group('PlanProductIds 상수', () {
    test('plus ID', () {
      expect(PlanProductIds.plus, 'com.relink.plus');
    });

    test('familyMonthly ID', () {
      expect(PlanProductIds.familyMonthly, 'com.relink.family_monthly');
    });

    test('familyAnnual ID', () {
      expect(PlanProductIds.familyAnnual, 'com.relink.family_annual');
    });

    test('familyPlusMonthly ID', () {
      expect(PlanProductIds.familyPlusMonthly, 'com.relink.family_plus_monthly');
    });

    test('familyPlusAnnual ID', () {
      expect(PlanProductIds.familyPlusAnnual, 'com.relink.family_plus_annual');
    });

    test('all 세트에 5개 포함', () {
      expect(PlanProductIds.all.length, 5);
    });

    test('subscriptions 세트에 4개 포함', () {
      expect(PlanProductIds.subscriptions.length, 4);
      expect(PlanProductIds.subscriptions, isNot(contains(PlanProductIds.plus)));
    });

    test('nonConsumables 세트에 plus만 포함', () {
      expect(PlanProductIds.nonConsumables.length, 1);
      expect(PlanProductIds.nonConsumables, contains(PlanProductIds.plus));
    });

    test('isSubscription — plus는 구독이 아님', () {
      expect(PlanProductIds.isSubscription(PlanProductIds.plus), isFalse);
    });

    test('isSubscription — familyMonthly는 구독', () {
      expect(
          PlanProductIds.isSubscription(PlanProductIds.familyMonthly), isTrue);
    });

    test('isSubscription — familyAnnual은 구독', () {
      expect(
          PlanProductIds.isSubscription(PlanProductIds.familyAnnual), isTrue);
    });

    test('isSubscription — familyPlusMonthly는 구독', () {
      expect(PlanProductIds.isSubscription(PlanProductIds.familyPlusMonthly),
          isTrue);
    });

    test('isSubscription — familyPlusAnnual은 구독', () {
      expect(PlanProductIds.isSubscription(PlanProductIds.familyPlusAnnual),
          isTrue);
    });

    test('isSubscription — 알 수 없는 ID → false', () {
      expect(PlanProductIds.isSubscription('com.unknown.id'), isFalse);
    });
  });

  // ── PlanService.planFromProductId (확장) ───────────────────────────────────

  group('PlanService.planFromProductId (확장)', () {
    test('모든 정의된 ID에 대해 free가 아닌 플랜 반환', () {
      for (final id in PlanProductIds.all) {
        final plan = PlanService.planFromProductId(id);
        expect(plan, isNot(UserPlan.free),
            reason: '$id should not map to free');
      }
    });

    test('빈 문자열 → free', () {
      expect(PlanService.planFromProductId(''), UserPlan.free);
    });

    test('null-like 문자열 → free', () {
      expect(PlanService.planFromProductId('null'), UserPlan.free);
    });

    test('대소문자 다른 ID → free (case-sensitive)', () {
      expect(
          PlanService.planFromProductId('COM.RELINK.PLUS'), UserPlan.free);
    });
  });

  // ── PurchaseResult sealed class ───────────────────────────────────────────

  group('PurchaseResult', () {
    test('PurchaseSuccess', () {
      final result = PurchaseSuccess(UserPlan.plus);
      expect(result, isA<PurchaseResult>());
      expect(result.plan, UserPlan.plus);
    });

    test('PurchasePending', () {
      final result = PurchasePending();
      expect(result, isA<PurchaseResult>());
    });

    test('PurchaseFailed', () {
      final result = PurchaseFailed('결제 실패');
      expect(result, isA<PurchaseResult>());
      expect(result.message, '결제 실패');
    });

    test('PurchaseCancelled', () {
      final result = PurchaseCancelled();
      expect(result, isA<PurchaseResult>());
    });

    test('switch pattern matching', () {
      PurchaseResult result = PurchaseSuccess(UserPlan.family);
      final message = switch (result) {
        PurchaseSuccess(:final plan) => 'Success: ${plan.displayName}',
        PurchasePending() => 'Pending',
        PurchaseFailed(:final message) => 'Failed: $message',
        PurchaseCancelled() => 'Cancelled',
      };
      expect(message, 'Success: 패밀리');
    });
  });

  // ── ReceiptVerificationResult ─────────────────────────────────────────────

  group('ReceiptVerificationResult', () {
    test('유효한 결과', () {
      final result = ReceiptVerificationResult(
        isValid: true,
        expiresAt: DateTime(2027, 1, 1),
      );
      expect(result.isValid, isTrue);
      expect(result.expiresAt, isNotNull);
      expect(result.errorMessage, isNull);
    });

    test('유효하지 않은 결과', () {
      const result = ReceiptVerificationResult(
        isValid: false,
        errorMessage: '영수증 검증 실패',
      );
      expect(result.isValid, isFalse);
      expect(result.expiresAt, isNull);
      expect(result.errorMessage, '영수증 검증 실패');
    });

    test('로컬 퍼스트 모드 (서버 없음)', () {
      const result = ReceiptVerificationResult(isValid: true);
      expect(result.isValid, isTrue);
      expect(result.expiresAt, isNull);
      expect(result.errorMessage, isNull);
    });
  });

  // ── PendingReceipt JSON ───────────────────────────────────────────────────

  group('PendingReceipt JSON', () {
    test('toJson → fromJson 왕복', () {
      final receipt = PendingReceipt(
        receipt: 'receipt-data-base64',
        productId: 'com.relink.family_monthly',
        platform: 'ios',
        createdAt: DateTime(2026, 4, 1, 10, 30),
      );
      final json = receipt.toJson();
      final restored = PendingReceipt.fromJson(json);
      expect(restored.receipt, 'receipt-data-base64');
      expect(restored.productId, 'com.relink.family_monthly');
      expect(restored.platform, 'ios');
      expect(restored.createdAt.year, 2026);
      expect(restored.createdAt.month, 4);
    });

    test('JSON 직렬화/역직렬화 string → Map → object', () {
      final receipt = PendingReceipt(
        receipt: 'test-receipt',
        productId: PlanProductIds.plus,
        platform: 'android',
        createdAt: DateTime(2025, 12, 25),
      );
      final jsonString = jsonEncode(receipt.toJson());
      final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
      final restored = PendingReceipt.fromJson(decoded);
      expect(restored.receipt, 'test-receipt');
      expect(restored.productId, PlanProductIds.plus);
      expect(restored.platform, 'android');
    });

    test('toJson 키 확인', () {
      final receipt = PendingReceipt(
        receipt: 'r',
        productId: 'p',
        platform: 'ios',
        createdAt: DateTime(2026),
      );
      final json = receipt.toJson();
      expect(json.containsKey('receipt'), isTrue);
      expect(json.containsKey('product_id'), isTrue);
      expect(json.containsKey('platform'), isTrue);
      expect(json.containsKey('created_at'), isTrue);
    });
  });

  // ── UserPlan 구독 관련 확장 ───────────────────────────────────────────────

  group('UserPlan 구독 관련', () {
    test('isSubscription — free/plus는 구독 아님', () {
      expect(UserPlan.free.isSubscription, isFalse);
      expect(UserPlan.plus.isSubscription, isFalse);
    });

    test('isSubscription — family/familyPlus는 구독', () {
      expect(UserPlan.family.isSubscription, isTrue);
      expect(UserPlan.familyPlus.isSubscription, isTrue);
    });

    test('hasVersionedBackup — familyPlus만 true', () {
      expect(UserPlan.free.hasVersionedBackup, isFalse);
      expect(UserPlan.plus.hasVersionedBackup, isFalse);
      expect(UserPlan.family.hasVersionedBackup, isFalse);
      expect(UserPlan.familyPlus.hasVersionedBackup, isTrue);
    });

    test('maxVideoCount', () {
      expect(UserPlan.free.maxVideoCount, 0);
      expect(UserPlan.plus.maxVideoCount, 10);
      expect(UserPlan.family.maxVideoCount, greaterThan(1000));
      expect(UserPlan.familyPlus.maxVideoCount, greaterThan(1000));
    });
  });
}
