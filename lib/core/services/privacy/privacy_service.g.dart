// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'privacy_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$privacyServiceHash() => r'4761eee7066976b6238b5367fcd43ac480e91707';

/// Privacy Layer 서비스 — local_auth 래퍼
///
/// 생체인증(Face ID / Touch ID / 지문)으로 개인 기억을 보호합니다.
/// 인증 세션은 [_sessionDuration] 동안 유지되어 반복 인증을 방지합니다.
///
/// Copied from [privacyService].
@ProviderFor(privacyService)
final privacyServiceProvider = AutoDisposeProvider<PrivacyService>.internal(
  privacyService,
  name: r'privacyServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$privacyServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PrivacyServiceRef = AutoDisposeProviderRef<PrivacyService>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
