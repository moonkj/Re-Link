import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../shared/repositories/settings_repository.dart';

part 'spouse_snap_notifier.g.dart';

/// 부부 자석 스냅 On/Off 상태
@riverpod
class SpouseSnapNotifier extends _$SpouseSnapNotifier {
  @override
  Future<bool> build() =>
      ref.read(settingsRepositoryProvider).isSpouseSnapEnabled();

  Future<void> setEnabled(bool enabled) async {
    await ref.read(settingsRepositoryProvider).setSpouseSnap(enabled);
    state = AsyncData(enabled);
  }
}
