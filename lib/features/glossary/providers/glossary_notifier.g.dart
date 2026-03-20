// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'glossary_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$allGlossaryHash() => r'66e3aff3f8bdf8c160c93c19e40766c896963f3f';

/// 전체 단어장 스트림 (가나다순)
///
/// Copied from [allGlossary].
@ProviderFor(allGlossary)
final allGlossaryProvider =
    AutoDisposeStreamProvider<List<GlossaryTableData>>.internal(
      allGlossary,
      name: r'allGlossaryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$allGlossaryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AllGlossaryRef = AutoDisposeStreamProviderRef<List<GlossaryTableData>>;
String _$glossaryNotifierHash() => r'29815868e054fb81b1118c3165cb7b9b20a0cf93';

/// 단어장 CRUD 오퍼레이션
///
/// Copied from [GlossaryNotifier].
@ProviderFor(GlossaryNotifier)
final glossaryNotifierProvider =
    AutoDisposeNotifierProvider<GlossaryNotifier, AsyncValue<void>>.internal(
      GlossaryNotifier.new,
      name: r'glossaryNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$glossaryNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$GlossaryNotifier = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
