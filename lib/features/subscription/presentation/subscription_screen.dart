import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../core/services/plan/plan_service.dart';
import '../../../design/glass/app_glass.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../design/tokens/app_spacing.dart';
import '../../../shared/models/user_plan.dart';
import '../../auth/providers/auth_notifier.dart';
import '../providers/plan_notifier.dart';

/// 플랜 선택 / 업그레이드 화면 (4-Plan: 무료 / 플러스 / 패밀리 / 패밀리플러스)
class SubscriptionScreen extends ConsumerStatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  ConsumerState<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends ConsumerState<SubscriptionScreen> {
  Map<String, ProductDetails> _products = {};
  bool _loading = true;
  bool _purchasing = false;
  bool _isAnnual = true; // 기본값: 연간 (할인)
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
      // 패밀리 플랜 구매 완료 후 미로그인이면 로그인 유도
      if (mounted) {
        final user = ref.read(authNotifierProvider).valueOrNull;
        final plan = ref.read(planNotifierProvider).valueOrNull;
        if (user == null && (plan == UserPlan.family || plan == UserPlan.familyPlus)) {
          await _showLoginPrompt();
        }
      }
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

  Future<void> _showLoginPrompt() async {
    final shouldLogin = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('클라우드 동기화를 사용하려면'),
        content: const Text(
          '패밀리 플랜의 클라우드 동기화와 가족 공유를 사용하려면 로그인이 필요합니다.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('나중에'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('로그인', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
    if (shouldLogin == true && mounted) {
      context.push(AppRoutes.login);
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
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topCenter,
                radius: 1.4,
                colors: [AppColors.bgSurface, AppColors.bgBase],
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
                        icon: Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 20),
                      ),
                      Expanded(
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
                      ? Center(child: CircularProgressIndicator(color: AppColors.primary))
                      : _storeError != null
                          ? _ErrorState(message: _storeError!)
                          : _PlanList(
                              currentPlan: currentPlan,
                              products: _products,
                              purchasing: _purchasing,
                              isAnnual: _isAnnual,
                              onToggleBilling: (val) {
                                setState(() => _isAnnual = val);
                              },
                              onBuy: _buy,
                            ),
                ),

                // 현재 구독 정보 표시 (#20)
                if (currentPlan.isSubscription)
                  _SubscriptionInfoSection(
                    currentPlan: currentPlan,
                  ),

                // 구매 복원
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                  child: TextButton(
                    onPressed: _purchasing ? null : _restore,
                    child: Text(
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
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),
        ],
      ),
    );
  }
}

// ── 월간/연간 토글 ────────────────────────────────────────────────────────────

class _BillingToggle extends StatelessWidget {
  const _BillingToggle({
    required this.isAnnual,
    required this.onChanged,
  });

  final bool isAnnual;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.glassSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ToggleTab(
            label: '월간',
            isSelected: !isAnnual,
            onTap: () => onChanged(false),
          ),
          _ToggleTab(
            label: '연간',
            isSelected: isAnnual,
            badge: '할인',
            onTap: () => onChanged(true),
          ),
        ],
      ),
    );
  }
}

