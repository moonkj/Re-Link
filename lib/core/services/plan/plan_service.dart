import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../../shared/models/user_plan.dart';

/// 인앱 구매 상품 ID
class PlanProductIds {
  static const String basic = 'com.relink.basic';
  static const String premium = 'com.relink.premium';
  static const String upgradeToPremium = 'com.relink.upgrade_to_premium';

  static const Set<String> all = {basic, premium, upgradeToPremium};
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

/// InAppPurchase 래퍼 서비스
class PlanService {
  PlanService(this._iap);

  final InAppPurchase _iap;
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

  /// 구매 완료 처리 (pendingCompletePurchase=true인 항목 consume)
  Future<void> completePurchase(PurchaseDetails details) =>
      _iap.completePurchase(details);

  /// 상품 구매 요청
  Future<bool> buy(ProductDetails product) {
    final param = PurchaseParam(productDetails: product);
    return _iap.buyNonConsumable(purchaseParam: param);
  }

  /// 구매 복원
  Future<void> restorePurchases() => _iap.restorePurchases();

  /// PurchaseDetails → UserPlan 매핑
  static UserPlan planFromProductId(String productId) {
    return switch (productId) {
      PlanProductIds.basic => UserPlan.basic,
      PlanProductIds.premium => UserPlan.premium,
      PlanProductIds.upgradeToPremium => UserPlan.premium,
      _ => UserPlan.free,
    };
  }

  void dispose() {
    _sub?.cancel();
  }
}
