import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../shared/models/node_model.dart';
import '../../../shared/repositories/node_repository.dart';
import '../../../shared/repositories/settings_repository.dart';
import '../../../shared/models/user_plan.dart';
import '../../../core/services/media/media_service.dart';
import '../../../core/errors/app_error.dart';

part 'node_notifier.g.dart';

@riverpod
class NodeNotifier extends _$NodeNotifier {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  NodeRepository get _repo => ref.read(nodeRepositoryProvider);
  SettingsRepository get _settings => ref.read(settingsRepositoryProvider);
  MediaService get _media => ref.read(mediaServiceProvider);

  // ── 생성 ──────────────────────────────────────────────────────────────────

  Future<NodeModel?> createNode({
    required String name,
    String? nickname,
    String? photoPath,
    String? bio,
    DateTime? birthDate,
    DateTime? deathDate,
    bool isGhost = false,
    double positionX = 0.0,
    double positionY = 0.0,
  }) async {
    state = const AsyncLoading();
    try {
      // 플랜 제한 체크
      await _checkNodeLimit();

      final node = await _repo.create(
        name: name,
        nickname: nickname,
        photoPath: photoPath,
        bio: bio,
        birthDate: birthDate,
        deathDate: deathDate,
        isGhost: isGhost,
        positionX: positionX,
        positionY: positionY,
      );
      state = const AsyncData(null);
      return node;
    } on PlanLimitError {
      state = const AsyncData(null);
      rethrow;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }

  // ── 수정 ──────────────────────────────────────────────────────────────────

  Future<void> updateNode(NodeModel node) async {
    state = const AsyncLoading();
    try {
      await _repo.update(node);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> updateTemperature(String id, int level) async {
    await _repo.updateTemperature(id, level.clamp(0, 5));
  }

  // ── 삭제 ──────────────────────────────────────────────────────────────────

  Future<void> deleteNode(String id) async {
    state = const AsyncLoading();
    try {
      final node = await _repo.getById(id);
      // 관련 미디어 파일 삭제
      if (node?.photoPath != null) {
        await _media.deleteFile(node!.photoPath);
      }
      await _repo.delete(id);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  // ── 관계 ──────────────────────────────────────────────────────────────────

  Future<NodeEdge?> addEdge({
    required String fromNodeId,
    required String toNodeId,
    required RelationType relation,
    String? label,
  }) async {
    try {
      final edge = await _repo.addEdge(
        fromNodeId: fromNodeId,
        toNodeId: toNodeId,
        relation: relation,
        label: label,
      );
      return edge;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }

  Future<void> deleteEdge(String id) async {
    try {
      await _repo.deleteEdge(id);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  // ── 플랜 제한 체크 ────────────────────────────────────────────────────────

  Future<void> _checkNodeLimit() async {
    final plan = await _settings.getUserPlan();
    final count = await _repo.count();
    if (count >= plan.maxNodes) {
      throw PlanLimitError(
        feature: '노드 추가',
        currentPlan: plan.displayName,
        requiredPlan: plan == UserPlan.free ? 'Basic' : 'Premium',
      );
    }
  }
}
