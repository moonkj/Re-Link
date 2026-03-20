import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/utils/haptic_service.dart';
import 'design/tokens/app_colors.dart';
import 'design/tokens/app_theme.dart';
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
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
      builder: isElderly
          ? (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: const TextScaler.linear(1.3),
                ),
                child: child ?? const SizedBox.shrink(),
              )
          : null,
    );
  }
}
