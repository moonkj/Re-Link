// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'changelog_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$changelogNotifierHash() => r'bc77bb864cba20780774ae0dcd698208345a8953';

/// 변경 로그 상태 관리
///
/// changelog.json 로드 + 최신 버전과 lastSeenVersion 비교
///
/// Copied from [ChangelogNotifier].
@ProviderFor(ChangelogNotifier)
final changelogNotifierProvider =
    AutoDisposeAsyncNotifierProvider<
      ChangelogNotifier,
      List<ChangelogEntry>
    >.internal(
      ChangelogNotifier.new,
      name: r'changelogNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$changelogNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ChangelogNotifier = AutoDisposeAsyncNotifier<List<ChangelogEntry>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
