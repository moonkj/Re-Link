import 'dart:async';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/media/media_service.dart';
import '../../../core/utils/haptic_service.dart';
import '../../../design/glass/app_glass.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../design/tokens/app_spacing.dart';
import '../providers/welcome_capsule_notifier.dart';

/// 환영 캡슐 녹음 바텀시트
/// 텍스트 메시지 (200자 제한) + 선택적 음성 녹음
class WelcomeCapsuleSheet extends ConsumerStatefulWidget {
  const WelcomeCapsuleSheet({super.key});

  @override
  ConsumerState<WelcomeCapsuleSheet> createState() =>
      _WelcomeCapsuleSheetState();
}

enum _VoiceState { idle, recording, recorded }

class _WelcomeCapsuleSheetState extends ConsumerState<WelcomeCapsuleSheet>
    with SingleTickerProviderStateMixin {
  final _messageCtrl = TextEditingController();
  late final RecorderController _recorderCtrl;
  PlayerController? _playerCtrl;
  StreamSubscription? _playerSub;

  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  _VoiceState _voiceState = _VoiceState.idle;
  int _elapsed = 0;
  int _recordedSeconds = 0;
  Timer? _timer;
  String? _recordedPath;

  static const int _maxChars = 200;

  @override
  void initState() {
    super.initState();
    _recorderCtrl = RecorderController();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    // 기존 상태가 있으면 복원
    final existing = ref.read(welcomeCapsuleNotifierProvider);
    if (existing.hasMessage) {
      _messageCtrl.text = existing.message;
    }
    if (existing.hasAudio) {
      _recordedPath = existing.audioPath;
      _recordedSeconds = existing.recordingSeconds;
      _voiceState = _VoiceState.recorded;
      _initPlayer(existing.audioPath!);
    }
  }

  Future<void> _initPlayer(String path) async {
    _playerCtrl?.dispose();
    _playerCtrl = PlayerController();
    await _playerCtrl!.preparePlayer(
      path: path,
      shouldExtractWaveform: true,
    );
    _playerSub?.cancel();
    _playerSub = _playerCtrl!.onPlayerStateChanged.listen((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _playerSub?.cancel();
    _timer?.cancel();
    _pulseCtrl.dispose();
    _recorderCtrl.dispose();
    _playerCtrl?.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final charCount = _messageCtrl.text.length;

    return GlassBottomSheet(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 핸들
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.glassBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // 제목
            Text(
              '환영 메시지',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '가족에게 보낼 따뜻한 환영 인사를 남겨보세요',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // ── 텍스트 입력 ────────────────────────────────────────────────────
            GlassCard(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextField(
                    controller: _messageCtrl,
                    maxLength: _maxChars,
                    maxLines: 4,
                    minLines: 2,
                    onChanged: (text) {
                      ref
                          .read(welcomeCapsuleNotifierProvider.notifier)
                          .setMessage(text);
                      setState(() {});
                    },
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.textPrimary,
                      height: 1.5,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText:
                          '예: 우리 가족 트리에 오신 것을 환영해요!',
                      hintStyle: TextStyle(
                        fontSize: 14,
                        color: AppColors.textTertiary,
                      ),
                      counterText: '',
                      isDense: true,
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                    ),
                  ),
                  Text(
                    '$charCount / $_maxChars',
                    style: TextStyle(
                      fontSize: 12,
                      color: charCount >= _maxChars
                          ? AppColors.error
                          : AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // ── 음성 녹음 섹션 ──────────────────────────────────────────────────
            Row(
              children: [
                Icon(Icons.mic_rounded, size: 18, color: AppColors.primary),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  '음성 메시지 (선택)',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // 파형 + 녹음 컨트롤
            if (_voiceState == _VoiceState.idle) ...[
              _buildIdleVoice(),
            ] else if (_voiceState == _VoiceState.recording) ...[
              _buildRecordingVoice(),
            ] else ...[
              _buildRecordedVoice(),
            ],

            const SizedBox(height: AppSpacing.xxxl),

            // ── 하단 버튼 ──────────────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: GlassButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Center(
                      child: Text(
                        '건너뛰기',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: PrimaryGlassButton(
                    label: '완료',
                    onPressed: _onDone,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }

  // ── Idle: 녹음 시작 버튼 ─────────────────────────────────────────────────

  Widget _buildIdleVoice() {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          GestureDetector(
            onTap: _startRecording,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary,
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x30000000),
                    blurRadius: 16,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.mic_rounded,
                color: AppColors.onPrimary,
                size: 28,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            '탭하여 녹음 시작',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  // ── Recording: 파형 + 경과 시간 + 중지 ───────────────────────────────────

  Widget _buildRecordingVoice() {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          RepaintBoundary(
            child: SizedBox(
              height: 60,
              child: AudioWaveforms(
                recorderController: _recorderCtrl,
                size: Size(MediaQuery.of(context).size.width - 120, 60),
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
          const SizedBox(height: AppSpacing.md),

          // 경과 시간
          Text(
            _formatTime(_elapsed),
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w300,
              color: AppColors.accent,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // 중지 버튼 (Pulse 애니메이션)
          GestureDetector(
            onTap: _stopRecording,
            child: AnimatedBuilder(
              animation: _pulseAnim,
              builder: (_, child) => Transform.scale(
                scale: _pulseAnim.value,
                child: child,
              ),
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.error,
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x30000000),
                      blurRadius: 16,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.stop_rounded,
                  color: AppColors.onPrimary,
                  size: 28,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Recorded: 파형 재생 + 다시 녹음 + 삭제 ────────────────────────────────

  Widget _buildRecordedVoice() {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          if (_playerCtrl != null)
            RepaintBoundary(
              child: SizedBox(
                height: 60,
                child: AudioFileWaveforms(
                  playerController: _playerCtrl!,
                  size: Size(MediaQuery.of(context).size.width - 120, 60),
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
          const SizedBox(height: AppSpacing.sm),

          Text(
            _formatTime(_recordedSeconds),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w300,
              color: AppColors.textPrimary,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 다시 녹음
              GlassCard(
                onTap: _resetRecording,
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Icon(
                  Icons.refresh,
                  color: AppColors.textSecondary,
                  size: 22,
                ),
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
                  size: 26,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              // 삭제
              GlassCard(
                onTap: _deleteRecording,
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Icon(
                  Icons.delete_outline,
                  color: AppColors.error,
                  size: 22,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── 녹음 제어 ────────────────────────────────────────────────────────────

  Future<void> _startRecording() async {
    HapticService.medium();
    final path = await ref.read(mediaServiceProvider).newVoicePath();
    await _recorderCtrl.record(path: path);
    _elapsed = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => _elapsed++);
        ref
            .read(welcomeCapsuleNotifierProvider.notifier)
            .updateRecordingSeconds(_elapsed);
      }
    });
    _pulseCtrl.repeat(reverse: true);
    ref.read(welcomeCapsuleNotifierProvider.notifier).startRecording();
    setState(() => _voiceState = _VoiceState.recording);
  }

  Future<void> _stopRecording() async {
    _timer?.cancel();
    _pulseCtrl.stop();
    _pulseCtrl.reset();
    final path = await _recorderCtrl.stop();
    if (path == null) return;
    _recordedPath = path;
    _recordedSeconds = _elapsed;

    ref.read(welcomeCapsuleNotifierProvider.notifier).stopRecording(path);

    await _initPlayer(path);
    setState(() => _voiceState = _VoiceState.recorded);
    HapticService.light();
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
    _pulseCtrl.stop();
    _pulseCtrl.reset();
    _playerCtrl?.stopPlayer();
    _playerCtrl?.dispose();
    _playerCtrl = null;
    _recordedPath = null;
    _recorderCtrl.refresh();
    ref.read(welcomeCapsuleNotifierProvider.notifier).removeAudio();
    setState(() {
      _voiceState = _VoiceState.idle;
      _elapsed = 0;
      _recordedSeconds = 0;
    });
  }

  void _deleteRecording() {
    HapticService.light();
    _resetRecording();
  }

  // ── 완료 ─────────────────────────────────────────────────────────────────

  void _onDone() {
    HapticService.medium();
    // 텍스트 최종 동기화
    ref
        .read(welcomeCapsuleNotifierProvider.notifier)
        .setMessage(_messageCtrl.text);
    Navigator.of(context).pop(true);
  }

  // ── 유틸 ─────────────────────────────────────────────────────────────────

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}
