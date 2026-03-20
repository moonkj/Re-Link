// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'voice_legacy_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$allVoiceLegaciesHash() => r'33b99aab64b1927c90d3524a1b60dc29ae2c94da';

/// 전체 보이스 유언 목록 스트림
///
/// Copied from [allVoiceLegacies].
@ProviderFor(allVoiceLegacies)
final allVoiceLegaciesProvider =
    AutoDisposeStreamProvider<List<VoiceLegacyTableData>>.internal(
      allVoiceLegacies,
      name: r'allVoiceLegaciesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$allVoiceLegaciesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AllVoiceLegaciesRef =
    AutoDisposeStreamProviderRef<List<VoiceLegacyTableData>>;
String _$voiceLegacyNotifierHash() =>
    r'22d4720d7535a7711ff085e2aa20c83f1e7e14cb';

/// 보이스 유언 CRUD 오퍼레이션
///
/// Copied from [VoiceLegacyNotifier].
@ProviderFor(VoiceLegacyNotifier)
final voiceLegacyNotifierProvider =
    AutoDisposeNotifierProvider<VoiceLegacyNotifier, AsyncValue<void>>.internal(
      VoiceLegacyNotifier.new,
      name: r'voiceLegacyNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$voiceLegacyNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$VoiceLegacyNotifier = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
