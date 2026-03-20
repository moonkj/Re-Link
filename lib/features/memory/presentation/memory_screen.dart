import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/privacy/privacy_service.dart';
import '../../../design/glass/app_glass.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../design/tokens/app_radius.dart';
import '../../../design/tokens/app_spacing.dart';
import '../../../shared/models/memory_model.dart';
import '../../../shared/models/user_plan.dart';
import '../../../shared/repositories/settings_repository.dart';
import '../../../shared/widgets/private_blur_overlay.dart';
import '../providers/memory_notifier.dart';
import '../widgets/add_memory_sheet.dart';
import '../widgets/memory_detail_sheet.dart';

/// 인물별 기억 목록 화면
class MemoryScreen extends ConsumerStatefulWidget {
  const MemoryScreen({super.key, required this.nodeId, required this.nodeName});
  final String nodeId;
  final String nodeName;

  @override
  ConsumerState<MemoryScreen> createState() => _MemoryScreenState();
}

class _MemoryScreenState extends ConsumerState<MemoryScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;

  static const _tabs = [
    (label: '전체', type: null),
    (label: '사진', type: MemoryType.photo),
    (label: '음성', type: MemoryType.voice),
    (label: '메모', type: MemoryType.note),
  ];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final memoriesAsync = ref.watch(memoriesForNodeProvider(widget.nodeId));

    return Scaffold(
      backgroundColor: AppColors.bgBase,
      body: Stack(
        children: [
          // 배경
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topCenter,
                radius: 1.2,
                colors: [AppColors.bgSurface, AppColors.bgBase],
              ),
            ),
          ),

          // 본문
          Column(
            children: [
              // 앱바
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.sm, AppSpacing.sm, AppSpacing.md, 0,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
                      ),
                      Expanded(
                        child: Text(
                          '${widget.nodeName}의 기억',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      memoriesAsync.when(
                        data: (memories) => Text(
                          '${memories.length}개',
                          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                        loading: () => const SizedBox.shrink(),
                        error: (e, s) => const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              ),

              // 탭바
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg, vertical: AppSpacing.sm,
                ),
                child: GlassCard(
                  padding: const EdgeInsets.all(4),
                  child: TabBar(
                    controller: _tabCtrl,
                    indicator: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    labelColor: Colors.white,
                    unselectedLabelColor: AppColors.textSecondary,
                    labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    unselectedLabelStyle: const TextStyle(fontSize: 13),
                    tabs: _tabs.map((t) => Tab(text: t.label)).toList(),
                  ),
                ),
              ),

              // 기억 목록
              Expanded(
                child: memoriesAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                  error: (e, _) => Center(
                    child: Text('오류: $e', style: const TextStyle(color: AppColors.error)),
                  ),
                  data: (memories) => TabBarView(
                    controller: _tabCtrl,
                    children: _tabs.map((t) {
                      final filtered = t.type == null
                          ? memories
                          : memories.where((m) => m.type == t.type).toList();
                      return _MemoryTabContent(
                        memories: filtered,
                        filterType: t.type,
                        onTap: (m) => _openDetail(m),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),

          // FAB
          Positioned(
            bottom: AppSpacing.xxl,
            right: AppSpacing.lg,
            child: GestureDetector(
              onTap: _showAddSheet,
              child: Container(
                width: AppSpacing.fabSize,
                height: AppSpacing.fabSize,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFF6EC6CA), Color(0xFF4A9EBF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x4D6EC6CA),
                      blurRadius: 20,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 28),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openDetail(MemoryModel memory) async {
    if (memory.isPrivate) {
      final privacy = ref.read(privacyServiceProvider);
      final enabled = await privacy.isEnabled();
      if (!mounted) return;
      if (enabled) {
        final authed = await privacy.authenticate();
        if (!mounted) return;
        if (!authed) return;
      }
    }
    if (!mounted) return;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MemoryDetailSheet(memory: memory),
    );
  }

  Future<void> _showAddSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddMemorySheet(nodeId: widget.nodeId),
    );
  }
}

// ── 탭별 콘텐츠 ──────────────────────────────────────────────────────────────

class _MemoryTabContent extends StatelessWidget {
  const _MemoryTabContent({
    required this.memories,
    required this.filterType,
    required this.onTap,
  });

  final List<MemoryModel> memories;
  final MemoryType? filterType;
  final void Function(MemoryModel) onTap;

  @override
  Widget build(BuildContext context) {
    if (memories.isEmpty) {
      return _EmptyState(type: filterType);
    }

    if (filterType == MemoryType.photo) {
      return _PhotoGrid(memories: memories, onTap: onTap);
    }

    // 전체 탭: 사진은 그리드 묶음, 나머지는 리스트
    if (filterType == null) {
      return _MixedList(memories: memories, onTap: onTap);
    }

    // 음성 탭 → 사용량 표시 + 리스트
    if (filterType == MemoryType.voice) {
      return Column(
        children: [
          _VoiceUsageBanner(),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, 100),
              itemCount: memories.length,
              separatorBuilder: (i, s) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (_, i) => _MemoryListTile(memory: memories[i], onTap: () => onTap(memories[i])),
            ),
          ),
        ],
      );
    }

    // 메모 탭 → 리스트
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, 100),
      itemCount: memories.length,
      separatorBuilder: (i, s) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (_, i) => _MemoryListTile(memory: memories[i], onTap: () => onTap(memories[i])),
    );
  }
}

