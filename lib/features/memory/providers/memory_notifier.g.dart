// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'memory_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$memoriesForNodeHash() => r'f955c5dd951d1e0999e679327c12621c1f24b5c0';

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

/// 노드별 기억 스트림
///
/// Copied from [memoriesForNode].
@ProviderFor(memoriesForNode)
const memoriesForNodeProvider = MemoriesForNodeFamily();

/// 노드별 기억 스트림
///
/// Copied from [memoriesForNode].
class MemoriesForNodeFamily extends Family<AsyncValue<List<MemoryModel>>> {
  /// 노드별 기억 스트림
  ///
  /// Copied from [memoriesForNode].
  const MemoriesForNodeFamily();

  /// 노드별 기억 스트림
  ///
  /// Copied from [memoriesForNode].
  MemoriesForNodeProvider call(String nodeId) {
    return MemoriesForNodeProvider(nodeId);
  }

  @override
  MemoriesForNodeProvider getProviderOverride(
    covariant MemoriesForNodeProvider provider,
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
  String? get name => r'memoriesForNodeProvider';
}

/// 노드별 기억 스트림
///
/// Copied from [memoriesForNode].
class MemoriesForNodeProvider
    extends AutoDisposeStreamProvider<List<MemoryModel>> {
  /// 노드별 기억 스트림
  ///
  /// Copied from [memoriesForNode].
  MemoriesForNodeProvider(String nodeId)
    : this._internal(
        (ref) => memoriesForNode(ref as MemoriesForNodeRef, nodeId),
        from: memoriesForNodeProvider,
        name: r'memoriesForNodeProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$memoriesForNodeHash,
        dependencies: MemoriesForNodeFamily._dependencies,
        allTransitiveDependencies:
            MemoriesForNodeFamily._allTransitiveDependencies,
        nodeId: nodeId,
      );

  MemoriesForNodeProvider._internal(
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
    Stream<List<MemoryModel>> Function(MemoriesForNodeRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MemoriesForNodeProvider._internal(
        (ref) => create(ref as MemoriesForNodeRef),
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
  AutoDisposeStreamProviderElement<List<MemoryModel>> createElement() {
    return _MemoriesForNodeProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MemoriesForNodeProvider && other.nodeId == nodeId;
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
mixin MemoriesForNodeRef on AutoDisposeStreamProviderRef<List<MemoryModel>> {
  /// The parameter `nodeId` of this provider.
  String get nodeId;
}

class _MemoriesForNodeProviderElement
    extends AutoDisposeStreamProviderElement<List<MemoryModel>>
    with MemoriesForNodeRef {
  _MemoriesForNodeProviderElement(super.provider);

  @override
  String get nodeId => (origin as MemoriesForNodeProvider).nodeId;
}

String _$totalVoiceMinutesHash() => r'45aa267dcf69ab3bdc1b6e9de6b52a41514095ca';

/// 전체 음성 사용량 (분 단위)
///
/// Copied from [totalVoiceMinutes].
@ProviderFor(totalVoiceMinutes)
final totalVoiceMinutesProvider = AutoDisposeFutureProvider<int>.internal(
  totalVoiceMinutes,
  name: r'totalVoiceMinutesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$totalVoiceMinutesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TotalVoiceMinutesRef = AutoDisposeFutureProviderRef<int>;
String _$totalPhotoCountHash() => r'6b25ffd475c94eec8080091922a1929e1cd3f328';

/// 전체 사진 수
///
/// Copied from [totalPhotoCount].
@ProviderFor(totalPhotoCount)
final totalPhotoCountProvider = AutoDisposeFutureProvider<int>.internal(
  totalPhotoCount,
  name: r'totalPhotoCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$totalPhotoCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TotalPhotoCountRef = AutoDisposeFutureProviderRef<int>;
String _$memoryNotifierHash() => r'baf7e7e80562afe72cf139de70243bea4a0a82a0';

/// 기억 CRUD 오퍼레이션
///
/// Copied from [MemoryNotifier].
@ProviderFor(MemoryNotifier)
final memoryNotifierProvider =
    AutoDisposeNotifierProvider<MemoryNotifier, AsyncValue<void>>.internal(
      MemoryNotifier.new,
      name: r'memoryNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$memoryNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$MemoryNotifier = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
