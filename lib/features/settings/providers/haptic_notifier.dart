import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../shared/repositories/settings_repository.dart';

part 'haptic_notifier.g.dart';

/// 햅틱 On/Off 상태 — 앱 전역 반응형 프로바이더
@riverpod
class HapticNotifier extends _$HapticNotifier {
  @override
  Future<bool> build() =>
      ref.read(settingsRepositoryProvider).isHapticEnabled();

  Future<void> setEnabled(bool enabled) async {
    await ref.read(settingsRepositoryProvider).setHapticEnabled(enabled);
    state = AsyncData(enabled);
  }
}
