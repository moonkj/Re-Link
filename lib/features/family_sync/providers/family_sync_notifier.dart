import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/services/sync/sync_service.dart';
import '../../../shared/models/user_plan.dart';
import '../../auth/providers/auth_notifier.dart';
import '../../subscription/providers/plan_notifier.dart';

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

    // 1. 로그인 + 플랜 확인 (관리자 오버라이드 반영)
    final user = ref.read(authNotifierProvider).valueOrNull;
    if (user == null) {
      state = state.copyWith(
        status: SyncStatus.error,
        errorMessage: '로그인이 필요합니다.',
      );
      return;
    }
    final plan = ref.read(planNotifierProvider).valueOrNull ?? UserPlan.free;
    if (!plan.hasCloud) {
      state = state.copyWith(
        status: SyncStatus.error,
        errorMessage: '패밀리 플랜 이상이 필요합니다.',
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
      debugPrint('[Sync] 다운로드=${result.pulled}, 업로드=${result.pushed}');
    } catch (e) {
      debugPrint('[Sync] 동기화 오류: $e');
      // 사용자에게 보여줄 에러 메시지 정리
      final msg = e.toString();
      final userMsg = msg.startsWith('Exception: ')
          ? msg.substring(11)
          : msg.contains('SocketException') || msg.contains('ClientException')
              ? '서버 연결에 실패했습니다. 네트워크를 확인해 주세요.'
              : '동기화 중 오류가 발생했습니다: $msg';
      state = state.copyWith(
        status: SyncStatus.error,
        errorMessage: userMsg,
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
