import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../design/glass/app_glass.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../design/tokens/app_spacing.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../core/utils/haptic_service.dart';
import '../providers/hyodo_notifier.dart';
import '../widgets/hyodo_gauge.dart';

/// 효도 온도계 대시보드 화면
class HyodoScreen extends ConsumerWidget {
  const HyodoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hyodoAsync = ref.watch(hyodoNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.bgBase,
      appBar: AppBar(
        title: Text(
          '효도 온도계',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          hyodoAsync.whenOrNull(
                data: (state) => state.entries.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.lg),
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.xs,
                            ),
                            decoration: BoxDecoration(
                              color: _badgeColor(state.averageScore)
                                  .withAlpha(30),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '평균 ${state.averageScore.toInt()}점',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _badgeColor(state.averageScore),
                              ),
                            ),
                          ),
                        ),
                      )
                    : null,
              ) ??
              const SizedBox.shrink(),
        ],
      ),
      body: hyodoAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(
            '데이터를 불러오지 못했습니다',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
        data: (state) {
          if (state.entries.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.thermostat_outlined,
              title: '효도 온도를 측정할 대상이 없어요',
              subtitle: '가족을 추가하고 기억을 기록하면\n효도 온도가 올라갑니다',
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              HapticService.light();
              await ref.read(hyodoNotifierProvider.notifier).refresh();
            },
            color: AppColors.primary,
            child: ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.pagePadding,
                vertical: AppSpacing.lg,
              ),
              children: [
                // ── 전체 평균 게이지 ──────────────────────────────────────────
                _OverallGaugeSection(state: state),
                const SizedBox(height: AppSpacing.xxl),

                // ── 관심이 필요해요 섹션 ──────────────────────────────────────
                if (state.needsAttention.isNotEmpty) ...[
                  _NeedsAttentionSection(entries: state.needsAttention),
                  const SizedBox(height: AppSpacing.xxl),
                ],

                // ── 전체 목록 ─────────────────────────────────────────────────
                _AllEntriesSection(entries: state.entries),
                const SizedBox(height: AppSpacing.xxxl),
              ],
            ),
          );
        },
      ),
    );
  }

  static Color _badgeColor(double score) {
    if (score < 16) return AppColors.tempIcy;
    if (score < 31) return AppColors.tempCool;
    if (score < 51) return AppColors.tempNeutral;
    if (score < 71) return AppColors.tempWarm;
    if (score < 86) return AppColors.tempHot;
    return AppColors.tempFire;
  }
}

// ── 전체 평균 게이지 섹션 ────────────────────────────────────────────────────

class _OverallGaugeSection extends StatelessWidget {
  const _OverallGaugeSection({required this.state});
  final HyodoState state;

  @override
  Widget build(BuildContext context) {
    final level = _levelFromScore(state.averageScore);
    return GlassCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xxl,
      ),
      child: Column(
        children: [
          Text(
            '전체 효도 온도',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          HyodoGauge(
            score: state.averageScore,
            level: level,
            size: 200,
            showLabel: false,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            _motivationalMessage(state.averageScore),
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  static String _levelFromScore(double score) {
    if (score < 16) return '냉담';
    if (score < 31) return '쌀쌀';
    if (score < 51) return '보통';
    if (score < 71) return '따뜻';
    if (score < 86) return '뜨거움';
    return '열정';
  }

  static String _motivationalMessage(double score) {
    if (score < 16) return '가족에게 안부를 전해볼까요?\n작은 기록이 큰 온기가 됩니다';
    if (score < 31) return '조금만 더 관심을 기울여보세요\n가족이 기다리고 있어요';
    if (score < 51) return '꾸준히 기록하고 계시네요!\n조금만 더 힘내볼까요?';
    if (score < 71) return '따뜻한 마음이 느껴집니다\n이 온기를 이어가세요!';
    if (score < 86) return '대단해요! 가족과 활발히 소통하고 계시네요';
    return '최고의 효도 온도! 가족의 행복이 가득합니다';
  }
}

// ── 관심 필요 섹션 ─────────────────────────────────────────────────────────

class _NeedsAttentionSection extends StatelessWidget {
  const _NeedsAttentionSection({required this.entries});
  final List<HyodoEntry> entries;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.notifications_active_outlined,
                color: AppColors.accent, size: 18),
            const SizedBox(width: AppSpacing.sm),
            Text(
              '관심이 필요해요',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        ...entries.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _NudgeCard(entry: entry),
            )),
      ],
    );
  }
}

