// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$authNotifierHash() => r'c796b3f13b54ab62081665047db3023d12594c53';

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
///
/// Copied from [AuthNotifier].
@ProviderFor(AuthNotifier)
final authNotifierProvider =
    AutoDisposeAsyncNotifierProvider<AuthNotifier, AuthUser?>.internal(
      AuthNotifier.new,
      name: r'authNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$authNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AuthNotifier = AutoDisposeAsyncNotifier<AuthUser?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
