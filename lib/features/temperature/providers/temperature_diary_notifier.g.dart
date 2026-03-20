// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'temperature_diary_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$temperatureLogsForNodeHash() =>
    r'ce71b0bbd871d08778983c9fc527a4c6cad4032a';

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

/// 노드별 온도 로그 스트림
///
/// Copied from [temperatureLogsForNode].
@ProviderFor(temperatureLogsForNode)
const temperatureLogsForNodeProvider = TemperatureLogsForNodeFamily();

/// 노드별 온도 로그 스트림
///
/// Copied from [temperatureLogsForNode].
class TemperatureLogsForNodeFamily
    extends Family<AsyncValue<List<TemperatureLog>>> {
  /// 노드별 온도 로그 스트림
  ///
  /// Copied from [temperatureLogsForNode].
  const TemperatureLogsForNodeFamily();

  /// 노드별 온도 로그 스트림
  ///
  /// Copied from [temperatureLogsForNode].
  TemperatureLogsForNodeProvider call(String nodeId) {
    return TemperatureLogsForNodeProvider(nodeId);
  }

  @override
  TemperatureLogsForNodeProvider getProviderOverride(
    covariant TemperatureLogsForNodeProvider provider,
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
  String? get name => r'temperatureLogsForNodeProvider';
}

/// 노드별 온도 로그 스트림
///
/// Copied from [temperatureLogsForNode].
class TemperatureLogsForNodeProvider
    extends AutoDisposeStreamProvider<List<TemperatureLog>> {
  /// 노드별 온도 로그 스트림
  ///
  /// Copied from [temperatureLogsForNode].
  TemperatureLogsForNodeProvider(String nodeId)
    : this._internal(
        (ref) =>
            temperatureLogsForNode(ref as TemperatureLogsForNodeRef, nodeId),
        from: temperatureLogsForNodeProvider,
        name: r'temperatureLogsForNodeProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$temperatureLogsForNodeHash,
        dependencies: TemperatureLogsForNodeFamily._dependencies,
        allTransitiveDependencies:
            TemperatureLogsForNodeFamily._allTransitiveDependencies,
        nodeId: nodeId,
      );

  TemperatureLogsForNodeProvider._internal(
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
    Stream<List<TemperatureLog>> Function(TemperatureLogsForNodeRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TemperatureLogsForNodeProvider._internal(
        (ref) => create(ref as TemperatureLogsForNodeRef),
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
  AutoDisposeStreamProviderElement<List<TemperatureLog>> createElement() {
    return _TemperatureLogsForNodeProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TemperatureLogsForNodeProvider && other.nodeId == nodeId;
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
mixin TemperatureLogsForNodeRef
    on AutoDisposeStreamProviderRef<List<TemperatureLog>> {
  /// The parameter `nodeId` of this provider.
  String get nodeId;
}

class _TemperatureLogsForNodeProviderElement
    extends AutoDisposeStreamProviderElement<List<TemperatureLog>>
    with TemperatureLogsForNodeRef {
  _TemperatureLogsForNodeProviderElement(super.provider);

  @override
  String get nodeId => (origin as TemperatureLogsForNodeProvider).nodeId;
}

String _$temperatureDiaryNotifierHash() =>
    r'08da5bee1b85caa733874954a473fd1985289cad';

/// 온도 일기 CRUD 오퍼레이션
///
/// Copied from [TemperatureDiaryNotifier].
@ProviderFor(TemperatureDiaryNotifier)
final temperatureDiaryNotifierProvider =
    AutoDisposeNotifierProvider<
      TemperatureDiaryNotifier,
      AsyncValue<void>
    >.internal(
      TemperatureDiaryNotifier.new,
      name: r'temperatureDiaryNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$temperatureDiaryNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$TemperatureDiaryNotifier = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
