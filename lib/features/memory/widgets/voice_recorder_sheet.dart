import 'dart:async';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/errors/app_error.dart';
import '../../../core/services/media/media_service.dart';
import '../../../design/glass/app_glass.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../design/tokens/app_spacing.dart';
import '../providers/memory_notifier.dart';

/// 음성 녹음 바텀시트
/// 녹음 → 파형 시각화 → 재생 미리보기 → 저장
class VoiceRecorderSheet extends ConsumerStatefulWidget {
  const VoiceRecorderSheet({super.key, required this.nodeId});
  final String nodeId;

  @override
  ConsumerState<VoiceRecorderSheet> createState() => _VoiceRecorderSheetState();
}

class _VoiceRecorderSheetState extends ConsumerState<VoiceRecorderSheet> {
  late final RecorderController _recorderCtrl;
  PlayerController? _playerCtrl;

  _RecordState _state = _RecordState.idle;
  int _elapsed = 0; // 녹음 경과 초
  Timer? _timer;
  String? _recordedPath;
  int _recordedSeconds = 0;
  bool _saving = false;
  final _titleCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _recorderCtrl = RecorderController();
  }

  @override
  void dispose() {
    _timer?.cancel();
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

          const Text(
            '음성 기억',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // 파형
          SizedBox(
            height: 80,
            child: _state == _RecordState.recorded && _playerCtrl != null
                ? AudioFileWaveforms(
                    playerController: _playerCtrl!,
                    size: Size(MediaQuery.of(context).size.width - 96, 80),
                    waveformType: WaveformType.fitWidth,
                    playerWaveStyle: const PlayerWaveStyle(
                      fixedWaveColor: AppColors.glassBorder,
                      liveWaveColor: AppColors.primary,
                      waveCap: StrokeCap.round,
                      waveThickness: 3,
                    ),
                  )
                : AudioWaveforms(
                    recorderController: _recorderCtrl,
                    size: Size(MediaQuery.of(context).size.width - 96, 80),
                    waveStyle: const WaveStyle(
                      waveColor: AppColors.primary,
                      extendWaveform: true,
                      showMiddleLine: false,
                      waveCap: StrokeCap.round,
                      waveThickness: 3,
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
            _RecordButton(
              isRecording: _state == _RecordState.recording,
              onTap: _state == _RecordState.recording ? _stopRecording : _startRecording,
            )
          else if (_state == _RecordState.recorded) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 다시 녹음
                GlassCard(
                  onTap: _resetRecording,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: const Icon(Icons.refresh, color: AppColors.textSecondary, size: 24),
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
            const SizedBox(height: AppSpacing.lg),

            // 제목 입력
            GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
              child: Row(
                children: [
                  const Icon(Icons.title, color: AppColors.primary, size: 18),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: TextField(
                      controller: _titleCtrl,
                      style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: '제목 (선택)',
                        hintStyle: TextStyle(fontSize: 14, color: AppColors.textTertiary),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
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
    setState(() => _state = _RecordState.recording);
  }

  Future<void> _stopRecording() async {
    _timer?.cancel();
    final path = await _recorderCtrl.stop();
    if (path == null) return;
    _recordedPath = path;
    _recordedSeconds = _elapsed;

    // PlayerController 초기화
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

  void _resetRecording() {
    _timer?.cancel();
    _playerCtrl?.stopPlayer();
    _playerCtrl?.dispose();
    _playerCtrl = null;
    _recordedPath = null;
    _recorderCtrl.refresh();
    setState(() {
      _state = _RecordState.idle;
      _elapsed = 0;
      _recordedSeconds = 0;
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
      );
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

class _RecordButton extends StatelessWidget {
  const _RecordButton({required this.isRecording, required this.onTap});
  final bool isRecording;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isRecording ? AppColors.error : AppColors.primary,
          boxShadow: [
            BoxShadow(
              color: (isRecording ? AppColors.error : AppColors.primary).withAlpha(80),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Icon(
          isRecording ? Icons.stop_rounded : Icons.mic_rounded,
          color: Colors.white,
          size: 32,
        ),
      ),
    );
  }
}
