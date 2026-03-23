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

String _$receivedBouquetsHash() => r'7df4c64269e812d5b22ed47236eb62b8965d3269';

/// 내가 받은 마음 목록
///
/// Copied from [receivedBouquets].
@ProviderFor(receivedBouquets)
const receivedBouquetsProvider = ReceivedBouquetsFamily();

/// 내가 받은 마음 목록
///
/// Copied from [receivedBouquets].
class ReceivedBouquetsFamily extends Family<AsyncValue<List<Bouquet>>> {
  /// 내가 받은 마음 목록
  ///
  /// Copied from [receivedBouquets].
  const ReceivedBouquetsFamily();

  /// 내가 받은 마음 목록
  ///
  /// Copied from [receivedBouquets].
  ReceivedBouquetsProvider call(String toNodeId) {
    return ReceivedBouquetsProvider(toNodeId);
  }

  @override
  ReceivedBouquetsProvider getProviderOverride(
    covariant ReceivedBouquetsProvider provider,
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
  String? get name => r'receivedBouquetsProvider';
}

/// 내가 받은 마음 목록
///
/// Copied from [receivedBouquets].
class ReceivedBouquetsProvider
    extends AutoDisposeFutureProvider<List<Bouquet>> {
  /// 내가 받은 마음 목록
  ///
  /// Copied from [receivedBouquets].
  ReceivedBouquetsProvider(String toNodeId)
    : this._internal(
        (ref) => receivedBouquets(ref as ReceivedBouquetsRef, toNodeId),
        from: receivedBouquetsProvider,
        name: r'receivedBouquetsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$receivedBouquetsHash,
        dependencies: ReceivedBouquetsFamily._dependencies,
        allTransitiveDependencies:
            ReceivedBouquetsFamily._allTransitiveDependencies,
        toNodeId: toNodeId,
      );

  ReceivedBouquetsProvider._internal(
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
    FutureOr<List<Bouquet>> Function(ReceivedBouquetsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ReceivedBouquetsProvider._internal(
        (ref) => create(ref as ReceivedBouquetsRef),
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
    return _ReceivedBouquetsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ReceivedBouquetsProvider && other.toNodeId == toNodeId;
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
mixin ReceivedBouquetsRef on AutoDisposeFutureProviderRef<List<Bouquet>> {
  /// The parameter `toNodeId` of this provider.
  String get toNodeId;
}

class _ReceivedBouquetsProviderElement
    extends AutoDisposeFutureProviderElement<List<Bouquet>>
    with ReceivedBouquetsRef {
  _ReceivedBouquetsProviderElement(super.provider);

  @override
  String get toNodeId => (origin as ReceivedBouquetsProvider).toNodeId;
}

String _$unreadBouquetCountHash() =>
    r'23b5797c9350472693bb6aa0bda17c20d92a6b2c';

/// 읽지 않은 마음 수 (N 뱃지용)
///
/// Copied from [unreadBouquetCount].
@ProviderFor(unreadBouquetCount)
const unreadBouquetCountProvider = UnreadBouquetCountFamily();

/// 읽지 않은 마음 수 (N 뱃지용)
///
/// Copied from [unreadBouquetCount].
class UnreadBouquetCountFamily extends Family<AsyncValue<int>> {
  /// 읽지 않은 마음 수 (N 뱃지용)
  ///
  /// Copied from [unreadBouquetCount].
  const UnreadBouquetCountFamily();

  /// 읽지 않은 마음 수 (N 뱃지용)
  ///
  /// Copied from [unreadBouquetCount].
  UnreadBouquetCountProvider call(String toNodeId) {
    return UnreadBouquetCountProvider(toNodeId);
  }

  @override
  UnreadBouquetCountProvider getProviderOverride(
    covariant UnreadBouquetCountProvider provider,
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
  String? get name => r'unreadBouquetCountProvider';
}

/// 읽지 않은 마음 수 (N 뱃지용)
///
/// Copied from [unreadBouquetCount].
class UnreadBouquetCountProvider extends AutoDisposeFutureProvider<int> {
  /// 읽지 않은 마음 수 (N 뱃지용)
  ///
  /// Copied from [unreadBouquetCount].
  UnreadBouquetCountProvider(String toNodeId)
    : this._internal(
        (ref) => unreadBouquetCount(ref as UnreadBouquetCountRef, toNodeId),
        from: unreadBouquetCountProvider,
        name: r'unreadBouquetCountProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$unreadBouquetCountHash,
        dependencies: UnreadBouquetCountFamily._dependencies,
        allTransitiveDependencies:
            UnreadBouquetCountFamily._allTransitiveDependencies,
        toNodeId: toNodeId,
      );

  UnreadBouquetCountProvider._internal(
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
    FutureOr<int> Function(UnreadBouquetCountRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: UnreadBouquetCountProvider._internal(
        (ref) => create(ref as UnreadBouquetCountRef),
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
  AutoDisposeFutureProviderElement<int> createElement() {
    return _UnreadBouquetCountProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UnreadBouquetCountProvider && other.toNodeId == toNodeId;
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
mixin UnreadBouquetCountRef on AutoDisposeFutureProviderRef<int> {
  /// The parameter `toNodeId` of this provider.
  String get toNodeId;
}

class _UnreadBouquetCountProviderElement
    extends AutoDisposeFutureProviderElement<int>
    with UnreadBouquetCountRef {
  _UnreadBouquetCountProviderElement(super.provider);

  @override
  String get toNodeId => (origin as UnreadBouquetCountProvider).toNodeId;
}

String _$bouquetNotifierHash() => r'ad5e60fd77b60890b5ab0d1374c5893964128272';

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
