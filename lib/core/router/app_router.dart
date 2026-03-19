import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/profile_setup/presentation/profile_setup_screen.dart';
import '../../features/canvas/presentation/canvas_screen.dart';
import '../../features/story/presentation/story_feed_screen.dart';
import '../../features/archive/presentation/archive_screen.dart';
import '../../features/backup/presentation/backup_screen.dart';
import '../../features/memory/presentation/memory_screen.dart';
import '../../features/search/presentation/search_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/subscription/presentation/subscription_screen.dart';
import '../../features/settings/presentation/privacy_policy_screen.dart';
import '../../shared/repositories/settings_repository.dart';
import '../../shared/widgets/ad_banner_widget.dart';

/// 라우트 경로 상수
abstract final class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String profileSetup = '/profile-setup';
  static const String canvas = '/canvas';
  static const String story = '/story';
  static const String archive = '/archive';
  static const String memory = '/memory/:nodeId';
  static const String backup = '/backup';
  static const String settings = '/settings';
  static const String search = '/search';
  static const String subscription = '/subscription';
  static const String privacyPolicy = '/privacy-policy';

  static String memoryPath(String nodeId) => '/memory/$nodeId';
}

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    redirect: (context, state) async {
      final settingsRepo = ref.read(settingsRepositoryProvider);
      final onboardingDone = await settingsRepo.isOnboardingDone();

      if (state.matchedLocation == AppRoutes.splash) {
        if (!onboardingDone) return AppRoutes.onboarding;
        return AppRoutes.canvas;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (_, s) => const _SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (_, s) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.profileSetup,
        builder: (_, s) => const ProfileSetupScreen(),
      ),
      // ── 5탭 ShellRoute ────────────────────────────────────────────────────
      ShellRoute(
        builder: (context, state, child) => _MainShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.canvas,
            builder: (_, s) => const CanvasScreen(),
          ),
          GoRoute(
            path: AppRoutes.story,
            builder: (_, s) => const StoryFeedScreen(),
          ),
          GoRoute(
            path: AppRoutes.archive,
            builder: (_, s) => const ArchiveScreen(),
          ),
          GoRoute(
            path: AppRoutes.settings,
            builder: (_, s) => const SettingsScreen(),
          ),
        ],
      ),
      // ── 독립 라우트 (탭 밖) ────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.memory,
        builder: (_, s) => MemoryScreen(
          nodeId: s.pathParameters['nodeId']!,
          nodeName: (s.extra as String?) ?? '',
        ),
      ),
      GoRoute(
        path: AppRoutes.search,
        builder: (_, s) => const SearchScreen(),
      ),
      GoRoute(
        path: AppRoutes.subscription,
        builder: (_, s) => const SubscriptionScreen(),
      ),
      GoRoute(
        path: AppRoutes.backup,
        builder: (_, s) => const BackupScreen(),
      ),
      GoRoute(
        path: AppRoutes.privacyPolicy,
        builder: (_, s) => const PrivacyPolicyScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('페이지 없음: ${state.error}')),
    ),
  );
});

// ── Splash ────────────────────────────────────────────────────────────────────

class _SplashScreen extends StatefulWidget {
  const _SplashScreen();

  @override
  State<_SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<_SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
    // GoRouter redirect가 자동 처리
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.go(AppRoutes.splash);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Re-Link',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF6C63FF),
                  letterSpacing: -1,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '가족의 기억을 잇다',
                style: TextStyle(fontSize: 16, color: Colors.white54),
              ),
              SizedBox(height: 48),
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF6C63FF),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Main Shell (5탭 하단 네비게이션) ───────────────────────────────────────────

class _MainShell extends ConsumerWidget {
  const _MainShell({required this.child});
  final Widget child;

  static const _tabs = [
    AppRoutes.canvas,
    AppRoutes.story,
    AppRoutes.archive,
    AppRoutes.settings,
  ];

  static int _indexFromLocation(String location) {
    if (location.startsWith(AppRoutes.story)) return 1;
    if (location.startsWith(AppRoutes.archive)) return 2;
    if (location.startsWith(AppRoutes.settings)) return 3;
    return 0; // canvas default
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).matchedLocation;
    final idx = _indexFromLocation(location);

    return Scaffold(
      body: child,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AdBannerWidget(),
          _CustomBottomNav(
            currentIndex: idx,
            onTabSelected: (i) {
              if (i == 4) {
                // + 버튼 — QuickAdd (캔버스 FAB와 동일 동작)
                context.go(AppRoutes.canvas);
                return;
              }
              context.go(_tabs[i]);
            },
          ),
        ],
      ),
    );
  }
}

/// 커스텀 5탭 바텀 네비게이션 (가운데 + 버튼 강조)
class _CustomBottomNav extends StatelessWidget {
  const _CustomBottomNav({
    required this.currentIndex,
    required this.onTabSelected,
  });

  final int currentIndex;
  final ValueChanged<int> onTabSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      decoration: const BoxDecoration(
        color: Color(0xFF0D0D1F),
        border: Border(top: BorderSide(color: Color(0x33FFFFFF), width: 0.5)),
      ),
      child: Row(
        children: [
          _NavItem(
            icon: Icons.account_tree_outlined,
            label: '홈',
            isSelected: currentIndex == 0,
            onTap: () => onTabSelected(0),
          ),
          _NavItem(
            icon: Icons.auto_stories_outlined,
            label: '이야기',
            isSelected: currentIndex == 1,
            onTap: () => onTabSelected(1),
          ),
          // + 버튼 (가운데)
          Expanded(
            child: GestureDetector(
              onTap: () => onTabSelected(4),
              child: Center(
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFF6C63FF), Color(0xFF9C94FF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x4D6C63FF),
                        blurRadius: 16,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 26),
                ),
              ),
            ),
          ),
          _NavItem(
            icon: Icons.photo_library_outlined,
            label: '보관함',
            isSelected: currentIndex == 2,
            onTap: () => onTabSelected(2),
          ),
          _NavItem(
            icon: Icons.settings_outlined,
            label: '설정',
            isSelected: currentIndex == 3,
            onTap: () => onTabSelected(3),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? const Color(0xFF6C63FF) : const Color(0x80FFFFFF);
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: color,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
