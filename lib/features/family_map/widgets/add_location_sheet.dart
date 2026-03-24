import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/haptic_service.dart';
import '../../../design/glass/app_glass.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../design/tokens/app_spacing.dart';
import '../../../shared/models/node_model.dart';
import '../../../shared/repositories/node_repository.dart';
import '../data/korean_locations.dart';
import '../providers/family_map_notifier.dart';

/// 위치 추가 바텀시트
class AddLocationSheet extends ConsumerStatefulWidget {
  const AddLocationSheet({super.key});

  @override
  ConsumerState<AddLocationSheet> createState() => _AddLocationSheetState();
}

class _AddLocationSheetState extends ConsumerState<AddLocationSheet> {
  final _searchCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _startYearCtrl = TextEditingController();
  final _endYearCtrl = TextEditingController();
  final _searchFocusNode = FocusNode();

  String? _selectedNodeId;
  double? _lat;
  double? _lng;
  bool _saving = false;
  KoreanLocation? _selectedLocation;
  List<NodeModel> _nodes = [];

  @override
  void initState() {
    super.initState();
    _loadNodes();
  }

  Future<void> _loadNodes() async {
    final nodes = await ref.read(nodeRepositoryProvider).getAll();
    if (!mounted) return;
    setState(() => _nodes = nodes);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _addressCtrl.dispose();
    _startYearCtrl.dispose();
    _endYearCtrl.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _selectLocation(KoreanLocation location) {
    HapticService.light();
    setState(() {
      _selectedLocation = location;
      _searchCtrl.text = location.name;
      _lat = location.lat;
      _lng = location.lng;
    });
    _searchFocusNode.unfocus();
  }

  bool get _isValid =>
      _selectedNodeId != null &&
      _searchCtrl.text.trim().isNotEmpty &&
      _lat != null &&
      _lng != null;

  /// 검색어로 위치 필터링
  List<KoreanLocation> _filterLocations(String query) {
    if (query.isEmpty) return [];
    final q = query.trim().toLowerCase();
    return koreanLocations
        .where((loc) => loc.name.toLowerCase().contains(q))
        .take(8)
        .toList();
  }

  Future<void> _save() async {
    if (!_isValid || _saving) return;
    setState(() => _saving = true);
    HapticService.medium();

    final startYear = int.tryParse(_startYearCtrl.text.trim());
    final endYear = int.tryParse(_endYearCtrl.text.trim());

    // 상세 주소가 있으면 합쳐서 저장
    final detail = _addressCtrl.text.trim();
    final fullAddress = detail.isNotEmpty
        ? '${_searchCtrl.text.trim()} $detail'
        : _searchCtrl.text.trim();

    await ref.read(familyMapNotifierProvider.notifier).addLocation(
          nodeId: _selectedNodeId!,
          address: fullAddress,
          lat: _lat!,
          lng: _lng!,
          startYear: startYear,
          endYear: endYear,
        );

    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return GlassBottomSheet(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 핸들 바
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.glassBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // 제목
            Text(
              '위치 추가',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // ── 가족 구성원 선택 ──────────────────────────────────
            Text(
              '가족 구성원',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: AppColors.glassSurface,
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: DropdownButton<String>(
                value: _selectedNodeId,
                isExpanded: true,
                underline: const SizedBox.shrink(),
                hint: Text(
                  '선택하세요',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.textTertiary,
                  ),
                ),
                dropdownColor: AppColors.bgSurface,
                style: TextStyle(fontSize: 15, color: AppColors.textPrimary),
                items: _nodes
                    .map((n) => DropdownMenuItem(
                          value: n.id,
                          child: Text(n.name),
                        ))
                    .toList(),
                onChanged: (v) {
                  HapticService.selection();
                  setState(() => _selectedNodeId = v);
                },
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // ── 주소 검색 (자동완성) ──────────────────────────────
            Text(
              '주소 검색',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            _AddressAutocomplete(
              controller: _searchCtrl,
              focusNode: _searchFocusNode,
              selectedLocation: _selectedLocation,
              onFilter: _filterLocations,
              onSelected: _selectLocation,
              onCleared: () {
                setState(() {
                  _selectedLocation = null;
                  _lat = null;
                  _lng = null;
                });
              },
            ),
            const SizedBox(height: AppSpacing.xl),

            // ── 상세 주소 (선택) ──────────────────────────────────
            Text(
              '상세 주소 (선택)',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _addressCtrl,
              style: TextStyle(color: AppColors.textPrimary, fontSize: 15),
              decoration: InputDecoration(
                hintText: '예: 흥덕구 대농로 17',
                hintStyle: TextStyle(color: AppColors.textTertiary),
                filled: true,
                fillColor: AppColors.glassSurface,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: AppColors.glassBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.primaryMint),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // ── 연도 범위 (선택) ──────────────────────────────────
            Text(
              '거주 기간 (선택)',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _startYearCtrl,
                    keyboardType: TextInputType.number,
                    style: TextStyle(
                        color: AppColors.textPrimary, fontSize: 15),
                    decoration: InputDecoration(
                      hintText: '시작 연도',
                      hintStyle: TextStyle(color: AppColors.textTertiary),
                      filled: true,
                      fillColor: AppColors.glassSurface,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: AppColors.glassBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide:
                            const BorderSide(color: AppColors.primaryMint),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    '~',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _endYearCtrl,
                    keyboardType: TextInputType.number,
                    style: TextStyle(
                        color: AppColors.textPrimary, fontSize: 15),
                    decoration: InputDecoration(
                      hintText: '종료 연도',
                      hintStyle: TextStyle(color: AppColors.textTertiary),
                      filled: true,
                      fillColor: AppColors.glassSurface,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: AppColors.glassBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide:
                            const BorderSide(color: AppColors.primaryMint),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxl),

            // ── 저장 버튼 ──────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: PrimaryGlassButton(
                label: '저장',
                onPressed: _isValid ? _save : null,
                isLoading: _saving,
              ),
            ),
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
          ],
        ),
      ),
    );
  }
}

/// 주소 검색 자동완성 위젯
class _AddressAutocomplete extends StatefulWidget {
  const _AddressAutocomplete({
    required this.controller,
    required this.focusNode,
    required this.selectedLocation,
    required this.onFilter,
    required this.onSelected,
    required this.onCleared,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final KoreanLocation? selectedLocation;
  final List<KoreanLocation> Function(String query) onFilter;
  final ValueChanged<KoreanLocation> onSelected;
  final VoidCallback onCleared;

  @override
  State<_AddressAutocomplete> createState() => _AddressAutocompleteState();
}

class _AddressAutocompleteState extends State<_AddressAutocomplete> {
  List<KoreanLocation> _suggestions = [];
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
    widget.focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    widget.focusNode.removeListener(_onFocusChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final text = widget.controller.text;
    // 이미 선택한 상태에서 텍스트가 변경되면 선택 해제
    if (widget.selectedLocation != null &&
        text != widget.selectedLocation!.name) {
      widget.onCleared();
    }
    final results = widget.onFilter(text);
    setState(() {
      _suggestions = results;
      _showSuggestions = results.isNotEmpty && widget.focusNode.hasFocus;
    });
  }

  void _onFocusChanged() {
    if (!widget.focusNode.hasFocus) {
      // 약간 딜레이를 줘서 탭 이벤트가 먼저 처리되도록
      Future.delayed(const Duration(milliseconds: 150), () {
        if (mounted) setState(() => _showSuggestions = false);
      });
    } else {
      _onTextChanged();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSelected = widget.selectedLocation != null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          style: TextStyle(color: AppColors.textPrimary, fontSize: 15),
          decoration: InputDecoration(
            hintText: '시/군/구 이름을 입력하세요',
            hintStyle: TextStyle(color: AppColors.textTertiary),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: isSelected
                  ? AppColors.primaryMint
                  : AppColors.textTertiary,
              size: 20,
            ),
            suffixIcon: widget.controller.text.isNotEmpty
                ? GestureDetector(
                    onTap: () {
                      widget.controller.clear();
                      widget.onCleared();
                      widget.focusNode.requestFocus();
                    },
                    child: Icon(
                      Icons.close_rounded,
                      color: AppColors.textTertiary,
                      size: 18,
                    ),
                  )
                : null,
            filled: true,
            fillColor: AppColors.glassSurface,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: isSelected
                    ? AppColors.primaryMint
                    : AppColors.glassBorder,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.primaryMint),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),

        // 선택 완료 표시
        if (isSelected) ...[
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Icon(
                Icons.check_circle_rounded,
                size: 14,
                color: AppColors.primaryMint,
              ),
              const SizedBox(width: 4),
              Text(
                '${widget.selectedLocation!.name} 선택됨',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.primaryMint,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],

        // 검색 결과 드롭다운
        if (_showSuggestions)
          Container(
            margin: const EdgeInsets.only(top: 4),
            constraints: const BoxConstraints(maxHeight: 220),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: AppColors.bgSurface,
              border: Border.all(color: AppColors.glassBorder),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: _suggestions.length,
                separatorBuilder: (_, _) => Divider(
                  height: 1,
                  color: AppColors.glassBorder,
                ),
                itemBuilder: (context, index) {
                  final loc = _suggestions[index];
                  return InkWell(
                    onTap: () => widget.onSelected(loc),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 18,
                            color: AppColors.textTertiary,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            loc.name,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}
