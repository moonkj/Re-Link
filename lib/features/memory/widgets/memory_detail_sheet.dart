import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../core/services/privacy/privacy_service.dart';
import '../../../core/utils/path_utils.dart';
import '../../../design/glass/app_glass.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../design/tokens/app_spacing.dart';
import '../../../shared/models/memory_model.dart';
import '../providers/memory_notifier.dart';
import '../../then_now/widgets/memory_picker_sheet.dart';

/// 기억 상세 시트 — 타입별 분기 + Privacy Layer 게이팅
class MemoryDetailSheet extends ConsumerStatefulWidget {
  const MemoryDetailSheet({super.key, required this.memory});
  final MemoryModel memory;

  @override
  ConsumerState<MemoryDetailSheet> createState() => _MemoryDetailSheetState();
}

class _MemoryDetailSheetState extends ConsumerState<MemoryDetailSheet> {
  PlayerController? _playerCtrl;
  StreamSubscription? _playerSub;
  bool _playerReady = false;

  /// 공개/개인 상태 (로컬 즉시 반영용)
  bool _isPrivate = false;

  /// Privacy Layer: 인증 완료 여부
  bool _privacyUnlocked = false;

  /// Privacy Layer: 활성화 여부 (설정에서)
  bool _privacyEnabled = false;

  /// Privacy Layer: 로딩 중
  bool _privacyLoading = true;

  @override
  void initState() {
    super.initState();
    _isPrivate = widget.memory.isPrivate;
    _checkPrivacy();
    if (widget.memory.type == MemoryType.voice && widget.memory.filePath != null) {
      _initPlayer();
    }
  }

  Future<void> _checkPrivacy() async {
    if (!widget.memory.isPrivate) {
      if (mounted) {
        setState(() {
          _privacyLoading = false;
          _privacyUnlocked = true;
        });
      }
      return;
    }

    final privacy = ref.read(privacyServiceProvider);
    final enabled = await privacy.isEnabled();
    if (!mounted) return;

    if (!enabled) {
      // Privacy Layer 비활성화 → 바로 노출
      setState(() {
        _privacyLoading = false;
        _privacyUnlocked = true;
      });
      return;
    }

    setState(() {
      _privacyEnabled = true;
      _privacyLoading = false;
    });

    // 자동 인증 시도 (세션 유효 시 바로 통과)
    _attemptAuth();
  }

  Future<void> _attemptAuth() async {
    final privacy = ref.read(privacyServiceProvider);
    final result = await privacy.authenticate();
    if (!mounted) return;
    setState(() => _privacyUnlocked = result);
  }

  Future<void> _initPlayer() async {
    _playerCtrl = PlayerController();
    await _playerCtrl!.preparePlayer(
      path: PathUtils.toAbsolute(widget.memory.filePath!) ?? widget.memory.filePath!,
      shouldExtractWaveform: true,
    );
    _playerSub = _playerCtrl!.onPlayerStateChanged.listen((_) {
      if (mounted) setState(() {});
    });
    if (mounted) setState(() => _playerReady = true);
  }

