import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/profile_setup/presentation/profile_setup_screen.dart';
import '../../features/canvas/presentation/canvas_screen.dart';
import '../../features/backup/presentation/backup_screen.dart';
import '../../shared/repositories/settings_repository.dart';

/// 라우트 경로 상수
abstract final class AppRoutes {
  static const String splash = '/';
  static const String profileSetup = '/profile-setup';
  static const String canvas = '/canvas';
  static const String nodeDetail = '/node/:id';
  static const String nodeCreate = '/node/create';
  static const String backup = '/backup';
  static const String settings = '/settings';
  static const String subscription = '/subscription';
}

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    redirect: (context, state) async {
      // 온보딩 완료 여부 확인
      final settings = ref.read(settingsRepositoryProvider);
      final done = await settings.isOnboardingDone();
      if (!done && state.matchedLocation == AppRoutes.splash) {
        return AppRoutes.profileSetup;
      }
      if (done && state.matchedLocation == AppRoutes.splash) {
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
        path: AppRoutes.profileSetup,
        builder: (_, s) => const ProfileSetupScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => _MainShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.canvas,
            builder: (_, s) => const CanvasScreen(),
          ),
          GoRoute(
            path: AppRoutes.backup,
            builder: (_, s) => const BackupScreen(),
          ),
          GoRoute(
            path: AppRoutes.settings,
            builder: (_, s) => const _PlaceholderScreen(title: '설정'),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.subscription,
        builder: (_, s) => const _PlaceholderScreen(title: '요금제'),
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

class _SplashScreenState extends State<_SplashScreen> {
  @override
  void initState() {
    super.initState();
    // GoRouter redirect가 자동 처리 — 짧은 딜레이만
    Future<void>.delayed(const Duration(milliseconds: 800), () {
      if (mounted) context.go(AppRoutes.splash);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0A0A1A),
      body: Center(
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
          ],
        ),
      ),
    );
  }
}

// ── Main Shell (하단 네비게이션) ───────────────────────────────────────────────

class _MainShell extends StatelessWidget {
  const _MainShell({required this.child});
  final Widget child;

  static int _indexFromLocation(String location) {
    if (location.startsWith(AppRoutes.canvas)) return 0;
    if (location.startsWith(AppRoutes.backup)) return 1;
    if (location.startsWith(AppRoutes.settings)) return 2;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final idx = _indexFromLocation(location);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: idx,
        onDestinationSelected: (i) {
          switch (i) {
            case 0:
              context.go(AppRoutes.canvas);
            case 1:
              context.go(AppRoutes.backup);
            case 2:
              context.go(AppRoutes.settings);
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.account_tree), label: '트리'),
          NavigationDestination(icon: Icon(Icons.cloud_sync), label: '백업'),
          NavigationDestination(icon: Icon(Icons.settings), label: '설정'),
        ],
      ),
    );
  }
}

class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text('$title — 개발 예정')),
    );
  }
}
