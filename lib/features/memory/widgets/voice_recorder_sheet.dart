import 'dart:async';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/errors/app_error.dart';
import '../../../core/services/media/media_service.dart';
import '../../../core/utils/haptic_service.dart';
import '../../../design/glass/app_glass.dart';
import '../../../design/motion/app_motion.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../design/tokens/app_spacing.dart';
import '../../badges/providers/badge_notifier.dart';
import '../../badges/widgets/badge_earned_dialog.dart';
import '../providers/memory_notifier.dart';

/// 음성 녹음 바텀시트
/// 녹음 → 파형 시각화 → 재생 미리보기 → 속도 조절 → 저장
class VoiceRecorderSheet extends ConsumerStatefulWidget {
  const VoiceRecorderSheet({super.key, required this.nodeId});
  final String nodeId;

  @override
  ConsumerState<VoiceRecorderSheet> createState() => _VoiceRecorderSheetState();
}

/// 재생 속도 단계
enum _PlaybackSpeed {
  half(0.5, '0.5×'),
  normal(1.0, '1×'),
  fast(1.5, '1.5×'),
  veryFast(2.0, '2×');

  const _PlaybackSpeed(this.rate, this.label);
  final double rate;
  final String label;
}

class _VoiceRecorderSheetState extends ConsumerState<VoiceRecorderSheet>
    with SingleTickerProviderStateMixin {
  late final RecorderController _recorderCtrl;
  PlayerController? _playerCtrl;

  // ── Pulse 애니메이션 (녹음 중 마이크 버튼) ─────────────────────────────────
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  _RecordState _state = _RecordState.idle;
  int _elapsed = 0;
  Timer? _timer;
  String? _recordedPath;
  int _recordedSeconds = 0;
  bool _saving = false;
  final _titleCtrl = TextEditingController();

  _PlaybackSpeed _speed = _PlaybackSpeed.normal;
  String? _selectedTag;

  @override
  void initState() {
    super.initState();
    _recorderCtrl = RecorderController();

    // Pulse 애니메이션: scale 1.0 → 1.15 → 1.0, 반복
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseCtrl.dispose();
    _recorderCtrl.dispose();
    _playerCtrl?.dispose();
    _titleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GlassBottomSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 핸들
          Center(
            child: Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(bottom: AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.glassBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          Text(
            '음성 기억',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // 파형
          RepaintBoundary(
            child: SizedBox(
              height: 80,
              child: _state == _RecordState.recorded && _playerCtrl != null
                  ? AudioFileWaveforms(
                      playerController: _playerCtrl!,
                      size: Size(MediaQuery.of(context).size.width - 96, 80),
                      waveformType: WaveformType.fitWidth,
                      playerWaveStyle: PlayerWaveStyle(
                        fixedWaveColor: AppColors.glassBorder,
                        liveWaveColor: AppColors.primary,
                        waveCap: StrokeCap.round,
                        waveThickness: 3,
                      ),
                    )
                  : AudioWaveforms(
                      recorderController: _recorderCtrl,
                      size: Size(MediaQuery.of(context).size.width - 96, 80),
                      waveStyle: WaveStyle(
                        waveColor: AppColors.primary,
                        extendWaveform: true,
                        showMiddleLine: false,
                        waveCap: StrokeCap.round,
                        waveThickness: 3,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // 타이머
          Text(
            _formatTime(_state == _RecordState.recorded ? _recordedSeconds : _elapsed),
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w300,
              color: _state == _RecordState.recording ? AppColors.accent : AppColors.textPrimary,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // 제어 버튼
          if (_state == _RecordState.idle || _state == _RecordState.recording)
            _PulseMicButton(
              isRecording: _state == _RecordState.recording,
              pulseAnim: _pulseAnim,
              onTap: _state == _RecordState.recording ? _stopRecording : _startRecording,
            )
          else if (_state == _RecordState.recorded) ...[
            // 재생 컨트롤 Row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 다시 녹음
                GlassCard(
                  onTap: _resetRecording,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Icon(Icons.refresh, color: AppColors.textSecondary, size: 24),
                ),
                const SizedBox(width: AppSpacing.lg),
                // 재생/일시정지
                GlassCard(
                  onTap: _togglePlayback,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Icon(
                    _playerCtrl?.playerState == PlayerState.playing
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    color: AppColors.primary,
                    size: 28,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // 속도 조절 Row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _PlaybackSpeed.values.map((s) {
                final isSelected = _speed == s;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: AnimatedContainer(
                    duration: AppMotion.vibeMeterStep,
                    curve: AppMotion.standard,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.glassSurface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.glassBorder,
                      ),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => _setSpeed(s),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        child: Text(
                          s.label,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.lg),

            // 태그 선택
            Wrap(
              spacing: AppSpacing.sm,
              children: ['이야기', '생일', '인터뷰', '노래', '기타'].map((tag) {
                final isSelected = _selectedTag == tag;
                return ChoiceChip(
                  label: Text(tag),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() => _selectedTag = selected ? tag : null);
                  },
                  selectedColor: AppColors.primaryMint,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    fontSize: 13,
                  ),
                  backgroundColor: AppColors.glassSurface,
                  side: BorderSide(
                    color: isSelected ? AppColors.primaryMint : AppColors.glassBorder,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.lg),

            // 제목 입력
            GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
              child: Row(
                children: [
                  Icon(Icons.title, color: AppColors.primary, size: 18),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: TextField(
                      controller: _titleCtrl,
                      style: TextStyle(fontSize: 14, color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: '제목 (선택)',
                        hintStyle: TextStyle(fontSize: 14, color: AppColors.textTertiary),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            SizedBox(
              width: double.infinity,
              child: PrimaryGlassButton(
                label: '저장',
                isLoading: _saving,
                onPressed: _save,
              ),
            ),
          ],

          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }

  // ── 녹음 제어 ─────────────────────────────────────────────────────────────

  Future<void> _startRecording() async {
    final path = await ref.read(mediaServiceProvider).newVoicePath();
    await _recorderCtrl.record(path: path);
    _elapsed = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _elapsed++);
    });
    _pulseCtrl.repeat(reverse: true);
    setState(() => _state = _RecordState.recording);
  }

  Future<void> _stopRecording() async {
    _timer?.cancel();
    _pulseCtrl.stop();
    _pulseCtrl.reset();
    final path = await _recorderCtrl.stop();
    if (path == null) return;
    _recordedPath = path;
    _recordedSeconds = _elapsed;

    _playerCtrl?.dispose();
    _playerCtrl = PlayerController();
    await _playerCtrl!.preparePlayer(path: path, shouldExtractWaveform: true);
    _playerCtrl!.onPlayerStateChanged.listen((_) {
      if (mounted) setState(() {});
    });

    setState(() => _state = _RecordState.recorded);
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

  Future<void> _setSpeed(_PlaybackSpeed s) async {
    if (_speed == s) return;
    HapticService.selection();
    setState(() => _speed = s);
    try {
      await _playerCtrl?.setRate(s.rate);
    } catch (_) {
      // setRate는 일부 플랫폼에서 지원 안될 수 있음 — 무시
    }
  }

  void _resetRecording() {
    _timer?.cancel();
    _pulseCtrl.stop();
    _pulseCtrl.reset();
    _playerCtrl?.stopPlayer();
    _playerCtrl?.dispose();
    _playerCtrl = null;
    _recordedPath = null;
    _recorderCtrl.refresh();
    setState(() {
      _state = _RecordState.idle;
      _elapsed = 0;
      _recordedSeconds = 0;
      _speed = _PlaybackSpeed.normal;
    });
  }

  // ── 저장 ─────────────────────────────────────────────────────────────────

  Future<void> _save() async {
    if (_recordedPath == null) return;
    setState(() => _saving = true);
    try {
      await ref.read(memoryNotifierProvider.notifier).addVoice(
        nodeId: widget.nodeId,
        filePath: _recordedPath!,
        durationSeconds: _recordedSeconds,
        title: _titleCtrl.text.trim().isEmpty ? null : _titleCtrl.text.trim(),
        tags: _selectedTag != null ? [_selectedTag!] : const [],
      );
      if (!mounted) return;
      HapticService.memoryAdded();
      // 배지 조건 확인
      final newBadges = await ref.read(badgeNotifierProvider.notifier).checkAndAward();
      if (newBadges.isNotEmpty && mounted) {
        await showDialog(
          context: context,
          builder: (_) => BadgeEarnedDialog(badge: newBadges.first),
        );
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on PlanLimitError catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.message),
        backgroundColor: AppColors.warning,
        action: SnackBarAction(label: '업그레이드', onPressed: () => Navigator.of(context).pop()),
      ));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('저장 실패: $e'),
        backgroundColor: AppColors.error,
      ));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // ── 유틸 ─────────────────────────────────────────────────────────────────

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}

enum _RecordState { idle, recording, recorded }

/// 마이크 버튼 — 녹음 중 pulse 애니메이션 (RepaintBoundary 독립)
class _PulseMicButton extends StatelessWidget {
  const _PulseMicButton({
    required this.isRecording,
    required this.pulseAnim,
    required this.onTap,
  });
  final bool isRecording;
  final Animation<double> pulseAnim;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: GestureDetector(
        onTap: onTap,
        child: isRecording
            ? AnimatedBuilder(
                animation: pulseAnim,
                builder: (_, child) => Transform.scale(
                  scale: pulseAnim.value,
                  child: child,
                ),
                child: _MicCircle(isRecording: true),
              )
            : _MicCircle(isRecording: false),
      ),
    );
  }
}

class _MicCircle extends StatelessWidget {
  const _MicCircle({required this.isRecording});
  final bool isRecording;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isRecording ? AppColors.error : AppColors.primary,
        boxShadow: const [
          BoxShadow(
            color: Color(0x30000000),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Icon(
        isRecording ? Icons.stop_rounded : Icons.mic_rounded,
        color: AppColors.onPrimary,
        size: 32,
      ),
    );
  }
}
