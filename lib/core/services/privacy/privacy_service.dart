import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../shared/repositories/settings_repository.dart';

part 'privacy_service.g.dart';

/// Privacy Layer 서비스 — local_auth 래퍼
///
/// 생체인증(Face ID / Touch ID / 지문)으로 개인 기억을 보호합니다.
/// 인증 세션은 [_sessionDuration] 동안 유지되어 반복 인증을 방지합니다.
@riverpod
PrivacyService privacyService(Ref ref) =>
    PrivacyService(ref.watch(settingsRepositoryProvider));

class PrivacyService {
  PrivacyService(this._settings);

  final SettingsRepository _settings;
  final LocalAuthentication _auth = LocalAuthentication();

  /// 마지막 인증 성공 시각 (세션 유지용)
  DateTime? _lastAuthenticatedAt;

  /// 인증 세션 유지 시간 (5분)
  static const _sessionDuration = Duration(minutes: 5);

  // ── 생체인증 가용 여부 ─────────────────────────────────────────────────────

  /// 기기에서 생체인증 사용 가능 여부
  Future<bool> isAvailable() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isSupported = await _auth.isDeviceSupported();
      return canCheck || isSupported;
    } on PlatformException {
      return false;
    }
  }

  // ── 설정 상태 ──────────────────────────────────────────────────────────────

  /// Privacy Layer 활성화 여부 (Settings DB 조회)
  Future<bool> isEnabled() => _settings.isPrivacyEnabled();

  /// Privacy Layer 활성화/비활성화 (Settings DB 저장)
  Future<void> setEnabled(bool enabled) =>
      _settings.setPrivacyEnabled(enabled);

  // ── 생체인증 실행 ─────────────────────────────────────────────────────────

  /// 생체인증 시도
  ///
  /// 세션이 유효한 경우 재인증 없이 `true` 반환.
  /// [reason]은 시스템 인증 다이얼로그에 표시되는 메시지.
  Future<bool> authenticate({
    String reason = '개인 기억을 보려면 인증이 필요합니다',
  }) async {
    // 세션 유효 → 재인증 불필요
    if (_isSessionValid()) return true;

    try {
      final result = await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false, // PIN/패턴 폴백 허용
        ),
      );
      if (result) {
        _lastAuthenticatedAt = DateTime.now();
      }
      return result;
    } on PlatformException {
      return false;
    }
  }

  /// 현재 인증 세션이 유효한지 확인
  bool _isSessionValid() {
    if (_lastAuthenticatedAt == null) return false;
    return DateTime.now().difference(_lastAuthenticatedAt!) < _sessionDuration;
  }

  /// 세션 무효화 (로그아웃/앱 종료 시)
  void invalidateSession() {
    _lastAuthenticatedAt = null;
  }
}
