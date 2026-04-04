import 'dart:async';
import 'dart:io';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart';
import '../../../core/utils/haptic_service.dart';
import '../../../core/utils/path_utils.dart';
import '../../../design/glass/app_glass.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../design/tokens/app_spacing.dart';
import '../../../shared/models/node_model.dart';
import '../../../shared/repositories/node_repository.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../providers/voice_legacy_notifier.dart';
import '../widgets/record_legacy_sheet.dart';
import '../widgets/voice_legacy_card.dart';

/// 보이스 유언 목록 화면
class VoiceLegacyScreen extends ConsumerWidget {
  const VoiceLegacyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final legaciesAsync = ref.watch(allVoiceLegaciesProvider);

    return Scaffold(
      backgroundColor: AppColors.bgBase,
      appBar: AppBar(
        title: Text(
          '보이스 유언',
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showRecordSheet(context),
        backgroundColor: AppColors.primary,
        child: Icon(Icons.mic, color: AppColors.onPrimary),
      ),
      body: legaciesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(
            '보이스 유언을 불러올 수 없습니다.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
        data: (legacies) {
          if (legacies.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.mic_none_outlined,
              title: '아직 보이스 유언이 없어요',
              subtitle: '소중한 가족에게 전하는\n음성 메시지를 남겨보세요.',
              actionLabel: '첫 유언 녹음하기',
              onAction: () => _showRecordSheet(context),
            );
          }

          return _VoiceLegacyList(legacies: legacies);
        },
      ),
    );
  }

  void _showRecordSheet(BuildContext context) {
    HapticService.light();
    showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const RecordLegacySheet(),
    );
  }
}

/// 보이스 유언 리스트 (노드 이름 해석 포함)
class _VoiceLegacyList extends ConsumerWidget {
  const _VoiceLegacyList({required this.legacies});
  final List<VoiceLegacyTableData> legacies;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 노드 이름을 해석하기 위해 전체 노드 스트림 구독
    final nodesAsync = ref.watch(_allNodesProvider);

