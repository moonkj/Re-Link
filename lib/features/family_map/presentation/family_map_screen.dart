import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/haptic_service.dart';
import '../../../design/glass/app_glass.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../design/tokens/app_spacing.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../providers/family_map_notifier.dart';
import '../widgets/add_location_sheet.dart';
import '../widgets/korea_map_painter.dart';
import '../widgets/location_card.dart';

/// 가족 지도 화면 — E-5
class FamilyMapScreen extends ConsumerStatefulWidget {
  const FamilyMapScreen({super.key});

  @override
  ConsumerState<FamilyMapScreen> createState() => _FamilyMapScreenState();
}

class _FamilyMapScreenState extends ConsumerState<FamilyMapScreen> {
  String? _selectedPinId;
  int? _yearFilter;
  final _mapKey = GlobalKey();

  // 타임라인 범위
  static const int _minYear = 1950;
  static final int _maxYear = DateTime.now().year;

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
        child: const Icon(Icons.add_location_alt_outlined, color: Colors.white),
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
              // ── 지도 영역 ─────────────────────────────────────────────
              Expanded(
                flex: 5,
                child: _buildMap(pins, isDark),
              ),

              // ── 타임라인 슬라이더 ─────────────────────────────────────
              _buildTimelineSlider(pins),

              // ── 위치 목록 ─────────────────────────────────────────────
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

  /// 지도 영역 (InteractiveViewer + CustomPainter)
  Widget _buildMap(List<MapPin> pins, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: InteractiveViewer(
          clipBehavior: Clip.none,
          constrained: false,
          minScale: 0.8,
          maxScale: 3.0,
          boundaryMargin: const EdgeInsets.all(100),
          child: GestureDetector(
            onTapDown: (details) => _onMapTap(details, pins),
            child: SizedBox(
              key: _mapKey,
              width: 400,
              height: 500,
              child: CustomPaint(
                painter: KoreaMapPainter(
                  pins: pins,
                  isDark: isDark,
                  selectedPinId: _selectedPinId,
                  yearFilter: _yearFilter,
                ),
                size: const Size(400, 500),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 지도 핀 탭 처리
  void _onMapTap(TapDownDetails details, List<MapPin> pins) {
    const mapSize = Size(400, 500);
    final hit = KoreaMapPainter.hitTestPin(
      details.localPosition,
      pins,
      mapSize,
      yearFilter: _yearFilter,
    );
    if (hit != null) {
      HapticService.light();
      setState(() {
        _selectedPinId = _selectedPinId == hit.id ? null : hit.id;
      });
    } else {
      setState(() => _selectedPinId = null);
    }
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
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.textTertiary,
                  ),
                ),
                Text(
                  '$_maxYear',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.textTertiary,
                  ),
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
    final filteredPins = _yearFilter == null
        ? pins
        : pins.where((p) {
            if (p.startYear != null && p.startYear! > _yearFilter!) {
              return false;
            }
            if (p.endYear != null && p.endYear! < _yearFilter!) return false;
            return true;
          }).toList();

    // 노드별 그룹핑
    final grouped = <String, List<MapPin>>{};
    for (final pin in filteredPins) {
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
                  _selectedPinId =
                      _selectedPinId == pin.id ? null : pin.id;
                });
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
