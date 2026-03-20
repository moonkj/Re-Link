import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../shared/models/temperature_log_model.dart';
import '../../../shared/repositories/temperature_log_repository.dart';

part 'temperature_diary_notifier.g.dart';

/// 노드별 온도 로그 스트림
@riverpod
Stream<List<TemperatureLog>> temperatureLogsForNode(
  TemperatureLogsForNodeRef ref,
  String nodeId,
) =>
    ref.watch(temperatureLogRepositoryProvider).watchForNode(nodeId);

/// 온도 일기 CRUD 오퍼레이션
@riverpod
class TemperatureDiaryNotifier extends _$TemperatureDiaryNotifier {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  TemperatureLogRepository get _repo =>
      ref.read(temperatureLogRepositoryProvider);

  /// 온도 로그 추가
  Future<TemperatureLog?> addLog({
    required String nodeId,
    required int temperature,
    String? emotionTag,
    DateTime? date,
  }) async {
    state = const AsyncLoading();
    try {
      final log = await _repo.create(
        nodeId: nodeId,
        temperature: temperature.clamp(0, 5),
        emotionTag: emotionTag,
        date: date,
      );
      state = const AsyncData(null);
      return log;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }

  /// 온도 로그 삭제
  Future<void> deleteLog(String id) async {
    state = const AsyncLoading();
    try {
      await _repo.delete(id);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  /// 특정 기간 로그 조회
  Future<List<TemperatureLog>> loadForNode(
    String nodeId, {
    DateTime? from,
    DateTime? to,
  }) async {
    try {
      return await _repo.getForNode(nodeId, from: from, to: to);
    } catch (_) {
      return [];
    }
  }
}
