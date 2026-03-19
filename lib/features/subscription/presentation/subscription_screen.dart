import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../../core/services/plan/plan_service.dart';
import '../../../design/glass/app_glass.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../design/tokens/app_spacing.dart';
import '../../../shared/models/user_plan.dart';
import '../providers/plan_notifier.dart';

/// 플랜 선택 / 업그레이드 화면
class SubscriptionScreen extends ConsumerStatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  ConsumerState<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends ConsumerState<SubscriptionScreen> {
  Map<String, ProductDetails> _products = {};
  bool _loading = true;
  bool _purchasing = false;
  String? _storeError;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final notifier = ref.read(planNotifierProvider.notifier);
    final available = await notifier.isStoreAvailable();
    if (!available) {
      if (mounted) {
        setState(() {
          _storeError = '스토어에 연결할 수 없습니다.';
          _loading = false;
        });
      }
      return;
    }
    final products = await notifier.loadProducts();
    if (mounted) {
      setState(() {
        _products = products;
        _loading = false;
      });
    }
  }

  Future<void> _buy(ProductDetails product) async {
    setState(() => _purchasing = true);
    try {
      await ref.read(planNotifierProvider.notifier).buy(product);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('구매 실패: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _purchasing = false);
    }
  }

  Future<void> _restore() async {
    setState(() => _purchasing = true);
    try {
      await ref.read(planNotifierProvider.notifier).restore();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('구매 복원 완료'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('복원 실패: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _purchasing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final planAsync = ref.watch(planNotifierProvider);
    final currentPlan = planAsync.valueOrNull ?? UserPlan.free;

    return Scaffold(
      backgroundColor: AppColors.bgBase,
      body: Stack(
        children: [
          // 배경 그라디언트
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topCenter,
                radius: 1.4,
                colors: [Color(0xFF1A1040), Color(0xFF0A0A1A)],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // 앱바
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: AppSpacing.sm,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                      ),
                      const Expanded(
                        child: Text(
                          '플랜 선택',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: _loading
                      ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                      : _storeError != null
                          ? _ErrorState(message: _storeError!)
                          : _PlanList(
                              currentPlan: currentPlan,
                              products: _products,
                              purchasing: _purchasing,
                              onBuy: _buy,
                            ),
                ),

                // 구매 복원
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                  child: TextButton(
                    onPressed: _purchasing ? null : _restore,
                    child: const Text(
                      '구매 복원',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 구매 중 오버레이
          if (_purchasing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),
        ],
      ),
    );
  }
}

// ── 플랜 목록 ──────────────────────────────────────────────────────────────────

class _PlanList extends StatelessWidget {
  const _PlanList({
    required this.currentPlan,
    required this.products,
    required this.purchasing,
    required this.onBuy,
  });

  final UserPlan currentPlan;
  final Map<String, ProductDetails> products;
  final bool purchasing;
  final void Function(ProductDetails) onBuy;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.md),
          _PlanCard(
            plan: UserPlan.free,
            isCurrent: currentPlan == UserPlan.free,
            product: null,
            purchasing: purchasing,
            onBuy: onBuy,
          ),
          const SizedBox(height: AppSpacing.md),
          _PlanCard(
            plan: UserPlan.basic,
            isCurrent: currentPlan == UserPlan.basic,
            product: products[PlanProductIds.basic],
            purchasing: purchasing,
            onBuy: onBuy,
          ),
          const SizedBox(height: AppSpacing.md),
          _PlanCard(
            plan: UserPlan.premium,
            isCurrent: currentPlan == UserPlan.premium,
            product: currentPlan == UserPlan.basic
                ? products[PlanProductIds.upgradeToPremium]
                : products[PlanProductIds.premium],
            purchasing: purchasing,
            onBuy: onBuy,
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}

// ── 플랜 카드 ──────────────────────────────────────────────────────────────────

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.isCurrent,
    required this.product,
    required this.purchasing,
    required this.onBuy,
  });

  final UserPlan plan;
  final bool isCurrent;
  final ProductDetails? product;
  final bool purchasing;
  final void Function(ProductDetails) onBuy;

  @override
  Widget build(BuildContext context) {
    final isPremium = plan == UserPlan.premium;
    final borderColor = isCurrent
        ? AppColors.primary
        : isPremium
            ? const Color(0xFFFFD700)
            : AppColors.glassBorder;

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          plan.displayName,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: isPremium ? const Color(0xFFFFD700) : AppColors.textPrimary,
                          ),
                        ),
                        if (isCurrent) ...[
                          const SizedBox(width: AppSpacing.sm),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withAlpha(40),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.primary.withAlpha(80)),
                            ),
                            child: const Text(
                              '현재 플랜',
                              style: TextStyle(fontSize: 11, color: AppColors.primary),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      plan.price,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                    ),
                    if (plan == UserPlan.basic)
                      const Text('1회 결제', style: TextStyle(fontSize: 12, color: AppColors.textTertiary)),
                    if (plan == UserPlan.premium)
                      const Text('1회 결제 · 영구 사용', style: TextStyle(fontSize: 12, color: AppColors.textTertiary)),
                  ],
                ),
              ),
              // 경계선 장식
              Container(
                width: 4,
                height: 60,
                decoration: BoxDecoration(
                  color: borderColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),
          const Divider(color: AppColors.glassBorder),
          const SizedBox(height: AppSpacing.sm),

          // 기능 목록
          ..._features(plan).map(
            (f) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(
                    f.enabled ? Icons.check_circle_outline : Icons.remove_circle_outline,
                    size: 16,
                    color: f.enabled ? AppColors.success : AppColors.textTertiary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    f.label,
                    style: TextStyle(
                      fontSize: 13,
                      color: f.enabled ? AppColors.textPrimary : AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 구매 버튼
          if (!isCurrent && plan != UserPlan.free) ...[
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (purchasing || product == null) ? null : () => onBuy(product!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isPremium ? const Color(0xFFFFD700) : AppColors.primary,
                  foregroundColor: isPremium ? Colors.black : Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  product != null
                      ? (plan == UserPlan.premium && product!.id == PlanProductIds.upgradeToPremium
                          ? '${product!.price} 업그레이드'
                          : '${product!.price} 구매')
                      : '스토어 미지원',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<({String label, bool enabled})> _features(UserPlan plan) => [
    (label: '노드 ${plan.maxNodes >= 999999 ? "무제한" : "${plan.maxNodes}개"}', enabled: true),
    (label: '사진 ${plan.maxPhotos >= 999999 ? "무제한" : "${plan.maxPhotos}장"}', enabled: true),
    (label: '음성 녹음 ${plan.hasVoice ? "${plan.maxVoiceMinutes}분" : "미지원"}', enabled: plan.hasVoice),
    (label: '광고 없음', enabled: !plan.hasAds),
  ];
}

// ── 에러 상태 ─────────────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off_outlined, size: 48, color: AppColors.textTertiary),
          const SizedBox(height: AppSpacing.md),
          Text(message, style: const TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
