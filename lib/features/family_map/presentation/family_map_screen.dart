import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/utils/haptic_service.dart';
import '../../../design/glass/app_glass.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../design/tokens/app_spacing.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../providers/family_map_notifier.dart';
import '../widgets/add_location_sheet.dart';
import '../widgets/location_card.dart';

/// 가족 지도 화면 — FlutterMap (OpenStreetMap) 기반
class FamilyMapScreen extends ConsumerStatefulWidget {
  const FamilyMapScreen({super.key});

  @override
  ConsumerState<FamilyMapScreen> createState() => _FamilyMapScreenState();
}

class _FamilyMapScreenState extends ConsumerState<FamilyMapScreen> {
  String? _selectedPinId;
  int? _yearFilter;
  final _mapCtrl = MapController();

  // 타임라인 범위
  static const int _minYear = 1950;
  static final int _maxYear = DateTime.now().year;

  // 한국 중심 좌표
  static const _koreaCenter = LatLng(36.5, 127.8);
  static const _defaultZoom = 7.0;

  @override
  Widget build(BuildContext context) {
    final pinsAsync = ref.watch(familyMapPinsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.bgBase,
      appBar: AppBar(
        title: Text(
          '가족 지도',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddSheet,
        backgroundColor: AppColors.primary,
        child: Icon(Icons.add_location_alt_outlined, color: AppColors.onPrimary),
      ),
      body: pinsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primaryMint),
        ),
        error: (e, _) => Center(
          child: Text(
            '오류 발생: $e',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
        data: (pins) {
          if (pins.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.map_outlined,
              title: '가족 지도가 비어있어요',
              subtitle: '가족 구성원이 살았던 곳을 기록하고\n지도 위에서 확인해보세요',
              actionLabel: '위치 추가',
              onAction: _showAddSheet,
            );
          }

          return Column(
            children: [
              // ── 지도 영역 ──────────────────────────────────────────
              Expanded(
                flex: 5,
                child: _buildMap(pins, isDark),
              ),

              // ── 타임라인 슬라이더 ──────────────────────────────────
              _buildTimelineSlider(pins),

              // ── 위치 목록 ──────────────────────────────────────────
              Expanded(
                flex: 4,
                child: _buildLocationList(pins),
              ),
            ],
          );
        },
      ),
    );
  }

  /// 필터 적용된 핀 목록
  List<MapPin> _filteredPins(List<MapPin> pins) {
    if (_yearFilter == null) return pins;
    return pins.where((p) {
      if (p.startYear != null && p.startYear! > _yearFilter!) return false;
      if (p.endYear != null && p.endYear! < _yearFilter!) return false;
      return true;
    }).toList();
  }

  /// FlutterMap 지도 영역
  Widget _buildMap(List<MapPin> pins, bool isDark) {
    final filtered = _filteredPins(pins);

    // 핀이 있으면 핀 중심으로, 없으면 한국 중심
    final center = filtered.isNotEmpty
        ? LatLng(
            filtered.map((p) => p.lat).reduce((a, b) => a + b) / filtered.length,
            filtered.map((p) => p.lng).reduce((a, b) => a + b) / filtered.length,
          )
        : _koreaCenter;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: FlutterMap(
          mapController: _mapCtrl,
          options: MapOptions(
            initialCenter: center,
            initialZoom: _defaultZoom,
            minZoom: 5,
            maxZoom: 18,
            onTap: (_, _) {
              setState(() => _selectedPinId = null);
            },
          ),
          children: [
            // 타일 레이어 (OpenStreetMap)
            TileLayer(
              urlTemplate: isDark
                  ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}@2x.png'
                  : 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}@2x.png',
              subdomains: const ['a', 'b', 'c', 'd'],
              userAgentPackageName: 'com.relink.reLink',
              maxZoom: 19,
            ),
            // 마커 레이어
            MarkerLayer(
              markers: filtered.map((pin) {
                final isSelected = pin.id == _selectedPinId;
                return Marker(
                  point: LatLng(pin.lat, pin.lng),
                  width: isSelected ? 120 : 44,
                  height: isSelected ? 60 : 44,
                  child: GestureDetector(
                    onTap: () {
                      HapticService.light();
                      setState(() {
                        _selectedPinId = _selectedPinId == pin.id ? null : pin.id;
                      });
                    },
                    child: isSelected
                        ? _buildSelectedMarker(pin)
                        : _buildDefaultMarker(pin),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  /// 기본 마커 (원형 아바타)
  Widget _buildDefaultMarker(MapPin pin) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primaryMint,
        border: Border.all(color: Colors.white, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryMint.withAlpha(80),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Text(
          pin.nodeName.isNotEmpty ? pin.nodeName[0] : '?',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  /// 선택된 마커 (이름 라벨 포함)
  Widget _buildSelectedMarker(MapPin pin) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryBlue.withAlpha(100),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            pin.nodeName,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 2),
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primaryBlue,
            border: Border.all(color: Colors.white, width: 2),
          ),
        ),
      ],
    );
  }

  /// 타임라인 슬라이더
  Widget _buildTimelineSlider(List<MapPin> pins) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '타임라인',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    HapticService.selection();
                    setState(() => _yearFilter = null);
                  },
                  child: Text(
                    _yearFilter == null ? '전체' : '$_yearFilter년',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryMint,
                    ),
                  ),
                ),
              ],
            ),
            SliderTheme(
              data: SliderThemeData(
                activeTrackColor: AppColors.primaryMint,
                inactiveTrackColor: AppColors.glassBorder,
                thumbColor: AppColors.primaryMint,
                overlayColor: AppColors.primaryMint.withAlpha(30),
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                trackHeight: 3,
              ),
              child: Slider(
                min: _minYear.toDouble(),
                max: _maxYear.toDouble(),
                divisions: _maxYear - _minYear,
                value: (_yearFilter ?? _maxYear).toDouble(),
                onChanged: (v) {
                  HapticService.selection();
                  setState(() => _yearFilter = v.round());
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$_minYear',
                  style: TextStyle(fontSize: 10, color: AppColors.textTertiary),
                ),
                Text(
                  '$_maxYear',
                  style: TextStyle(fontSize: 10, color: AppColors.textTertiary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 위치 목록
  Widget _buildLocationList(List<MapPin> pins) {
    final filtered = _filteredPins(pins);

    // 노드별 그룹핑
    final grouped = <String, List<MapPin>>{};
    for (final pin in filtered) {
      (grouped[pin.nodeName] ??= []).add(pin);
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      children: [
        for (final entry in grouped.entries) ...[
          Padding(
            padding: const EdgeInsets.only(
              top: AppSpacing.sm,
              bottom: AppSpacing.xs,
            ),
            child: Text(
              entry.key,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          for (final pin in entry.value)
            LocationCard(
              pin: pin,
              isSelected: pin.id == _selectedPinId,
              onTap: () {
                setState(() {
                  _selectedPinId = _selectedPinId == pin.id ? null : pin.id;
                });
                // 선택 시 지도 해당 위치로 이동
                _mapCtrl.move(LatLng(pin.lat, pin.lng), 12);
              },
              onDelete: () => _confirmDelete(pin),
            ),
        ],
        const SizedBox(height: AppSpacing.massive),
      ],
    );
  }

  /// 추가 바텀시트
  void _showAddSheet() {
    HapticService.medium();
    showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: const AddLocationSheet(),
      ),
    );
  }

  /// 삭제 확인
  void _confirmDelete(MapPin pin) {
    HapticService.heavy();
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          '위치 삭제',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          '${pin.nodeName}의 "${pin.address}" 위치를 삭제하시겠습니까?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              '취소',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              '삭제',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true) {
        ref.read(familyMapNotifierProvider.notifier).deleteLocation(pin.id);
        if (_selectedPinId == pin.id) {
          setState(() => _selectedPinId = null);
        }
      }
    });
  }
}
