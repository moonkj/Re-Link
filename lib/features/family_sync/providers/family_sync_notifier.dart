import 'package:riverpod_annotation/riverpod_annotation.dart';

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
}

@riverpod
class FamilySyncNotifier extends _$FamilySyncNotifier {
  @override
  FamilySyncState build() => const FamilySyncState();

  Future<void> sync() async {
    state = state.copyWith(status: SyncStatus.syncing);
    try {
      // SyncService 호출 (추후 연동)
      await Future.delayed(const Duration(seconds: 1)); // placeholder
      state = state.copyWith(
        status: SyncStatus.success,
        lastSyncAt: DateTime.now(),
      );
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
