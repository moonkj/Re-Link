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
import '../providers/voice_legacy_notifier.dart';

/// 보이스 유언 녹음 바텀시트
class RecordLegacySheet extends ConsumerStatefulWidget {
  const RecordLegacySheet({super.key});

  @override
  ConsumerState<RecordLegacySheet> createState() => _RecordLegacySheetState();
}

enum _RecordState { idle, recording, recorded }

class _RecordLegacySheetState extends ConsumerState<RecordLegacySheet>
    with SingleTickerProviderStateMixin {
  final _titleCtrl = TextEditingController();
  late final RecorderController _recorderCtrl;
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  _RecordState _recordState = _RecordState.idle;
  int _elapsed = 0;
  Timer? _timer;
  String? _recordedPath;
  int _recordedSeconds = 0;
  bool _saving = false;

  // 노드 선택
  NodeModel? _fromNode;
  NodeModel? _toNode;

  // 공개 조건
  String _openCondition = 'date'; // 'date' or 'manual'
  DateTime _openDate = DateTime.now().add(const Duration(days: 365));

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
    _timer?.cancel();
    _pulseCtrl.dispose();
    _recorderCtrl.dispose();
    _titleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GlassBottomSheet(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Row(
              children: [
                Icon(Icons.mic_outlined, color: AppColors.primary, size: 22),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  '보이스 유언 녹음',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            // 제목
            TextField(
              controller: _titleCtrl,
              style: TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                labelText: '제목 *',
                hintText: '예: 내 아들에게 전하는 말',
                labelStyle: TextStyle(color: AppColors.textSecondary),
                hintStyle: TextStyle(color: AppColors.textTertiary),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.glassBorder)),
                focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primary)),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // 보낸 사람 (From)
            Text(
              '보낸 사람',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            _NodeSelector(
              selectedNode: _fromNode,
              placeholder: '보낸 사람 선택',
              onTap: () => _pickNode(isFrom: true),
            ),
            const SizedBox(height: AppSpacing.lg),

            // 받을 사람 (To)
            Text(
              '받을 사람',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            _NodeSelector(
              selectedNode: _toNode,
              placeholder: '받을 사람 선택',
              onTap: () => _pickNode(isFrom: false),
            ),
            const SizedBox(height: AppSpacing.lg),

            // 공개 조건
            Text(
              '공개 조건',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                _ConditionChip(
                  label: '날짜 지정',
                  isSelected: _openCondition == 'date',
                  onTap: () => setState(() => _openCondition = 'date'),
                ),
                const SizedBox(width: AppSpacing.sm),
                _ConditionChip(
                  label: '수동 공개',
                  isSelected: _openCondition == 'manual',
                  onTap: () => setState(() => _openCondition = 'manual'),
                ),
              ],
            ),
            if (_openCondition == 'date') ...[
              const SizedBox(height: AppSpacing.sm),
              GlassCard(
                onTap: _pickDate,
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today_outlined,
                        color: AppColors.primary, size: 20),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      '${_openDate.year}년 ${_openDate.month}월 ${_openDate.day}일',
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.edit_outlined,
                        color: AppColors.textTertiary, size: 18),
                  ],
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.xl),

            // 녹음 영역
            Center(
              child: Column(
                children: [
                  // 파형
                  RepaintBoundary(
                    child: SizedBox(
                      height: 60,
                      child: AudioWaveforms(
                        recorderController: _recorderCtrl,
                        size: Size(
                            MediaQuery.of(context).size.width - 96, 60),
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

                  // 타이머
                  Text(
                    _formatTime(_recordState == _RecordState.recorded
                        ? _recordedSeconds
                        : _elapsed),
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w300,
                      color: _recordState == _RecordState.recording
                          ? AppColors.accent
                          : AppColors.textPrimary,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // 녹음/정지 버튼
                  if (_recordState == _RecordState.idle ||
                      _recordState == _RecordState.recording)
                    GestureDetector(
                      onTap: _recordState == _RecordState.recording
                          ? _stopRecording
                          : _startRecording,
                      child: RepaintBoundary(
                        child: _recordState == _RecordState.recording
                            ? AnimatedBuilder(
                                animation: _pulseAnim,
                                builder: (_, child) => Transform.scale(
                                  scale: _pulseAnim.value,
                                  child: child,
                                ),
                                child: _buildMicCircle(isRecording: true),
                              )
                            : _buildMicCircle(isRecording: false),
                      ),
                    )
                  else ...[
                    // 녹음 완료: 다시 녹음
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GlassCard(
                          onTap: _resetRecording,
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.refresh,
                                  color: AppColors.textSecondary, size: 20),
                              const SizedBox(width: AppSpacing.sm),
                              Text(
                                '다시 녹음',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle,
                              color: AppColors.success, size: 18),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            '녹음 완료 ${_formatTime(_recordedSeconds)}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // 저장 버튼
            if (_recordState == _RecordState.recorded)
              SizedBox(
                width: double.infinity,
                child: PrimaryGlassButton(
                  label: '유언 봉인하기',
                  icon: Icon(Icons.lock_outlined,
                      color: AppColors.onPrimary, size: 18),
                  isLoading: _saving,
                  onPressed: _canSave ? _save : null,
                ),
              ),
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
          ],
        ),
      ),
    );
  }

  Widget _buildMicCircle({bool isRecording = false}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 64,
      height: 64,
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
        size: 28,
      ),
    );
  }

  bool get _canSave =>
      _titleCtrl.text.trim().isNotEmpty &&
      _fromNode != null &&
      _toNode != null &&
      _recordedPath != null &&
      !_saving;

  // ── 노드 선택 ──────────────────────────────────────────────────────────

  Future<void> _pickNode({required bool isFrom}) async {
    final nodesAsync = ref.read(nodeRepositoryProvider).getControllableNodes();
    final nodes = await nodesAsync;
    if (!mounted) return;

    final selected = await showModalBottomSheet<NodeModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _NodePickerSheet(nodes: nodes),
    );

    if (selected != null && mounted) {
      setState(() {
        if (isFrom) {
          _fromNode = selected;
        } else {
          _toNode = selected;
        }
      });
      HapticService.selection();
    }
  }

  // ── 날짜 선택 ──────────────────────────────────────────────────────────

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _openDate,
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 30)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            brightness: Theme.of(context).brightness,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null && mounted) {
      setState(() => _openDate = picked);
      HapticService.selection();
    }
  }

  // ── 녹음 제어 ──────────────────────────────────────────────────────────

  Future<void> _startRecording() async {
    final path = await ref.read(mediaServiceProvider).newVoicePath();
    await _recorderCtrl.record(path: path);
    _elapsed = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _elapsed++);
    });
    _pulseCtrl.repeat(reverse: true);
    setState(() => _recordState = _RecordState.recording);
  }

  Future<void> _stopRecording() async {
    _timer?.cancel();
    _pulseCtrl.stop();
    _pulseCtrl.reset();
    final path = await _recorderCtrl.stop();
    if (path == null) return;
    _recordedPath = path;
    _recordedSeconds = _elapsed;
    setState(() => _recordState = _RecordState.recorded);
  }

  void _resetRecording() {
    _timer?.cancel();
    _pulseCtrl.stop();
    _pulseCtrl.reset();
    _recordedPath = null;
    _recorderCtrl.refresh();
    setState(() {
      _recordState = _RecordState.idle;
      _elapsed = 0;
      _recordedSeconds = 0;
    });
  }

  // ── 저장 ───────────────────────────────────────────────────────────────

  Future<void> _save() async {
    if (!_canSave) return;
    setState(() => _saving = true);

    final id = await ref.read(voiceLegacyNotifierProvider.notifier).create(
          fromNodeId: _fromNode!.id,
          toNodeId: _toNode!.id,
          title: _titleCtrl.text.trim(),
          voicePath: _recordedPath!,
          durationSeconds: _recordedSeconds,
          openCondition: _openCondition,
          openDate: _openCondition == 'date' ? _openDate : null,
        );

    if (!mounted) return;

    if (id != null) {
      HapticService.celebration();
      Navigator.of(context).pop(true);
    } else {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('보이스 유언 저장에 실패했습니다.')),
      );
    }
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}