// ── 사진 그리드 ──────────────────────────────────────────────────────────────

class _PhotoGrid extends StatelessWidget {
  const _PhotoGrid({required this.memories, required this.onTap});
  final List<MemoryModel> memories;
  final void Function(MemoryModel) onTap;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: memories.length,
      itemBuilder: (_, i) {
        final m = memories[i];
        final photoWidget = Hero(
          tag: 'photo_${m.id}',
          child: ClipRRect(
            borderRadius: AppRadius.radiusSm,
            child: m.thumbnailPath != null
                ? Image.file(File(m.thumbnailPath!), fit: BoxFit.cover)
                : Container(
                    color: AppColors.glassSurface,
                    child: Icon(Icons.photo_outlined, color: AppColors.textTertiary),
                  ),
          ),
        );

        if (m.isPrivate) {
          return PrivateBlurOverlay(
            onTap: () => onTap(m),
            borderRadius: AppRadius.radiusSm,
            showMessage: false,
            iconSize: 18,
            child: m.thumbnailPath != null
                ? Image.file(File(m.thumbnailPath!), fit: BoxFit.cover)
                : Container(
                    color: AppColors.glassSurface,
                    child: Icon(Icons.photo_outlined, color: AppColors.textTertiary),
                  ),
          );
        }

        return GestureDetector(
          onTap: () => onTap(m),
          child: photoWidget,
        );
      },
    );
  }
}

// ── 혼합 목록 (전체 탭) ───────────────────────────────────────────────────────

class _MixedList extends StatelessWidget {
  const _MixedList({required this.memories, required this.onTap});
  final List<MemoryModel> memories;
  final void Function(MemoryModel) onTap;

  @override
  Widget build(BuildContext context) {
    // 사진 묶음을 찾아 그리드로, 나머지는 리스트로
    final List<Widget> items = [];
    final photos = memories.where((m) => m.type == MemoryType.photo).toList();
    final others = memories.where((m) => m.type != MemoryType.photo).toList();

    if (photos.isNotEmpty) {
      items.add(Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
          ),
          itemCount: photos.length,
          itemBuilder: (_, i) {
            final m = photos[i];

            if (m.isPrivate) {
              return PrivateBlurOverlay(
                onTap: () => onTap(m),
                borderRadius: AppRadius.radiusSm,
                showMessage: false,
                iconSize: 18,
                child: m.thumbnailPath != null
                    ? Image.file(File(m.thumbnailPath!), fit: BoxFit.cover)
                    : Container(
                        color: AppColors.glassSurface,
                        child: Icon(Icons.photo_outlined, color: AppColors.textTertiary),
                      ),
              );
            }

            return GestureDetector(
              onTap: () => onTap(m),
              child: Hero(
                tag: 'photo_${m.id}',
                child: ClipRRect(
                  borderRadius: AppRadius.radiusSm,
                  child: m.thumbnailPath != null
                      ? Image.file(File(m.thumbnailPath!), fit: BoxFit.cover)
                      : Container(
                          color: AppColors.glassSurface,
                          child: Icon(Icons.photo_outlined, color: AppColors.textTertiary),
                        ),
                ),
              ),
            );
          },
        ),
      ));
    }

    for (final m in others) {
      items.add(Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: _MemoryListTile(memory: m, onTap: () => onTap(m)),
      ));
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, 100),
      children: items,
    );
  }
}

