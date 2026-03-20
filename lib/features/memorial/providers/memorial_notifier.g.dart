// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'memorial_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$memorialMessagesForNodeHash() =>
    r'2cec96ba89c188139c23b3083f7305a165642278';

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

/// 노드별 추모 메시지 스트림
///
/// Copied from [memorialMessagesForNode].
@ProviderFor(memorialMessagesForNode)
const memorialMessagesForNodeProvider = MemorialMessagesForNodeFamily();

/// 노드별 추모 메시지 스트림
///
/// Copied from [memorialMessagesForNode].
class MemorialMessagesForNodeFamily
    extends Family<AsyncValue<List<MemorialMessagesTableData>>> {
  /// 노드별 추모 메시지 스트림
  ///
  /// Copied from [memorialMessagesForNode].
  const MemorialMessagesForNodeFamily();

  /// 노드별 추모 메시지 스트림
  ///
  /// Copied from [memorialMessagesForNode].
  MemorialMessagesForNodeProvider call(String nodeId) {
    return MemorialMessagesForNodeProvider(nodeId);
  }

  @override
  MemorialMessagesForNodeProvider getProviderOverride(
    covariant MemorialMessagesForNodeProvider provider,
  ) {
    return call(provider.nodeId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'memorialMessagesForNodeProvider';
}

/// 노드별 추모 메시지 스트림
///
/// Copied from [memorialMessagesForNode].
class MemorialMessagesForNodeProvider
    extends AutoDisposeStreamProvider<List<MemorialMessagesTableData>> {
  /// 노드별 추모 메시지 스트림
  ///
  /// Copied from [memorialMessagesForNode].
  MemorialMessagesForNodeProvider(String nodeId)
    : this._internal(
        (ref) =>
            memorialMessagesForNode(ref as MemorialMessagesForNodeRef, nodeId),
        from: memorialMessagesForNodeProvider,
        name: r'memorialMessagesForNodeProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$memorialMessagesForNodeHash,
        dependencies: MemorialMessagesForNodeFamily._dependencies,
        allTransitiveDependencies:
            MemorialMessagesForNodeFamily._allTransitiveDependencies,
        nodeId: nodeId,
      );

  MemorialMessagesForNodeProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.nodeId,
  }) : super.internal();

  final String nodeId;

  @override
  Override overrideWith(
    Stream<List<MemorialMessagesTableData>> Function(
      MemorialMessagesForNodeRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MemorialMessagesForNodeProvider._internal(
        (ref) => create(ref as MemorialMessagesForNodeRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        nodeId: nodeId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<MemorialMessagesTableData>>
  createElement() {
    return _MemorialMessagesForNodeProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MemorialMessagesForNodeProvider && other.nodeId == nodeId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, nodeId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MemorialMessagesForNodeRef
    on AutoDisposeStreamProviderRef<List<MemorialMessagesTableData>> {
  /// The parameter `nodeId` of this provider.
  String get nodeId;
}

class _MemorialMessagesForNodeProviderElement
    extends AutoDisposeStreamProviderElement<List<MemorialMessagesTableData>>
    with MemorialMessagesForNodeRef {
  _MemorialMessagesForNodeProviderElement(super.provider);

  @override
  String get nodeId => (origin as MemorialMessagesForNodeProvider).nodeId;
}

String _$memorialNotifierHash() => r'46e3d5bfb2f8504472c94e663e57308f825b9afd';

/// 추모 메시지 CRUD 오퍼레이션
///
/// Copied from [MemorialNotifier].
@ProviderFor(MemorialNotifier)
final memorialNotifierProvider =
    AutoDisposeNotifierProvider<MemorialNotifier, AsyncValue<void>>.internal(
      MemorialNotifier.new,
      name: r'memorialNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$memorialNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$MemorialNotifier = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
