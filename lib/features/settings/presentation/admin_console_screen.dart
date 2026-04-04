/// 관리자 콘솔 화면
/// - 요금제 오버라이드
/// - 더미 데이터 생성/삭제
/// - 배지 전체 획득/초기화
/// - DB 통계
library;

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/env_config.dart';
import 'package:http/http.dart' as http;
import '../../../core/database/tables/settings_table.dart';
import '../../../design/glass/app_glass.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../design/tokens/app_radius.dart';
import '../../../design/tokens/app_spacing.dart';
import '../../../shared/models/user_plan.dart';
import '../../../shared/repositories/db_provider.dart';
import '../../../shared/repositories/node_repository.dart';
import '../../../shared/repositories/settings_repository.dart';
import '../../../shared/widgets/section_label.dart';
import '../../badges/models/badge_definition.dart';
import '../../tree_growth/providers/tree_growth_notifier.dart';
import '../../../shared/repositories/memory_repository.dart';
import '../services/dummy_family_generator.dart';
import '../services/dummy_memory_generator.dart';

class AdminConsoleScreen extends ConsumerStatefulWidget {
  const AdminConsoleScreen({super.key});

  @override
  ConsumerState<AdminConsoleScreen> createState() => _AdminConsoleScreenState();
}

class _AdminConsoleScreenState extends ConsumerState<AdminConsoleScreen> {
  bool _generating = false;
  String? _genStatus;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgBase,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios,
              color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Admin Console',
          style: TextStyle(
            color: AppColors.accent,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        children: [
          // 경고 배너
          _WarningBanner(),
          const SizedBox(height: AppSpacing.xl),

          // 접속 통계
          _AccessStatsSection(),
          const SizedBox(height: AppSpacing.xl),

          // 요금제 오버라이드
          _PlanOverrideSection(),
          const SizedBox(height: AppSpacing.xl),

          // 더미 노드 데이터
          _DummyDataSection(
            generating: _generating,
            status: _genStatus,
            onGenerate: _generateDummy,
            onClear: _clearDummy,
          ),
          const SizedBox(height: AppSpacing.xl),

          // 더미 기억 데이터
          _DummyMemorySection(
            generating: _generating,
            status: _genStatus,
            onGenerate: _generateDummyMemories,
            onClear: _clearDummyMemories,
          ),
          const SizedBox(height: AppSpacing.xl),

          // 배지 관리
          _BadgeSection(),
          const SizedBox(height: AppSpacing.xl),

          // 나무 성장 상태
          _TreeGrowthSection(),
          const SizedBox(height: AppSpacing.xl),

          // 사용자 플랜 부여
          _GrantPlanSection(),
          const SizedBox(height: AppSpacing.xl),

          // DB 통계
          _DbStatsSection(),
          const SizedBox(height: AppSpacing.xl),

          // 관리자 모드 비활성화
          _DisableAdminSection(),
          const SizedBox(height: AppSpacing.xxxl),
        ],
      ),
    );
  }

  // ── 더미 데이터 생성 ────────────────────────────────────────────────────

  Future<void> _generateDummy() async {
    setState(() {
      _generating = true;
      _genStatus = '가족 트리 생성 중...';
    });

    try {
      final repo = ref.read(nodeRepositoryProvider);
      final settings = ref.read(settingsRepositoryProvider);
      final generator = DummyFamilyGenerator();
      final data = generator.generate();

      // 노드 생성
      final nodeIds = <int, String>{}; // index → actual ID
      for (int i = 0; i < data.nodes.length; i++) {
        if (!mounted) return;
        setState(() => _genStatus = '노드 생성 ${i + 1}/${data.nodes.length}');

        final n = data.nodes[i];
        final node = await repo.create(
          name: n.name,
          bio: n.bio,
          birthDate: n.birthDate,
          deathDate: n.deathDate,
          isGhost: n.isGhost,
          temperature: n.temperature,
          positionX: n.positionX,
          positionY: n.positionY,
          tags: n.tags,
        );
        nodeIds[i] = node.id;
      }

      // 엣지 생성
      setState(() => _genStatus = '관계 연결 중...');
      for (final e in data.edges) {
        final fromId = nodeIds[e.fromIndex];
        final toId = nodeIds[e.toIndex];
        if (fromId != null && toId != null) {
          await repo.addEdge(
            fromNodeId: fromId,
            toNodeId: toId,
            relation: e.relation,
          );
        }
      }

      await settings.set(SettingsKey.adminDummyGenerated, 'true');

      // 나무 성장 provider 갱신
      ref.invalidate(treeGrowthNotifierProvider);

      if (!mounted) return;
      setState(() {
        _generating = false;
        _genStatus = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${data.nodes.length}개 노드, ${data.edges.length}개 관계 생성 완료'),
          backgroundColor: AppColors.primary,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _generating = false;
        _genStatus = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('에러: $e'), backgroundColor: AppColors.accent),
      );
    }
  }

  // ── 더미 기억 생성 ────────────────────────────────────────────────────

  Future<void> _generateDummyMemories() async {
    setState(() {
      _generating = true;
      _genStatus = '기억 데이터 생성 중...';
    });

    try {
      final nodeRepo = ref.read(nodeRepositoryProvider);
      final memRepo = ref.read(memoryRepositoryProvider);

      // 기존 노드 목록 가져오기 (기억을 배분할 대상)
      final allNodes = await nodeRepo.getAll();
      if (allNodes.isEmpty) {
        if (!mounted) return;
        setState(() { _generating = false; _genStatus = null; });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('노드가 없습니다. 먼저 더미 노드를 생성하세요.'),
            backgroundColor: AppColors.accent,
          ),
        );
        return;
      }

      final generator = DummyMemoryGenerator();
      final memories = generator.generate();

      for (int i = 0; i < memories.length; i++) {
        if (!mounted) return;
        if (i % 20 == 0) {
          setState(() => _genStatus = '기억 생성 ${i + 1}/${memories.length}');
        }

        final m = memories[i];
        // 노드에 라운드로빈 배분
        final targetNode = allNodes[i % allNodes.length];
        await memRepo.create(
          nodeId: targetNode.id,
          type: m.type,
          title: m.title,
          description: m.description,
          durationSeconds: m.durationSeconds,
          dateTaken: m.dateTaken,
          tags: m.tags,
        );
      }

      // 나무 성장 provider 갱신
      ref.invalidate(treeGrowthNotifierProvider);

      if (!mounted) return;
      setState(() { _generating = false; _genStatus = null; });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${memories.length}개 기억 생성 완료 (사진50+음성50+이야기50+메모50)'),
          backgroundColor: AppColors.primary,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() { _generating = false; _genStatus = null; });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('에러: $e'), backgroundColor: AppColors.accent),
      );
    }
  }

  Future<void> _clearDummyMemories() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgBase,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('더미 기억 삭제',
            style: TextStyle(color: AppColors.textPrimary)),
        content: Text('__ADMIN_DUMMY__ 태그가 있는 모든 기억을 삭제합니다.',
            style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('취소', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('삭제', style: TextStyle(color: AppColors.accent)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() {
      _generating = true;
      _genStatus = '더미 기억 삭제 중...';
    });

    try {
      final memRepo = ref.read(memoryRepositoryProvider);
      final deleted = await memRepo.deleteDummyMemories();

      // 나무 성장 provider 갱신
      ref.invalidate(treeGrowthNotifierProvider);

      if (!mounted) return;
      setState(() { _generating = false; _genStatus = null; });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$deleted개 더미 기억 삭제 완료'),
          backgroundColor: AppColors.primary,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() { _generating = false; _genStatus = null; });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('에러: $e'), backgroundColor: AppColors.accent),
      );
    }
  }

  Future<void> _clearDummy() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgBase,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('더미 데이터 삭제',
            style: TextStyle(color: AppColors.textPrimary)),
        content: Text('__ADMIN_DUMMY__ 태그가 있는 모든 노드를 삭제합니다.',
            style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('취소', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('삭제', style: TextStyle(color: AppColors.accent)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() {
      _generating = true;
      _genStatus = '더미 데이터 삭제 중...';
    });

    try {
      final db = ref.read(appDatabaseProvider);
      final repo = ref.read(nodeRepositoryProvider);
      final settings = ref.read(settingsRepositoryProvider);

      // __ADMIN_DUMMY__ 태그가 있는 노드 찾기
      final allNodes = await repo.getAll();
      int deleted = 0;
      for (final node in allNodes) {
        if (node.tags.contains('__ADMIN_DUMMY__')) {
          await db.deleteNode(node.id);
          deleted++;
        }
      }

      await settings.set(SettingsKey.adminDummyGenerated, 'false');

      // 나무 성장 provider 갱신
      ref.invalidate(treeGrowthNotifierProvider);

      if (!mounted) return;
      setState(() {
        _generating = false;
        _genStatus = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$deleted개 더미 노드 삭제 완료'),
          backgroundColor: AppColors.primary,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _generating = false;
        _genStatus = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('에러: $e'), backgroundColor: AppColors.accent),
      );
    }
  }
}

