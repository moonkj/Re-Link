// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'canvas_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$canvasNodeHash() => r'936d809f496bfb4259d574b859c3b3ef469370c4';

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

/// 특정 노드 조회 (상세 화면용)
///
/// Copied from [canvasNode].
@ProviderFor(canvasNode)
const canvasNodeProvider = CanvasNodeFamily();

/// 특정 노드 조회 (상세 화면용)
///
/// Copied from [canvasNode].
class CanvasNodeFamily extends Family<NodeModel?> {
  /// 특정 노드 조회 (상세 화면용)
  ///
  /// Copied from [canvasNode].
  const CanvasNodeFamily();

  /// 특정 노드 조회 (상세 화면용)
  ///
  /// Copied from [canvasNode].
  CanvasNodeProvider call(String id) {
    return CanvasNodeProvider(id);
  }

  @override
  CanvasNodeProvider getProviderOverride(
    covariant CanvasNodeProvider provider,
  ) {
    return call(provider.id);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'canvasNodeProvider';
}

/// 특정 노드 조회 (상세 화면용)
///
/// Copied from [canvasNode].
class CanvasNodeProvider extends AutoDisposeProvider<NodeModel?> {
  /// 특정 노드 조회 (상세 화면용)
  ///
  /// Copied from [canvasNode].
  CanvasNodeProvider(String id)
    : this._internal(
        (ref) => canvasNode(ref as CanvasNodeRef, id),
        from: canvasNodeProvider,
        name: r'canvasNodeProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$canvasNodeHash,
        dependencies: CanvasNodeFamily._dependencies,
        allTransitiveDependencies: CanvasNodeFamily._allTransitiveDependencies,
        id: id,
      );

  CanvasNodeProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final String id;

  @override
  Override overrideWith(NodeModel? Function(CanvasNodeRef provider) create) {
    return ProviderOverride(
      origin: this,
      override: CanvasNodeProvider._internal(
        (ref) => create(ref as CanvasNodeRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<NodeModel?> createElement() {
    return _CanvasNodeProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CanvasNodeProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CanvasNodeRef on AutoDisposeProviderRef<NodeModel?> {
  /// The parameter `id` of this provider.
  String get id;
}

class _CanvasNodeProviderElement extends AutoDisposeProviderElement<NodeModel?>
    with CanvasNodeRef {
  _CanvasNodeProviderElement(super.provider);

  @override
  String get id => (origin as CanvasNodeProvider).id;
}

String _$canvasNotifierHash() => r'6c931c71aa773f8fb912942009faf15ac0744078';

/// See also [CanvasNotifier].
@ProviderFor(CanvasNotifier)
final canvasNotifierProvider =
    AutoDisposeNotifierProvider<CanvasNotifier, CanvasState>.internal(
      CanvasNotifier.new,
      name: r'canvasNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$canvasNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CanvasNotifier = AutoDisposeNotifier<CanvasState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
