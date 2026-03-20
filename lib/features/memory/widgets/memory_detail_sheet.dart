import 'dart:io';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../design/glass/app_glass.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../design/tokens/app_spacing.dart';
import '../../../shared/models/memory_model.dart';
import '../providers/memory_notifier.dart';

/// 기억 상세 시트 — 타입별 분기
class MemoryDetailSheet extends ConsumerStatefulWidget {
  const MemoryDetailSheet({super.key, required this.memory});
  final MemoryModel memory;

  @override
  ConsumerState<MemoryDetailSheet> createState() => _MemoryDetailSheetState();
}

class _MemoryDetailSheetState extends ConsumerState<MemoryDetailSheet> {
  PlayerController? _playerCtrl;
  bool _playerReady = false;

  @override
  void initState() {
    super.initState();
    if (widget.memory.type == MemoryType.voice && widget.memory.filePath != null) {
      _initPlayer();
    }
  }

  Future<void> _initPlayer() async {
    _playerCtrl = PlayerController();
    await _playerCtrl!.preparePlayer(
      path: widget.memory.filePath!,
      shouldExtractWaveform: true,
    );
    _playerCtrl!.onPlayerStateChanged.listen((_) {
      if (mounted) setState(() {});
    });
    if (mounted) setState(() => _playerReady = true);
  }

  @override
  void dispose() {
    _playerCtrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GlassBottomSheet(
      padding: EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 핸들 + 액션 바
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.memory.title ?? widget.memory.type.label,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                ),
                GestureDetector(
                  onTap: () => _confirmDelete(context),
                  child: const Icon(Icons.delete_outline, color: AppColors.error, size: 22),
                ),
                const SizedBox(width: AppSpacing.sm),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Icon(Icons.close, color: AppColors.textSecondary, size: 22),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // 타입별 본문
          switch (widget.memory.type) {
            MemoryType.photo => _PhotoContent(memory: widget.memory),
            MemoryType.voice => _VoiceContent(
                memory: widget.memory,
                playerCtrl: _playerCtrl,
                playerReady: _playerReady,
                onToggle: _togglePlayback,
              ),
            MemoryType.note => _NoteContent(memory: widget.memory),
          },

          const SizedBox(height: AppSpacing.lg),

          // 날짜
          if (widget.memory.dateTaken != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
              child: Row(
                children: [
                  Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.textTertiary),
                  const SizedBox(width: 6),
                  Text(
                    _formatDate(widget.memory.dateTaken!),
                    style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
                  ),
                ],
              ),
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

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgElevated,
        title: Text('기억 삭제', style: TextStyle(color: AppColors.textPrimary)),
        content: Text('이 기억을 삭제합니다.', style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('취소')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('삭제', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (!context.mounted) return;
    await ref.read(memoryNotifierProvider.notifier).deleteMemory(widget.memory);
    if (!context.mounted) return;
    Navigator.of(context).pop();
  }

  String _formatDate(DateTime dt) =>
      '${dt.year}년 ${dt.month}월 ${dt.day}일';
}

// ── 사진 ──────────────────────────────────────────────────────────────────────

class _PhotoContent extends StatelessWidget {
  const _PhotoContent({required this.memory});
  final MemoryModel memory;

  @override
  Widget build(BuildContext context) {
    if (memory.filePath == null) {
      return Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Icon(Icons.broken_image_outlined, color: AppColors.textTertiary, size: 48),
      );
    }
    return GestureDetector(
      onTap: () => _openFullscreen(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Hero(
          tag: 'photo_${memory.id}',
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              File(memory.filePath!),
              height: 260,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }

  void _openFullscreen(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => Scaffold(
        backgroundColor: Colors.black,
        body: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Center(
            child: InteractiveViewer(
              child: Image.file(File(memory.filePath!)),
            ),
          ),
        ),
      ),
    ));
  }
}

// ── 음성 ──────────────────────────────────────────────────────────────────────

class _VoiceContent extends StatelessWidget {
  const _VoiceContent({
    required this.memory,
    required this.playerCtrl,
    required this.playerReady,
    required this.onToggle,
  });

  final MemoryModel memory;
  final PlayerController? playerCtrl;
  final bool playerReady;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: GlassCard(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            // 파형
            if (playerReady && playerCtrl != null)
              AudioFileWaveforms(
                playerController: playerCtrl!,
                size: Size(MediaQuery.of(context).size.width - 96, 60),
                waveformType: WaveformType.fitWidth,
                playerWaveStyle: PlayerWaveStyle(
                  fixedWaveColor: AppColors.glassBorder,
                  liveWaveColor: AppColors.primary,
                  waveCap: StrokeCap.round,
                  waveThickness: 3,
                ),
              )
            else
              const SizedBox(
                height: 60,
                child: Center(
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                ),
              ),
            const SizedBox(height: AppSpacing.md),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: playerReady ? onToggle : null,
                  child: Container(
                    width: 52, height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: playerReady ? AppColors.primary : AppColors.glassSurface,
                    ),
                    child: Icon(
                      playerCtrl?.playerState == PlayerState.playing
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Text(
                  memory.formattedDuration ?? '--:--',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300, color: AppColors.textPrimary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── 메모 ──────────────────────────────────────────────────────────────────────

class _NoteContent extends StatelessWidget {
  const _NoteContent({required this.memory});
  final MemoryModel memory;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: GlassCard(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: SizedBox(
          width: double.infinity,
          child: Text(
            memory.description ?? '',
            style: TextStyle(fontSize: 15, color: AppColors.textPrimary, height: 1.6),
          ),
        ),
      ),
    );
  }
}
