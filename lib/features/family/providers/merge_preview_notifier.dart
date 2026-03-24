import 'dart:convert';
import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path_lib;
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/services/media/media_service.dart';
import '../../../core/services/sync/media_upload_queue_service.dart';
import '../../../shared/models/node_model.dart';
import '../../../shared/repositories/node_repository.dart';
import '../../../shared/repositories/settings_repository.dart';
import '../../../shared/repositories/db_provider.dart';
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
    this.theirEdgeCount = 0,
    this.theirMemoryCount = 0,
    this.isLoading = false,
    this.error,
  });

  final String? rlinkPath;
  final List<NodeModel> newNodes;
  final List<MergeConflict> conflicts;
  final Map<String, ConflictResolution> resolutions;
  final int theirEdgeCount;
  final int theirMemoryCount;
  final bool isLoading;
  final String? error;

  int get totalIncoming => newNodes.length + conflicts.length;

  MergePreviewState copyWith({
    String? rlinkPath,
    List<NodeModel>? newNodes,
    List<MergeConflict>? conflicts,
    Map<String, ConflictResolution>? resolutions,
    int? theirEdgeCount,
    int? theirMemoryCount,
    bool? isLoading,
    String? error,
  }) =>
      MergePreviewState(
        rlinkPath: rlinkPath ?? this.rlinkPath,
        newNodes: newNodes ?? this.newNodes,
        conflicts: conflicts ?? this.conflicts,
        resolutions: resolutions ?? this.resolutions,
        theirEdgeCount: theirEdgeCount ?? this.theirEdgeCount,
        theirMemoryCount: theirMemoryCount ?? this.theirMemoryCount,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

/// .rlink에서 파싱된 데이터 (노드 + 관계선 + 기억)
class _ParsedRlinkData {
  final List<NodeModel> nodes;
  final List<NodeEdgesTableData> edges;
  final List<MemoriesTableData> memories;
  const _ParsedRlinkData({
    required this.nodes,
    required this.edges,
    required this.memories,
  });
}

@riverpod
class MergePreviewNotifier extends _$MergePreviewNotifier {
  @override
  MergePreviewState build() => const MergePreviewState();

  NodeRepository get _nodeRepo => ref.read(nodeRepositoryProvider);
  AppDatabase get _db => ref.read(appDatabaseProvider);

  /// 임시 추출 디렉토리 (병합 시 미디어 복사에 사용)
  Directory? _extractDir;

  /// .rlink 파일을 파싱해 충돌 감지
  Future<void> loadRlink(String rlinkPath) async {
    state = state.copyWith(isLoading: true, rlinkPath: rlinkPath, error: null);
    try {
      final bytes = await File(rlinkPath).readAsBytes();
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

      // ZIP을 임시 디렉토리에 추출 (미디어 파일 복사용)
      final tmpDir = await getTemporaryDirectory();
      _extractDir = Directory(path_lib.join(
        tmpDir.path,
        'merge_${DateTime.now().millisecondsSinceEpoch}',
      ));
      await _extractDir!.create(recursive: true);
      await extractArchiveToDisk(archive, _extractDir!.path);

      // 내 DB 노드 목록
      final myNodes = await _nodeRepo.getAll();
      final myNodeMap = {for (final n in myNodes) n.id: n};

      // 상대방 DB에서 노드 + 관계선 + 기억 읽기
      final parsed = await _parseTheirData(archive);

      final newNodes = <NodeModel>[];
      final conflicts = <MergeConflict>[];

      for (final theirNode in parsed.nodes) {
        final myNode = myNodeMap[theirNode.id];
        if (myNode == null) {
          newNodes.add(theirNode);
        } else if (myNode.name != theirNode.name) {
          // 이름이 다른 경우에만 충돌 (updatedAt 차이는 무시)
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
        theirEdgeCount: parsed.edges.length,
        theirMemoryCount: parsed.memories.length,
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

  /// 병합 실행 — 선택된 해결책으로 DB 반영 (트랜잭션)
  Future<bool> applyMerge() async {
    state = state.copyWith(isLoading: true);
    try {
      // 상대방 데이터 다시 파싱
      if (state.rlinkPath == null) return false;
      final bytes = await File(state.rlinkPath!).readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);
      final parsed = await _parseTheirData(archive);

      // 병합할 노드 ID 집합 (새 노드 + theirs/both 충돌 해결)
      final mergedNodeIds = <String>{};
      for (final node in state.newNodes) {
        mergedNodeIds.add(node.id);
      }
      for (final conflict in state.conflicts) {
        final resolution = state.resolutions[conflict.nodeId] ??
            ConflictResolution.mine;
        if (resolution != ConflictResolution.mine) {
          mergedNodeIds.add(conflict.nodeId);
        }
      }

      // 트랜잭션으로 원자적 실행
      await _db.transaction(() async {
        // 1. 새 노드 삽입
        for (final node in state.newNodes) {
          await _nodeRepo.createWithModel(node);
        }

        // 2. 충돌 해결
        for (final conflict in state.conflicts) {
          final resolution = state.resolutions[conflict.nodeId] ??
              ConflictResolution.mine;
          switch (resolution) {
            case ConflictResolution.theirs:
              await _nodeRepo.updateFromModel(conflict.theirNode);
            case ConflictResolution.both:
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
              break;
          }
        }

        // 3. 관계선 삽입 (양쪽 노드가 모두 존재하는 것만)
        for (final edge in parsed.edges) {
          // 양쪽 노드가 병합 대상이거나 이미 내 DB에 있는지 확인
          final fromExists = mergedNodeIds.contains(edge.fromNodeId) ||
              await _db.getNode(edge.fromNodeId) != null;
          final toExists = mergedNodeIds.contains(edge.toNodeId) ||
              await _db.getNode(edge.toNodeId) != null;
          if (fromExists && toExists) {
            // 중복 확인
            final existing = await _db.findEdgeBetween(
                edge.fromNodeId, edge.toNodeId);
            if (existing == null) {
              await _db.upsertEdge(NodeEdgesTableCompanion.insert(
                id: edge.id,
                fromNodeId: edge.fromNodeId,
                toNodeId: edge.toNodeId,
                relation: edge.relation,
                label: Value(edge.label),
              ));
            }
          }
        }

        // 4. 기억 삽입 (연결된 노드가 존재하는 것만)
        for (final memory in parsed.memories) {
          final nodeExists = mergedNodeIds.contains(memory.nodeId) ||
              await _db.getNode(memory.nodeId) != null;
          if (nodeExists) {
            // 중복 확인 (같은 ID)
            final existing = await _db.getMemory(memory.id);
            if (existing == null) {
              await _db.upsertMemory(MemoriesTableCompanion.insert(
                id: memory.id,
                nodeId: memory.nodeId,
                type: memory.type,
                title: Value(memory.title),
                description: Value(memory.description),
                filePath: Value(memory.filePath),
                thumbnailPath: Value(memory.thumbnailPath),
                durationSeconds: Value(memory.durationSeconds),
                dateTaken: Value(memory.dateTaken),
                tagsJson: Value(memory.tagsJson),
                isPrivate: Value(memory.isPrivate),
              ));
            }
          }
        }
      });

      // 5. 미디어 파일 복사 (트랜잭션 외부 — 파일 I/O)
      if (_extractDir != null) {
        await _copyMergeMedia(_extractDir!);
      }

      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      debugPrint('[MergePreview] 병합 실패: $e');
      state = state.copyWith(isLoading: false, error: '병합 실패: $e');
      return false;
    } finally {
      // 임시 디렉토리 정리
      _cleanupExtractDir();
    }
  }

  /// 추출된 .rlink의 media 디렉토리를 앱 미디어 디렉토리로 복사
  Future<void> _copyMergeMedia(Directory extractDir) async {
    final mediaService = ref.read(mediaServiceProvider);
    final appMediaDir = await mediaService.mediaRootDir;

    // 추출된 media 디렉토리 찾기
    final backupMedia = Directory(path_lib.join(extractDir.path, 'media'));
    if (!await backupMedia.exists()) return;

    if (!await appMediaDir.exists()) {
      await appMediaDir.create(recursive: true);
    }

    // 백업 미디어의 파일을 앱 미디어로 복사 (기존 파일은 덮어쓰지 않음)
    await for (final entity in backupMedia.list(recursive: true)) {
      if (entity is File) {
        final relativePath = path_lib.relative(entity.path, from: backupMedia.path);
        final targetFile = File(path_lib.join(appMediaDir.path, relativePath));
        if (!await targetFile.exists()) {
          await targetFile.parent.create(recursive: true);
          await entity.copy(targetFile.path);
        }
      }
    }
  }

  /// 임시 추출 디렉토리 정리
  void _cleanupExtractDir() {
    try {
      _extractDir?.deleteSync(recursive: true);
    } catch (_) {}
    _extractDir = null;
  }

  /// .rlink ZIP에서 노드 + 관계선 + 기억 파싱 (임시 파일 DB)
  Future<_ParsedRlinkData> _parseTheirData(Archive archive) async {
    final dbFile = archive.findFile('relink.db');
    if (dbFile == null) {
      return const _ParsedRlinkData(nodes: [], edges: [], memories: []);
    }

    final dir = await Directory.systemTemp.createTemp('rlink_merge');
    final tmpDbPath = '${dir.path}/incoming.db';
    await File(tmpDbPath).writeAsBytes(dbFile.content as List<int>);

    try {
      final tempDb = AppDatabase.forMerge(tmpDbPath);
      final tempRepo = NodeRepository(
        tempDb,
        uploadQueue: ref.read(mediaUploadQueueServiceProvider),
        settings: SettingsRepository(tempDb),
      );

      final nodes = await tempRepo.getAll();
      final edges = await tempDb.select(tempDb.nodeEdgesTable).get();
      final memories = await tempDb.select(tempDb.memoriesTable).get();

      await tempDb.close();
      await dir.delete(recursive: true);

      return _ParsedRlinkData(
        nodes: nodes,
        edges: edges,
        memories: memories,
      );
    } catch (e) {
      debugPrint('[MergePreview] 임시 DB 파싱 실패: $e');
      try {
        await dir.delete(recursive: true);
      } catch (_) {}
      return const _ParsedRlinkData(nodes: [], edges: [], memories: []);
    }
  }
}