    return nodesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const SizedBox.shrink(),
      data: (nodes) {
        final nodeMap = {for (final n in nodes) n.id: n.name};

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pagePadding,
            AppSpacing.lg,
            AppSpacing.pagePadding,
            100, // FAB 아래 여백
          ),
          itemCount: legacies.length,
          separatorBuilder: (_, __) =>
              const SizedBox(height: AppSpacing.md),
          itemBuilder: (context, i) {
            final legacy = legacies[i];
            final fromName = nodeMap[legacy.fromNodeId] ?? '알 수 없음';
            final toName = nodeMap[legacy.toNodeId] ?? '알 수 없음';

            return VoiceLegacyCard(
              legacy: legacy,
              fromName: fromName,
              toName: toName,
              onTap: () =>
                  _onLegacyTap(context, ref, legacy, fromName, toName),
              onLongPress: () =>
                  _confirmDeleteLegacy(context, ref, legacy),
            );
          },
        );
      },
    );
  }

  /// 유언 삭제 확인 (롱프레스 — 봉인 상태에서도 삭제 가능)
  void _confirmDeleteLegacy(
    BuildContext context,
    WidgetRef ref,
    VoiceLegacyTableData legacy,
  ) {
    HapticService.medium();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          '유언 삭제',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          '"${legacy.title}" 유언을 삭제할까요?\n음성 파일도 함께 삭제됩니다.',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('취소',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await ref
                  .read(voiceLegacyNotifierProvider.notifier)
                  .delete(legacy.id);
            },
            child: const Text(
              '삭제',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onLegacyTap(
    BuildContext context,
    WidgetRef ref,
    VoiceLegacyTableData legacy,
    String fromName,
    String toName,
  ) {
    final now = DateTime.now();

    if (legacy.isOpened) {
      // 이미 열린 유언 -> 재생
      _showPlaySheet(context, ref, legacy, fromName, toName);
    } else if (legacy.openCondition == 'manual' ||
        (legacy.openDate != null && !legacy.openDate!.isAfter(now))) {
      // 열 수 있는 유언 -> 열기 확인
      _showOpenConfirm(context, ref, legacy);
    } else {
      // 봉인된 유언 -> 안내 + 삭제 힌트
      HapticService.light();
      final dateStr = legacy.openDate != null
          ? '${legacy.openDate!.year}년 ${legacy.openDate!.month}월 ${legacy.openDate!.day}일에 열 수 있어요.'
          : '수동 공개 조건이 충족되어야 열 수 있어요.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$dateStr\n삭제하려면 길게 누르세요.'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showOpenConfirm(
    BuildContext context,
    WidgetRef ref,
    VoiceLegacyTableData legacy,
  ) {
    HapticService.medium();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgSurface,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.lock_open, color: AppColors.accent, size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '유언을 열까요?',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          '"${legacy.title}" 유언을 열면\n다시 봉인할 수 없습니다.',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              '취소',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final success = await ref
                  .read(voiceLegacyNotifierProvider.notifier)
                  .open(legacy.id);
              if (success) {
                HapticService.celebration();
              }
            },
            child: const Text(
              '열기',
              style: TextStyle(
                color: AppColors.accent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPlaySheet(
    BuildContext context,
    WidgetRef ref,
    VoiceLegacyTableData legacy,
    String fromName,
    String toName,
  ) {
    HapticService.light();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PlayLegacySheet(
        legacy: legacy,
        fromName: fromName,
        toName: toName,
      ),
    );
  }
}

/// 전체 노드 목록 스트림 (이름 해석용)
final _allNodesProvider = StreamProvider<List<NodeModel>>((ref) {
  return ref.watch(nodeRepositoryProvider).watchAll();
});

/// 열린 유언 재생 바텀시트
class _PlayLegacySheet extends ConsumerStatefulWidget {
  const _PlayLegacySheet({
    required this.legacy,
    required this.fromName,
    required this.toName,
  });

  final VoiceLegacyTableData legacy;
  final String fromName;
  final String toName;

  @override
  ConsumerState<_PlayLegacySheet> createState() => _PlayLegacySheetState();
}

class _PlayLegacySheetState extends ConsumerState<_PlayLegacySheet> {
  PlayerController? _playerCtrl;
  StreamSubscription? _playerSub;
  bool _prepared = false;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    // 상대경로/절대경로 모두 처리
    final resolvedPath = PathUtils.toAbsolute(widget.legacy.voicePath);
    if (resolvedPath == null || !File(resolvedPath).existsSync()) return;
    _playerCtrl = PlayerController();
    try {
      await _playerCtrl!.preparePlayer(
        path: resolvedPath,
        shouldExtractWaveform: true,
      );
      _playerSub = _playerCtrl!.onPlayerStateChanged.listen((_) {
        if (mounted) setState(() {});
      });
      if (mounted) setState(() => _prepared = true);
    } catch (_) {
      // 파일 재생 준비 실패 시 무시
    }
  }

  @override
  void dispose() {
    _playerSub?.cancel();
    _playerCtrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GlassBottomSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Row(
            children: [
              const Icon(Icons.play_circle_outlined,
                  color: AppColors.success, size: 22),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  widget.legacy.title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              // 삭제 버튼
              IconButton(
                icon: Icon(Icons.delete_outline,
                    color: AppColors.error, size: 20),
                onPressed: () => _confirmDelete(context),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // From -> To
          Text(
            '${widget.fromName} \u2192 ${widget.toName}',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // 파형 + 재생
          if (_prepared && _playerCtrl != null) ...[
            Center(
              child: RepaintBoundary(
                child: SizedBox(
                  height: 60,
                  child: AudioFileWaveforms(
                    playerController: _playerCtrl!,
                    size: Size(
                        MediaQuery.of(context).size.width - 96, 60),
                    waveformType: WaveformType.fitWidth,
                    playerWaveStyle: PlayerWaveStyle(
                      fixedWaveColor: AppColors.glassBorder,
                      liveWaveColor: AppColors.primary,
                      waveCap: StrokeCap.round,
                      waveThickness: 3,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Center(
              child: GlassCard(
                onTap: _togglePlayback,
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Icon(
                  _playerCtrl?.playerState == PlayerState.playing
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  color: AppColors.primary,
                  size: 32,
                ),
              ),
            ),
          ] else
            Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Text(
                  '음성 파일을 불러올 수 없습니다.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.lg),

          // 날짜 정보
          Text(
            '만든 날: ${_formatDate(widget.legacy.createdAt)}',
            style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
          ),
          if (widget.legacy.openedAt != null)
            Text(
              '열린 날: ${_formatDate(widget.legacy.openedAt!)}',
              style:
                  TextStyle(fontSize: 12, color: AppColors.textTertiary),
            ),
          Text(
            '길이: ${_formatDuration(widget.legacy.durationSeconds)}',
            style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }

  Future<void> _togglePlayback() async {
    if (_playerCtrl == null) return;
    if (_playerCtrl!.playerState == PlayerState.playing) {
      await _playerCtrl!.pausePlayer();
    } else {
      await _playerCtrl!.startPlayer();
    }
    setState(() {});
  }

  void _confirmDelete(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgSurface,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          '유언 삭제',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          '"${widget.legacy.title}" 유언을 삭제할까요?\n음성 파일도 함께 삭제됩니다.',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('취소',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await ref
                  .read(voiceLegacyNotifierProvider.notifier)
                  .delete(widget.legacy.id);
              if (context.mounted) {
                HapticService.heavy();
                Navigator.of(context).pop(); // 바텀시트 닫기
              }
            },
            child: const Text(
              '삭제',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) =>
      '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')}';

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    if (m > 0) return '$m분 ${s > 0 ? "${s}초" : ""}';
    return '$s초';
  }
}
