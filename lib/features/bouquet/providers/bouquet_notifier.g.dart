// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bouquet_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$bouquetsThisWeekHash() => r'e0d739c3571ab005ddbb7a2bcd4fe77e60b81da0';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// 노드별 이번 주 꽃 목록 스트림 (캔버스 오버레이 / 디테일시트용)
///
/// Copied from [bouquetsThisWeek].
@ProviderFor(bouquetsThisWeek)
const bouquetsThisWeekProvider = BouquetsThisWeekFamily();

/// 노드별 이번 주 꽃 목록 스트림 (캔버스 오버레이 / 디테일시트용)
///
/// Copied from [bouquetsThisWeek].
class BouquetsThisWeekFamily extends Family<AsyncValue<List<Bouquet>>> {
  /// 노드별 이번 주 꽃 목록 스트림 (캔버스 오버레이 / 디테일시트용)
  ///
  /// Copied from [bouquetsThisWeek].
  const BouquetsThisWeekFamily();

  /// 노드별 이번 주 꽃 목록 스트림 (캔버스 오버레이 / 디테일시트용)
  ///
  /// Copied from [bouquetsThisWeek].
  BouquetsThisWeekProvider call(String toNodeId) {
    return BouquetsThisWeekProvider(toNodeId);
  }

  @override
  BouquetsThisWeekProvider getProviderOverride(
    covariant BouquetsThisWeekProvider provider,
  ) {
    return call(provider.toNodeId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'bouquetsThisWeekProvider';
}

/// 노드별 이번 주 꽃 목록 스트림 (캔버스 오버레이 / 디테일시트용)
///
/// Copied from [bouquetsThisWeek].
class BouquetsThisWeekProvider
    extends AutoDisposeFutureProvider<List<Bouquet>> {
  /// 노드별 이번 주 꽃 목록 스트림 (캔버스 오버레이 / 디테일시트용)
  ///
  /// Copied from [bouquetsThisWeek].
  BouquetsThisWeekProvider(String toNodeId)
    : this._internal(
        (ref) => bouquetsThisWeek(ref as BouquetsThisWeekRef, toNodeId),
        from: bouquetsThisWeekProvider,
        name: r'bouquetsThisWeekProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$bouquetsThisWeekHash,
        dependencies: BouquetsThisWeekFamily._dependencies,
        allTransitiveDependencies:
            BouquetsThisWeekFamily._allTransitiveDependencies,
        toNodeId: toNodeId,
      );

  BouquetsThisWeekProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.toNodeId,
  }) : super.internal();

  final String toNodeId;

  @override
  Override overrideWith(
    FutureOr<List<Bouquet>> Function(BouquetsThisWeekRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: BouquetsThisWeekProvider._internal(
        (ref) => create(ref as BouquetsThisWeekRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        toNodeId: toNodeId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Bouquet>> createElement() {
    return _BouquetsThisWeekProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is BouquetsThisWeekProvider && other.toNodeId == toNodeId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, toNodeId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin BouquetsThisWeekRef on AutoDisposeFutureProviderRef<List<Bouquet>> {
  /// The parameter `toNodeId` of this provider.
  String get toNodeId;
}

class _BouquetsThisWeekProviderElement
    extends AutoDisposeFutureProviderElement<List<Bouquet>>
    with BouquetsThisWeekRef {
  _BouquetsThisWeekProviderElement(super.provider);

  @override
  String get toNodeId => (origin as BouquetsThisWeekProvider).toNodeId;
}

String _$bouquetsForNodeHash() => r'a0ad5758e6a7aa4c8571ee97a9a144b1f89413b0';

/// 노드별 전체 꽃 목록
///
/// Copied from [bouquetsForNode].
@ProviderFor(bouquetsForNode)
const bouquetsForNodeProvider = BouquetsForNodeFamily();

/// 노드별 전체 꽃 목록
///
/// Copied from [bouquetsForNode].
class BouquetsForNodeFamily extends Family<AsyncValue<List<Bouquet>>> {
  /// 노드별 전체 꽃 목록
  ///
  /// Copied from [bouquetsForNode].
  const BouquetsForNodeFamily();

  /// 노드별 전체 꽃 목록
  ///
  /// Copied from [bouquetsForNode].
  BouquetsForNodeProvider call(String toNodeId) {
    return BouquetsForNodeProvider(toNodeId);
  }

  @override
  BouquetsForNodeProvider getProviderOverride(
    covariant BouquetsForNodeProvider provider,
  ) {
    return call(provider.toNodeId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'bouquetsForNodeProvider';
}

/// 노드별 전체 꽃 목록
///
/// Copied from [bouquetsForNode].
class BouquetsForNodeProvider extends AutoDisposeFutureProvider<List<Bouquet>> {
  /// 노드별 전체 꽃 목록
  ///
  /// Copied from [bouquetsForNode].
  BouquetsForNodeProvider(String toNodeId)
    : this._internal(
        (ref) => bouquetsForNode(ref as BouquetsForNodeRef, toNodeId),
        from: bouquetsForNodeProvider,
        name: r'bouquetsForNodeProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$bouquetsForNodeHash,
        dependencies: BouquetsForNodeFamily._dependencies,
        allTransitiveDependencies:
            BouquetsForNodeFamily._allTransitiveDependencies,
        toNodeId: toNodeId,
      );

  BouquetsForNodeProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.toNodeId,
  }) : super.internal();

  final String toNodeId;

  @override
  Override overrideWith(
    FutureOr<List<Bouquet>> Function(BouquetsForNodeRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: BouquetsForNodeProvider._internal(
        (ref) => create(ref as BouquetsForNodeRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        toNodeId: toNodeId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Bouquet>> createElement() {
    return _BouquetsForNodeProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is BouquetsForNodeProvider && other.toNodeId == toNodeId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, toNodeId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin BouquetsForNodeRef on AutoDisposeFutureProviderRef<List<Bouquet>> {
  /// The parameter `toNodeId` of this provider.
  String get toNodeId;
}

class _BouquetsForNodeProviderElement
    extends AutoDisposeFutureProviderElement<List<Bouquet>>
    with BouquetsForNodeRef {
  _BouquetsForNodeProviderElement(super.provider);

  @override
  String get toNodeId => (origin as BouquetsForNodeProvider).toNodeId;
}

String _$bouquetNotifierHash() => r'7833c77a4dc6c4ce98cc8de7ed588df11c301cb9';

/// 꽃 보내기 CRUD 오퍼레이션
///
/// Copied from [BouquetNotifier].
@ProviderFor(BouquetNotifier)
final bouquetNotifierProvider =
    AutoDisposeNotifierProvider<BouquetNotifier, AsyncValue<void>>.internal(
      BouquetNotifier.new,
      name: r'bouquetNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$bouquetNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$BouquetNotifier = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
