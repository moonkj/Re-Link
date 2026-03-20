import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/haptic_service.dart';
import '../../../design/glass/app_glass.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../design/tokens/app_spacing.dart';
import '../../../shared/models/node_model.dart';
import '../../../shared/repositories/node_repository.dart';
import '../providers/family_map_notifier.dart';

/// 미리 정의된 한국 도시 좌표
class _KoreanCity {
  final String name;
  final double lat;
  final double lng;
  const _KoreanCity(this.name, this.lat, this.lng);
}

const _koreanCities = <_KoreanCity>[
  _KoreanCity('서울', 37.5665, 126.9780),
  _KoreanCity('부산', 35.1796, 129.0756),
  _KoreanCity('대구', 35.8714, 128.6014),
  _KoreanCity('인천', 37.4563, 126.7052),
  _KoreanCity('광주', 35.1595, 126.8526),
  _KoreanCity('대전', 36.3504, 127.3845),
  _KoreanCity('울산', 35.5384, 129.3114),
  _KoreanCity('세종', 36.4800, 127.2890),
  _KoreanCity('제주', 33.4996, 126.5312),
  _KoreanCity('수원', 37.2636, 127.0286),
  _KoreanCity('창원', 35.2270, 128.6811),
  _KoreanCity('전주', 35.8242, 127.1480),
  _KoreanCity('춘천', 37.8813, 127.7300),
  _KoreanCity('포항', 36.0190, 129.3435),
  _KoreanCity('경주', 35.8562, 129.2247),
];

/// 위치 추가 바텀시트
class AddLocationSheet extends ConsumerStatefulWidget {
  const AddLocationSheet({super.key});

  @override
  ConsumerState<AddLocationSheet> createState() => _AddLocationSheetState();
}

class _AddLocationSheetState extends ConsumerState<AddLocationSheet> {
  final _addressCtrl = TextEditingController();
  final _startYearCtrl = TextEditingController();
  final _endYearCtrl = TextEditingController();

  String? _selectedNodeId;
  double? _lat;
  double? _lng;
  bool _saving = false;
  _KoreanCity? _selectedCity;
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
    _addressCtrl.dispose();
    _startYearCtrl.dispose();
    _endYearCtrl.dispose();
    super.dispose();
  }

  void _selectCity(_KoreanCity city) {
    HapticService.light();
    setState(() {
      _selectedCity = city;
      _addressCtrl.text = city.name;
      _lat = city.lat;
      _lng = city.lng;
    });
  }

  bool get _isValid =>
      _selectedNodeId != null &&
      _addressCtrl.text.trim().isNotEmpty &&
      _lat != null &&
      _lng != null;

  Future<void> _save() async {
    if (!_isValid || _saving) return;
    setState(() => _saving = true);
    HapticService.medium();

    final startYear = int.tryParse(_startYearCtrl.text.trim());
    final endYear = int.tryParse(_endYearCtrl.text.trim());

    await ref.read(familyMapNotifierProvider.notifier).addLocation(
          nodeId: _selectedNodeId!,
          address: _addressCtrl.text.trim(),
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

            // ── 가족 구성원 선택 ──────────────────────────────────────────────────
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

            // ── 빠른 선택: 한국 주요 도시 ────────────────────────────────────────
            Text(
              '도시 빠른 선택',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: _koreanCities.map((city) {
                final isSelected = _selectedCity == city;
                return GestureDetector(
                  onTap: () => _selectCity(city),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: isSelected
                          ? AppColors.primaryMint.withAlpha(30)
                          : AppColors.glassSurface,
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primaryMint
                            : AppColors.glassBorder,
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      city.name,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: isSelected
                            ? AppColors.primaryMint
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.xl),

            // ── 주소 직접 입력 ─────────────────────────────────────────────────
            Text(
              '주소 (상세)',
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
                hintText: '예: 서울 종로구, 부산 해운대',
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

            // ── 연도 범위 (선택) ──────────────────────────────────────────────
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

            // ── 저장 버튼 ─────────────────────────────────────────────────────
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