class _ToggleTab extends StatelessWidget {
  const _ToggleTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.badge,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.onPrimary : AppColors.textSecondary,
              ),
            ),
            if (badge != null && isSelected) ...[
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: AppColors.onPrimary.withAlpha(40),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badge!,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onPrimary,
                  ),
                ),
              ),
            ],
          ],
        ),
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
    required this.isAnnual,
    required this.onToggleBilling,
    required this.onBuy,
  });

  final UserPlan currentPlan;
  final Map<String, ProductDetails> products;
  final bool purchasing;
  final bool isAnnual;
  final ValueChanged<bool> onToggleBilling;
  final void Function(ProductDetails) onBuy;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.sm),

          // 월간/연간 토글
          _BillingToggle(
            isAnnual: isAnnual,
            onChanged: onToggleBilling,
          ),

          const SizedBox(height: AppSpacing.lg),

          // 무료
          _PlanCard(
            plan: UserPlan.free,
            isCurrent: currentPlan == UserPlan.free,
            product: null,
            purchasing: purchasing,
            isAnnual: isAnnual,
            onBuy: onBuy,
          ),
          const SizedBox(height: AppSpacing.md),

          // 플러스
          _PlanCard(
            plan: UserPlan.plus,
            isCurrent: currentPlan == UserPlan.plus,
            product: products[PlanProductIds.plus],
            purchasing: purchasing,
            isAnnual: isAnnual,
            onBuy: onBuy,
          ),
          const SizedBox(height: AppSpacing.md),

          // 패밀리 (BEST)
          _PlanCard(
            plan: UserPlan.family,
            isCurrent: currentPlan == UserPlan.family,
            product: isAnnual
                ? products[PlanProductIds.familyAnnual]
                : products[PlanProductIds.familyMonthly],
            purchasing: purchasing,
            isAnnual: isAnnual,
            onBuy: onBuy,
          ),
          const SizedBox(height: AppSpacing.md),

          // 패밀리플러스
          _PlanCard(
            plan: UserPlan.familyPlus,
            isCurrent: currentPlan == UserPlan.familyPlus,
            product: isAnnual
                ? products[PlanProductIds.familyPlusAnnual]
                : products[PlanProductIds.familyPlusMonthly],
            purchasing: purchasing,
            isAnnual: isAnnual,
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
    required this.isAnnual,
    required this.onBuy,
  });

  final UserPlan plan;
  final bool isCurrent;
  final ProductDetails? product;
  final bool purchasing;
  final bool isAnnual;
  final void Function(ProductDetails) onBuy;

  /// 플랜별 테마 색상
  Color get _themeColor => switch (plan) {
        UserPlan.free => AppColors.planFree,
        UserPlan.plus => AppColors.planPlus,
        UserPlan.family => AppColors.planFamily,
        UserPlan.familyPlus => AppColors.planFamilyPlus,
      };

  /// BEST 배지 표시 여부
  bool get _showBestBadge => plan == UserPlan.family;

  @override
  Widget build(BuildContext context) {
    final borderColor = isCurrent
        ? AppColors.primary
        : _themeColor.withAlpha(120);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        GlassCard(
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
                                color: _themeColor,
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
                                child: Text(
                                  '현재 플랜',
                                  style: TextStyle(fontSize: 11, color: AppColors.primary),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        // 가격 섹션
                        _buildPriceSection(),
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
              Divider(color: AppColors.glassBorder),
              const SizedBox(height: AppSpacing.sm),

              // 기능 목록
              ..._featuresForPlan(plan).map(
                (f) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      Icon(
                        f.enabled ? Icons.check_circle_outline : Icons.remove_circle_outline,
                        size: 16,
                        color: f.enabled ? AppColors.success : AppColors.textTertiary,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          f.label,
                          style: TextStyle(
                            fontSize: 13,
                            color: f.enabled ? AppColors.textPrimary : AppColors.textTertiary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 구매/구독 버튼
              if (!isCurrent && plan != UserPlan.free) ...[
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: (purchasing || product == null) ? null : () => onBuy(product!),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _themeColor,
                      foregroundColor:
                          plan == UserPlan.familyPlus ? Colors.black : AppColors.onPrimary,
                      disabledBackgroundColor: _themeColor.withAlpha(80),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: Text(
                      _buttonLabel,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),

        // BEST 배지 (패밀리)
        if (_showBestBadge)
          Positioned(
            top: -10,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF9B7DFF), Color(0xFF7C5CFF)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x30000000),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: const Text(
                'BEST',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ── 가격 섹션 ───────────────────────────────────────────────────────────────

  Widget _buildPriceSection() {
    switch (plan) {
      case UserPlan.free:
        return Text(
          '무료',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        );

      case UserPlan.plus:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '₩4,900',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.planPlus.withAlpha(25),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.planPlus.withAlpha(60)),
              ),
              child: Text(
                '1회 결제 · 영구 소유',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.planPlus,
                ),
              ),
            ),
          ],
        );

      case UserPlan.family:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isAnnual ? '₩37,900/년' : '₩3,900/월',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            if (isAnnual)
              Text(
                '월 ₩3,158 · 20% 할인',
                style: TextStyle(fontSize: 12, color: AppColors.planFamily),
              )
            else
              Text(
                '연 ₩37,900 (20% 할인)',
                style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
              ),
          ],
        );

      case UserPlan.familyPlus:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isAnnual ? '₩61,900/년' : '₩6,900/월',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            if (isAnnual)
              Text(
                '월 ₩5,158 · 25% 할인',
                style: TextStyle(fontSize: 12, color: AppColors.planFamilyPlus),
              )
            else
              Text(
                '연 ₩61,900 (25% 할인)',
                style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
              ),
          ],
        );
    }
  }

  // ── 구매 버튼 라벨 ─────────────────────────────────────────────────────────

  String get _buttonLabel {
    if (product == null) return '스토어 미지원';

    switch (plan) {
      case UserPlan.plus:
        return '₩4,900 결제하기';
      case UserPlan.family:
        return isAnnual ? '연 ₩37,900 구독하기' : '월 ₩3,900 구독하기';
      case UserPlan.familyPlus:
        return isAnnual ? '연 ₩61,900 구독하기' : '월 ₩6,900 구독하기';
      default:
        return '';
    }
  }
}