// ── 경고 배너 ──────────────────────────────────────────────────────────────

class _WarningBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.accent.withAlpha(20),
        border: Border.all(color: AppColors.accent.withAlpha(80), width: 1),
        borderRadius: AppRadius.radiusMd,
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: AppColors.accent, size: 24),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'DEVELOPER ONLY\n테스트 목적으로만 사용하세요.',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.accent,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── 접속 통계 섹션 ──────────────────────────────────────────────────────────

class _AccessStatsSection extends ConsumerStatefulWidget {
  @override
  ConsumerState<_AccessStatsSection> createState() =>
      _AccessStatsSectionState();
}

class _AccessStatsSectionState extends ConsumerState<_AccessStatsSection> {
  bool _loading = true;
  String? _error;
  int _today = 0;
  int _thisWeek = 0;
  int _thisMonth = 0;
  int _totalUnique = 0;
  int _totalRegistered = 0;
  int _planFree = 0;
  int _planPlus = 0;
  int _planFamily = 0;
  int _planFamilyPlus = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      const adminSecret =
          String.fromEnvironment('ADMIN_SECRET', defaultValue: '');
      final response = await http.get(
        Uri.parse('${EnvConfig.workersBaseUrl}/admin/stats'),
        headers: {'X-Admin-Secret': adminSecret},
      ).timeout(const Duration(seconds: 10));
      if (!mounted) return;
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final data = body['data'] as Map<String, dynamic>;
        setState(() {
          _today = (data['today'] as num?)?.toInt() ?? 0;
          _thisWeek = (data['this_week'] as num?)?.toInt() ?? 0;
          _thisMonth = (data['this_month'] as num?)?.toInt() ?? 0;
          _totalUnique = (data['total_unique'] as num?)?.toInt() ?? 0;
          _totalRegistered = (data['total_registered'] as num?)?.toInt() ?? 0;
          _planFree = (data['plan_free'] as num?)?.toInt() ?? 0;
          _planPlus = (data['plan_plus'] as num?)?.toInt() ?? 0;
          _planFamily = (data['plan_family'] as num?)?.toInt() ?? 0;
          _planFamilyPlus = (data['plan_family_plus'] as num?)?.toInt() ?? 0;
          _loading = false;
        });
      } else {
        setState(() {
          _error = 'HTTP ${response.statusCode}';
          _loading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '$e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(child: SectionLabel(label: '접속 통계')),
            if (!_loading)
              GestureDetector(
                onTap: _loadStats,
                child: Icon(Icons.refresh, color: AppColors.primary, size: 20),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        GlassCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: _loading
              ? Center(
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppColors.primary))
              : _error != null
                  ? Text(
                      '오류: $_error',
                      style:
                          TextStyle(fontSize: 13, color: AppColors.accent),
                    )
                  : Column(
                      children: [
                        _StatRow('오늘 접속', '$_today명'),
                        _StatRow('이번 주', '$_thisWeek명'),
                        _StatRow('이번 달', '$_thisMonth명'),
                        _StatRow('누적 접속', '$_totalUnique명'),
                        _StatRow('총 가입자', '$_totalRegistered명'),
                        const Divider(height: 16),
                        _StatRow('무료', '$_planFree명'),
                        _StatRow('플러스', '$_planPlus명'),
                        _StatRow('패밀리', '$_planFamily명'),
                        _StatRow('패밀리플러스', '$_planFamilyPlus명'),
                      ],
                    ),
        ),
      ],
    );
  }
}

