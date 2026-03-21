import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/errors/app_error.dart';
import '../../../core/services/media/media_service.dart';
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
      state = const AsyncData(null);
      return memory;
    } on PlanLimitError {
      state = const AsyncData(null);
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
      state = const AsyncData(null);
      return memory;
    } on PlanLimitError {
      state = const AsyncData(null);
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
      final memory = await _repo.create(
        nodeId: nodeId,
        type: MemoryType.voice,
        title: title,
        filePath: filePath,
        durationSeconds: durationSeconds,
        dateTaken: DateTime.now(),
        tags: tags,
        isPrivate: isPrivate,
      );
      state = const AsyncData(null);
      return memory;
    } on PlanLimitError {
      state = const AsyncData(null);
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
      // 파일 삭제
      await _media.deleteFile(memory.filePath);
      await _media.deleteFile(memory.thumbnailPath);
      await _repo.delete(memory.id);
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
}
