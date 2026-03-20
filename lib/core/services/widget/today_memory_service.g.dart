// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'today_memory_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$todayMemoryServiceHash() =>
    r'82f2707cf2ad1d0a38bfbdd2e3490d99df7632ff';

/// TodayMemoryService 프로바이더
///
/// Copied from [todayMemoryService].
@ProviderFor(todayMemoryService)
final todayMemoryServiceProvider =
    AutoDisposeProvider<TodayMemoryService>.internal(
      todayMemoryService,
      name: r'todayMemoryServiceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$todayMemoryServiceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TodayMemoryServiceRef = AutoDisposeProviderRef<TodayMemoryService>;
String _$todayMemoriesHash() => r'3ed7883283cf1d7e89eb88d3dd4e88f3d04ac83b';

/// 오늘의 기억 목록 프로바이더
///
/// Copied from [todayMemories].
@ProviderFor(todayMemories)
final todayMemoriesProvider =
    AutoDisposeFutureProvider<List<TodayMemoryData>>.internal(
      todayMemories,
      name: r'todayMemoriesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$todayMemoriesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TodayMemoriesRef = AutoDisposeFutureProviderRef<List<TodayMemoryData>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
