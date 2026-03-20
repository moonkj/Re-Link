import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/database/app_database.dart';
import '../../../shared/repositories/voice_legacy_repository.dart';

part 'voice_legacy_notifier.g.dart';

/// 전체 보이스 유언 목록 스트림
@riverpod
Stream<List<VoiceLegacyTableData>> allVoiceLegacies(Ref ref) =>
    ref.watch(voiceLegacyRepositoryProvider).watchAll();

/// 보이스 유언 CRUD 오퍼레이션
@riverpod
class VoiceLegacyNotifier extends _$VoiceLegacyNotifier {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  VoiceLegacyRepository get _repo =>
      ref.read(voiceLegacyRepositoryProvider);

  /// 보이스 유언 생성
  Future<String?> create({
    required String fromNodeId,
    required String toNodeId,
    required String title,
    required String voicePath,
    required int durationSeconds,
    required String openCondition,
    DateTime? openDate,
  }) async {
    state = const AsyncLoading();
    try {
      final id = await _repo.create(
        fromNodeId: fromNodeId,
        toNodeId: toNodeId,
        title: title,
        voicePath: voicePath,
        durationSeconds: durationSeconds,
        openCondition: openCondition,
        openDate: openDate,
      );
      state = const AsyncData(null);
      return id;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }

  /// 봉인 해제
  Future<bool> open(String id) async {
    state = const AsyncLoading();
    try {
      await _repo.open(id);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  /// 삭제
  Future<bool> delete(String id) async {
    state = const AsyncLoading();
    try {
      await _repo.delete(id);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}
