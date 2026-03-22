import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../../shared/models/user_plan.dart';
import '../auth/auth_http_client.dart';
import '../../../shared/repositories/settings_repository.dart';

/// 인앱 구매 상품 ID (앱 전체에서 이 클래스만 참조)
class PlanProductIds {
  // 1회성 구매
  static const String plus = 'com.relink.plus';

  // 자동 갱신 구독
  static const String familyMonthly = 'com.relink.family_monthly';
  static const String familyAnnual = 'com.relink.family_annual';
  static const String familyPlusMonthly = 'com.relink.family_plus_monthly';
  static const String familyPlusAnnual = 'com.relink.family_plus_annual';

  static const Set<String> all = {
    plus,
    familyMonthly,
    familyAnnual,
    familyPlusMonthly,
    familyPlusAnnual,
  };

  /// 구독 상품 ID 목록
  static const Set<String> subscriptions = {
    familyMonthly,
    familyAnnual,
    familyPlusMonthly,
    familyPlusAnnual,
  };

  /// 비소모성 (1회 구매) 상품 ID 목록
  static const Set<String> nonConsumables = {plus};

  /// 상품 ID가 구독인지 여부
  static bool isSubscription(String productId) =>
      subscriptions.contains(productId);
}

/// 구매 결과
sealed class PurchaseResult {}

class PurchaseSuccess extends PurchaseResult {
  PurchaseSuccess(this.plan);
  final UserPlan plan;
}

class PurchasePending extends PurchaseResult {}

class PurchaseFailed extends PurchaseResult {
  PurchaseFailed(this.message);
  final String message;
}

class PurchaseCancelled extends PurchaseResult {}

/// 영수증 검증 결과
class ReceiptVerificationResult {
  const ReceiptVerificationResult({
    required this.isValid,
    this.expiresAt,
    this.errorMessage,
  });

  final bool isValid;
  final DateTime? expiresAt;
  final String? errorMessage;
}

/// 로컬 대기 중 영수증 (서버 미응답 시 재시도용)
class PendingReceipt {
  const PendingReceipt({
    required this.receipt,
    required this.productId,
    required this.platform,
    required this.createdAt,
  });

