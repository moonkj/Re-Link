// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tree_growth_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$treeGrowthNotifierHash() =>
    r'42ab896f4acc9f8d74354203ee18598aa0fffb36';

/// 가족 나무 성장 노티파이어
///
/// 노드 수, 기억 수, 스트릭 카운트를 기반으로 성장 점수를 계산하고
/// 해당하는 성장 단계와 현재 계절을 반환한다.
///
/// Copied from [TreeGrowthNotifier].
@ProviderFor(TreeGrowthNotifier)
final treeGrowthNotifierProvider =
    AutoDisposeAsyncNotifierProvider<
      TreeGrowthNotifier,
      TreeGrowthState
    >.internal(
      TreeGrowthNotifier.new,
      name: r'treeGrowthNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$treeGrowthNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$TreeGrowthNotifier = AutoDisposeAsyncNotifier<TreeGrowthState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