class _NudgeCard extends StatelessWidget {
  const _NudgeCard({required this.entry});
  final HyodoEntry entry;

  @override
  Widget build(BuildContext context) {
    final nudge = entry.daysSinceLastRecord >= 999
        ? '${entry.nodeName}님과의 기억이 아직 없어요. 첫 기록을 남겨보세요!'
        : entry.daysSinceLastRecord >= 14
            ? '2주가 지났어요, ${entry.nodeName}님에게 안부를 전해보세요'
            : entry.daysSinceLastRecord >= 7
                ? '한 주가 지났어요, ${entry.nodeName}님에게 안부를 전해보세요'
                : '${entry.nodeName}님과 더 많은 기억을 기록해보세요';

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          // 아바타
          _NodeAvatar(
            photoPath: entry.photoPath,
            name: entry.nodeName,
            size: 44,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        entry.nodeName,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _colorForEntry(entry).withAlpha(30),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${entry.score.toInt()}점',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _colorForEntry(entry),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  nudge,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Color _colorForEntry(HyodoEntry entry) {
    if (entry.score < 16) return AppColors.tempIcy;
    if (entry.score < 31) return AppColors.tempCool;
    return AppColors.tempNeutral;
  }
}

// ── 전체 목록 (2열 그리드) ──────────────────────────────────────────────────

class _AllEntriesSection extends StatelessWidget {
  const _AllEntriesSection({required this.entries});
  final List<HyodoEntry> entries;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '가족별 효도 온도',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: AppSpacing.md,
            crossAxisSpacing: AppSpacing.md,
            childAspectRatio: 0.85,
          ),
          itemCount: entries.length,
          itemBuilder: (context, index) {
            return _EntryCard(entry: entries[index]);
          },
        ),
      ],
    );
  }
}

class _EntryCard extends StatelessWidget {
  const _EntryCard({required this.entry});
  final HyodoEntry entry;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 아바타
          _NodeAvatar(
            photoPath: entry.photoPath,
            name: entry.nodeName,
            size: 36,
          ),
          const SizedBox(height: AppSpacing.sm),
          // 미니 게이지
          HyodoGauge(
            score: entry.score,
            level: entry.level,
            nodeName: entry.nodeName,
            size: 100,
            showLabel: false,
          ),
          const Spacer(),
          // 이름
          Text(
            entry.nodeName,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          // 마지막 기록
          Text(
            entry.daysSinceLastRecord >= 999
                ? '기록 없음'
                : entry.daysSinceLastRecord == 0
                    ? '오늘 기록함'
                    : '${entry.daysSinceLastRecord}일 전',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── 공통 노드 아바타 ──────────────────────────────────────────────────────────

class _NodeAvatar extends StatelessWidget {
  const _NodeAvatar({
    required this.photoPath,
    required this.name,
    this.size = 44,
  });

  final String? photoPath;
  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.glassSurface,
        border: Border.all(color: AppColors.glassBorder, width: 1),
        image: photoPath != null
            ? DecorationImage(
                image: FileImage(File(photoPath!)),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: photoPath == null
          ? Center(
              child: Text(
                name.isNotEmpty ? name[0] : '?',
                style: TextStyle(
                  fontSize: size * 0.4,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            )
          : null,
    );
  }
}
