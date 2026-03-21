import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_token_storage.g.dart';

/// flutter_secure_storage 키 상수
abstract final class _TokenKeys {
  static const String accessToken = 'relink_access_token';
  static const String refreshToken = 'relink_refresh_token';
  static const String userId = 'relink_user_id';
}

/// Riverpod provider — AuthTokenStorage 싱글톤
@riverpod
AuthTokenStorage authTokenStorage(Ref ref) {
  return const AuthTokenStorage();
}

/// JWT 토큰 보안 저장소
/// flutter_secure_storage (Keychain / Keystore) 사용
class AuthTokenStorage {
  const AuthTokenStorage();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  /// 액세스/리프레시 토큰을 함께 저장
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    String? userId,
  }) async {
    await Future.wait([
      _storage.write(key: _TokenKeys.accessToken, value: accessToken),
      _storage.write(key: _TokenKeys.refreshToken, value: refreshToken),
      if (userId != null)
        _storage.write(key: _TokenKeys.userId, value: userId),
    ]);
  }

  /// 저장된 액세스 토큰 조회 (없으면 null)
  Future<String?> getAccessToken() async {
    return _storage.read(key: _TokenKeys.accessToken);
  }

  /// 저장된 리프레시 토큰 조회 (없으면 null)
  Future<String?> getRefreshToken() async {
    return _storage.read(key: _TokenKeys.refreshToken);
  }

  /// 저장된 사용자 ID 조회 (없으면 null)
  Future<String?> getUserId() async {
    return _storage.read(key: _TokenKeys.userId);
  }

  /// 모든 인증 토큰 삭제 (로그아웃 시 호출)
  Future<void> clearTokens() async {
    await Future.wait([
      _storage.delete(key: _TokenKeys.accessToken),
      _storage.delete(key: _TokenKeys.refreshToken),
      _storage.delete(key: _TokenKeys.userId),
    ]);
  }

  /// 액세스 토큰만 업데이트 (토큰 갱신 시)
  Future<void> updateAccessToken(String accessToken) async {
    await _storage.write(key: _TokenKeys.accessToken, value: accessToken);
  }
}
