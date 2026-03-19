import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../shared/repositories/settings_repository.dart';

part 'elderly_mode_notifier.g.dart';

/// 어르신 모드 상태 — 앱 전역 반응형 프로바이더
/// `app.dart`에서 watch하여 MediaQuery.textScaler를 1.3×으로 오버라이드
@riverpod
class ElderlyModeNotifier extends _$ElderlyModeNotifier {
  @override
  Future<bool> build() =>
      ref.read(settingsRepositoryProvider).isElderlyMode();

  Future<void> setEnabled(bool enabled) async {
    await ref.read(settingsRepositoryProvider).setElderlyMode(enabled);
    state = AsyncData(enabled);
  }
}
