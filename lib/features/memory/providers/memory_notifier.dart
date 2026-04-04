import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/errors/app_error.dart';
import '../../../core/services/media/media_service.dart';
import '../../../core/services/sync/media_upload_queue_service.dart';
import '../../../core/utils/path_utils.dart';
import '../../../shared/models/memory_model.dart';
import '../../../shared/models/user_plan.dart';
import '../../../shared/repositories/memory_repository.dart';
import '../../../shared/repositories/settings_repository.dart';

part 'memory_notifier.g.dart';

/// 노드별 기억 스트림
@riverpod
Stream<List<MemoryModel>> memoriesForNode(Ref ref, String nodeId) =>
    ref.watch(memoryRepositoryProvider).watchForNode(nodeId);

/// 전체 음성 사용량 (분 단위)
@riverpod
Future<int> totalVoiceMinutes(Ref ref) =>
    ref.watch(memoryRepositoryProvider).totalVoiceMinutes();

/// 전체 사진 수
@riverpod
Future<int> totalPhotoCount(Ref ref) =>
    ref.watch(memoryRepositoryProvider).totalPhotoCount();

/// 기억 CRUD 오퍼레이션
@riverpod
class MemoryNotifier extends _$MemoryNotifier {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  MemoryRepository get _repo => ref.read(memoryRepositoryProvider);
  SettingsRepository get _settings => ref.read(settingsRepositoryProvider);
  MediaService get _media => ref.read(mediaServiceProvider);
  MediaUploadQueueService get _uploadQueue =>
      ref.read(mediaUploadQueueServiceProvider);

  // ── 사진 추가 ────────────────────────────────────────────────────────────

