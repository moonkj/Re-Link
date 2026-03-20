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

  /// 두 노드 사이의 기존 엣지 조회 (방향 무관)
  Future<NodeEdge?> findEdge({
    required String fromNodeId,
    required String toNodeId,
  }) async {
    try {
      return await _repo.findEdge(
        fromNodeId: fromNodeId,
        toNodeId: toNodeId,
      );
    } catch (_) {
      return null;
    }
  }

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
    } catch (e) {
      // 엣지 추가 실패 시 AsyncError로 전환하지 않음 (UI 깨짐 방지)
      // 호출자가 null 반환으로 에러를 감지하도록 함
      return null;
    }
  }

  /// 기존 엣지의 관계 타입을 변경합니다.
  Future<void> updateEdgeRelation(
      String edgeId, RelationType newRelation) async {
    try {
      await _repo.updateEdgeRelation(edgeId, newRelation);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> deleteEdge(String id) async {
    try {
      await _repo.deleteEdge(id);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  // ── Ghost Node 자동 생성 ─────────────────────────────────────────────────

  /// 새 노드를 생성하고 [anchorId] 노드와 [relation]으로 연결합니다.
  /// child / parent 관계인 경우, anchor 노드에 배우자가 없으면
  /// Ghost 배우자 노드를 자동으로 생성합니다.
  Future<NodeModel?> createNodeWithAutoGhost({
    required String name,
    required String anchorId,
    required RelationType relation,
    String? nickname,
    bool isGhost = false,
    double positionX = 0.0,
    double positionY = 0.0,
  }) async {
    state = const AsyncLoading();
    try {
      await _checkNodeLimit();

      // 1. 새 노드 생성
      final node = await _repo.create(
        name: name,
        nickname: nickname,
        isGhost: isGhost,
        positionX: positionX,
        positionY: positionY,
      );

      // 2. anchor ↔ new 노드 관계 연결
      await _repo.addEdge(
        fromNodeId: anchorId,
        toNodeId: node.id,
        relation: relation,
      );

      // 3. child/parent 관계 시 배우자 Ghost 자동 생성
      if (relation == RelationType.child || relation == RelationType.parent) {
        final parentId =
            relation == RelationType.child ? anchorId : node.id;
        final parentNode = await _repo.getById(parentId);
        if (parentNode != null) {
          final hasSpouse = await _repo.hasSpouse(parentId);
          if (!hasSpouse) {
            final plan = await _settings.getUserPlan();
            final count = await _repo.count();
            if (count < plan.maxNodes) {
              final ghostSpouse = await _repo.create(
                name: '미확인 배우자',
                isGhost: true,
                positionX: parentNode.positionX + 160,
                positionY: parentNode.positionY,
              );
              await _repo.addEdge(
                fromNodeId: parentId,
                toNodeId: ghostSpouse.id,
                relation: RelationType.spouse,
              );
            }
          }
        }
      }

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

  /// 새 노드의 Ghost 부모(아버지/어머니)를 자동으로 생성합니다.
  /// 플랜 한도 내에서 최대 2개의 Ghost 노드를 생성합니다.
  Future<void> createGhostParentsFor(NodeModel child) async {
    try {
      final plan = await _settings.getUserPlan();
      int count = await _repo.count();

      if (count < plan.maxNodes) {
        final ghostFather = await _repo.create(
          name: '미확인 아버지',
          isGhost: true,
          positionX: child.positionX - 80,
          positionY: child.positionY - 200,
        );
        await _repo.addEdge(
          fromNodeId: ghostFather.id,
          toNodeId: child.id,
          relation: RelationType.child,
        );
        count++;

        if (count < plan.maxNodes) {
          final ghostMother = await _repo.create(
            name: '미확인 어머니',
            isGhost: true,
            positionX: child.positionX + 80,
            positionY: child.positionY - 200,
          );
          await _repo.addEdge(
            fromNodeId: ghostMother.id,
            toNodeId: child.id,
            relation: RelationType.child,
          );
          await _repo.addEdge(
            fromNodeId: ghostFather.id,
            toNodeId: ghostMother.id,
            relation: RelationType.spouse,
          );
        }
      }
    } catch (_) {}
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
