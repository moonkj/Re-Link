import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/onboarding/presentation/first_family_screen.dart';
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
import '../../features/settings/presentation/terms_screen.dart';
import '../../features/family/presentation/merge_preview_screen.dart';
import '../../features/temperature/presentation/temperature_diary_screen.dart';
import '../../features/memorial/presentation/memorial_screen.dart';
import '../../features/capsule/presentation/capsule_list_screen.dart';
import '../../features/badges/presentation/badge_list_screen.dart';
import '../../features/hyodo/presentation/hyodo_screen.dart';
// jokbo/palgojodo 기능 삭제됨 — import 제거
import '../../features/clan/presentation/clan_explorer_screen.dart';
import '../../features/birthday/presentation/birthday_screen.dart';
import '../../features/invite/presentation/invite_screen.dart';
import '../../features/invite/presentation/join_family_screen.dart';
import '../../features/snapshot/presentation/snapshot_share_screen.dart';
import '../../features/wrapped/presentation/wrapped_screen.dart';
import '../../features/recipe/presentation/recipe_list_screen.dart';
import '../../features/family_map/presentation/family_map_screen.dart';
import '../../features/voice_legacy/presentation/voice_legacy_screen.dart';
import '../../features/settings/presentation/admin_console_screen.dart';
import '../../features/settings/presentation/feedback_screen.dart';
import '../../features/then_now/presentation/then_now_screen.dart';
import '../../features/backup/presentation/restore_detect_screen.dart';
import '../../features/bouquet/presentation/bouquet_wrapped_screen.dart';
import '../../features/holiday/presentation/ritual_guide_screen.dart';
import '../../features/family_hub/presentation/family_hub_screen.dart';
import '../../features/explore_hub/presentation/explore_hub_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/providers/auth_notifier.dart';
import '../../features/family_sync/presentation/family_members_screen.dart';
import '../../features/family_sync/presentation/accept_invite_screen.dart';
import '../../shared/repositories/settings_repository.dart';
import '../../design/tokens/screen_mood.dart';
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
  static const String terms = '/terms';
  static const String firstFamily = '/first-family';
  static const String mergePreview = '/merge-preview';
  static const String temperatureDiary = '/temperature-diary/:nodeId';
  static const String memorial = '/memorial/:nodeId';
  static const String capsules = '/capsules';
  static const String badges = '/badges';
  static const String hyodo = '/hyodo';
  // jokbo/palgojodo 라우트 삭제됨
  static const String clan = '/clan';
  static const String invite = '/invite';
  static const String snapshot = '/snapshot/:memoryId';
  static const String wrapped = '/wrapped';
  static const String birthday = '/birthday';
  static const String recipes = '/recipes';
  static const String familyMap = '/family-map';
  static const String voiceLegacy = '/voice-legacy';
  static const String feedback = '/feedback';
  static const String thenNow = '/then-now';
  static const String restoreDetect = '/restore-detect';
  static const String bouquetWrapped = '/bouquet-wrapped';
  static const String ritualGuide = '/ritual-guide';
  static const String familyHub = '/family-hub';
  static const String exploreHub = '/explore-hub';
  static const String adminConsole = '/admin-console';
  static const String login = '/login';
  static const String familyMembers = '/family-members';
  static const String acceptInvite = '/invite/accept';
  static const String joinFamily = '/join-family';

  static String memoryPath(String nodeId) => '/memory/$nodeId';
  static String temperatureDiaryPath(String nodeId) =>
      '/temperature-diary/$nodeId';
  static String memorialPath(String nodeId) => '/memorial/$nodeId';
  static String snapshotPath(String memoryId) => '/snapshot/$memoryId';
}

/// 외부 앱에서 열린 .rlink 파일 경로 (복원 대기)
String? _pendingRlinkPath;

