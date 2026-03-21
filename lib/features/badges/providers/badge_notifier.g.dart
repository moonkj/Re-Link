// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'badge_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$badgeNotifierHash() => r'a208ac366449b56fd48a99cdec9562b2ccc57ad6';

/// 배지 시스템 상태 관리
///
/// Copied from [BadgeNotifier].
@ProviderFor(BadgeNotifier)
final badgeNotifierProvider =
    AutoDisposeAsyncNotifierProvider<
      BadgeNotifier,
      List<BadgeDefinition>
    >.internal(
      BadgeNotifier.new,
      name: r'badgeNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$badgeNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$BadgeNotifier = AutoDisposeAsyncNotifier<List<BadgeDefinition>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