  final String receipt;
  final String productId;
  final String platform;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
        'receipt': receipt,
        'product_id': productId,
        'platform': platform,
        'created_at': createdAt.toIso8601String(),
      };

  factory PendingReceipt.fromJson(Map<String, dynamic> json) =>
      PendingReceipt(
        receipt: json['receipt'] as String,
        productId: json['product_id'] as String,
        platform: json['platform'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}

/// InAppPurchase 래퍼 서비스
class PlanService {
  PlanService(this._iap, {this.authHttpClient, this.settingsRepository});

  final InAppPurchase _iap;
  final AuthHttpClient? authHttpClient;
  final SettingsRepository? settingsRepository;
  StreamSubscription<List<PurchaseDetails>>? _sub;

  /// 스토어 이용 가능 여부 확인
  Future<bool> isAvailable() => _iap.isAvailable();

  /// 상품 정보 조회
  Future<Map<String, ProductDetails>> loadProducts() async {
    final response = await _iap.queryProductDetails(PlanProductIds.all);
    if (response.error != null) {
      debugPrint('[PlanService] queryProductDetails error: ${response.error}');
    }
    return {for (final p in response.productDetails) p.id: p};
  }

  /// 구매 스트림 수신 시작 — 앱 기동 시 1회 호출
  Stream<List<PurchaseDetails>> get purchaseStream => _iap.purchaseStream;

  /// 구매 완료 처리 + 서버 영수증 검증
  /// 서버 검증 성공 시에만 true 반환, 서버 불가 시 로컬 저장 후 true 반환
  Future<bool> completePurchaseWithVerification(
      PurchaseDetails details) async {
    // 서버 영수증 검증 시도
    final verified = await verifyReceipt(details);

    if (!verified.isValid && verified.errorMessage != null) {
      // 서버에서 명시적으로 거부한 경우 — 업그레이드 불가
      debugPrint(
          '[PlanService] 영수증 검증 실패: ${verified.errorMessage}');
      await _iap.completePurchase(details);
      return false;
    }

    // 구독 만료일 저장
    if (verified.expiresAt != null) {
      await _saveSubscriptionExpiry(
          details.productID, verified.expiresAt!);
    }

    // 스토어에 구매 완료 처리
    await _iap.completePurchase(details);
    return true;
  }

  /// 서버 영수증 검증
  /// 서버 불가 시에도 로컬에 저장하고 유효로 간주 (오프라인 우선)
  Future<ReceiptVerificationResult> verifyReceipt(
      PurchaseDetails details) async {
    final client = authHttpClient;
    if (client == null) {
      // HTTP 클라이언트 없음 — 로컬 퍼스트 모드
      return const ReceiptVerificationResult(isValid: true);
    }

    try {
      final platform = Platform.isIOS ? 'ios' : 'android';
      final receipt = details.verificationData.serverVerificationData;

      final response = await client.post(
        '/purchase/verify',
        body: {
          'receipt': receipt,
          'product_id': details.productID,
          'platform': platform,
        },
      );

      if (response.statusCode == 200) {
        final data =
            jsonDecode(response.body) as Map<String, dynamic>;
        final result = data['data'] as Map<String, dynamic>?;
        return ReceiptVerificationResult(
          isValid: result?['valid'] as bool? ?? true,
          expiresAt: result?['expires_at'] != null
              ? DateTime.tryParse(result!['expires_at'] as String)
              : null,
          errorMessage: result?['error'] as String?,
        );
      } else if (response.statusCode == 403) {
        // 서버가 영수증을 명시적으로 거부
        return ReceiptVerificationResult(
          isValid: false,
          errorMessage: '영수증 검증 실패 (${response.statusCode})',
        );
      } else {
        // 서버 일시 오류 — 로컬에 저장 후 나중에 재시도
        await _savePendingReceipt(details);
        return const ReceiptVerificationResult(isValid: true);
      }
    } catch (e) {
      // 네트워크 오류 — 로컬에 저장 후 나중에 재시도
      debugPrint('[PlanService] 영수증 검증 네트워크 오류: $e');
      await _savePendingReceipt(details);
      return const ReceiptVerificationResult(isValid: true);
    }
  }

  /// 미검증 영수증 로컬 저장 (나중에 재시도)
  Future<void> _savePendingReceipt(PurchaseDetails details) async {
    final settings = settingsRepository;
    if (settings == null) return;

    final pending = PendingReceipt(
      receipt: details.verificationData.serverVerificationData,
      productId: details.productID,
      platform: Platform.isIOS ? 'ios' : 'android',
      createdAt: DateTime.now(),
    );
    await settings.set(
        'pending_receipt_${details.productID}', jsonEncode(pending.toJson()));
  }

  /// 미검증 영수증 재시도 (앱 시작 시 호출)
  Future<void> retryPendingReceipts() async {
    final settings = settingsRepository;
    final client = authHttpClient;
    if (settings == null || client == null) return;

    // 구독 상품 ID별 대기 영수증 확인
    for (final productId in PlanProductIds.all) {
      final raw = await settings.get('pending_receipt_$productId');
      if (raw == null || raw.isEmpty) continue;

      try {
        final pending = PendingReceipt.fromJson(
            jsonDecode(raw) as Map<String, dynamic>);
        final response = await client.post(
          '/purchase/verify',
          body: {
            'receipt': pending.receipt,
            'product_id': pending.productId,
            'platform': pending.platform,
          },
        );

        if (response.statusCode == 200 || response.statusCode == 403) {
          // 검증 완료 (성공 또는 거부) — 대기 영수증 삭제
          await settings.set('pending_receipt_$productId', '');
          debugPrint('[PlanService] 대기 영수증 재검증 완료: $productId');
        }
        // 기타 상태코드: 다음 앱 시작 시 재시도
      } catch (e) {
        debugPrint('[PlanService] 대기 영수증 재시도 실패: $e');
      }
    }
  }

  /// 구독 만료일 로컬 저장
  Future<void> _saveSubscriptionExpiry(
      String productId, DateTime expiresAt) async {
    final settings = settingsRepository;
    if (settings == null) return;
    await settings.set(
        'subscription_expires_at', expiresAt.toIso8601String());
  }

  /// 구독 만료일 조회
  Future<DateTime?> getSubscriptionExpiry() async {
    final settings = settingsRepository;
    if (settings == null) return null;
    final v = await settings.get('subscription_expires_at');
    return v == null || v.isEmpty ? null : DateTime.tryParse(v);
  }

  /// 구매 완료 처리 (pendingCompletePurchase=true인 항목 consume)
  Future<void> completePurchase(PurchaseDetails details) =>
      _iap.completePurchase(details);

  /// 상품 구매 요청
  /// - plus: 1회성 비소모성 구매 (buyNonConsumable)
  /// - family, familyPlus: 자동 갱신 구독 (buyNonConsumable — in_app_purchase 패키지에서
  ///   구독/비소모성 모두 buyNonConsumable() 사용, 스토어 측 상품 타입으로 구분)
  Future<bool> buy(ProductDetails product) {
    final param = PurchaseParam(productDetails: product);
    // in_app_purchase 패키지는 구독과 비소모성 모두 buyNonConsumable() 사용
    // 실제 구분은 App Store Connect / Google Play Console의 상품 타입에 의해 결정
    return _iap.buyNonConsumable(purchaseParam: param);
  }

  /// 구매 복원
  Future<void> restorePurchases() => _iap.restorePurchases();

  /// PurchaseDetails → UserPlan 매핑
  static UserPlan planFromProductId(String productId) {
    return switch (productId) {
      PlanProductIds.plus => UserPlan.plus,
      PlanProductIds.familyMonthly => UserPlan.family,
      PlanProductIds.familyAnnual => UserPlan.family,
      PlanProductIds.familyPlusMonthly => UserPlan.familyPlus,
      PlanProductIds.familyPlusAnnual => UserPlan.familyPlus,
      _ => UserPlan.free,
    };
  }

  void dispose() {
    _sub?.cancel();
  }
}
