// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plan_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$planNotifierHash() => r'f8290bf9febc8dd311f52faeee81087e818982c3';

/// 현재 플랜 상태 (DB에서 읽음)
///
/// Copied from [PlanNotifier].
@ProviderFor(PlanNotifier)
final planNotifierProvider =
    AutoDisposeAsyncNotifierProvider<PlanNotifier, UserPlan>.internal(
      PlanNotifier.new,
      name: r'planNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$planNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$PlanNotifier = AutoDisposeAsyncNotifier<UserPlan>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
