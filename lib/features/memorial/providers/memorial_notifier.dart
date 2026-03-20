import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/database/app_database.dart';
import '../../../shared/repositories/memorial_repository.dart';

part 'memorial_notifier.g.dart';

/// 노드별 추모 메시지 스트림
@riverpod
Stream<List<MemorialMessagesTableData>> memorialMessagesForNode(
  Ref ref,
  String nodeId,
) =>
    ref.watch(memorialRepositoryProvider).watchForNode(nodeId);

/// 추모 메시지 CRUD 오퍼레이션
@riverpod
class MemorialNotifier extends _$MemorialNotifier {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  MemorialRepository get _repo => ref.read(memorialRepositoryProvider);

  /// 추모 메시지 작성
  Future<String?> addMessage({
    required String nodeId,
    required String message,
    String? authorName,
  }) async {
    state = const AsyncLoading();
    try {
      final id = await _repo.create(
        nodeId: nodeId,
        message: message,
        authorName: authorName,
      );
      state = const AsyncData(null);
      return id;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }

  /// 추모 메시지 삭제
  Future<void> deleteMessage(String id) async {
    state = const AsyncLoading();
    try {
      await _repo.delete(id);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
