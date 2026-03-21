import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/services/plan/plan_service.dart';
import '../../../shared/models/user_plan.dart';
import '../../../shared/repositories/settings_repository.dart';

part 'plan_notifier.g.dart';

/// 현재 플랜 상태 (DB에서 읽음)
@riverpod
class PlanNotifier extends _$PlanNotifier {
  StreamSubscription<List<PurchaseDetails>>? _purchaseSub;
  late final PlanService _planService;

  @override
  Future<UserPlan> build() async {
    _planService = PlanService(InAppPurchase.instance);
    _listenToPurchases();
    ref.onDispose(() => _purchaseSub?.cancel());
    return ref.read(settingsRepositoryProvider).getUserPlan();
  }

  void _listenToPurchases() {
    _purchaseSub = _planService.purchaseStream.listen(
      _handlePurchaseUpdates,
      onError: (Object e) => debugPrint('[PlanNotifier] purchaseStream error: $e'),
    );
  }

  Future<void> _handlePurchaseUpdates(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.pending) continue;

      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        final plan = PlanService.planFromProductId(purchase.productID);
        await _upgradePlan(plan);
        if (purchase.pendingCompletePurchase) {
          await _planService.completePurchase(purchase);
        }
      } else if (purchase.status == PurchaseStatus.error) {
        debugPrint('[PlanNotifier] purchase error: ${purchase.error}');
      }
    }
  }

  Future<void> _upgradePlan(UserPlan newPlan) async {
    final current = state.valueOrNull ?? UserPlan.free;
    // 다운그레이드 방지 (enum 순서: free=0 < plus=1 < family=2 < familyPlus=3)
    if (newPlan.index <= current.index) return;
    await ref.read(settingsRepositoryProvider).setUserPlan(newPlan);
    state = AsyncData(newPlan);
  }

  /// 상품 목록 조회
  Future<Map<String, ProductDetails>> loadProducts() =>
      _planService.loadProducts();

  /// 구매 요청
  Future<void> buy(ProductDetails product) async {
    await _planService.buy(product);
  }

  /// 구매 복원
  Future<void> restore() async {
    await _planService.restorePurchases();
  }

  /// 스토어 이용 가능 여부
  Future<bool> isStoreAvailable() => _planService.isAvailable();
}
