/// 인증된 사용자 모델
/// Cloudflare Workers 응답에서 파싱하여 사용
class AuthUser {
  /// 서버 발급 사용자 ID (형식: 'usr_xxx')
  final String id;

  final String? email;

  /// 인증 제공자: 'apple' | 'google'
  final String provider;

  /// 요금제: 'free' | 'plus' | 'family' | 'familyPlus'
  final String plan;

  /// 패밀리 그룹 ID (패밀리 플랜 이상에서만 존재)
  final String? familyGroupId;

  /// JWT 액세스 토큰
  final String accessToken;

  const AuthUser({
    required this.id,
    this.email,
    required this.provider,
    required this.plan,
    this.familyGroupId,
    required this.accessToken,
  });

  factory AuthUser.fromJson(
    Map<String, dynamic> json,
    String accessToken,
  ) {
    return AuthUser(
      id: json['id'] as String,
      email: json['email'] as String?,
      provider: json['provider'] as String? ?? 'apple',
      plan: json['plan'] as String? ?? 'free',
      familyGroupId: json['family_group_id'] as String?,
      accessToken: accessToken,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'provider': provider,
        'plan': plan,
        'family_group_id': familyGroupId,
      };

  AuthUser copyWith({
    String? id,
    String? email,
    String? provider,
    String? plan,
    String? familyGroupId,
    String? accessToken,
  }) {
    return AuthUser(
      id: id ?? this.id,
      email: email ?? this.email,
      provider: provider ?? this.provider,
      plan: plan ?? this.plan,
      familyGroupId: familyGroupId ?? this.familyGroupId,
      accessToken: accessToken ?? this.accessToken,
    );
  }

  /// 패밀리 플랜 이상 여부 (클라우드 동기화, 가족 공유 가능)
  bool get hasFamilyPlan => plan == 'family' || plan == 'familyPlus';

  /// 광고 없는 플랜 여부
  bool get isAdFree => plan != 'free';

  @override
  String toString() =>
      'AuthUser(id: $id, email: $email, provider: $provider, plan: $plan)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthUser &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          provider == other.provider;

  @override
  int get hashCode => Object.hash(id, provider);
}
