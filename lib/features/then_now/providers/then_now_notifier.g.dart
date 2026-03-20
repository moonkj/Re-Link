// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'then_now_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$allThenNowPairsHash() => r'da97d77a9b2f16854c48779d0dc491ed5f508fc7';

/// 전체 Then & Now 페어 스트림
///
/// Copied from [allThenNowPairs].
@ProviderFor(allThenNowPairs)
final allThenNowPairsProvider =
    AutoDisposeStreamProvider<List<ThenNowPair>>.internal(
      allThenNowPairs,
      name: r'allThenNowPairsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$allThenNowPairsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AllThenNowPairsRef = AutoDisposeStreamProviderRef<List<ThenNowPair>>;
String _$thenNowNotifierHash() => r'2ad1a43d88023272ea11e520ee189f5e4d515672';

/// Then & Now CRUD 오퍼레이션
///
/// Copied from [ThenNowNotifier].
@ProviderFor(ThenNowNotifier)
final thenNowNotifierProvider =
    AutoDisposeNotifierProvider<ThenNowNotifier, AsyncValue<void>>.internal(
      ThenNowNotifier.new,
      name: r'thenNowNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$thenNowNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ThenNowNotifier = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