// ── 플랜별 기능 목록 ─────────────────────────────────────────────────────────

List<({String label, bool enabled})> _featuresForPlan(UserPlan plan) {
  switch (plan) {
    case UserPlan.free:
      return [
        (label: '가족 노드 15개', enabled: true),
        (label: '사진 50장', enabled: true),
        (label: '음성 5분', enabled: true),
        (label: '광고 포함', enabled: false),
      ];
    case UserPlan.plus:
      return [
        (label: '노드 무제한', enabled: true),
        (label: '사진 무제한', enabled: true),
        (label: '음성 무제한', enabled: true),
        (label: '영상 30초 (10개)', enabled: true),
        (label: '광고 없음', enabled: true),
        (label: '기기 내 저장 (로컬 전용)', enabled: true),
      ];
    case UserPlan.family:
      return [
        (label: '플러스 전체 포함', enabled: true),
        (label: '클라우드 동기화 20GB', enabled: true),
        (label: '가족 실시간 공유 6명', enabled: true),
        (label: '영상 최대 3분 · 클라우드 저장', enabled: true),
        (label: '자동 클라우드 백업', enabled: true),
        (label: '우선 고객 지원', enabled: true),
      ];
    case UserPlan.familyPlus:
      return [
        (label: '패밀리 전체 포함', enabled: true),
        (label: '클라우드 100GB', enabled: true),
        (label: '가족 초대 무제한', enabled: true),
        (label: '영상 최대 10분 · 클라우드 저장', enabled: true),
        (label: '버전 관리 백업', enabled: true),
        (label: '신기능 얼리 액세스', enabled: true),
      ];
  }
}

// ── 구독 정보 섹션 (#20) ───────────────────────────────────────────────────────

class _SubscriptionInfoSection extends ConsumerWidget {
  const _SubscriptionInfoSection({required this.currentPlan});

  final UserPlan currentPlan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<DateTime?>(
      future: ref.read(planNotifierProvider.notifier).getSubscriptionExpiry(),
      builder: (context, snapshot) {
        final expiresAt = snapshot.data;

        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          child: GlassCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.card_membership_outlined,
                        size: 18, color: AppColors.primary),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      '현재 구독 정보',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Divider(color: AppColors.glassBorder),
                const SizedBox(height: AppSpacing.sm),

                // 플랜명
                _InfoRow(
                  label: '플랜',
                  value: currentPlan.displayName,
                ),

                // 갱신일
                if (expiresAt != null)
                  _InfoRow(
                    label: '다음 갱신일',
                    value: _formatDate(expiresAt),
                  ),

                const SizedBox(height: AppSpacing.sm),

                // 구독 관리 안내
                Text(
                  '구독 해지는 기기의 설정 > 구독에서 가능합니다.',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}년 ${date.month}월 ${date.day}일';
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
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
          Icon(Icons.cloud_off_outlined, size: 48, color: AppColors.textTertiary),
          const SizedBox(height: AppSpacing.md),
          Text(message, style: TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
