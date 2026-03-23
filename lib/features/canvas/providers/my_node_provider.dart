import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/database/tables/settings_table.dart';
import '../../../shared/repositories/settings_repository.dart';

part 'my_node_provider.g.dart';

/// 내 노드 ID 상태 관리
@riverpod
class MyNodeNotifier extends _$MyNodeNotifier {
  @override
  Future<String?> build() async {
    final repo = ref.watch(settingsRepositoryProvider);
    return repo.getMyNodeId();
  }

  /// 나로 설정
  Future<void> setMyNode(String nodeId) async {
    final repo = ref.read(settingsRepositoryProvider);
    await repo.setMyNodeId(nodeId);
    state = AsyncData(nodeId);
  }

  /// 나 설정 해제
  Future<void> clearMyNode() async {
    final repo = ref.read(settingsRepositoryProvider);
    await repo.set(SettingsKey.myNodeId, '');
    state = const AsyncData(null);
  }

  // ── PIN 관련 ────────────────────────────────────────────────────────────

  /// 저장된 PIN 가져오기 (null이면 미등록)
  Future<String?> getPin() async {
    final repo = ref.read(settingsRepositoryProvider);
    return repo.getMyNodePin();
  }

  /// PIN 저장
  Future<void> setPin(String pin) async {
    final repo = ref.read(settingsRepositoryProvider);
    await repo.setMyNodePin(pin);
  }

  /// PIN 검증
  Future<bool> verifyPin(String pin) async {
    final savedPin = await getPin();
    return savedPin == pin;
  }

  /// PIN 삭제 (초기화)
  Future<void> clearPin() async {
    final repo = ref.read(settingsRepositoryProvider);
    await repo.clearMyNodePin();
  }
}
