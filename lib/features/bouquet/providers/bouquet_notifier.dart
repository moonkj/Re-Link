import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../shared/models/bouquet_model.dart';
import '../../../shared/repositories/bouquet_repository.dart';

part 'bouquet_notifier.g.dart';

/// 노드별 이번 주 꽃 목록 스트림 (캔버스 오버레이 / 디테일시트용)
@riverpod
Future<List<Bouquet>> bouquetsThisWeek(Ref ref, String toNodeId) =>
    ref.watch(bouquetRepositoryProvider).getThisWeek(toNodeId);

/// 노드별 전체 꽃 목록
@riverpod
Future<List<Bouquet>> bouquetsForNode(Ref ref, String toNodeId) =>
    ref.watch(bouquetRepositoryProvider).getForNode(toNodeId);

/// 꽃 보내기 CRUD 오퍼레이션
@riverpod
class BouquetNotifier extends _$BouquetNotifier {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  BouquetRepository get _repo => ref.read(bouquetRepositoryProvider);

  /// 꽃 보내기
  Future<Bouquet?> sendFlower({
    required String fromNodeId,
    required String toNodeId,
    required FlowerType flowerType,
  }) async {
    state = const AsyncLoading();
    try {
      final bouquet = await _repo.sendFlower(
        fromNodeId: fromNodeId,
        toNodeId: toNodeId,
        flowerType: flowerType,
      );
      state = const AsyncData(null);
      // 주간 캐시 무효화
      ref.invalidate(bouquetsThisWeekProvider(toNodeId));
      ref.invalidate(bouquetsForNodeProvider(toNodeId));
      return bouquet;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }

  /// 꽃 삭제
  Future<void> deleteBouquet(String id, String toNodeId) async {
    state = const AsyncLoading();
    try {
      await _repo.delete(id);
      state = const AsyncData(null);
      // 캐시 무효화
      ref.invalidate(bouquetsThisWeekProvider(toNodeId));
      ref.invalidate(bouquetsForNodeProvider(toNodeId));
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
