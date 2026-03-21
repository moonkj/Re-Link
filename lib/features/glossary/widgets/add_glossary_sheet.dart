import 'dart:async';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/media/media_service.dart';
import '../../../core/utils/haptic_service.dart';
import '../../../design/glass/app_glass.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../design/tokens/app_spacing.dart';
import '../../../shared/models/node_model.dart';
import '../../../shared/repositories/node_repository.dart';
import '../../badges/providers/badge_notifier.dart';
import '../../badges/widgets/badge_earned_dialog.dart';
import '../providers/glossary_notifier.dart';

/// 단어 추가 바텀시트 (음성 녹음 포함)
class AddGlossarySheet extends ConsumerStatefulWidget {
  const AddGlossarySheet({super.key});

  @override
  ConsumerState<AddGlossarySheet> createState() => _AddGlossarySheetState();
}

enum _VoiceState { idle, recording, recorded }

class _AddGlossarySheetState extends ConsumerState<AddGlossarySheet>
    with SingleTickerProviderStateMixin {
  final _wordCtrl = TextEditingController();
  final _meaningCtrl = TextEditingController();
  final _exampleCtrl = TextEditingController();
  bool _saving = false;

  // 선택된 노드 (누가 쓰는 표현인지)
  NodeModel? _selectedNode;

  // ── 음성 녹음 ──────────────────────────────────────────────────────────────
  late final RecorderController _recorderCtrl;
  PlayerController? _playerCtrl;
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  _VoiceState _voiceState = _VoiceState.idle;
  int _elapsed = 0;
  Timer? _timer;
  String? _recordedPath;

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
  }

  @override
  void dispose() {
    _wordCtrl.dispose();
    _meaningCtrl.dispose();
    _exampleCtrl.dispose();
    _timer?.cancel();
    _pulseCtrl.dispose();
    _recorderCtrl.dispose();
    _playerCtrl?.dispose();
    super.dispose();
  }

  bool get _isValid =>
      _wordCtrl.text.trim().isNotEmpty && _meaningCtrl.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return GlassBottomSheet(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xxl,
        AppSpacing.xxl,
        AppSpacing.xxl,
        AppSpacing.xxl + bottomInset,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 헤더 ──────────────────────────────────────────────
          Text(
            '새 표현 등록',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '가족만의 특별한 표현을 기록하세요',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // ── 단어 (필수) ──────────────────────────────────────
          TextField(
            controller: _wordCtrl,
            style: TextStyle(color: AppColors.textPrimary),
            onChanged: (_) => setState(() {}),
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: '표현 *',
              hintText: '예: 깜순이',
              labelStyle: TextStyle(color: AppColors.textSecondary),
              hintStyle: TextStyle(color: AppColors.textTertiary),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.glassBorder),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── 뜻 (필수) ───────────────────────────────────────
          TextField(
            controller: _meaningCtrl,
            style: TextStyle(color: AppColors.textPrimary),
            onChanged: (_) => setState(() {}),
            textInputAction: TextInputAction.next,
            maxLines: 2,
            minLines: 1,
            decoration: InputDecoration(
              labelText: '뜻 *',
              hintText: '예: 외할머니가 나를 부르던 별명',
              labelStyle: TextStyle(color: AppColors.textSecondary),
              hintStyle: TextStyle(color: AppColors.textTertiary),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.glassBorder),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── 예문 (선택) ─────────────────────────────────────
          TextField(
            controller: _exampleCtrl,
            style: TextStyle(color: AppColors.textPrimary),
            textInputAction: TextInputAction.done,
            maxLines: 2,
            minLines: 1,
            decoration: InputDecoration(
              labelText: '사용 예시 (선택)',
              hintText: '예: "깜순아, 밥 먹으렴~"',
              labelStyle: TextStyle(color: AppColors.textSecondary),
              hintStyle: TextStyle(color: AppColors.textTertiary),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.glassBorder),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // ── 음성 녹음 섹션 ──────────────────────────────────
          _buildVoiceSection(),
          const SizedBox(height: AppSpacing.lg),

          // ── 노드 선택 (누가 쓰는 표현?) ─────────────────────
          GestureDetector(
            onTap: _pickNode,
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              decoration: BoxDecoration(
                color: AppColors.glassSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.glassBorder, width: 0.5),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 18,
                    color: _selectedNode != null
                        ? AppColors.primary
                        : AppColors.textTertiary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      _selectedNode?.name ?? '누가 쓰는 표현인가요? (선택)',
                      style: TextStyle(
                        fontSize: 14,
                        color: _selectedNode != null
                            ? AppColors.textPrimary
                            : AppColors.textTertiary,
                      ),
                    ),
                  ),
                  if (_selectedNode != null)
                    GestureDetector(
                      onTap: () => setState(() => _selectedNode = null),
                      child: Icon(Icons.close, size: 16,
                          color: AppColors.textTertiary),
                    )
                  else
                    Icon(Icons.chevron_right, size: 18,
                        color: AppColors.textTertiary),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // ── 등록 버튼 ──────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: PrimaryGlassButton(
              label: '등록하기',
              isLoading: _saving,
              onPressed: _isValid ? _submit : null,
            ),
          ),
        ],
      ),
    );
  }

  // ── 음성 녹음 섹션 UI ─────────────────────────────────────────────────────

  Widget _buildVoiceSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.glassSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.glassBorder, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.mic_outlined,
                size: 16,
                color: _voiceState == _VoiceState.recorded
                    ? AppColors.primary
                    : AppColors.textTertiary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                '발음 녹음 (선택)',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              if (_voiceState == _VoiceState.recording)
                Text(
                  _formatTime(_elapsed),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.accent,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              if (_voiceState == _VoiceState.recorded)
                GestureDetector(
                  onTap: _resetVoice,
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: Icon(Icons.delete_outline,
                        size: 16, color: AppColors.error.withAlpha(180)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // 상태별 UI
          if (_voiceState == _VoiceState.idle)
            _buildIdleVoice()
          else if (_voiceState == _VoiceState.recording)
            _buildRecordingVoice()
          else
            _buildRecordedVoice(),
        ],
      ),
    );
  }

  Widget _buildIdleVoice() {
    return GestureDetector(
      onTap: _startRecording,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.primary.withAlpha(15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppColors.primary.withAlpha(40),
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.mic, size: 18, color: AppColors.primary),
            const SizedBox(width: AppSpacing.xs),
            Text(
              '탭하여 녹음 시작',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordingVoice() {
    return GestureDetector(
      onTap: _stopRecording,
      child: AnimatedBuilder(
        animation: _pulseAnim,
        builder: (_, child) => Transform.scale(
          scale: _pulseAnim.value,
          child: child,
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.accent.withAlpha(20),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.accent.withAlpha(60),
              width: 0.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.stop_rounded, size: 20, color: AppColors.accent),
              const SizedBox(width: AppSpacing.xs),
              Text(
                '탭하여 녹음 정지',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecordedVoice() {
    return Row(
      children: [
        // 재생/일시정지 버튼
        GestureDetector(
          onTap: _togglePlayback,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withAlpha(20),
              border: Border.all(
                color: AppColors.primary.withAlpha(60),
              ),
            ),
            child: Icon(
              _playerCtrl?.playerState == PlayerState.playing
                  ? Icons.pause_rounded
                  : Icons.play_arrow_rounded,
              size: 20,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),

        // 파형
        Expanded(
          child: _playerCtrl != null
              ? SizedBox(
                  height: 28,
                  child: AudioFileWaveforms(
                    playerController: _playerCtrl!,
                    size: const Size(double.infinity, 28),
                    waveformType: WaveformType.fitWidth,
                    playerWaveStyle: PlayerWaveStyle(
                      fixedWaveColor: AppColors.glassBorder,
                      liveWaveColor: AppColors.primary,
                      waveCap: StrokeCap.round,
                      waveThickness: 2,
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
        const SizedBox(width: AppSpacing.sm),

        // 녹음 시간
        Text(
          _formatTime(_elapsed),
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textTertiary,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }

  // ── 녹음 제어 ─────────────────────────────────────────────────────────────

  Future<void> _startRecording() async {
    HapticService.light();
    final path = await ref.read(mediaServiceProvider).newVoicePath();
    await _recorderCtrl.record(path: path);
    _elapsed = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _elapsed++);
    });
    _pulseCtrl.repeat(reverse: true);
    setState(() => _voiceState = _VoiceState.recording);
  }

  Future<void> _stopRecording() async {
    _timer?.cancel();
    _pulseCtrl.stop();
    _pulseCtrl.reset();
    HapticService.medium();
    final path = await _recorderCtrl.stop();
    if (path == null) return;
    _recordedPath = path;

    _playerCtrl?.dispose();
    _playerCtrl = PlayerController();
    await _playerCtrl!.preparePlayer(path: path, shouldExtractWaveform: true);
    _playerCtrl!.onPlayerStateChanged.listen((_) {
      if (mounted) setState(() {});
    });

    if (mounted) setState(() => _voiceState = _VoiceState.recorded);
  }

  Future<void> _togglePlayback() async {
    if (_playerCtrl == null) return;
    HapticService.selection();
    if (_playerCtrl!.playerState == PlayerState.playing) {
      await _playerCtrl!.pausePlayer();
    } else {
      await _playerCtrl!.startPlayer();
    }
    if (mounted) setState(() {});
  }

  void _resetVoice() {
    _timer?.cancel();
    _pulseCtrl.stop();
    _pulseCtrl.reset();
    _playerCtrl?.stopPlayer();
    _playerCtrl?.dispose();
    _playerCtrl = null;
    _recordedPath = null;
    _recorderCtrl.refresh();
    HapticService.light();
    setState(() {
      _voiceState = _VoiceState.idle;
      _elapsed = 0;
    });
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  // ── 노드 선택 바텀시트 ──────────────────────────────────────────────────────

  Future<void> _pickNode() async {
    HapticService.light();
    final nodes = await ref.read(nodeRepositoryProvider).getAll();
    if (!mounted || nodes.isEmpty) return;

    final picked = await showModalBottomSheet<NodeModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _NodePickerSheet(nodes: nodes),
    );

    if (picked != null && mounted) {
      setState(() => _selectedNode = picked);
    }
  }

  // ── 저장 ───────────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    if (!_isValid) return;
    setState(() => _saving = true);

    final id = await ref.read(glossaryNotifierProvider.notifier).create(
          word: _wordCtrl.text.trim(),
          meaning: _meaningCtrl.text.trim(),
          example: _exampleCtrl.text.trim().isEmpty
              ? null
              : _exampleCtrl.text.trim(),
          voicePath: _recordedPath,
          nodeId: _selectedNode?.id,
        );

    if (!mounted) return;
    setState(() => _saving = false);

    if (id != null) {
      // 배지 조건 확인
      final newBadges = await ref.read(badgeNotifierProvider.notifier).checkAndAward();
      if (newBadges.isNotEmpty && mounted) {
        await showDialog(
          context: context,
          builder: (_) => BadgeEarnedDialog(badge: newBadges.first),
        );
      }
      if (!mounted) return;
      HapticService.medium();
      Navigator.of(context).pop(true);
    }
  }
}

// ── 노드 선택 시트 ─────────────────────────────────────────────────────────────

class _NodePickerSheet extends StatelessWidget {
  const _NodePickerSheet({required this.nodes});
  final List<NodeModel> nodes;

  @override
  Widget build(BuildContext context) {
    return GlassBottomSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '누가 쓰는 표현인가요?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.4,
            ),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: nodes.length,
              separatorBuilder: (_, _) =>
                  Divider(color: AppColors.glassBorder, height: 1),
              itemBuilder: (ctx, i) {
                final node = nodes[i];
                return ListTile(
                  leading: CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.primary.withAlpha(30),
                    child: Text(
                      node.name.isNotEmpty ? node.name[0] : '?',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  title: Text(
                    node.name,
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  subtitle: node.nickname != null
                      ? Text(
                          node.nickname!,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        )
                      : null,
                  trailing: node.isGhost
                      ? Icon(Icons.blur_on, size: 14,
                          color: AppColors.textTertiary)
                      : null,
                  onTap: () {
                    HapticService.light();
                    Navigator.of(ctx).pop(node);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
