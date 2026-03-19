import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Placeholder screens — will be replaced in Phase 1 development
import '../../features/auth/presentation/login_screen.dart';
import '../../features/canvas/presentation/canvas_screen.dart';

/// 라우트 경로 상수
abstract final class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String onboarding = '/onboarding';
  static const String canvas = '/canvas';
  static const String nodeDetail = '/node/:id';
  static const String nodeEdit = '/node/:id/edit';
  static const String nodeCreate = '/node/create';
  static const String memoryDetail = '/memory/:id';
  static const String aiChat = '/ai-chat';
  static const String family = '/family';
  static const String settings = '/settings';
  static const String subscription = '/subscription';
  static const String profile = '/profile';
}

/// GoRouter 인스턴스
final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      // TODO: Auth 상태에 따른 리다이렉트 (Phase 1)
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const _SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => _MainShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.canvas,
            builder: (context, state) => const CanvasScreen(),
          ),
          GoRoute(
            path: AppRoutes.family,
            builder: (context, state) => const _PlaceholderScreen(title: '가족 공간'),
          ),
          GoRoute(
            path: AppRoutes.aiChat,
            builder: (context, state) => const _PlaceholderScreen(title: 'AI 채팅'),
          ),
          GoRoute(
            path: AppRoutes.settings,
            builder: (context, state) => const _PlaceholderScreen(title: '설정'),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.subscription,
        builder: (context, state) =>
            const _PlaceholderScreen(title: '요금제 선택'),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('페이지를 찾을 수 없습니다: ${state.error}'),
      ),
    ),
  );
});

/// 스플래시 화면 (임시)
class _SplashScreen extends StatefulWidget {
  const _SplashScreen();

  @override
  State<_SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<_SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future<void>.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
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
              ),
            ),
            SizedBox(height: 8),
            Text(
              '가족의 기억을 잇다',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 메인 쉘 (하단 네비게이션)
class _MainShell extends StatelessWidget {
  const _MainShell({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        destinations: const [
          NavigationDestination(icon: Icon(Icons.account_tree), label: '트리'),
          NavigationDestination(icon: Icon(Icons.group), label: '가족'),
          NavigationDestination(icon: Icon(Icons.smart_toy), label: 'AI'),
          NavigationDestination(icon: Icon(Icons.settings), label: '설정'),
        ],
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              context.go(AppRoutes.canvas);
            case 1:
              context.go(AppRoutes.family);
            case 2:
              context.go(AppRoutes.aiChat);
            case 3:
              context.go(AppRoutes.settings);
          }
        },
      ),
    );
  }
}

/// 임시 플레이스홀더 화면
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
