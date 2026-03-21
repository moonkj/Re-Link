import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/services/sync/sync_service.dart';
import '../../auth/providers/auth_notifier.dart';

part 'family_sync_notifier.g.dart';

enum SyncStatus { idle, syncing, success, error }

class FamilySyncState {
  const FamilySyncState({
    this.status = SyncStatus.idle,
    this.lastSyncAt,
    this.errorMessage,
    this.pendingCount = 0,
  });
  final SyncStatus status;
  final DateTime? lastSyncAt;
  final String? errorMessage;
  final int pendingCount;

  bool get isSyncing => status == SyncStatus.syncing;
}

@riverpod
class FamilySyncNotifier extends _$FamilySyncNotifier {
  @override
  FamilySyncState build() => const FamilySyncState();

  /// 클라우드 동기화 실행
  /// - 패밀리 플랜 + 로그인 + 온라인 상태에서만 동작
  Future<void> sync() async {
    if (state.isSyncing) return;

    // 1. 로그인 확인
    final user = ref.read(authNotifierProvider).valueOrNull;
    if (user == null || !user.hasFamilyPlan) {
      state = state.copyWith(
        status: SyncStatus.error,
        errorMessage: '패밀리 플랜 로그인이 필요합니다.',
      );
      return;
    }

    // 2. 네트워크 확인
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity.contains(ConnectivityResult.none) ||
        connectivity.isEmpty) {
      state = state.copyWith(
        status: SyncStatus.error,
        errorMessage: '인터넷 연결을 확인해 주세요.',
      );
      return;
    }

    state = state.copyWith(status: SyncStatus.syncing, errorMessage: null);
    try {
      final result = await ref.read(syncServiceProvider).sync();
      state = state.copyWith(
        status: SyncStatus.success,
        lastSyncAt: DateTime.now(),
        pendingCount: 0,
      );
      // ignore: avoid_print
      print('[Sync] pulled=${result.pulled}, pushed=${result.pushed}');
    } catch (e) {
      state = state.copyWith(
        status: SyncStatus.error,
        errorMessage: e.toString(),
      );
    }
  }
}

// copyWith extension
extension FamilySyncStateExtension on FamilySyncState {
  FamilySyncState copyWith({
    SyncStatus? status,
    DateTime? lastSyncAt,
    String? errorMessage,
    int? pendingCount,
  }) => FamilySyncState(
    status: status ?? this.status,
    lastSyncAt: lastSyncAt ?? this.lastSyncAt,
    errorMessage: errorMessage ?? this.errorMessage,
    pendingCount: pendingCount ?? this.pendingCount,
  );
}
