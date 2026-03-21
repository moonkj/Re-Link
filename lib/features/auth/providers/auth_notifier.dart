import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/services/auth/auth_service.dart';
import '../../../shared/models/auth_user.dart';

part 'auth_notifier.g.dart';

/// 인증 상태 전역 관리 Notifier
///
/// 사용 예:
/// ```dart
/// // 상태 읽기
/// final user = ref.watch(authNotifierProvider).valueOrNull;
///
/// // 로그인 여부
/// final notifier = ref.read(authNotifierProvider.notifier);
/// if (notifier.isLoggedIn) { ... }
///
/// // 로그인
/// await notifier.signInWithApple();
/// ```
@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  Future<AuthUser?> build() async {
    // 앱 시작 시 저장된 토큰으로 자동 로그인 시도
    return ref.read(authServiceProvider).tryAutoLogin();
  }

  // ── Apple Sign-In ──────────────────────────────────────────────────────

  /// Apple ID로 로그인
  /// 성공 시 state를 [AsyncData(AuthUser)]로 업데이트
  /// 실패 시 [AsyncError]로 업데이트
  Future<void> signInWithApple() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authServiceProvider).signInWithApple(),
    );
  }

  // ── Google Sign-In ─────────────────────────────────────────────────────

  /// Google 계정으로 로그인
  /// 성공 시 state를 [AsyncData(AuthUser)]로 업데이트
  /// 실패 시 [AsyncError]로 업데이트
  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authServiceProvider).signInWithGoogle(),
    );
  }

  // ── 로그아웃 ───────────────────────────────────────────────────────────

  /// 로그아웃 처리
  /// 성공 시 state를 [AsyncData(null)]로 초기화
  Future<void> signOut() async {
    state = const AsyncLoading();
    try {
      await ref.read(authServiceProvider).signOut();
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  // ── 계정 삭제 ──────────────────────────────────────────────────────────

  /// 계정 완전 삭제 (AppStore 정책 준수)
  Future<void> deleteAccount() async {
    state = const AsyncLoading();
    try {
      await ref.read(authServiceProvider).deleteAccount();
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  // ── 편의 getter ────────────────────────────────────────────────────────

  /// 현재 로그인 여부
  bool get isLoggedIn => state.valueOrNull != null;

  /// 패밀리 플랜 이상 여부 (클라우드 동기화, 가족 공유 가능)
  bool get hasFamilyPlan => state.valueOrNull?.hasFamilyPlan ?? false;

  /// 현재 요금제
  String get currentPlan => state.valueOrNull?.plan ?? 'free';

  /// 현재 사용자 (로그인 안된 경우 null)
  AuthUser? get currentUser => state.valueOrNull;
}
