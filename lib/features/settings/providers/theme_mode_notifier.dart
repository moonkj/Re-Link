import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../shared/repositories/settings_repository.dart';

part 'theme_mode_notifier.g.dart';

/// 테마 모드 상태 — system / light / dark
@riverpod
class ThemeModeNotifier extends _$ThemeModeNotifier {
  @override
  Future<ThemeMode> build() async {
    final mode = await ref.read(settingsRepositoryProvider).getThemeMode();
    return _parse(mode);
  }

  Future<void> setMode(ThemeMode mode) async {
    await ref.read(settingsRepositoryProvider).setThemeMode(_serialize(mode));
    state = AsyncData(mode);
  }

  static ThemeMode _parse(String v) => switch (v) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };

  static String _serialize(ThemeMode m) => switch (m) {
        ThemeMode.light => 'light',
        ThemeMode.dark => 'dark',
        _ => 'system',
      };
}