// ── 요금제 오버라이드 섹션 ─────────────────────────────────────────────────

class _PlanOverrideSection extends ConsumerStatefulWidget {
  @override
  ConsumerState<_PlanOverrideSection> createState() =>
      _PlanOverrideSectionState();
}

class _PlanOverrideSectionState extends ConsumerState<_PlanOverrideSection> {
  UserPlan? _currentPlan;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPlan();
  }

  Future<void> _loadPlan() async {
    final plan = await ref.read(settingsRepositoryProvider).getUserPlan();
    if (!mounted) return;
    setState(() {
      _currentPlan = plan;
      _loading = false;
    });
  }

  Future<void> _setPlan(UserPlan plan) async {
    await ref.read(settingsRepositoryProvider).setUserPlan(plan);
    if (!mounted) return;
    setState(() => _currentPlan = plan);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('요금제 → ${plan.displayName} 변경됨 (재시작 시 완전 반영)'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionLabel(label: '요금제 오버라이드'),
        const SizedBox(height: AppSpacing.sm),
        GlassCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: _loading
              ? Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '현재: ${_currentPlan?.displayName ?? "?"} (${_currentPlan?.price ?? "?"})',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: UserPlan.values.map((plan) {
                        final isActive = _currentPlan == plan;
                        return GlassButton(
                          onPressed: isActive ? null : () => _setPlan(plan),
                          backgroundColor: isActive
                              ? AppColors.primary.withAlpha(40)
                              : null,
                          child: Text(
                            plan.displayName,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight:
                                  isActive ? FontWeight.w700 : FontWeight.w500,
                              color: isActive
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}

// ── 더미 데이터 섹션 ──────────────────────────────────────────────────────

class _DummyDataSection extends StatelessWidget {
  const _DummyDataSection({
    required this.generating,
    required this.status,
    required this.onGenerate,
    required this.onClear,
  });

  final bool generating;
  final String? status;
  final VoidCallback onGenerate;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionLabel(label: '더미 데이터'),
        const SizedBox(height: AppSpacing.sm),
        GlassCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '50개 한국 가족 노드 + 관계를 자동 생성합니다.\n'
                '5세대 구조 (증조부모→조부모→부모→나/형제→자녀)',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              if (generating) ...[
                LinearProgressIndicator(
                  backgroundColor: AppColors.glassBorder,
                  valueColor: AlwaysStoppedAnimation(AppColors.primary),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  status ?? '처리 중...',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ] else
                Row(
                  children: [
                    Expanded(
                      child: GlassButton(
                        onPressed: onGenerate,
                        backgroundColor: AppColors.primary.withAlpha(20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_circle_outline,
                                color: AppColors.primary, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              '50개 생성',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: GlassButton(
                        onPressed: onClear,
                        backgroundColor: AppColors.accent.withAlpha(20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.delete_outline,
                                color: AppColors.accent, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              '더미 삭제',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.accent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── 더미 기억 섹션 ────────────────────────────────────────────────────────

class _DummyMemorySection extends StatelessWidget {
  const _DummyMemorySection({
    required this.generating,
    required this.status,
    required this.onGenerate,
    required this.onClear,
  });

  final bool generating;
  final String? status;
  final VoidCallback onGenerate;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionLabel(label: '더미 기억 데이터'),
        const SizedBox(height: AppSpacing.sm),
        GlassCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '기존 노드에 기억을 자동 배분합니다.\n'
                '사진 50 + 음성 50 + 이야기 50 + 메모 50 = 200개',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              if (generating) ...[
                LinearProgressIndicator(
                  backgroundColor: AppColors.glassBorder,
                  valueColor: AlwaysStoppedAnimation(AppColors.secondary),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  status ?? '처리 중...',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ] else
                Row(
                  children: [
                    Expanded(
                      child: GlassButton(
                        onPressed: onGenerate,
                        backgroundColor: AppColors.secondary.withAlpha(20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.auto_stories,
                                color: AppColors.secondary, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              '200개 생성',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.secondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: GlassButton(
                        onPressed: onClear,
                        backgroundColor: AppColors.accent.withAlpha(20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.delete_outline,
                                color: AppColors.accent, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              '기억 삭제',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.accent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── 배지 관리 섹션 ────────────────────────────────────────────────────────

class _BadgeSection extends ConsumerStatefulWidget {
  @override
  ConsumerState<_BadgeSection> createState() => _BadgeSectionState();
}

class _BadgeSectionState extends ConsumerState<_BadgeSection> {
  int _earned = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCount();
  }

  Future<void> _loadCount() async {
    final settings = ref.read(settingsRepositoryProvider);
    final str = await settings.get(SettingsKey.earnedBadges) ?? '';
    if (!mounted) return;
    setState(() {
      _earned = str.isEmpty ? 0 : str.split(',').length;
      _loading = false;
    });
  }

  Future<void> _awardAll() async {
    final settings = ref.read(settingsRepositoryProvider);
    final allIds = BadgeDefinition.values.map((b) => b.id).join(',');
    await settings.set(SettingsKey.earnedBadges, allIds);
    await settings.set(SettingsKey.adminAllBadges, 'true');
    if (!mounted) return;
    setState(() => _earned = BadgeDefinition.values.length);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${BadgeDefinition.values.length}개 배지 전체 획득!'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Future<void> _revokeAll() async {
    final settings = ref.read(settingsRepositoryProvider);
    await settings.set(SettingsKey.earnedBadges, '');
    await settings.set(SettingsKey.adminAllBadges, 'false');
    if (!mounted) return;
    setState(() => _earned = 0);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('모든 배지 초기화'),
        backgroundColor: AppColors.accent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionLabel(label: '배지 관리'),
        const SizedBox(height: AppSpacing.sm),
        GlassCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: _loading
              ? Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '획득: $_earned / ${BadgeDefinition.values.length}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: GlassButton(
                            onPressed: _awardAll,
                            backgroundColor: AppColors.primary.withAlpha(20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.emoji_events,
                                    color: AppColors.primary, size: 18),
                                const SizedBox(width: 6),
                                Text(
                                  '전체 획득',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: GlassButton(
                            onPressed: _revokeAll,
                            backgroundColor: AppColors.accent.withAlpha(20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.restart_alt,
                                    color: AppColors.accent, size: 18),
                                const SizedBox(width: 6),
                                Text(
                                  '전체 초기화',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.accent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}

// ── DB 통계 섹션 ──────────────────────────────────────────────────────────

class _DbStatsSection extends ConsumerStatefulWidget {
  @override
  ConsumerState<_DbStatsSection> createState() => _DbStatsSectionState();
}

class _DbStatsSectionState extends ConsumerState<_DbStatsSection> {
  Map<String, int>? _stats;
  int _edgeCount = 0;
  int _ghostCount = 0;
  int _photoCount = 0;
  int _voiceCount = 0;
  int _noteCount = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final db = ref.read(appDatabaseProvider);
    final stats = await db.getStats();
    final ghosts = await db.ghostNodeCount();
    final photos = await db.memoryCountByType('photo');
    final voices = await db.memoryCountByType('voice');
    final notes = await db.memoryCountByType('note');

    // 엣지 수
    final edges = await db.select(db.nodeEdgesTable).get();

    if (!mounted) return;
    setState(() {
      _stats = stats;
      _edgeCount = edges.length;
      _ghostCount = ghosts;
      _photoCount = photos;
      _voiceCount = voices;
      _noteCount = notes;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(child: SectionLabel(label: 'DB 통계')),
            if (!_loading)
              GestureDetector(
                onTap: () {
                  setState(() => _loading = true);
                  _loadStats();
                },
                child: Icon(Icons.refresh, color: AppColors.primary, size: 20),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        GlassCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: _loading
              ? Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))
              : Column(
                  children: [
                    _StatRow('노드', '${_stats?['nodes'] ?? 0}개'),
                    _StatRow('  └ Ghost', '$_ghostCount개'),
                    _StatRow('관계(엣지)', '$_edgeCount개'),
                    _StatRow('기억', '${_stats?['memories'] ?? 0}개'),
                    _StatRow('  └ 사진', '$_photoCount개'),
                    _StatRow('  └ 음성', '$_voiceCount개'),
                    _StatRow('  └ 메모', '$_noteCount개'),
                  ],
                ),
        ),
      ],
    );
  }
}

// ── 사용자 플랜 부여 ──────────────────────────────────────────────────────

class _GrantPlanSection extends ConsumerStatefulWidget {
  const _GrantPlanSection();

  @override
  ConsumerState<_GrantPlanSection> createState() => _GrantPlanSectionState();
}

class _GrantPlanSectionState extends ConsumerState<_GrantPlanSection> {
  final _emailCtrl = TextEditingController();
  UserPlan _selectedPlan = UserPlan.family;
  int _durationDays = 30;
  bool _isLoading = false;
  String? _result;
  List<Map<String, dynamic>> _searchResults = [];

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _searchUser() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) return;
    setState(() => _isLoading = true);
    try {
      const adminSecret = String.fromEnvironment('ADMIN_SECRET', defaultValue: '');
      final response = await http.get(
        Uri.parse('${EnvConfig.workersBaseUrl}/admin/search-user?email=${Uri.encodeComponent(email)}'),
        headers: {
          'X-Admin-Secret': adminSecret,
        },
      ).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final data = body['data'] as Map<String, dynamic>;
        final users = (data['users'] as List).cast<Map<String, dynamic>>();
        setState(() {
          _searchResults = users;
          _result = '${users.length}명 검색됨';
        });
      } else {
        setState(() => _result = '검색 실패: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => _result = '오류: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _grantPlan(String email) async {
    setState(() => _isLoading = true);
    try {
      const adminSecret = String.fromEnvironment('ADMIN_SECRET', defaultValue: '');
      final planName = _selectedPlan == UserPlan.familyPlus
          ? 'family_plus'
          : _selectedPlan.name;
      final response = await http.post(
        Uri.parse('${EnvConfig.workersBaseUrl}/admin/grant-plan'),
        headers: {
          'Content-Type': 'application/json',
          'X-Admin-Secret': adminSecret,
        },
        body: jsonEncode({
          'email': email,
          'plan': planName,
          'duration_days': _durationDays,
        }),
      ).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final data = body['data'] as Map<String, dynamic>;
        setState(() => _result =
            '✅ ${data['email']} → ${data['new_plan']} (${data['duration_days']}일, ~${data['expires_at']})');
      } else {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        setState(() => _result = '❌ ${body['message'] ?? response.statusCode}');
      }
    } catch (e) {
      setState(() => _result = '오류: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionLabel(label: '사용자 플랜 부여'),
        const SizedBox(height: AppSpacing.sm),
        // 이메일 검색
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _emailCtrl,
                decoration: InputDecoration(
                  hintText: '이메일 검색',
                  hintStyle: TextStyle(color: AppColors.textTertiary),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(borderRadius: AppRadius.radiusMd),
                ),
                style: TextStyle(fontSize: 14, color: AppColors.textPrimary),
                onSubmitted: (_) => _searchUser(),
              ),
            ),
            const SizedBox(width: 8),
            GlassButton(
              onPressed: _isLoading ? null : _searchUser,
              child: _isLoading
                  ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))
                  : Icon(Icons.search, size: 20, color: AppColors.primary),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        // 검색 결과
        if (_searchResults.isNotEmpty) ...[
          ..._searchResults.map((u) => GlassCard(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${u['email']}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                Text('플랜: ${u['plan']} · ${u['storage_used_mb']}MB 사용', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                if (u['plan_expires_at'] != null)
                  Text('만료: ${u['plan_expires_at']}', style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                const SizedBox(height: 8),
                // 플랜 선택 + 기간 + 부여 버튼
                Row(
                  children: [
                    // 플랜 선택
                    DropdownButton<UserPlan>(
                      value: _selectedPlan,
                      dropdownColor: AppColors.bgSurface,
                      style: TextStyle(fontSize: 12, color: AppColors.textPrimary),
                      items: UserPlan.values.map((p) => DropdownMenuItem(
                        value: p,
                        child: Text(p.displayName),
                      )).toList(),
                      onChanged: (p) => setState(() => _selectedPlan = p ?? UserPlan.family),
                    ),
                    const SizedBox(width: 8),
                    // 기간 선택
                    DropdownButton<int>(
                      value: _durationDays,
                      dropdownColor: AppColors.bgSurface,
                      style: TextStyle(fontSize: 12, color: AppColors.textPrimary),
                      items: const [
                        DropdownMenuItem(value: 7, child: Text('7일')),
                        DropdownMenuItem(value: 30, child: Text('30일')),
                        DropdownMenuItem(value: 90, child: Text('90일')),
                        DropdownMenuItem(value: 365, child: Text('1년')),
                      ],
                      onChanged: (d) => setState(() => _durationDays = d ?? 30),
                    ),
                    const Spacer(),
                    // 부여 버튼
                    ElevatedButton(
                      onPressed: _isLoading ? null : () => _grantPlan(u['email'] as String),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      ),
                      child: Text('부여', style: TextStyle(fontSize: 12, color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          )),
        ],

        // 결과 메시지
        if (_result != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(_result!, style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ],
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
          Text(value,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}

// ── 나무 성장 상태 섹션 ──────────────────────────────────────────────────

class _TreeGrowthSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(treeGrowthNotifierProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(child: SectionLabel(label: '나무 성장 상태')),
            GestureDetector(
              onTap: () => ref.invalidate(treeGrowthNotifierProvider),
              child: Icon(Icons.refresh, color: AppColors.primary, size: 20),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        GlassCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: asyncState.when(
            data: (state) => Column(
              children: [
                _StatRow('성장 점수', '${state.score}점'),
                _StatRow('성장 단계', state.stage.name),
                _StatRow('계절', state.season.name),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'sprout(≤10) → sapling(≤30) → smallTree(≤80) → bigTree(≤200) → grandTree(>200)',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textTertiary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
            loading: () =>
                Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary)),
            error: (e, _) => Text(
              '에러: $e',
              style: TextStyle(fontSize: 13, color: AppColors.accent),
            ),
          ),
        ),
      ],
    );
  }
}

// ── 관리자 모드 비활성화 ──────────────────────────────────────────────────

class _DisableAdminSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionLabel(label: '관리자 모드'),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          width: double.infinity,
          child: GlassButton(
            onPressed: () async {
              final settings = ref.read(settingsRepositoryProvider);
              await settings.set(SettingsKey.adminModeEnabled, 'false');
              if (!context.mounted) return;
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('관리자 모드 비활성화됨'),
                  backgroundColor: AppColors.textSecondary,
                ),
              );
            },
            backgroundColor: AppColors.accent.withAlpha(15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.power_settings_new,
                    color: AppColors.accent, size: 18),
                const SizedBox(width: 6),
                Text(
                  '관리자 모드 끄기',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accent,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