/// 외부에서 대기 중인 .rlink 파일 경로를 가져오고 초기화
String? consumePendingRlinkPath() {
  final path = _pendingRlinkPath;
  _pendingRlinkPath = null;
  return path;
}

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    redirect: (BuildContext context, GoRouterState state) {
      final location = state.matchedLocation;
      final fullUri = state.uri.toString();

      // .rlink 파일 URI 가로채기 (카카오톡 등 외부 앱에서 열기)
      if (fullUri.contains('.rlink') || location.contains('.rlink')) {
        _pendingRlinkPath = Uri.decodeComponent(fullUri.replaceFirst('file://', ''));
        return AppRoutes.splash;
      }

      // 딥링크 초대: relink://invite/accept?code=XXX 또는 ?token=XXX
      if (fullUri.contains('invite/accept')) {
        final uri = state.uri;
        final serverToken = uri.queryParameters['token'];
        final localCode = uri.queryParameters['code'];
        // 서버 토큰 → 초대 수락 화면
        if (serverToken != null && serverToken.isNotEmpty) {
          return '${AppRoutes.acceptInvite}?token=${Uri.encodeComponent(serverToken)}';
        }
        // 로컬 코드 → 참여하기 화면 (코드 자동 입력)
        if (localCode != null && localCode.isNotEmpty) {
          return '${AppRoutes.joinFamily}?code=${Uri.encodeComponent(localCode)}';
        }
      }
      // 패밀리 전용 보호 라우트 (#18)
      const protectedRoutes = [
        AppRoutes.familyMembers,
      ];
      if (!protectedRoutes.any((r) => location.startsWith(r))) return null;

      final authState = ref.read(authNotifierProvider);
      // 로딩 중이면 통과
      if (authState.isLoading) return null;
      // 미로그인 → 로그인 화면 (redirect 쿼리파람으로 원래 경로 보존)
      if (authState.valueOrNull == null) {
        return '${AppRoutes.login}?redirect=${Uri.encodeComponent(location)}';
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
      GoRoute(
        path: AppRoutes.firstFamily,
        builder: (_, s) => const FirstFamilyScreen(),
      ),
      // ── 5탭 ShellRoute (홈/기억/가족/탐색/설정) ──────────────────────────
      ShellRoute(
        builder: (context, state, child) => _MainShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.canvas,
            builder: (_, s) => const CanvasScreen(),
          ),
          GoRoute(
            path: AppRoutes.archive,
            builder: (_, s) => const ArchiveScreen(),
          ),
          GoRoute(
            path: AppRoutes.familyHub,
            builder: (_, s) => const FamilyHubScreen(),
          ),
          GoRoute(
            path: AppRoutes.exploreHub,
            builder: (_, s) => const ExploreHubScreen(),
          ),
          GoRoute(
            path: AppRoutes.settings,
            builder: (_, s) => const SettingsScreen(),
          ),
        ],
      ),
      // ── 독립 라우트 (탭 밖) ────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.story,
        builder: (_, s) => const StoryFeedScreen(),
      ),
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
      GoRoute(
        path: AppRoutes.terms,
        builder: (_, s) => const TermsScreen(),
      ),
      GoRoute(
        path: AppRoutes.mergePreview,
        builder: (_, s) => MergePreviewScreen(
          rlinkPath: s.uri.queryParameters['path'] ?? '',
        ),
      ),
      GoRoute(
        path: AppRoutes.temperatureDiary,
        builder: (_, s) {
          final nodeId = s.pathParameters['nodeId']!;
          final nodeName = (s.extra as String?) ?? '';
          return TemperatureDiaryScreen(
            nodeId: nodeId,
            nodeName: nodeName,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.memorial,
        builder: (_, s) {
          final nodeId = s.pathParameters['nodeId']!;
          final extra = s.extra as Map<String, dynamic>? ?? {};
          return MemorialScreen(
            nodeId: nodeId,
            nodeName: (extra['nodeName'] as String?) ?? '',
            photoPath: extra['photoPath'] as String?,
            birthDate: extra['birthDate'] as DateTime?,
            deathDate: extra['deathDate'] as DateTime?,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.capsules,
        builder: (_, s) => const CapsuleListScreen(),
      ),
      GoRoute(
        path: AppRoutes.badges,
        builder: (_, s) => const BadgeListScreen(),
      ),
      GoRoute(
        path: AppRoutes.hyodo,
        builder: (_, s) => const HyodoScreen(),
      ),
      // jokbo/palgojodo GoRoute 삭제됨
      GoRoute(
        path: AppRoutes.clan,
        builder: (_, s) => const ClanExplorerScreen(),
      ),
      GoRoute(
        path: AppRoutes.invite,
        builder: (_, s) => const InviteScreen(),
      ),
      GoRoute(
        path: AppRoutes.joinFamily,
        builder: (_, s) => JoinFamilyScreen(
          initialCode: s.uri.queryParameters['code'],
        ),
      ),
      GoRoute(
        path: AppRoutes.snapshot,
        builder: (_, s) => SnapshotShareScreen(
          memoryId: s.pathParameters['memoryId']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.wrapped,
        builder: (_, s) => const WrappedScreen(),
      ),
      GoRoute(
        path: AppRoutes.birthday,
        builder: (_, s) => const BirthdayScreen(),
      ),
      GoRoute(
        path: AppRoutes.recipes,
        builder: (_, s) => const RecipeListScreen(),
      ),
      GoRoute(
        path: AppRoutes.familyMap,
        builder: (_, s) => const FamilyMapScreen(),
      ),
      GoRoute(
        path: AppRoutes.voiceLegacy,
        builder: (_, s) => const VoiceLegacyScreen(),
      ),
      GoRoute(
        path: AppRoutes.feedback,
        builder: (_, s) => const FeedbackScreen(),
      ),
      GoRoute(
        path: AppRoutes.thenNow,
        builder: (_, s) {
          final extra = s.extra as Map<String, dynamic>? ?? {};
          return ThenNowScreen(
            memoryId1: extra['memoryId1'] as String? ?? '',
            memoryId2: extra['memoryId2'] as String? ?? '',
            label: extra['label'] as String?,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.restoreDetect,
        builder: (_, s) => const RestoreDetectScreen(),
      ),
      GoRoute(
        path: AppRoutes.bouquetWrapped,
        builder: (_, s) => const BouquetWrappedScreen(),
      ),
      GoRoute(
        path: AppRoutes.ritualGuide,
        builder: (_, s) => const RitualGuideScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminConsole,
        builder: (_, s) => const AdminConsoleScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.familyMembers,
        builder: (context, state) => const FamilyMembersScreen(),
      ),
      GoRoute(
        path: AppRoutes.acceptInvite,
        builder: (context, state) {
          final token = state.uri.queryParameters['token'] ?? '';
          return AcceptInviteScreen(token: token);
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('페이지 없음: ${state.error}')),
    ),
  );
});

// ── Splash ────────────────────────────────────────────────────────────────────

class _SplashScreen extends ConsumerStatefulWidget {
  const _SplashScreen();

  @override
  ConsumerState<_SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<_SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoCtrl;
  late Animation<double> _logoScale;
  late AnimationController _taglineCtrl;
  Timer? _navTimer;

  // 태그라인 단어 목록
  static const _taglineWords = ['단절된', '선을', '잇고,', '잊혀진', '온기를', '기록하다.'];

  @override
  void initState() {
    super.initState();

    // 로고 scale 0.8→1.0 (springSnappy 400ms)
    _logoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _logoScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut),
    );

    // 태그라인 stagger (총 6단어 × 80ms = 480ms + 200ms 초기 딜레이)
    _taglineCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 680),
    );

    // 시퀀스: 로고 → 200ms 대기 → 태그라인
    _logoCtrl.forward();
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _taglineCtrl.forward();
    });

    _navTimer = Timer(const Duration(milliseconds: 1800), _doNavigate);
  }

  void _doNavigate() {
    if (!mounted) return;
    final settingsRepo = ref.read(settingsRepositoryProvider);
    settingsRepo
        .isOnboardingDone()
        .timeout(const Duration(seconds: 3))
        .then((done) async {
          if (!mounted) return;
          if (!done) {
            context.go(AppRoutes.restoreDetect);
            return;
          }
          // 온보딩 완료 → 로그인 상태 확인 (로딩 완료까지 대기)
          try {
            final authUser = await ref
                .read(authNotifierProvider.future)
                .timeout(const Duration(seconds: 5));
            if (!mounted) return;
            context.go(authUser != null ? AppRoutes.canvas : AppRoutes.login);
          } catch (_) {
            // 타임아웃 또는 에러 → 로그인 화면
            if (mounted) context.go(AppRoutes.login);
          }
        })
        .catchError((_) {
          if (mounted) context.go(AppRoutes.restoreDetect);
        });
  }

  @override
  void dispose() {
    _navTimer?.cancel();
    _logoCtrl.dispose();
    _taglineCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.platformBrightnessOf(context);
    final isLight = brightness == Brightness.light;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isLight
                ? const [Color(0xFF6EC6CA), Color(0xFF4A9EBF)]
                : const [Color(0xFF0D1117), Color(0xFF1E2840)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 로고 scale 애니메이션
              ScaleTransition(
                scale: _logoScale,
                child: Column(
                  children: [
                    // Bezier 곡선 마크
                    CustomPaint(
                      size: const Size(60, 30),
                      painter: _BezierMarkPainter(
                        color: isLight ? Colors.white : const Color(0xFF6EC6CA),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Re-Link',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w700,
                        color: isLight ? Colors.white : const Color(0xFF6EC6CA),
                        letterSpacing: -1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 태그라인 단어별 stagger fade-in
              AnimatedBuilder(
                animation: _taglineCtrl,
                builder: (context, _) {
                  return Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 4,
                    children: List.generate(_taglineWords.length, (i) {
                      // 각 단어의 진입 시점: i * 80ms / 680ms
                      final start = (i * 80) / 680;
                      final end = ((i * 80) + 200) / 680;
                      final opacity = Interval(
                        start.clamp(0.0, 1.0),
                        end.clamp(0.0, 1.0),
                        curve: Curves.easeOut,
                      ).transform(_taglineCtrl.value);
                      return Opacity(
                        opacity: opacity,
                        child: Text(
                          _taglineWords[i],
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: isLight
                                ? Colors.white.withAlpha((opacity * 200).toInt())
                                : Colors.white.withAlpha((opacity * 140).toInt()),
                          ),
                        ),
                      );
                    }),
                  );
                },
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: isLight ? Colors.white70 : const Color(0xFF6EC6CA),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bezier 곡선 마크 (두 점을 잇는 곡선 — Re-Link 브랜드)
class _BezierMarkPainter extends CustomPainter {
  const _BezierMarkPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // 끊어진 선 두 개 + 중앙 연결 곡선
    final path = Path()
      ..moveTo(0, size.height * 0.7)
      ..lineTo(size.width * 0.2, size.height * 0.7)
      ..moveTo(size.width * 0.2, size.height * 0.7)
      ..cubicTo(
        size.width * 0.4, size.height * 0.7,
        size.width * 0.45, size.height * 0.1,
        size.width * 0.55, size.height * 0.3,
      )
      ..cubicTo(
        size.width * 0.65, size.height * 0.5,
        size.width * 0.6, size.height * 0.7,
        size.width * 0.8, size.height * 0.7,
      )
      ..moveTo(size.width * 0.8, size.height * 0.7)
      ..lineTo(size.width, size.height * 0.7);

    canvas.drawPath(path, paint);

    // 양쪽 끝 점 (노드 표현)
    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(0, size.height * 0.7), 4, dotPaint);
    canvas.drawCircle(Offset(size.width, size.height * 0.7), 4, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _BezierMarkPainter old) => old.color != color;
}

// ── Main Shell (5탭 하단 네비게이션: 홈/기억/가족/탐색/설정) ─────────────────────

class _MainShell extends ConsumerWidget {
  const _MainShell({required this.child});
  final Widget child;

  static const _tabs = [
    AppRoutes.canvas,     // 0: 홈
    AppRoutes.archive,    // 1: 기억
    AppRoutes.familyHub,  // 2: 가족
    AppRoutes.exploreHub, // 3: 탐색
    AppRoutes.settings,   // 4: 설정
  ];

  static int _indexFromLocation(String location) {
    if (location.startsWith(AppRoutes.archive)) return 1;
    if (location.startsWith(AppRoutes.familyHub)) return 2;
    if (location.startsWith(AppRoutes.exploreHub)) return 3;
    if (location.startsWith(AppRoutes.settings)) return 4;
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
              context.go(_tabs[i]);
            },
          ),
        ],
      ),
    );
  }
}

