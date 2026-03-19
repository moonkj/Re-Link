import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'design/tokens/app_theme.dart';
import 'features/settings/providers/elderly_mode_notifier.dart';

/// Re-Link 앱 루트
class ReLink extends ConsumerWidget {
  const ReLink({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    // 어르신 모드: 1.3× textScaler를 앱 전역에 주입
    final isElderly =
        ref.watch(elderlyModeNotifierProvider).valueOrNull ?? false;

    return MaterialApp.router(
      title: 'Re-Link',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
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
