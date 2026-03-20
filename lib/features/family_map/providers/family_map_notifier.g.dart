// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'family_map_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$familyMapPinsHash() => r'96665e2f1f9b4e8120c30dd03bac565a8a505577';

/// 전체 위치 스트림 — 노드 정보와 조인하여 MapPin 리스트 반환
///
/// Copied from [familyMapPins].
@ProviderFor(familyMapPins)
final familyMapPinsProvider = AutoDisposeStreamProvider<List<MapPin>>.internal(
  familyMapPins,
  name: r'familyMapPinsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$familyMapPinsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FamilyMapPinsRef = AutoDisposeStreamProviderRef<List<MapPin>>;
String _$familyMapNotifierHash() => r'e332e9b83c431f5750cfd960bdf989043c343789';

/// 가족 지도 CRUD 오퍼레이션
///
/// Copied from [FamilyMapNotifier].
@ProviderFor(FamilyMapNotifier)
final familyMapNotifierProvider =
    AutoDisposeNotifierProvider<FamilyMapNotifier, AsyncValue<void>>.internal(
      FamilyMapNotifier.new,
      name: r'familyMapNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$familyMapNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$FamilyMapNotifier = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