/// 커스텀 5탭 바텀 네비게이션 (홈/기억/가족/탐색/설정)
class _CustomBottomNav extends StatelessWidget {
  const _CustomBottomNav({
    required this.currentIndex,
    required this.onTabSelected,
  });

  final int currentIndex;
  final ValueChanged<int> onTabSelected;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mood = MoodColors.fromTabIndex(currentIndex);

    return Container(
          height: 85,
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xCC0D0D1F)
                : const Color(0xE6F5F7FA),
            border: Border(
              top: BorderSide(
                color: isDark
                    ? const Color(0x33FFFFFF)
                    : const Color(0x20000000),
                width: 0.5,
              ),
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final tabWidth = constraints.maxWidth / 5;
              return Stack(
                children: [
                  // 슬라이딩 그라디언트 인디케이터 필
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeOutCubic,
                    left: tabWidth * currentIndex + (tabWidth - 48) / 2,
                    top: 18,
                    child: Container(
                      width: 48,
                      height: 32,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          colors: MoodColors.indicatorGradient(mood),
                        ),
                        border: Border.all(
                          color: MoodColors.indicatorBorder(mood),
                          width: 1,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x20000000),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // 탭 아이템들
                  Row(
                    children: [
                      _NavItem(
                        icon: Icons.account_tree_outlined,
                        label: '홈',
                        isSelected: currentIndex == 0,
                        mood: MoodColors.fromTabIndex(0),
                        currentMood: mood,
                        onTap: () => onTabSelected(0),
                      ),
                      _NavItem(
                        icon: Icons.photo_library_outlined,
                        label: '기억',
                        isSelected: currentIndex == 1,
                        mood: MoodColors.fromTabIndex(1),
                        currentMood: mood,
                        onTap: () => onTabSelected(1),
                      ),
                      _NavItem(
                        icon: Icons.favorite_outline,
                        label: '가족',
                        isSelected: currentIndex == 2,
                        mood: MoodColors.fromTabIndex(2),
                        currentMood: mood,
                        onTap: () => onTabSelected(2),
                      ),
                      _NavItem(
                        icon: Icons.explore_outlined,
                        label: '탐색',
                        isSelected: currentIndex == 3,
                        mood: MoodColors.fromTabIndex(3),
                        currentMood: mood,
                        onTap: () => onTabSelected(3),
                      ),
                      _NavItem(
                        icon: Icons.settings_outlined,
                        label: '설정',
                        isSelected: currentIndex == 4,
                        mood: MoodColors.fromTabIndex(4),
                        currentMood: mood,
                        onTap: () => onTabSelected(4),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.mood,
    required this.currentMood,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final ScreenMood mood;
  final ScreenMood currentMood;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // 선택된 탭: 해당 무드의 액센트 컬러
    final color = isSelected
        ? MoodColors.accent(currentMood)
        : isDark
            ? const Color(0x80FFFFFF)
            : const Color(0x99000000);
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
