import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/utils/haptic_service.dart';
import 'design/tokens/app_colors.dart';
import 'design/tokens/app_theme.dart';
import 'features/changelog/presentation/changelog_modal.dart';
import 'features/auth/providers/auth_notifier.dart';
import 'features/changelog/providers/changelog_notifier.dart';
import 'features/backup/providers/backup_notifier.dart';
import 'features/family_sync/providers/family_sync_notifier.dart';
import 'features/memorial/providers/memorial_notifier.dart';
import 'features/settings/providers/elderly_mode_notifier.dart';
import 'features/settings/providers/haptic_notifier.dart';
import 'features/settings/providers/theme_mode_notifier.dart';

/// Re-Link 앱 루트
class ReLink extends ConsumerWidget {
  const ReLink({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);

    // 어르신 모드: 1.3× textScaler를 앱 전역에 주입
    final isElderly =
        ref.watch(elderlyModeNotifierProvider).maybeWhen(
          data: (v) => v,
          orElse: () => false,
        );

    // 테마 모드: system / light / dark
    final themeMode =
        ref.watch(themeModeNotifierProvider).maybeWhen(
          data: (v) => v,
          orElse: () => ThemeMode.system,
        );

    // 햅틱 글로벌 On/Off 동기화
    final hapticEnabled =
        ref.watch(hapticNotifierProvider).maybeWhen(
          data: (v) => v,
          orElse: () => true,
        );
    HapticService.enabled = hapticEnabled;

    // 밝기 동기화 — AppColors getter가 올바른 Day/Night 값 반환하도록
    final platformBrightness = MediaQuery.platformBrightnessOf(context);
    final resolvedBrightness = themeMode == ThemeMode.system
        ? platformBrightness
        : (themeMode == ThemeMode.dark ? Brightness.dark : Brightness.light);
    AppColors.updateBrightness(resolvedBrightness);

    // 테마 변경 시 AppColors static getter를 사용하는 모든 위젯이
    // 즉시 리빌드되도록 brightness 기반 Key로 트리 강제 갱신
    return MaterialApp.router(
      key: ValueKey(resolvedBrightness),
      title: 'Re-Link',
      debugShowCheckedModeBanner: false,
      locale: const Locale('ko', 'KR'),
      supportedLocales: const [Locale('ko', 'KR')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
      builder: (context, child) {
        Widget result = child ?? const SizedBox.shrink();

        // 어르신 모드: 1.3× textScaler
        if (isElderly) {
          result = MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: const TextScaler.linear(1.3),
            ),
            child: result,
          );
        }

        // 변경 로그 체크 오버레이
        return _ChangelogChecker(child: result);
      },
    );
  }
}

/// 앱 첫 프레임 후 변경 로그 표시 여부를 확인하는 위젯
class _ChangelogChecker extends ConsumerStatefulWidget {
  const _ChangelogChecker({required this.child});
  final Widget child;

  @override
  ConsumerState<_ChangelogChecker> createState() => _ChangelogCheckerState();
}

class _ChangelogCheckerState extends ConsumerState<_ChangelogChecker>
    with WidgetsBindingObserver {
  /// static으로 앱 라이프사이클 동안 1회만 실행 보장
  /// (MaterialApp key 변경 시 위젯 재생성 방어)
  static bool _checked = false;

  StreamSubscription<Uri>? _linkSub;
  DateTime? _lastSyncTrigger;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _checkChangelog();
    });
    _initDeepLinks();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _linkSub?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _triggerSyncIfNeeded();
      // 포그라운드 복귀 시 자동 백업 체크 (24시간 경과 시 실행)
      ref.read(backupNotifierProvider.notifier).checkAutoBackup();
    }
  }

  /// 포그라운드 복귀 시 5분 이상 경과했고 패밀리 플랜이면 자동 동기화
  void _triggerSyncIfNeeded() {
    final user = ref.read(authNotifierProvider).valueOrNull;
    if (user == null || !user.hasFamilyPlan) return;

    final now = DateTime.now();
    if (_lastSyncTrigger != null &&
        now.difference(_lastSyncTrigger!) < const Duration(minutes: 5)) {
      return;
    }
    _lastSyncTrigger = now;
    ref.read(familySyncNotifierProvider.notifier).sync();
  }

  void _initDeepLinks() {
    final appLinks = AppLinks();
    // 앱 실행 중 수신된 링크
    _linkSub = appLinks.uriLinkStream.listen((uri) {
      _handleDeepLink(uri);
    }, onError: (_) {});
    // 앱이 종료된 상태에서 링크로 실행된 경우
    appLinks.getInitialLink().then((uri) {
      if (uri != null) _handleDeepLink(uri);
    }).catchError((_) {});
  }

  void _handleDeepLink(Uri uri) {
    if (!mounted) return;
    final router = ref.read(goRouterProvider);
    // 초대 링크: relink://invite/accept?token=xxx
    if (uri.pathSegments.length >= 2 &&
        uri.pathSegments[0] == 'invite' &&
        uri.pathSegments[1] == 'accept') {
      final token = uri.queryParameters['token'] ?? '';
      if (token.isNotEmpty) {
        router.go('${AppRoutes.acceptInvite}?token=${Uri.encodeComponent(token)}');
      }
    }
  }

  Future<void> _checkChangelog() async {
    if (_checked) return;
    _checked = true;

    try {
      // 변경 로그 데이터 로드 대기
      final notifier = ref.read(changelogNotifierProvider.notifier);

      // AsyncNotifier가 build() 완료될 때까지 대기
      await ref.read(changelogNotifierProvider.future);

      // 기일 알림 스케줄 (앱 시작 시 1회)
      ref.read(memorialAnniversarySchedulerProvider);

      final shouldShow = await notifier.shouldShowChangelog();
      if (!shouldShow) return;

      final entry = notifier.latestEntry;
      if (entry == null) return;

      if (!mounted) return;
      await ChangelogModal.show(context, entry);
    } catch (_) {
      // 변경 로그 로드 실패 시 무시 — 핵심 기능 아님
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