// ── 노드 선택 칩 ──────────────────────────────────────────────────────────

class _NodeSelector extends StatelessWidget {
  const _NodeSelector({
    required this.selectedNode,
    required this.placeholder,
    required this.onTap,
  });

  final NodeModel? selectedNode;
  final String placeholder;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      child: Row(
        children: [
          Icon(
            selectedNode != null
                ? Icons.person_outlined
                : Icons.person_add_outlined,
            color: selectedNode != null
                ? AppColors.primary
                : AppColors.textTertiary,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              selectedNode?.name ?? placeholder,
              style: TextStyle(
                fontSize: 15,
                color: selectedNode != null
                    ? AppColors.textPrimary
                    : AppColors.textTertiary,
                fontWeight:
                    selectedNode != null ? FontWeight.w500 : FontWeight.w400,
              ),
            ),
          ),
          Icon(Icons.chevron_right,
              color: AppColors.textTertiary, size: 18),
        ],
      ),
    );
  }
}

// ── 공개 조건 칩 ──────────────────────────────────────────────────────────

class _ConditionChip extends StatelessWidget {
  const _ConditionChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withAlpha(30)
              : AppColors.glassSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.glassBorder,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

// ── 노드 선택 바텀시트 ──────────────────────────────────────────────────

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
            '가족 구성원 선택',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (nodes.isEmpty)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Center(
                child: Text(
                  '등록된 가족이 없습니다.\n먼저 노드를 추가해 주세요.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 300),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: nodes.length,
                separatorBuilder: (_, __) =>
                    Divider(color: AppColors.glassBorder, height: 1),
                itemBuilder: (context, i) {
                  final node = nodes[i];
                  return ListTile(
                    leading: CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.primary.withAlpha(30),
                      child: Text(
                        node.name.isNotEmpty ? node.name[0] : '?',
                        style: TextStyle(
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
                              color: AppColors.textTertiary,
                            ),
                          )
                        : null,
                    onTap: () => Navigator.of(context).pop(node),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