// ── 리스트 타일 ──────────────────────────────────────────────────────────────

class _MemoryListTile extends StatelessWidget {
  const _MemoryListTile({required this.memory, required this.onTap});
  final MemoryModel memory;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isVoice = memory.type == MemoryType.voice;
    final color = isVoice ? AppColors.accent : AppColors.primary;

    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withAlpha(30),
            ),
            child: Icon(
              memory.isPrivate
                  ? Icons.lock_rounded
                  : (isVoice ? Icons.mic_rounded : Icons.notes_rounded),
              color: memory.isPrivate ? AppColors.accent : color,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        memory.isPrivate
                            ? '비공개 ${memory.type.label}'
                            : (memory.title ?? memory.type.label),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: memory.isPrivate
                              ? AppColors.textTertiary
                              : AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (memory.isPrivate) ...[
                      const SizedBox(width: 4),
                      Icon(Icons.lock, size: 12, color: AppColors.textTertiary),
                    ],
                  ],
                ),
                if (!memory.isPrivate) ...[
                  if (isVoice && memory.formattedDuration != null)
                    Text(memory.formattedDuration!, style: TextStyle(fontSize: 12, color: AppColors.textSecondary))
                  else if (!isVoice && memory.description != null)
                    Text(
                      memory.description!,
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ] else
                  Text(
                    '탭하여 인증 후 열기',
                    style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
                  ),
              ],
            ),
          ),
          Text(
            _formatDate(memory.createdAt),
            style: TextStyle(fontSize: 11, color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) => '${dt.month}/${dt.day}';
}

// ── 음성 사용량 배너 ─────────────────────────────────────────────────────────

class _VoiceUsageBanner extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usedAsync = ref.watch(totalVoiceMinutesProvider);
    final planAsync = ref.watch(
      settingsRepositoryProvider.select((r) => r.getUserPlan()),
    );

    return FutureBuilder<UserPlan>(
      future: planAsync,
      builder: (context, planSnap) {
        final plan = planSnap.data ?? UserPlan.free;
        if (!plan.hasVoice) return const SizedBox.shrink();

        return usedAsync.when(
          data: (used) {
            final max = plan.maxVoiceMinutes;
            final ratio = (used / max).clamp(0.0, 1.0);
            final isWarning = ratio >= 0.8;

            return Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, 0),
              child: GlassCard(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.mic_outlined,
                            size: 14,
                            color: isWarning ? AppColors.accent : AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          '음성 $used분 / $max분 사용',
                          style: TextStyle(
                            fontSize: 12,
                            color: isWarning ? AppColors.accent : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: AppRadius.radiusXs,
                      child: LinearProgressIndicator(
                        value: ratio,
                        minHeight: 6,
                        backgroundColor: AppColors.glassSurface,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isWarning ? AppColors.accent : AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (e, s) => const SizedBox.shrink(),
        );
      },
    );
  }
}

// ── 빈 상태 ──────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({this.type});
  final MemoryType? type;

  @override
  Widget build(BuildContext context) {
    final (icon, msg) = switch (type) {
      MemoryType.photo => (Icons.photo_library_outlined, '사진 기억이 없습니다'),
      MemoryType.voice => (Icons.mic_none_outlined, '음성 기억이 없습니다'),
      MemoryType.note => (Icons.notes_outlined, '메모 기억이 없습니다'),
      null => (Icons.memory_outlined, '기억이 없습니다\n+ 버튼으로 추가해 보세요'),
    };
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 56, color: AppColors.textTertiary),
          const SizedBox(height: AppSpacing.md),
          Text(msg, style: TextStyle(fontSize: 14, color: AppColors.textTertiary), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
