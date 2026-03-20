import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../shared/repositories/settings_repository.dart';

part 'reduce_motion_notifier.g.dart';

/// 애니메이션 줄이기 상태 — 앱 전역 반응형 프로바이더
@riverpod
class ReduceMotionNotifier extends _$ReduceMotionNotifier {
  @override
  Future<bool> build() =>
      ref.read(settingsRepositoryProvider).isReduceMotion();

  Future<void> setEnabled(bool enabled) async {
    await ref.read(settingsRepositoryProvider).setReduceMotion(enabled);
    state = AsyncData(enabled);
  }
}
