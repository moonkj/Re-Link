import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../../../core/database/app_database.dart';
import '../../../shared/repositories/db_provider.dart';

part 'family_map_notifier.g.dart';

/// 지도 위 핀 데이터
class MapPin {
  final String id;
  final String nodeId;
  final String nodeName;
  final String? photoPath;
  final String address;
  final double lat;
  final double lng;
  final int? startYear;
  final int? endYear;
  final DateTime createdAt;

  const MapPin({
    required this.id,
    required this.nodeId,
    required this.nodeName,
    this.photoPath,
    required this.address,
    required this.lat,
    required this.lng,
    this.startYear,
    this.endYear,
    required this.createdAt,
  });
}

/// 전체 위치 스트림 — 노드 정보와 조인하여 MapPin 리스트 반환
@riverpod
Stream<List<MapPin>> familyMapPins(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.watchAllLocations().asyncMap((locations) async {
    final pins = <MapPin>[];
    for (final loc in locations) {
      final node = await db.getNode(loc.nodeId);
      pins.add(MapPin(
        id: loc.id,
        nodeId: loc.nodeId,
        nodeName: node?.name ?? '알 수 없음',
        photoPath: node?.photoPath,
        address: loc.address,
        lat: loc.latitude,
        lng: loc.longitude,
        startYear: loc.startYear,
        endYear: loc.endYear,
        createdAt: loc.createdAt,
      ));
    }
    return pins;
  });
}

/// 가족 지도 CRUD 오퍼레이션
@riverpod
class FamilyMapNotifier extends _$FamilyMapNotifier {
  static const _uuid = Uuid();

  @override
  AsyncValue<void> build() => const AsyncData(null);

  AppDatabase get _db => ref.read(appDatabaseProvider);

  /// 위치 추가
  Future<void> addLocation({
    required String nodeId,
    required String address,
    required double lat,
    required double lng,
    int? startYear,
    int? endYear,
  }) async {
    state = const AsyncLoading();
    try {
      final id = _uuid.v4();
      await _db.upsertNodeLocation(
        NodeLocationsTableCompanion.insert(
          id: id,
          nodeId: nodeId,
          address: address,
          latitude: lat,
          longitude: lng,
          startYear: Value(startYear),
          endYear: Value(endYear),
        ),
      );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  /// 위치 삭제
  Future<void> deleteLocation(String id) async {
    state = const AsyncLoading();
    try {
      await _db.deleteNodeLocation(id);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
