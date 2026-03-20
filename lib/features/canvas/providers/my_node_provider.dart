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
}
