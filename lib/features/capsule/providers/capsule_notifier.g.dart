// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'capsule_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$allCapsulesHash() => r'254aed18ab001b9ff9eeb45800d1ee4c3fcac227';

/// 전체 캡슐 목록 스트림
///
/// Copied from [allCapsules].
@ProviderFor(allCapsules)
final allCapsulesProvider =
    AutoDisposeStreamProvider<List<CapsulesTableData>>.internal(
      allCapsules,
      name: r'allCapsulesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$allCapsulesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AllCapsulesRef = AutoDisposeStreamProviderRef<List<CapsulesTableData>>;
String _$capsuleNotifierHash() => r'ef7b71ec69927714aab86af6cc45b1b56b9226a7';

/// 캡슐 CRUD 오퍼레이션
///
/// Copied from [CapsuleNotifier].
@ProviderFor(CapsuleNotifier)
final capsuleNotifierProvider =
    AutoDisposeNotifierProvider<CapsuleNotifier, AsyncValue<void>>.internal(
      CapsuleNotifier.new,
      name: r'capsuleNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$capsuleNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CapsuleNotifier = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
