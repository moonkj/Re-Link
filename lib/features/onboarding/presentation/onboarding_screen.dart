import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../core/services/notification/notification_service.dart';
import '../../../design/glass/app_glass.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../design/tokens/app_spacing.dart';
import '../../../shared/repositories/settings_repository.dart';

/// 온보딩 3스텝 화면 (첫 실행 시)
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  /// 페이지 수 (Step 1~3, 마지막은 알림 권한)
  static const _pageCount = 3;

  static final _pages = [
    _OnboardingData(
      icon: Icons.account_tree_outlined,
      title: '살아있는\n가족 이야기',
      subtitle: '딱딱한 족보를 벗어나\n무한 캔버스 위에 가족을 연결하세요',
      color: AppColors.primary,
    ),
    _OnboardingData(
      icon: Icons.auto_stories_outlined,
      title: '사진, 음성, 메모로\n기억 보존',
      subtitle: '소중한 순간을 여러 형태로 남기고\n언제든 꺼내볼 수 있어요',
      color: AppColors.secondary,
    ),
    _OnboardingData(
      icon: Icons.notifications_active_outlined,
      title: '가족의 중요한 순간을\n놓치지 마세요',
      subtitle: '생일, 기일, 따뜻한 리마인더를\n알림으로 받아보세요',
      color: AppColors.accent,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _complete() async {
    await ref.read(settingsRepositoryProvider).setOnboardingDone();
    if (!mounted) return;
    context.go(AppRoutes.profileSetup);
  }

  Future<void> _skip() => _complete();

  void _nextPage() {
    if (_currentPage < _pageCount - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _complete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgBase,
      body: Stack(
        children: [
          // ── 배경 ─────────────────────────────────────────────
          Container(
            color: AppColors.bgBase,
          ),

          // ── PageView ────────────────────────────────────────────────────
          PageView.builder(
            controller: _pageController,
            itemCount: _pageCount,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (_, i) {
              // Step 3 (index 2): 알림 권한 페이지
              if (i == 2) {
                return _NotificationPermissionPage(
                  data: _pages[i],
                  onComplete: _complete,
                );
              }
              return _OnboardingPage(data: _pages[i]);
            },
          ),

          // ── 스킵 버튼 (PageView 위에 렌더링) ─────────────────────────────
          Positioned(
            top: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: TextButton(
                  onPressed: _skip,
                  child: Text(
                    '건너뛰기',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                  ),
                ),
              ),
            ),
          ),

          // ── 하단 인디케이터 + CTA ────────────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 페이지 인디케이터
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _pageCount,
                        (i) => AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: i == _currentPage ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: i == _currentPage
                                ? AppColors.primary
                                : AppColors.textDisabled,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    // CTA 버튼
                    SizedBox(
                      width: double.infinity,
                      child: PrimaryGlassButton(
                        label: _currentPage < _pageCount - 1 ? '다음' : '시작하기',
                        onPressed: _nextPage,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 온보딩 개별 페이지 (Step 1, 2)
class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({required this.data});
  final _OnboardingData data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 80), // 스킵 버튼 공간
          // 아이콘 일러스트
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: data.color.withAlpha(25),
              border: Border.all(color: data.color.withAlpha(60), width: 1.5),
            ),
            child: Icon(data.icon, size: 80, color: data.color),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text(
            data.title,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1.25,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            data.subtitle,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 160), // 하단 버튼 공간
        ],
      ),
    );
  }
}

/// Step 3: 알림 권한 요청 페이지 (인터랙티브)
class _NotificationPermissionPage extends ConsumerStatefulWidget {
  const _NotificationPermissionPage({
    required this.data,
    required this.onComplete,
  });

  final _OnboardingData data;
  final VoidCallback onComplete;

  @override
  ConsumerState<_NotificationPermissionPage> createState() =>
      _NotificationPermissionPageState();
}

class _NotificationPermissionPageState
    extends ConsumerState<_NotificationPermissionPage>
    with TickerProviderStateMixin {
  bool _permissionGranted = false;
  bool _requesting = false;

  // 셀레브레이션 애니메이션
  late final AnimationController _bounceController;
  late final Animation<double> _bounceAnimation;
  late final AnimationController _confettiController;
  late final Animation<double> _confettiAnimation;

  @override
  void initState() {
    super.initState();

    // Scale bounce: 0.8 → 1.2 → 1.0
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _bounceAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.8), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 0.8, end: 1.2), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 40),
    ]).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.easeInOut,
    ));

    // Confetti fade-in + rise
    _confettiController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _confettiAnimation = CurvedAnimation(
      parent: _confettiController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _requestPermission() async {
    if (_requesting || _permissionGranted) return;
    setState(() => _requesting = true);

    try {
      final svc = ref.read(notificationServiceProvider);
      final granted = await svc.requestPermission();

      if (!mounted) return;

      if (granted) {
        setState(() {
          _permissionGranted = true;
          _requesting = false;
        });
        // 셀레브레이션 애니메이션 실행
        _bounceController.forward();
        _confettiController.forward();
      } else {
        setState(() => _requesting = false);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _requesting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 80),
          // 아이콘 + 셀레브레이션
          Stack(
            alignment: Alignment.center,
            children: [
              // Confetti 이모지 애니메이션
              if (_permissionGranted)
                AnimatedBuilder(
                  animation: _confettiAnimation,
                  builder: (_, __) => Opacity(
                    opacity: _confettiAnimation.value,
                    child: Transform.translate(
                      offset: Offset(0, -30 * _confettiAnimation.value),
                      child: const Text(
                        '🎉🎊✨',
                        style: TextStyle(fontSize: 32),
                      ),
                    ),
                  ),
                ),
              // Scale bounce 아이콘
              AnimatedBuilder(
                animation: _bounceAnimation,
                builder: (_, child) => Transform.scale(
                  scale: _bounceAnimation.value,
                  child: child,
                ),
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _permissionGranted
                        ? AppColors.secondary.withAlpha(25)
                        : widget.data.color.withAlpha(25),
                    border: Border.all(
                      color: _permissionGranted
                          ? AppColors.secondary.withAlpha(60)
                          : widget.data.color.withAlpha(60),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    _permissionGranted
                        ? Icons.notifications_active
                        : widget.data.icon,
                    size: 80,
                    color: _permissionGranted
                        ? AppColors.secondary
                        : widget.data.color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text(
            _permissionGranted
                ? '알림이\n활성화되었어요!'
                : widget.data.title,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1.25,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            _permissionGranted
                ? '가족의 생일, 기일, 따뜻한 리마인더를\n놓치지 않을 거예요'
                : widget.data.subtitle,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xxl),
          // 알림 허용 버튼 (권한 미허용 시만 표시)
          if (!_permissionGranted)
            SizedBox(
              width: double.infinity,
              child: PrimaryGlassButton(
                label: _requesting ? '권한 요청 중...' : '알림 허용하기',
                onPressed: _requesting ? null : _requestPermission,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          const SizedBox(height: 100), // 하단 버튼 공간
        ],
      ),
    );
  }
}

class _OnboardingData {
  const _OnboardingData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
}
