import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart';
import '../../../core/utils/haptic_service.dart';
import '../../../design/glass/app_glass.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../design/tokens/app_spacing.dart';
import '../../../shared/repositories/node_repository.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../providers/glossary_notifier.dart';
import '../widgets/add_glossary_sheet.dart';
import '../widgets/glossary_card.dart';

/// 가족 단어장 메인 화면
class GlossaryScreen extends ConsumerStatefulWidget {
  const GlossaryScreen({super.key});

  @override
  ConsumerState<GlossaryScreen> createState() => _GlossaryScreenState();
}

class _GlossaryScreenState extends ConsumerState<GlossaryScreen> {
  final _searchCtrl = TextEditingController();
  Timer? _debounce;

  /// 검색 결과 — null이면 전체 목록 모드
  List<GlossaryTableData>? _searchResults;
  bool _isSearching = false;

  // 노드 이름 캐시 (nodeId → name)
  Map<String, String> _nodeNameCache = {};

  @override
  void initState() {
    super.initState();
    _loadNodeNames();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  /// 노드 이름 캐시 로드
  Future<void> _loadNodeNames() async {
    final nodes = await ref.read(nodeRepositoryProvider).getAll();
    if (!mounted) return;
    setState(() {
      _nodeNameCache = {for (final n in nodes) n.id: n.name};
    });
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = null;
        _isSearching = false;
      });
      return;
    }
    setState(() => _isSearching = true);
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      final results =
          await ref.read(glossaryNotifierProvider.notifier).search(query);
      if (!mounted) return;
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    });
  }

  Future<void> _openAddSheet() async {
    HapticService.light();
    final added = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddGlossarySheet(),
    );
    if (added == true) {
      _loadNodeNames(); // 노드 캐시 새로고침
    }
  }

  Future<void> _deleteEntry(String id) async {
    HapticService.medium();
    await ref.read(glossaryNotifierProvider.notifier).delete(id);
  }

  @override
  Widget build(BuildContext context) {
    final glossaryAsync = ref.watch(allGlossaryProvider);

    return Scaffold(
      backgroundColor: AppColors.bgBase,
      appBar: AppBar(
        title: Text(
          '가족 단어장',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new,
              color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddSheet,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          // ── 검색 바 ────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.pagePadding,
              vertical: AppSpacing.sm,
            ),
            child: GlassCard(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.xs,
              ),
              child: Row(
                children: [
                  Icon(Icons.search, size: 20, color: AppColors.textTertiary),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: _onSearchChanged,
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: '표현 또는 뜻 검색',
                        hintStyle: TextStyle(color: AppColors.textTertiary),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                      ),
                    ),
                  ),
                  if (_searchCtrl.text.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _searchCtrl.clear();
                        _onSearchChanged('');
                      },
                      child: Icon(Icons.close, size: 18,
                          color: AppColors.textTertiary),
                    ),
                ],
              ),
            ),
          ),

          // ── 콘텐츠 ────────────────────────────────────────────
          Expanded(
            child: _isSearching
                ? const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : _searchResults != null
                    ? _buildList(_searchResults!)
                    : glossaryAsync.when(
                        data: (entries) => _buildList(entries),
                        loading: () => const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        error: (e, _) => Center(
                          child: Text(
                            '불러오기 실패: $e',
                            style: TextStyle(color: AppColors.error),
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<GlossaryTableData> entries) {
    if (entries.isEmpty) {
      // 검색 결과가 비어있는 경우 vs 전체가 빈 경우
      if (_searchResults != null) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.search_off, size: 48,
                  color: AppColors.textTertiary),
              const SizedBox(height: AppSpacing.lg),
              Text(
                '검색 결과가 없어요',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        );
      }
      return EmptyStateWidget(
        icon: Icons.menu_book_outlined,
        title: '아직 등록된 가족 표현이 없어요',
        subtitle: '외할머니가 부르던 나의 어릴 적 별명을\n기록해보세요',
        actionLabel: '첫 표현 등록',
        onAction: _openAddSheet,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pagePadding,
        AppSpacing.sm,
        AppSpacing.pagePadding,
        AppSpacing.massive + AppSpacing.xxxl, // FAB 영역 확보
      ),
      itemCount: entries.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (_, i) {
        final entry = entries[i];
        final nodeName =
            entry.nodeId != null ? _nodeNameCache[entry.nodeId!] : null;
        return GlossaryCard(
          entry: entry,
          nodeName: nodeName,
          onDelete: () => _deleteEntry(entry.id),
        );
      },
    );
  }
}