  /// 갤러리에서 사진 선택 후 저장
  Future<MemoryModel?> addPhotoFromGallery({
    required String nodeId,
    String? title,
    DateTime? dateTaken,
  }) async {
    state = const AsyncLoading();
    try {
      await _checkPhotoLimit();
      final result = await _media.pickAndSavePhoto();
      if (result == null) {
        state = const AsyncData(null);
        return null;
      }
      final memory = await _repo.create(
        nodeId: nodeId,
        type: MemoryType.photo,
        title: title,
        filePath: result.photoPath,
        thumbnailPath: result.thumbnailPath,
        dateTaken: dateTaken ?? DateTime.now(),
      );
      // 패밀리 플랜이면 R2 자동 업로드 큐에 추가
      await _enqueuePhotoUploadIfCloud(memory);
      state = const AsyncData(null);
      return memory;
    } on PlanLimitError catch (e, st) {
      // PlanLimitError를 AsyncError로 전달하여 UI에서 에러 메시지 표시 (#13)
      state = AsyncError(e, st);
      rethrow;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }

  /// 카메라로 촬영 후 저장
  Future<MemoryModel?> addPhotoFromCamera({
    required String nodeId,
    String? title,
  }) async {
    state = const AsyncLoading();
    try {
      await _checkPhotoLimit();
      final result = await _media.captureAndSavePhoto();
      if (result == null) {
        state = const AsyncData(null);
        return null;
      }
      final memory = await _repo.create(
        nodeId: nodeId,
        type: MemoryType.photo,
        title: title,
        filePath: result.photoPath,
        thumbnailPath: result.thumbnailPath,
        dateTaken: DateTime.now(),
      );
      // 패밀리 플랜이면 R2 자동 업로드 큐에 추가
      await _enqueuePhotoUploadIfCloud(memory);
      state = const AsyncData(null);
      return memory;
    } on PlanLimitError catch (e, st) {
      // PlanLimitError를 AsyncError로 전달하여 UI에서 에러 메시지 표시 (#13)
      state = AsyncError(e, st);
      rethrow;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }

  /// 이미 저장된 사진 파일로 기억 생성 (AddMemorySheet용)
  Future<MemoryModel?> addPhotoFromFile({
    required String nodeId,
    required String filePath,
    String? thumbnailPath,
    String? title,
    DateTime? dateTaken,
    bool isPrivate = false,
  }) async {
    state = const AsyncLoading();
    try {
      await _checkPhotoLimit();
      final memory = await _repo.create(
        nodeId: nodeId,
        type: MemoryType.photo,
        title: title,
        filePath: filePath,
        thumbnailPath: thumbnailPath,
        dateTaken: dateTaken ?? DateTime.now(),
        isPrivate: isPrivate,
      );
      // 패밀리 플랜이면 R2 자동 업로드 큐에 추가
      await _enqueuePhotoUploadIfCloud(memory);
      state = const AsyncData(null);
      return memory;
    } on PlanLimitError catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }

  // ── 음성 추가 ────────────────────────────────────────────────────────────

  Future<MemoryModel?> addVoice({
    required String nodeId,
    required String filePath,
    required int durationSeconds,
    String? title,
    List<String> tags = const [],
    bool isPrivate = false,
  }) async {
    state = const AsyncLoading();
    try {
      await _checkVoiceLimit(durationSeconds);
      // 절대경로 → 상대경로 변환 (복원 시 경로 호환성)
      final relPath = PathUtils.toRelative(filePath) ?? filePath;
      final memory = await _repo.create(
        nodeId: nodeId,
        type: MemoryType.voice,
        title: title,
        filePath: relPath,
        durationSeconds: durationSeconds,
        dateTaken: DateTime.now(),
        tags: tags,
        isPrivate: isPrivate,
      );
      // 패밀리 플랜이면 R2 자동 업로드 큐에 추가
      await _enqueueVoiceUploadIfCloud(memory);
      state = const AsyncData(null);
      return memory;
    } on PlanLimitError catch (e, st) {
      // PlanLimitError를 AsyncError로 전달하여 UI에서 에러 메시지 표시 (#13)
      state = AsyncError(e, st);
      rethrow;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }

  // ── 메모 추가 ────────────────────────────────────────────────────────────

  Future<MemoryModel?> addNote({
    required String nodeId,
    required String description,
    String? title,
    List<String> tags = const [],
    bool isPrivate = false,
  }) async {
    state = const AsyncLoading();
    try {
      final memory = await _repo.create(
        nodeId: nodeId,
        type: MemoryType.note,
        title: title,
        description: description,
        dateTaken: DateTime.now(),
        tags: tags,
        isPrivate: isPrivate,
      );
      state = const AsyncData(null);
      return memory;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }

  // ── 삭제 ────────────────────────────────────────────────────────────────

  Future<void> deleteMemory(MemoryModel memory) async {
    state = const AsyncLoading();
    try {
      // DB 레코드 먼저 삭제 (실패 시 파일은 남지만 데이터 무결성 유지)
      await _repo.delete(memory.id);
      // 파일 삭제 (실패해도 DB는 이미 정리됨)
      try {
        await _media.deleteFile(memory.filePath);
        await _media.deleteFile(memory.thumbnailPath);
      } catch (_) {
        // 파일 삭제 실패는 무시 (고아 파일은 백업 시 정리됨)
      }
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  // ── Privacy ──────────────────────────────────────────────────────────────

  /// 기억 공개/개인 설정 변경
  Future<void> updatePrivacy(String memoryId, {required bool isPrivate}) async {
    await _repo.setPrivate(memoryId, isPrivate: isPrivate);
  }

  // ── 플랜 제한 ────────────────────────────────────────────────────────────

  Future<void> _checkPhotoLimit() async {
    final plan = await _settings.getUserPlan();
    final count = await _repo.totalPhotoCount();
    if (count >= plan.maxPhotos) {
      throw PlanLimitError(
        feature: '사진 추가',
        currentPlan: plan.displayName,
        requiredPlan: plan == UserPlan.free ? '플러스' : '패밀리',
      );
    }
  }

  Future<void> _checkVoiceLimit(int newDurationSeconds) async {
    final plan = await _settings.getUserPlan();
    final usedMinutes = await _repo.totalVoiceMinutes();
    final addingMinutes = (newDurationSeconds / 60).ceil();
    if (usedMinutes + addingMinutes > plan.maxVoiceMinutes) {
      throw PlanLimitError(
        feature: '음성 저장',
        currentPlan: plan.displayName,
        requiredPlan: plan == UserPlan.free ? '플러스' : '패밀리',
      );
    }
  }

  // ── 영상 추가 ────────────────────────────────────────────────────────────

  /// 이미 저장된 영상 파일을 DB에 등록 + R2 업로드 큐
  Future<MemoryModel?> addVideo({
    required String nodeId,
    String? title,
    required String filePath,
    String? thumbnailPath,
    int? durationSeconds,
    bool isPrivate = false,
  }) async {
    try {
      final relPath = PathUtils.toRelative(filePath) ?? filePath;
      final relThumb = thumbnailPath != null
          ? (PathUtils.toRelative(thumbnailPath) ?? thumbnailPath)
          : null;
      final memory = await _repo.create(
        nodeId: nodeId,
        type: MemoryType.video,
        title: title,
        filePath: relPath,
        thumbnailPath: relThumb,
        durationSeconds: durationSeconds,
        dateTaken: DateTime.now(),
        isPrivate: isPrivate,
      );
      await _enqueueVideoUploadIfCloud(memory);
      return memory;
    } catch (e) {
      return null;
    }
  }

  /// 갤러리에서 영상 선택 후 저장
  Future<MemoryModel?> addVideoFromGallery({
    required String nodeId,
    String? title,
    required int durationSeconds,
    List<String> tags = const [],
    bool isPrivate = false,
  }) async {
    state = const AsyncLoading();
    try {
      final videoPath = await _media.pickAndSaveVideo();
      if (videoPath == null) {
        state = const AsyncData(null);
        return null;
      }
      final thumbnailPath = await _media.generateVideoThumbnail(videoPath);
      final memory = await _repo.create(
        nodeId: nodeId,
        type: MemoryType.video,
        title: title,
        filePath: videoPath,
        thumbnailPath: thumbnailPath,
        durationSeconds: durationSeconds,
        dateTaken: DateTime.now(),
        tags: tags,
        isPrivate: isPrivate,
      );
      // 패밀리 플랜이면 R2 자동 업로드 큐에 추가
      await _enqueueVideoUploadIfCloud(memory);
      state = const AsyncData(null);
      return memory;
    } on PlanLimitError catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }

  /// 카메라로 영상 촬영 후 저장
  Future<MemoryModel?> addVideoFromCamera({
    required String nodeId,
    required int maxSeconds,
    String? title,
    required int durationSeconds,
    List<String> tags = const [],
    bool isPrivate = false,
  }) async {
    state = const AsyncLoading();
    try {
      final videoPath =
          await _media.captureAndSaveVideo(maxSeconds: maxSeconds);
      if (videoPath == null) {
        state = const AsyncData(null);
        return null;
      }
      final thumbnailPath = await _media.generateVideoThumbnail(videoPath);
      final memory = await _repo.create(
        nodeId: nodeId,
        type: MemoryType.video,
        title: title,
        filePath: videoPath,
        thumbnailPath: thumbnailPath,
        durationSeconds: durationSeconds,
        dateTaken: DateTime.now(),
        tags: tags,
        isPrivate: isPrivate,
      );
      // 패밀리 플랜이면 R2 자동 업로드 큐에 추가
      await _enqueueVideoUploadIfCloud(memory);
      state = const AsyncData(null);
      return memory;
    } on PlanLimitError catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }

  // ── R2 업로드 큐 자동 등록 ──────────────────────────────────────────────

  /// 패밀리 플랜 여부 확인 (클라우드 업로드 가능 여부)
  Future<bool> _hasCloudPlan() async {
    final plan = await _settings.getUserPlan();
    return plan.hasCloud;
  }

  /// 사진 메모리 → R2 업로드 큐 등록 (사진 + 썸네일)
  Future<void> _enqueuePhotoUploadIfCloud(MemoryModel memory) async {
    if (!await _hasCloudPlan()) return;
    try {
      // 사진 파일 업로드
      if (memory.filePath != null) {
        final absPath = PathUtils.toAbsolute(memory.filePath) ?? memory.filePath!;
        await _uploadQueue.enqueue(
          memoryId: memory.id,
          localPath: absPath,
          category: 'photo',
          contentType: 'image/webp',
        );
      }
      // 썸네일 업로드
      if (memory.thumbnailPath != null) {
        final absThumb =
            PathUtils.toAbsolute(memory.thumbnailPath) ?? memory.thumbnailPath!;
        await _uploadQueue.enqueue(
          memoryId: memory.id,
          localPath: absThumb,
          category: 'thumbnail',
          contentType: 'image/webp',
        );
      }
      debugPrint('[MemoryNotifier] 사진 R2 업로드 큐 등록: ${memory.id}');
    } catch (e) {
      debugPrint('[MemoryNotifier] R2 큐 등록 오류 (무시): $e');
    }
  }

  /// 음성 메모리 → R2 업로드 큐 등록
  Future<void> _enqueueVoiceUploadIfCloud(MemoryModel memory) async {
    if (!await _hasCloudPlan()) return;
    try {
      if (memory.filePath != null) {
        final absPath = PathUtils.toAbsolute(memory.filePath) ?? memory.filePath!;
        await _uploadQueue.enqueue(
          memoryId: memory.id,
          localPath: absPath,
          category: 'voice',
          contentType: 'audio/m4a',
        );
      }
      debugPrint('[MemoryNotifier] 음성 R2 업로드 큐 등록: ${memory.id}');
    } catch (e) {
      debugPrint('[MemoryNotifier] R2 큐 등록 오류 (무시): $e');
    }
  }

  /// 영상 메모리 → R2 업로드 큐 등록 (영상 + 썸네일)
  Future<void> _enqueueVideoUploadIfCloud(MemoryModel memory) async {
    if (!await _hasCloudPlan()) return;
    try {
      // 영상 파일 업로드
      if (memory.filePath != null) {
        final absPath = PathUtils.toAbsolute(memory.filePath) ?? memory.filePath!;
        await _uploadQueue.enqueue(
          memoryId: memory.id,
          localPath: absPath,
          category: 'video',
          contentType: 'video/mp4',
        );
      }
      // 영상 썸네일 업로드
      if (memory.thumbnailPath != null) {
        final absThumb =
            PathUtils.toAbsolute(memory.thumbnailPath) ?? memory.thumbnailPath!;
        await _uploadQueue.enqueue(
          memoryId: memory.id,
          localPath: absThumb,
          category: 'thumbnail',
          contentType: 'image/jpeg',
        );
      }
      debugPrint('[MemoryNotifier] 영상 R2 업로드 큐 등록: ${memory.id}');
    } catch (e) {
      debugPrint('[MemoryNotifier] R2 큐 등록 오류 (무시): $e');
    }
  }
}
