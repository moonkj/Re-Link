import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/haptic_service.dart';
import '../../../design/glass/app_glass.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../design/tokens/app_spacing.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../models/clan_data.dart';
import '../providers/clan_explorer_notifier.dart';
import '../widgets/clan_art_card.dart';
import '../widgets/clan_share_card.dart';

/// K-4 한국 성씨 클랜 탐색기
class ClanExplorerScreen extends ConsumerStatefulWidget {
  const ClanExplorerScreen({super.key});

  @override
  ConsumerState<ClanExplorerScreen> createState() =>
      _ClanExplorerScreenState();
}

class _ClanExplorerScreenState extends ConsumerState<ClanExplorerScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  /// 현재 펼쳐진 성씨 인덱스 (null이면 모두 접힘)
  int? _expandedIndex;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() {
      _query = value.trim();
      _expandedIndex = null; // 검색 시 펼침 초기화
    });
  }

  void _clearSearch() {
    _searchCtrl.clear();
    _onSearchChanged('');
  }

  void _toggleExpand(int index) {
    HapticService.light();
    setState(() {
      _expandedIndex = _expandedIndex == index ? null : index;
    });
  }

  void _showShareSheet(ClanInfo clan, String surname) {
    HapticService.medium();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => GlassBottomSheet(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pagePadding,
          AppSpacing.lg,
          AppSpacing.pagePadding,
          AppSpacing.xxxl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 드래그 핸들
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: AppSpacing.lg),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: AppColors.textTertiary,
              ),
            ),
            ClanShareCard(clan: clan, surname: surname),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  void _showArtCardSheet(ClanInfo clan, String surname) {
    HapticService.medium();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => GlassBottomSheet(
          padding: EdgeInsets.zero,
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.pagePadding,
              AppSpacing.lg,
              AppSpacing.pagePadding,
              AppSpacing.xxxl,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 드래그 핸들
                Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: AppColors.textTertiary,
                  ),
                ),
                // 타이틀
                Text(
                  '아트 카드 만들기',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '스타일을 선택하고 공유하세요',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                ClanArtCard(clan: clan, surname: surname),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final clansAsync = ref.watch(clanExplorerNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.bgBase,
      appBar: AppBar(
        title: Text(
          '성씨 탐색기',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new,
              color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          // ── 검색 바 ──────────────────────────────────────────
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
                  Icon(Icons.search,
                      size: 20, color: AppColors.textTertiary),
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
                        hintText: '성씨, 본관, 인물 검색',
                        hintStyle:
                            TextStyle(color: AppColors.textTertiary),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.sm),
                      ),
                    ),
                  ),
                  if (_searchCtrl.text.isNotEmpty)
                    GestureDetector(
                      onTap: _clearSearch,
                      child: Icon(Icons.close,
                          size: 18, color: AppColors.textTertiary),
                    ),
                ],
              ),
            ),
          ),

          // ── 콘텐츠 ──────────────────────────────────────────
          Expanded(
            child: clansAsync.when(
              data: (allClans) {
                final filtered = _query.isEmpty
                    ? allClans
                    : ref
                        .read(clanExplorerNotifierProvider.notifier)
                        .search(_query);
                return _buildContent(filtered);
              },
              loading: () => Center(
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
              ),
              error: (e, _) => Center(
                child: Text(
                  '데이터 로드 실패: $e',
                  style: TextStyle(color: AppColors.error),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(List<ClanSurname> clans) {
    if (clans.isEmpty) {
      if (_query.isNotEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.search_off,
                  size: 48, color: AppColors.textTertiary),
              const SizedBox(height: AppSpacing.lg),
              Text(
                '검색 결과가 없어요',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                '다른 성씨나 본관으로 검색해보세요',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        );
      }
      return const EmptyStateWidget(
        icon: Icons.family_restroom,
        title: '성씨 데이터 없음',
        subtitle: '성씨 데이터를 불러올 수 없습니다.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pagePadding,
        AppSpacing.sm,
        AppSpacing.pagePadding,
        AppSpacing.massive,
      ),
      itemCount: clans.length + (_query.isEmpty ? 1 : 0),
      itemBuilder: (context, index) {
        // CTA 배너 (검색이 비어있을 때만)
        if (_query.isEmpty && index == 0) {
          return _buildCtaBanner();
        }
        final clanIndex = _query.isEmpty ? index - 1 : index;
        final surname = clans[clanIndex];
        final isExpanded = _expandedIndex == clanIndex;
        return _ClanSurnameCard(
          surname: surname,
          isExpanded: isExpanded,
          onToggle: () => _toggleExpand(clanIndex),
          onShare: (clan) => _showShareSheet(clan, surname.surname),
          onArtCard: (clan) => _showArtCardSheet(clan, surname.surname),
        );
      },
    );
  }

  Widget _buildCtaBanner() {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: GlassCard(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AppColors.primaryMint, AppColors.primaryBlue],
                ),
              ),
              child: const Icon(
                Icons.family_restroom,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '나의 성씨 찾기',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '성씨와 본관을 검색하여 가문의 역사를 알아보세요',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios,
                size: 14, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}

// ── 성씨 카드 (Expandable) ──────────────────────────────────────────────────

class _ClanSurnameCard extends StatelessWidget {
  const _ClanSurnameCard({
    required this.surname,
    required this.isExpanded,
    required this.onToggle,
    required this.onShare,
    required this.onArtCard,
  });

  final ClanSurname surname;
  final bool isExpanded;
  final VoidCallback onToggle;
  final ValueChanged<ClanInfo> onShare;
  final ValueChanged<ClanInfo> onArtCard;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: GlassCard(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            // 헤더 (탭하여 펼치기/접기)
            InkWell(
              onTap: onToggle,
              borderRadius: BorderRadius.circular(28),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    // 성씨 (큰 글씨)
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withAlpha(25),
                        border: Border.all(
                          color: AppColors.primary.withAlpha(60),
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          surname.surname,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                '${surname.surname}씨',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Text(
                                surname.romanized,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textTertiary,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${surname.clans.length}개 본관',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.expand_more,
                        color: AppColors.textTertiary,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 펼쳐진 본관 목록
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: _buildClanList(),
              crossFadeState: isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 250),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClanList() {
    return Column(
      children: [
        Divider(color: AppColors.glassBorder, height: 1),
        ...surname.clans.map((clan) => _ClanDetail(
              clan: clan,
              surname: surname.surname,
              onShare: () => onShare(clan),
              onArtCard: () => onArtCard(clan),
            )),
      ],
    );
  }
}

// ── 본관 상세 ───────────────────────────────────────────────────────────────

class _ClanDetail extends StatelessWidget {
  const _ClanDetail({
    required this.clan,
    required this.surname,
    required this.onShare,
    required this.onArtCard,
  });

  final ClanInfo clan;
  final String surname;
  final VoidCallback onShare;
  final VoidCallback onArtCard;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 본관 이름 + 인구 배지
          Row(
            children: [
              Icon(Icons.location_on_outlined,
                  size: 16, color: AppColors.secondary),
              const SizedBox(width: AppSpacing.xs),
              Text(
                '${clan.origin} $surname씨',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: AppColors.secondary.withAlpha(25),
                ),
                child: Text(
                  clan.populationFormatted,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.secondary,
                  ),
                ),
              ),
              const Spacer(),
              // 공유 버튼
              GestureDetector(
                onTap: onShare,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.glassSurface,
                  ),
                  child: Icon(Icons.share_outlined,
                      size: 16, color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // 시조 + 설립
          Row(
            children: [
              Text(
                '시조: ${clan.founder}',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              if (clan.foundedYearFormatted != null) ...[
                const SizedBox(width: AppSpacing.md),
                Text(
                  '(${clan.foundedYearFormatted})',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // 설명
          Text(
            clan.description,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // 유명 인물 칩
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: clan.famousPeople
                .map((person) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: AppColors.primary.withAlpha(15),
                        border: Border.all(
                          color: AppColors.primary.withAlpha(40),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        person,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ))
                .toList(),
          ),

          const SizedBox(height: AppSpacing.md),

          // 아트 카드 만들기 버튼
          GestureDetector(
            onTap: onArtCard,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryMint.withAlpha(30),
                    AppColors.primaryBlue.withAlpha(30),
                  ],
                ),
                border: Border.all(
                  color: AppColors.primary.withAlpha(50),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.palette_outlined,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    '아트 카드 만들기',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
