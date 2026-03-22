import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/services/plan/plan_service.dart';
import '../../../core/services/auth/auth_http_client.dart';
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
    final settingsRepo = ref.read(settingsRepositoryProvider);

    // AuthHttpClient는 옵셔널 — 로컬 퍼스트 사용자는 서버 검증 불가
    AuthHttpClient? httpClient;
    try {
      httpClient = ref.read(authHttpClientProvider);
    } catch (_) {
      // authHttpClientProvider 미등록 시 null 유지
    }

    _planService = PlanService(
      InAppPurchase.instance,
      authHttpClient: httpClient,
      settingsRepository: settingsRepo,
    );

    _listenToPurchases();
    ref.onDispose(() => _purchaseSub?.cancel());

    // DB에서 현재 플랜 읽기
    final currentPlan = await settingsRepo.getUserPlan();

    // 앱 시작 시 구독 동기화: 구매 복원으로 최신 상태 확인 (#11)
    _syncSubscriptionOnStart();

    // 구독 플랜인 경우 만료 체크 (#3)
    if (currentPlan.isSubscription) {
      _checkSubscriptionValidity(currentPlan);
    }

    // 미검증 영수증 재시도 (#2)
    _planService.retryPendingReceipts();

    return currentPlan;
  }

  void _listenToPurchases() {
    _purchaseSub = _planService.purchaseStream.listen(
      _handlePurchaseUpdates,
      onError: (Object e) =>
          debugPrint('[PlanNotifier] purchaseStream error: $e'),
    );
  }

  /// 앱 시작 시 구독 동기화 — restorePurchases 호출로 최신 상태 반영 (#11)
  Future<void> _syncSubscriptionOnStart() async {
    try {
      final available = await _planService.isAvailable();
      if (!available) return;
      await _planService.restorePurchases();
      debugPrint('[PlanNotifier] 앱 시작 구독 동기화 완료');
    } catch (e) {
      debugPrint('[PlanNotifier] 앱 시작 구독 동기화 실패: $e');
    }
  }

  /// 구독 유효성 체크 — 만료되었으면 무료 플랜으로 다운그레이드 (#3)
  Future<void> _checkSubscriptionValidity(UserPlan currentPlan) async {
    try {
      final expiresAt = await _planService.getSubscriptionExpiry();
      if (expiresAt == null) {
        // 만료일 정보 없음 — restorePurchases에서 갱신 예정
        return;
      }

      if (expiresAt.isBefore(DateTime.now())) {
        // 구독 만료 → 무료 플랜으로 다운그레이드
        debugPrint('[PlanNotifier] 구독 만료 감지: $expiresAt');
        final settings = ref.read(settingsRepositoryProvider);
        await settings.setUserPlan(UserPlan.free);
        state = const AsyncData(UserPlan.free);
      }
    } catch (e) {
      debugPrint('[PlanNotifier] 구독 유효성 체크 오류: $e');
    }
  }

  Future<void> _handlePurchaseUpdates(
      List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      // pending 상태 처리 (#6) — 로딩 상태 표시
      if (purchase.status == PurchaseStatus.pending) {
        state = const AsyncLoading();
        debugPrint('[PlanNotifier] 구매 대기 중: ${purchase.productID}');
        continue;
      }

      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        final plan = PlanService.planFromProductId(purchase.productID);

        // 서버 영수증 검증 후 플랜 업그레이드 (#2)
        if (purchase.pendingCompletePurchase) {
          final verified = await _planService
              .completePurchaseWithVerification(purchase);
          if (!verified) {
            // 서버가 명시적으로 거부 — 업그레이드 불가
            debugPrint(
                '[PlanNotifier] 영수증 검증 실패, 업그레이드 불가');
            state = AsyncData(
                state.valueOrNull ?? UserPlan.free);
            continue;
          }
        }

        await _upgradePlan(plan);
      } else if (purchase.status == PurchaseStatus.error) {
        debugPrint(
            '[PlanNotifier] purchase error: ${purchase.error}');
        // 에러 시 현재 플랜 유지 (로딩 상태 해제)
        state = AsyncData(state.valueOrNull ?? UserPlan.free);
      } else if (purchase.status == PurchaseStatus.canceled) {
        debugPrint(
            '[PlanNotifier] purchase cancelled: ${purchase.productID}');
        // 취소 시 현재 플랜 유지 (로딩 상태 해제)
        state = AsyncData(state.valueOrNull ?? UserPlan.free);
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

  /// 구독 만료일 조회 (UI 표시용)
  Future<DateTime?> getSubscriptionExpiry() =>
      _planService.getSubscriptionExpiry();
}
