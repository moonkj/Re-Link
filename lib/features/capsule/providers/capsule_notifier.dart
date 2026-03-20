import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/database/app_database.dart';
import '../../../shared/repositories/capsule_repository.dart';

part 'capsule_notifier.g.dart';

/// 전체 캡슐 목록 스트림
@riverpod
Stream<List<CapsulesTableData>> allCapsules(Ref ref) =>
    ref.watch(capsuleRepositoryProvider).watchAll();

/// 캡슐 CRUD 오퍼레이션
@riverpod
class CapsuleNotifier extends _$CapsuleNotifier {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  CapsuleRepository get _repo => ref.read(capsuleRepositoryProvider);

  /// 캡슐 생성
  Future<String?> create({
    required String title,
    String? message,
    required DateTime openDate,
    required List<String> memoryIds,
  }) async {
    state = const AsyncLoading();
    try {
      final id = await _repo.create(
        title: title,
        message: message,
        openDate: openDate,
        memoryIds: memoryIds,
      );
      state = const AsyncData(null);
      return id;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }

  /// 캡슐 열기 (잠금 해제)
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

  /// 캡슐 삭제
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
