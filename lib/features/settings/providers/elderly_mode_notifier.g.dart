// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'elderly_mode_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$elderlyModeNotifierHash() =>
    r'9954f713697369d2bc7684dfd95b85dadce03e17';

/// 어르신 모드 상태 — 앱 전역 반응형 프로바이더
/// `app.dart`에서 watch하여 MediaQuery.textScaler를 1.3×으로 오버라이드
///
/// Copied from [ElderlyModeNotifier].
@ProviderFor(ElderlyModeNotifier)
final elderlyModeNotifierProvider =
    AutoDisposeAsyncNotifierProvider<ElderlyModeNotifier, bool>.internal(
      ElderlyModeNotifier.new,
      name: r'elderlyModeNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$elderlyModeNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ElderlyModeNotifier = AutoDisposeAsyncNotifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
