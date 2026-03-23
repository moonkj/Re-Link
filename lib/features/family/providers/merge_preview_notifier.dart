import 'dart:convert';
import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/services/sync/media_upload_queue_service.dart';
import '../../../shared/models/node_model.dart';
import '../../../shared/repositories/node_repository.dart';
import '../../../shared/repositories/settings_repository.dart';
import '../../../core/database/app_database.dart';

part 'merge_preview_notifier.g.dart';

/// 충돌 노드 — 같은 ID로 내 DB와 상대방 .rlink에 모두 존재
class MergeConflict {
  const MergeConflict({
    required this.nodeId,
    required this.myNode,
    required this.theirNode,
  });
  final String nodeId;
  final NodeModel myNode;
  final NodeModel theirNode;
}

/// 병합 선택 (충돌 해결)
enum ConflictResolution { mine, theirs, both }

/// 병합 미리보기 상태
class MergePreviewState {
  const MergePreviewState({
    this.rlinkPath,
    this.newNodes = const [],
    this.conflicts = const [],
    this.resolutions = const {},
    this.isLoading = false,
    this.error,
  });

  final String? rlinkPath;
  final List<NodeModel> newNodes;       // 내 DB에 없는 새 노드
  final List<MergeConflict> conflicts;  // 같은 ID, 다른 내용
  final Map<String, ConflictResolution> resolutions;
  final bool isLoading;
  final String? error;

  int get totalIncoming => newNodes.length + conflicts.length;

  MergePreviewState copyWith({
    String? rlinkPath,
    List<NodeModel>? newNodes,
    List<MergeConflict>? conflicts,
    Map<String, ConflictResolution>? resolutions,
    bool? isLoading,
    String? error,
  }) =>
      MergePreviewState(
        rlinkPath: rlinkPath ?? this.rlinkPath,
        newNodes: newNodes ?? this.newNodes,
        conflicts: conflicts ?? this.conflicts,
        resolutions: resolutions ?? this.resolutions,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

@riverpod
class MergePreviewNotifier extends _$MergePreviewNotifier {
  @override
  MergePreviewState build() => const MergePreviewState();

  NodeRepository get _nodeRepo => ref.read(nodeRepositoryProvider);

  /// .rlink 파일을 파싱해 충돌 감지
  Future<void> loadRlink(String rlinkPath) async {
    state = state.copyWith(isLoading: true, rlinkPath: rlinkPath, error: null);
    try {
      final bytes = File(rlinkPath).readAsBytesSync();
      final archive = ZipDecoder().decodeBytes(bytes);

      // manifest.json 파싱
      final manifestFile = archive.findFile('manifest.json');
      if (manifestFile == null) {
        state = state.copyWith(isLoading: false, error: '올바른 .rlink 파일이 아닙니다');
        return;
      }
      final manifest = json.decode(utf8.decode(manifestFile.content as List<int>));
      if (manifest['version'] == null) {
        state = state.copyWith(isLoading: false, error: '지원하지 않는 백업 버전입니다');
        return;
      }

      // 내 DB 노드 목록
      final myNodes = await _nodeRepo.getAll();
      final myNodeMap = {for (final n in myNodes) n.id: n};

      // 상대방 DB에서 노드 읽기 (임시 DB)
      final theirNodes = await _parseTheirNodes(archive);

      final newNodes = <NodeModel>[];
      final conflicts = <MergeConflict>[];

      for (final theirNode in theirNodes) {
        final myNode = myNodeMap[theirNode.id];
        if (myNode == null) {
          newNodes.add(theirNode);
        } else if (myNode.name != theirNode.name ||
            myNode.updatedAt != theirNode.updatedAt) {
          conflicts.add(MergeConflict(
            nodeId: theirNode.id,
            myNode: myNode,
            theirNode: theirNode,
          ));
        }
      }

      // 기본 해결: 내 것 유지
      final defaultResolutions = <String, ConflictResolution>{
        for (final c in conflicts) c.nodeId: ConflictResolution.mine,
      };

      state = state.copyWith(
        isLoading: false,
        newNodes: newNodes,
        conflicts: conflicts,
        resolutions: defaultResolutions,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: '파일 파싱 실패: $e');
    }
  }

  /// 충돌 해결 방식 설정
  void setResolution(String nodeId, ConflictResolution resolution) {
    state = state.copyWith(
      resolutions: {...state.resolutions, nodeId: resolution},
    );
  }

  /// 병합 실행 — 선택된 해결책으로 DB 반영
  Future<bool> applyMerge() async {
    state = state.copyWith(isLoading: true);
    try {
      // 새 노드 삽입
      for (final node in state.newNodes) {
        await _nodeRepo.createWithModel(node);
      }

      // 충돌 해결
      for (final conflict in state.conflicts) {
        final resolution = state.resolutions[conflict.nodeId] ??
            ConflictResolution.mine;
        switch (resolution) {
          case ConflictResolution.theirs:
            await _nodeRepo.updateFromModel(conflict.theirNode);
          case ConflictResolution.both:
            // 상대방 노드를 새 ID로 복사
            await _nodeRepo.create(
              name: '${conflict.theirNode.name} (가져옴)',
              nickname: conflict.theirNode.nickname,
              bio: conflict.theirNode.bio,
              birthDate: conflict.theirNode.birthDate,
              isGhost: conflict.theirNode.isGhost,
              temperature: conflict.theirNode.temperature,
              positionX: conflict.theirNode.positionX + 50,
              positionY: conflict.theirNode.positionY + 50,
            );
          case ConflictResolution.mine:
            break; // 내 것 유지 — 아무것도 안 함
        }
      }

      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: '병합 실패: $e');
      return false;
    }
  }

  /// .rlink ZIP에서 노드 목록 파싱 (임시 파일 DB)
  Future<List<NodeModel>> _parseTheirNodes(Archive archive) async {
    final dbFile = archive.findFile('relink.db');
    if (dbFile == null) return [];

    // 임시 파일에 DB 쓰기
    final dir = await Directory.systemTemp.createTemp('rlink_merge');
    final tmpDbPath = '${dir.path}/incoming.db';
    File(tmpDbPath).writeAsBytesSync(dbFile.content as List<int>);

    try {
      final tempDb = AppDatabase.forMerge(tmpDbPath);
      final tempRepo = NodeRepository(
        tempDb,
        uploadQueue: ref.read(mediaUploadQueueServiceProvider),
        settings: SettingsRepository(tempDb),
      );
      final nodes = await tempRepo.getAll();
      await tempDb.close();
      dir.deleteSync(recursive: true);
      return nodes;
    } catch (_) {
      dir.deleteSync(recursive: true);
      return [];
    }
  }
}
