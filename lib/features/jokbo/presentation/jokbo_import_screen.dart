import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/haptic_service.dart';
import '../../../design/glass/app_glass.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../design/tokens/app_spacing.dart';
import '../providers/jokbo_import_notifier.dart';
import '../widgets/generation_input_step.dart';

/// 족보 가져오기 마법사 화면
///
/// Step 0: 세대 수 선택 (1~8)
/// Step 1~N: 각 세대별 인물 입력
/// Step N+1: 미리보기 + 가져오기 실행
class JokboImportScreen extends ConsumerStatefulWidget {
  const JokboImportScreen({super.key});

  @override
  ConsumerState<JokboImportScreen> createState() => _JokboImportScreenState();
}

class _JokboImportScreenState extends ConsumerState<JokboImportScreen> {
  /// 0 = 세대 수 선택, 1~N = 세대 입력, N+1 = 미리보기
  int _wizardStep = 0;
  bool _isCommitting = false;

  @override
  Widget build(BuildContext context) {
    final jokboState = ref.watch(jokboImportNotifierProvider);
    final maxGen = jokboState.maxGeneration;

    // 총 스텝: 1(세대선택) + maxGen(각 세대) + 1(미리보기) = maxGen + 2
    final totalSteps = maxGen + 2;

    return Scaffold(
      backgroundColor: AppColors.bgBase,
      appBar: AppBar(
        title: Text(
          '족보 가져오기',
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
          icon: Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () {
            if (_wizardStep == 0) {
              context.pop();
            } else {
              _showExitDialog();
            }
          },
        ),
        actions: [
          if (jokboState.totalCount > 0)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.md),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(20),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    '${jokboState.totalCount}명',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // 진행률 표시
          _buildProgressBar(totalSteps),

          // 본문
          Expanded(
            child: _buildStepContent(jokboState),
          ),

          // 하단 네비게이션 버튼
          _buildBottomNav(jokboState),
        ],
      ),
    );
  }

  Widget _buildProgressBar(int totalSteps) {
    final progress = (_wizardStep + 1) / totalSteps;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _stepLabel,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              Text(
                '${_wizardStep + 1} / $totalSteps',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              backgroundColor: AppColors.glassSurface,
              valueColor: AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
      ],
    );
  }

  String get _stepLabel {
    final jokboState = ref.read(jokboImportNotifierProvider);
    if (_wizardStep == 0) return '세대 수 선택';
    if (_wizardStep <= jokboState.maxGeneration) return '$_wizardStep세대 입력';
    return '미리보기';
  }

  Widget _buildStepContent(JokboImportState jokboState) {
    if (_wizardStep == 0) {
      return _buildGenerationPicker(jokboState);
    } else if (_wizardStep <= jokboState.maxGeneration) {
      return GenerationInputStep(
        key: ValueKey('gen_$_wizardStep'),
        generation: _wizardStep,
      );
    } else {
      return _buildPreview(jokboState);
    }
  }

  // ── Step 0: 세대 수 선택 ─────────────────────────────────────────────────

  Widget _buildGenerationPicker(JokboImportState jokboState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.xl),
          // 아이콘
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AppColors.primaryMint, AppColors.primaryBlue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Icon(
                Icons.account_tree_outlined,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Center(
            child: Text(
              '몇 세대를 기록할까요?',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Center(
            child: Text(
              '1세대가 가장 윗세대 (조상)입니다\n나중에 더 추가할 수 있어요',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxxl),

          // 세대 수 슬라이더
          GlassCard(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              children: [
                Text(
                  '${jokboState.maxGeneration}세대',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: AppColors.primary,
                    inactiveTrackColor: AppColors.glassSurface,
                    thumbColor: AppColors.primary,
                    overlayColor: AppColors.primary.withAlpha(30),
                    trackHeight: 4,
                  ),
                  child: Slider(
                    value: jokboState.maxGeneration.toDouble(),
                    min: 1,
                    max: 8,
                    divisions: 7,
                    label: '${jokboState.maxGeneration}세대',
                    onChanged: (v) {
                      HapticService.selection();
                      ref
                          .read(jokboImportNotifierProvider.notifier)
                          .setMaxGeneration(v.round());
                    },
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '1세대',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textTertiary,
                        ),
                      ),
                      Text(
                        '8세대',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // 세대별 가이드
          GlassCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '세대 가이드',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                _buildGuideRow('1~2세대', '부모 + 나'),
                _buildGuideRow('3~4세대', '조부모까지'),
                _buildGuideRow('5~6세대', '증조부모까지'),
                _buildGuideRow('7~8세대', '고조부모 이상'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideRow(String gen, String desc) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            gen,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            desc,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ── Preview Step ─────────────────────────────────────────────────────────

  Widget _buildPreview(JokboImportState jokboState) {
    // 세대별 그룹
    final genGroups = <int, List<JokboEntry>>{};
    for (final e in jokboState.entries) {
      genGroups.putIfAbsent(e.generation, () => []).add(e);
    }
    final sortedGens = genGroups.keys.toList()..sort();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 요약 헤더
          Center(
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.success.withAlpha(20),
                  ),
                  child: const Icon(
                    Icons.check_circle_outline,
                    color: AppColors.success,
                    size: 36,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  '총 ${jokboState.totalCount}명 추가 예정',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${jokboState.maxGeneration}세대 가족이 캔버스에 배치됩니다',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // 세대별 목록
          ...sortedGens.map((gen) {
            final members = genGroups[gen]!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(20),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          '$gen세대',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        '${members.length}명',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                GlassCard(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    children: members.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Icon(
                              entry.gender == '남'
                                  ? Icons.man
                                  : entry.gender == '여'
                                      ? Icons.woman
                                      : Icons.person_outline,
                              size: 18,
                              color: entry.gender == '남'
                                  ? AppColors.primaryBlue
                                  : entry.gender == '여'
                                      ? AppColors.accent
                                      : AppColors.textSecondary,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              entry.name,
                              style: TextStyle(
                                fontSize: 15,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
            );
          }),

          if (jokboState.totalCount == 0)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xxxl),
                child: Column(
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 48,
                      color: AppColors.textDisabled,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      '아직 추가된 인물이 없습니다\n이전 단계에서 가족을 추가하세요',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
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

  // ── 하단 네비게이션 ─────────────────────────────────────────────────────

  Widget _buildBottomNav(JokboImportState jokboState) {
    final isPreview = _wizardStep > jokboState.maxGeneration;
    final hasEntries = jokboState.totalCount > 0;

    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.pagePadding,
        right: AppSpacing.pagePadding,
        bottom: MediaQuery.of(context).padding.bottom + AppSpacing.lg,
        top: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.glassBorder, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          // 이전 버튼
          if (_wizardStep > 0)
            Expanded(
              child: GlassButton(
                onPressed: _goBack,
                child: Text(
                  '이전',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          if (_wizardStep > 0) const SizedBox(width: AppSpacing.md),

          // 다음 / 가져오기 버튼
          Expanded(
            flex: _wizardStep > 0 ? 2 : 1,
            child: isPreview
                ? PrimaryGlassButton(
                    label: _isCommitting ? '가져오는 중...' : '가져오기',
                    isLoading: _isCommitting,
                    onPressed: hasEntries ? _commitJokbo : null,
                  )
                : PrimaryGlassButton(
                    label: '다음',
                    onPressed: _goNext,
                  ),
          ),
        ],
      ),
    );
  }

  void _goNext() {
    HapticService.light();
    setState(() {
      _wizardStep++;
    });
    // 세대 입력 시작이면 notifier에도 currentGeneration 동기화
    final maxGen = ref.read(jokboImportNotifierProvider).maxGeneration;
    if (_wizardStep >= 1 && _wizardStep <= maxGen) {
      // 세대 입력 단계
    }
  }

  void _goBack() {
    HapticService.light();
    setState(() {
      if (_wizardStep > 0) _wizardStep--;
    });
  }

  Future<void> _commitJokbo() async {
    final jokboState = ref.read(jokboImportNotifierProvider);
    if (jokboState.totalCount == 0) return;

    setState(() => _isCommitting = true);

    try {
      final count = await ref
          .read(jokboImportNotifierProvider.notifier)
          .commitToDatabase();

      if (!mounted) return;

      HapticService.celebration();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$count명의 가족이 캔버스에 추가되었습니다'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 3),
        ),
      );

      // 캔버스로 돌아가기
      if (mounted) {
        context.go(AppRoutes.canvas);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isCommitting = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('오류가 발생했습니다: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _showExitDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          '족보 가져오기 취소',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          '입력한 내용이 모두 사라집니다.\n정말 나가시겠어요?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              '계속 입력',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(jokboImportNotifierProvider.notifier).reset();
              if (mounted) context.pop();
            },
            child: const Text(
              '나가기',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