  @override
  void dispose() {
    _playerSub?.cancel();
    _playerCtrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Privacy Layer 로딩 중
    if (_privacyLoading) {
      return GlassBottomSheet(
        padding: EdgeInsets.zero,
        child: SizedBox(
          height: 200,
          child: Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        ),
      );
    }

    // Private 기억이고 인증 미완료 → 블러 + 잠금 오버레이 (토글 pill은 항상 표시)
    if (widget.memory.isPrivate && _privacyEnabled && !_privacyUnlocked) {
      return _LockedOverlay(
        memory: widget.memory,
        onUnlock: _attemptAuth,
        onClose: () => Navigator.of(context).pop(),
        isPrivate: _isPrivate,
        onTogglePrivacy: () async {
          final newPrivate = !_isPrivate;
          setState(() => _isPrivate = newPrivate);
          await ref.read(memoryNotifierProvider.notifier).updatePrivacy(
            widget.memory.id,
            isPrivate: newPrivate,
          );
        },
      );
    }

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
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // 공개/개인 토글 알약 (share 아이콘 왼쪽)
                _PrivacyPill(isPrivate: _isPrivate, onToggle: _togglePrivacy),
                const SizedBox(width: AppSpacing.sm),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    final router = GoRouter.of(context);
                    Navigator.of(context).pop();
                    router.push(AppRoutes.snapshotPath(widget.memory.id));
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Icon(Icons.share_outlined, color: AppColors.textSecondary, size: 22),
                  ),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _confirmDelete(context),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Icon(Icons.delete_outline, color: AppColors.error, size: 22),
                  ),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Navigator.of(context).pop(),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Icon(Icons.close, color: AppColors.textSecondary, size: 22),
                  ),
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
            MemoryType.video => _VideoContent(memory: widget.memory),
          },

          const SizedBox(height: AppSpacing.lg),

          // Then & Now 버튼 (사진 타입만)
          if (widget.memory.type == MemoryType.photo && widget.memory.filePath != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.md),
              child: GestureDetector(
                onTap: () => _openThenNowPicker(context),
                child: GlassCard(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                  child: Row(
                    children: [
                      Icon(Icons.compare_rounded, size: 20, color: AppColors.primary),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Then & Now',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              '다른 사진과 비교하기',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, size: 20, color: AppColors.textTertiary),
                    ],
                  ),
                ),
              ),
            ),

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

  Future<void> _togglePrivacy() async {
    final newPrivate = !_isPrivate;
    setState(() => _isPrivate = newPrivate);
    await ref.read(memoryNotifierProvider.notifier).updatePrivacy(
      widget.memory.id,
      isPrivate: newPrivate,
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

  Future<void> _openThenNowPicker(BuildContext context) async {
    final selectedMemory = await showModalBottomSheet<MemoryModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MemoryPickerSheet(
        nodeId: widget.memory.nodeId,
        excludeMemoryId: widget.memory.id,
      ),
    );
    if (selectedMemory == null) return;
    if (!context.mounted) return;

    final router = GoRouter.of(context);
    Navigator.of(context).pop(); // 현재 detail sheet 닫기
    router.push(
      AppRoutes.thenNow,
      extra: {
        'memoryId1': widget.memory.id,
        'memoryId2': selectedMemory.id,
      },
    );
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

// ── 잠금 오버레이 (인증 전) ───────────────────────────────────────────────────

class _LockedOverlay extends StatelessWidget {
  const _LockedOverlay({
    required this.memory,
    required this.onUnlock,
    required this.onClose,
    required this.isPrivate,
    required this.onTogglePrivacy,
  });

  final MemoryModel memory;
  final VoidCallback onUnlock;
  final VoidCallback onClose;
  final bool isPrivate;
  final VoidCallback onTogglePrivacy;

  @override
  Widget build(BuildContext context) {
    return GlassBottomSheet(
      padding: EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 제목 + 토글 아이콘 + 닫기 버튼 (항상 표시)
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    memory.title ?? memory.type.label,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // 공개/개인 토글 — 잠금 상태에서도 항상 표시
                _PrivacyPill(isPrivate: isPrivate, onToggle: onTogglePrivacy),
                const SizedBox(width: AppSpacing.sm),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onClose,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Icon(Icons.close, color: AppColors.textSecondary, size: 22),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // 블러된 콘텐츠 미리보기 + 잠금 아이콘
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                height: 200,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // 배경: 타입에 따른 미리보기 (블러 처리)
                    _BlurredPreview(memory: memory),
                    // 블러 필터
                    BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: Container(
                        color: AppColors.bgBase.withAlpha(80),
                      ),
                    ),
                    // 잠금 아이콘 + 텍스트
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.accent.withAlpha(30),
                            ),
                            child: const Icon(
                              Icons.lock_rounded,
                              color: AppColors.accent,
                              size: 28,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            '인증이 필요한 기억입니다',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // 잠금 해제 버튼
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
            child: SizedBox(
              width: double.infinity,
              child: GlassButton(
                onPressed: onUnlock,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.fingerprint, color: AppColors.accent, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      '인증하여 보기',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 블러 처리를 위한 배경 미리보기
class _BlurredPreview extends StatelessWidget {
  const _BlurredPreview({required this.memory});
  final MemoryModel memory;

  @override
  Widget build(BuildContext context) {
    switch (memory.type) {
      case MemoryType.photo:
        if (memory.thumbnailPath != null) {
          return Image.file(
            PathUtils.resolveFile(memory.thumbnailPath) ?? File(memory.thumbnailPath!),
            fit: BoxFit.cover,
            cacheWidth: 400,
          );
        }
        if (memory.filePath != null) {
          return Image.file(
            PathUtils.resolveFile(memory.filePath) ?? File(memory.filePath!),
            fit: BoxFit.cover,
            cacheWidth: 400,
          );
        }
        return Container(color: AppColors.glassSurface);
      case MemoryType.voice:
        return Container(
          color: AppColors.accent.withAlpha(20),
          child: Center(
            child: Icon(Icons.mic_rounded, size: 48, color: AppColors.accent),
          ),
        );
      case MemoryType.note:
        return Container(
          color: AppColors.primary.withAlpha(20),
          child: Center(
            child: Icon(Icons.notes_rounded, size: 48, color: AppColors.primary),
          ),
        );
      case MemoryType.video:
        return Container(
          color: AppColors.bgSurface,
          child: const Center(
            child: Icon(Icons.videocam_rounded, size: 48, color: Colors.white54),
          ),
        );
    }
  }
}

// ── 공개/비공개 알약 토글 ─────────────────────────────────────────────────────

class _PrivacyPill extends StatelessWidget {
  const _PrivacyPill({required this.isPrivate, required this.onToggle});
  final bool isPrivate;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onToggle,
      child: Container(
        height: 30,
        decoration: BoxDecoration(
          color: AppColors.glassSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.glassBorder, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _PillOption(
              icon: Icons.public,
              label: '공개',
              selected: !isPrivate,
              color: AppColors.primary,
            ),
            _PillOption(
              icon: Icons.lock_outline,
              label: '비공개',
              selected: isPrivate,
              color: AppColors.accent,
            ),
          ],
        ),
      ),
    );
  }
}

class _PillOption extends StatelessWidget {
  const _PillOption({
    required this.icon,
    required this.label,
    required this.selected,
    required this.color,
  });
  final IconData icon;
  final String label;
  final bool selected;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: selected ? color.withAlpha(200) : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13,
            color: selected ? Colors.white : AppColors.textTertiary,
          ),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
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
              File(PathUtils.toAbsolute(memory.filePath!) ?? memory.filePath!),
              height: 260,
              width: double.infinity,
              fit: BoxFit.cover,
              cacheWidth: 400,
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
              child: Image.file(File(PathUtils.toAbsolute(memory.filePath!) ?? memory.filePath!), cacheWidth: 800),
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
              SizedBox(
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
                      color: playerReady ? AppColors.onPrimary : AppColors.textPrimary,
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

// ── 영상 ──────────────────────────────────────────────────────────────────────

class _VideoContent extends StatefulWidget {
  const _VideoContent({required this.memory});
  final MemoryModel memory;

  @override
  State<_VideoContent> createState() => _VideoContentState();
}

class _VideoContentState extends State<_VideoContent> {
  VideoPlayerController? _ctrl;
  bool _playerLoading = false;
  bool _playerReady = false;

  @override
  void dispose() {
    _ctrl?.dispose();
    super.dispose();
  }

  /// 탭 시 VideoPlayer 지연 로드
  Future<void> _startPlay() async {
    if (_playerLoading || _playerReady) return;
    if (widget.memory.filePath == null) return;
    final file = File(PathUtils.toAbsolute(widget.memory.filePath!) ?? widget.memory.filePath!);
    if (!file.existsSync()) return;

    setState(() => _playerLoading = true);
    try {
      final ctrl = VideoPlayerController.file(file);
      await ctrl.initialize();
      ctrl.addListener(() { if (mounted) setState(() {}); });
      if (!mounted) return;
      setState(() {
        _ctrl = ctrl;
        _playerReady = true;
        _playerLoading = false;
      });
      await ctrl.play();
    } catch (_) {
      if (mounted) setState(() => _playerLoading = false);
    }
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  String _fmtSec(int? seconds) {
    if (seconds == null) return '0:00';
    return '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isPlaying = _ctrl?.value.isPlaying ?? false;
    final position = _ctrl?.value.position ?? Duration.zero;
    final duration = _ctrl?.value.duration ?? Duration(seconds: widget.memory.durationSeconds ?? 0);
    final progress = duration.inMilliseconds > 0
        ? position.inMilliseconds / duration.inMilliseconds
        : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        children: [
          // 영상 화면
          GestureDetector(
            onTap: () async {
              if (!_playerReady) {
                await _startPlay();
              } else if (isPlaying) {
                _ctrl!.pause();
              } else {
                _ctrl!.play();
              }
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: _ctrl?.value.aspectRatio ?? 16 / 9,
                child: Stack(
                  fit: StackFit.expand,
                  alignment: Alignment.center,
                  children: [
                    // 썸네일 포스터 (VideoPlayer 로드 전)
                    if (!_playerReady && widget.memory.thumbnailPath != null)
                      Image.file(File(PathUtils.toAbsolute(widget.memory.thumbnailPath!) ?? widget.memory.thumbnailPath!), fit: BoxFit.cover, cacheWidth: 400)
                    else if (!_playerReady)
                      Container(color: AppColors.bgSurface),

                    // VideoPlayer (로드 완료 후)
                    if (_playerReady && _ctrl != null)
                      VideoPlayer(_ctrl!),

                    // 로딩 인디케이터
                    if (_playerLoading)
                      Container(
                        color: Colors.black45,
                        child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                      ),

                    // 플레이 버튼 (정지 상태)
                    if (!isPlaying && !_playerLoading)
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.play_arrow, color: Colors.white, size: 36),
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          // 진행 바 (VideoPlayer 로드 후에만)
          if (_playerReady) ...[
            SliderTheme(
              data: SliderThemeData(
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                trackHeight: 3,
              ),
              child: Slider(
                value: progress.clamp(0.0, 1.0),
                onChanged: (v) => _ctrl!.seekTo(
                  Duration(milliseconds: (v * duration.inMilliseconds).round()),
                ),
                activeColor: AppColors.primary,
                inactiveColor: AppColors.glassBorder,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_formatDuration(position),
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  Text(_formatDuration(duration),
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
          ] else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(_fmtSec(widget.memory.durationSeconds),
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
