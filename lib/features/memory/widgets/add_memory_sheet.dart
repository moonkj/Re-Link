import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart'; // duration 체크용 임시 컨트롤러
import '../../../core/errors/app_error.dart';
import '../../../design/glass/app_glass.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../design/tokens/app_spacing.dart';
import '../../../shared/models/memory_model.dart';
import '../../../shared/models/user_plan.dart';
import '../../../core/services/media/media_service.dart';
import '../../../shared/repositories/memory_repository.dart';
import '../../../shared/repositories/settings_repository.dart';
import '../../../core/utils/haptic_service.dart';
import '../../badges/providers/badge_notifier.dart';
import '../../badges/widgets/badge_earned_dialog.dart';
import '../providers/memory_notifier.dart';
import 'voice_recorder_sheet.dart';

/// 기억 타입 선택 + 사진/메모 추가 시트
class AddMemorySheet extends ConsumerStatefulWidget {
  const AddMemorySheet({super.key, required this.nodeId});
  final String nodeId;

  @override
  ConsumerState<AddMemorySheet> createState() => _AddMemorySheetState();
}

/// 감정 태그 (메모용)
enum EmotionTag {
  joy('기쁨', '😊'),
  longing('그리움', '🥺'),
  surprise('놀람', '😲'),
  love('사랑', '❤️'),
  sadness('슬픔', '😢');

  const EmotionTag(this.label, this.emoji);
  final String label;
  final String emoji;
}

class _AddMemorySheetState extends ConsumerState<AddMemorySheet> {
  MemoryType? _selectedType;
  bool _saving = false;

  // 메모 필드
  final _titleCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  // 감정 태그 + 공개 범위 (메모용)
  EmotionTag? _emotionTag;
  bool _isPrivate = false;

  // 사진 미리보기
  String? _photoPath;
  String? _thumbPath;
  DateTime? _dateTaken;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _noteCtrl.dispose();
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

            if (_selectedType == null) ...[
              Text(
                '기억 추가',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              const SizedBox(height: AppSpacing.lg),
              _TypeSelector(onSelect: (type) {
                if (type == MemoryType.voice) {
                  _openVoiceRecorder();
                } else {
                  setState(() => _selectedType = type);
                }
              }),
            ] else if (_selectedType == MemoryType.photo) ...[
              _PhotoForm(
                photoPath: _photoPath,
                thumbPath: _thumbPath,
                dateTaken: _dateTaken,
                titleCtrl: _titleCtrl,
                saving: _saving,
                onPickGallery: _pickFromGallery,
                onPickCamera: _pickFromCamera,
                onDateChanged: (d) => setState(() => _dateTaken = d),
                onSave: _savePhoto,
                onBack: () => setState(() {
                  _selectedType = null;
                  _photoPath = null;
                  _thumbPath = null;
                }),
                isPrivate: _isPrivate,
                onPrivateChanged: (v) => setState(() => _isPrivate = v),
              ),
            ] else if (_selectedType == MemoryType.note) ...[
              _NoteForm(
                titleCtrl: _titleCtrl,
                noteCtrl: _noteCtrl,
                saving: _saving,
                emotionTag: _emotionTag,
                isPrivate: _isPrivate,
                onEmotionChanged: (t) => setState(() => _emotionTag = t),
                onPrivateChanged: (v) => setState(() => _isPrivate = v),
                onSave: _saveNote,
                onBack: () => setState(() => _selectedType = null),
              ),
            ] else if (_selectedType == MemoryType.video) ...[
              _VideoForm(
                nodeId: widget.nodeId,
                onBack: () => setState(() => _selectedType = null),
              ),
            ],

            SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
          ],
        ),
      ),
    );
  }

  // ── 사진 ──────────────────────────────────────────────────────────────────

  Future<void> _pickFromGallery() async {
    setState(() => _saving = true);
    try {
      await _checkPhotoAndPick(fromCamera: false);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickFromCamera() async {
    setState(() => _saving = true);
    try {
      await _checkPhotoAndPick(fromCamera: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _checkPhotoAndPick({required bool fromCamera}) async {
    final media = ref.read(mediaServiceProvider);
    final result = fromCamera
        ? await media.captureAndSavePhoto()
        : await media.pickAndSavePhoto();
    if (!mounted || result == null) return;
    setState(() {
      _photoPath = result.photoPath;
      _thumbPath = result.thumbnailPath;
    });
  }

  Future<void> _savePhoto() async {
    if (_photoPath == null) return;
    setState(() => _saving = true);
    try {
      // 플랜 제한 체크
      final plan = await ref.read(settingsRepositoryProvider).getUserPlan();
      final count = await ref.read(memoryRepositoryProvider).totalPhotoCount();
      if (count >= plan.maxPhotos) {
        throw PlanLimitError(
          feature: '사진 추가',
          currentPlan: plan.displayName,
          requiredPlan: plan == UserPlan.free ? '플러스' : '패밀리',
        );
      }
      // 파일은 이미 선택/저장됨 → 바로 DB 저장
      await ref.read(memoryRepositoryProvider).create(
        nodeId: widget.nodeId,
        type: MemoryType.photo,
        title: _titleCtrl.text.trim().isEmpty ? null : _titleCtrl.text.trim(),
        filePath: _photoPath,
        thumbnailPath: _thumbPath,
        dateTaken: _dateTaken ?? DateTime.now(),
        isPrivate: _isPrivate,
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
      _showLimitSnack(e);
    } catch (e) {
      if (!mounted) return;
      _showErrorSnack('$e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // ── 메모 ──────────────────────────────────────────────────────────────────

  Future<void> _saveNote() async {
    final desc = _noteCtrl.text.trim();
    if (desc.isEmpty) {
      _showErrorSnack('내용을 입력해 주세요');
      return;
    }
    setState(() => _saving = true);
    try {
      await ref.read(memoryNotifierProvider.notifier).addNote(
        nodeId: widget.nodeId,
        description: desc,
        title: _titleCtrl.text.trim().isEmpty ? null : _titleCtrl.text.trim(),
        tags: _emotionTag != null ? [_emotionTag!.name] : const [],
        isPrivate: _isPrivate,
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
    } catch (e) {
      if (!mounted) return;
      _showErrorSnack('$e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // ── 음성 녹음 시트 열기 ───────────────────────────────────────────────────

  Future<void> _openVoiceRecorder() async {
    Navigator.of(context).pop(); // 타입 선택 시트 닫기
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => VoiceRecorderSheet(nodeId: widget.nodeId),
    );
  }

  // ── 유틸 ──────────────────────────────────────────────────────────────────

  void _showLimitSnack(PlanLimitError e) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(e.message),
      backgroundColor: AppColors.warning,
      action: SnackBarAction(label: '업그레이드', onPressed: () => Navigator.of(context).pop()),
    ));
  }

  void _showErrorSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: AppColors.error,
    ));
  }
}

// ── 타입 선택 ──────────────────────────────────────────────────────────────

class _TypeSelector extends StatelessWidget {
  const _TypeSelector({required this.onSelect});
  final void Function(MemoryType) onSelect;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _TypeButton(icon: Icons.photo_library_outlined, label: '사진', color: AppColors.secondary, onTap: () => onSelect(MemoryType.photo)),
        const SizedBox(width: AppSpacing.sm),
        _TypeButton(icon: Icons.mic_outlined, label: '음성', color: AppColors.accent, onTap: () => onSelect(MemoryType.voice)),
        const SizedBox(width: AppSpacing.sm),
        _TypeButton(icon: Icons.notes_outlined, label: '메모', color: AppColors.primary, onTap: () => onSelect(MemoryType.note)),
        const SizedBox(width: AppSpacing.sm),
        _TypeButton(icon: Icons.videocam_outlined, label: '영상', color: AppColors.tempWarm, onTap: () => onSelect(MemoryType.video)),
      ],
    );
  }
}

class _TypeButton extends StatelessWidget {
  const _TypeButton({required this.icon, required this.label, required this.color, required this.onTap});
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GlassCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: AppSpacing.xs),
            Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

// ── 사진 폼 ──────────────────────────────────────────────────────────────────

class _PhotoForm extends StatelessWidget {
  const _PhotoForm({
    required this.photoPath,
    required this.thumbPath,
    required this.dateTaken,
    required this.titleCtrl,
    required this.saving,
    required this.onPickGallery,
    required this.onPickCamera,
    required this.onDateChanged,
    required this.onSave,
    required this.onBack,
    required this.isPrivate,
    required this.onPrivateChanged,
  });

  final String? photoPath;
  final String? thumbPath;
  final DateTime? dateTaken;
  final TextEditingController titleCtrl;
  final bool saving;
  final VoidCallback onPickGallery;
  final VoidCallback onPickCamera;
  final void Function(DateTime?) onDateChanged;
  final VoidCallback onSave;
  final VoidCallback onBack;
  final bool isPrivate;
  final void Function(bool) onPrivateChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            GestureDetector(onTap: onBack, child: Icon(Icons.arrow_back, color: AppColors.textSecondary)),
            const SizedBox(width: AppSpacing.sm),
            Text('사진 기억', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),

        // 사진 미리보기 or 선택 버튼
        if (photoPath != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(File(photoPath!), height: 200, width: double.infinity, fit: BoxFit.cover),
          )
        else
          Row(
            children: [
              Expanded(
                child: GlassCard(
                  onTap: onPickGallery,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                  child: Column(
                    children: [
                      Icon(Icons.photo_library_outlined, color: AppColors.secondary, size: 28),
                      const SizedBox(height: 4),
                      Text('갤러리', style: TextStyle(fontSize: 12, color: AppColors.secondary)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: GlassCard(
                  onTap: onPickCamera,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                  child: Column(
                    children: [
                      Icon(Icons.camera_alt_outlined, color: AppColors.secondary, size: 28),
                      const SizedBox(height: 4),
                      Text('카메라', style: TextStyle(fontSize: 12, color: AppColors.secondary)),
                    ],
                  ),
                ),
              ),
            ],
          ),

        if (photoPath != null) ...[
          const SizedBox(height: AppSpacing.sm),
          GlassCard(
            onTap: onPickGallery,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.refresh, color: AppColors.textSecondary, size: 16),
                SizedBox(width: 4),
                Text('사진 변경', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],

        const SizedBox(height: AppSpacing.md),

        // 제목 (선택)
        GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
          child: Row(
            children: [
              Icon(Icons.title, color: AppColors.primary, size: 18),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: TextField(
                  controller: titleCtrl,
                  style: TextStyle(fontSize: 14, color: AppColors.textPrimary),
                  decoration: InputDecoration(
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
        const SizedBox(height: AppSpacing.md),

        // 공개 범위 토글
        GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 2),
          child: Row(
            children: [
              Icon(
                isPrivate ? Icons.lock_outline : Icons.public,
                color: isPrivate ? AppColors.accent : AppColors.primary,
                size: 18,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  isPrivate ? '나만 보기' : '가족과 공유',
                  style: TextStyle(fontSize: 14, color: AppColors.textPrimary),
                ),
              ),
              Switch(
                value: isPrivate,
                onChanged: onPrivateChanged,
                activeThumbColor: AppColors.accent,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),

        SizedBox(
          width: double.infinity,
          child: PrimaryGlassButton(
            label: '저장',
            isLoading: saving,
            onPressed: photoPath == null ? null : onSave,
          ),
        ),
      ],
    );
  }
}

// ── 영상 폼 ──────────────────────────────────────────────────────────────────

class _VideoForm extends ConsumerStatefulWidget {
  const _VideoForm({required this.nodeId, this.onSaved, required this.onBack});
  final String nodeId;
  final VoidCallback? onSaved;
  final VoidCallback onBack;

  @override
  ConsumerState<_VideoForm> createState() => _VideoFormState();
}

class _VideoFormState extends ConsumerState<_VideoForm> {
  String? _videoPath;
  String? _thumbPath;
  int _durationSeconds = 0;
  final _titleCtrl = TextEditingController();
  bool _saving = false;
  bool _picking = false;
  bool _isPrivate = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickVideo() async {
    setState(() => _picking = true);
    try {
      final plan = await ref.read(settingsRepositoryProvider).getUserPlan();
      if (!plan.hasVideo) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('영상은 플러스 플랜부터 사용 가능합니다'), backgroundColor: AppColors.error),
        );
        return;
      }

      final media = ref.read(mediaServiceProvider);
      final videoPath = await media.pickAndSaveVideo();
      if (!mounted || videoPath == null) return;

      // duration 체크만을 위한 임시 컨트롤러 (미리보기에는 사용 안 함)
      final ctrl = VideoPlayerController.file(File(videoPath));
      await ctrl.initialize();
      final duration = ctrl.value.duration.inSeconds;
      await ctrl.dispose();

      // 플랜 초 제한 초과 시 파일 삭제 후 에러
      if (plan.maxVideoSeconds > 0 && duration > plan.maxVideoSeconds) {
        try { File(videoPath).deleteSync(); } catch (_) {}
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('영상이 너무 깁니다 (최대 ${plan.maxVideoSeconds}초)'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      // 썸네일 생성 (정적 이미지로 미리보기)
      final thumbPath = await media.generateVideoThumbnail(videoPath);

      if (!mounted) return;
      setState(() {
        _videoPath = videoPath;
        _thumbPath = thumbPath;
        _durationSeconds = duration;
      });
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  Future<void> _captureVideo() async {
    setState(() => _picking = true);
    try {
      final plan = await ref.read(settingsRepositoryProvider).getUserPlan();
      if (!plan.hasVideo) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('영상은 플러스 플랜부터 사용 가능합니다'), backgroundColor: AppColors.error),
        );
        return;
      }
      final media = ref.read(mediaServiceProvider);
      final videoPath = await media.captureAndSaveVideo(maxSeconds: plan.maxVideoSeconds);
      if (!mounted || videoPath == null) return;

      final ctrl = VideoPlayerController.file(File(videoPath));
      await ctrl.initialize();
      final duration = ctrl.value.duration.inSeconds;
      await ctrl.dispose();

      final thumbPath = await media.generateVideoThumbnail(videoPath);

      if (!mounted) return;
      setState(() {
        _videoPath = videoPath;
        _thumbPath = thumbPath;
        _durationSeconds = duration;
      });
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  Future<void> _save() async {
    if (_videoPath == null) return;
    setState(() => _saving = true);
    try {
      final plan = await ref.read(settingsRepositoryProvider).getUserPlan();
      final count = await ref.read(memoryRepositoryProvider).totalVideoCount();
      if (count >= plan.maxVideoCount) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('영상 저장 한도 초과 (플랜: ${plan.displayName})'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      await ref.read(memoryRepositoryProvider).create(
        nodeId: widget.nodeId,
        type: MemoryType.video,
        title: _titleCtrl.text.trim().isEmpty ? null : _titleCtrl.text.trim(),
        filePath: _videoPath,
        thumbnailPath: _thumbPath,
        durationSeconds: _durationSeconds,
        dateTaken: DateTime.now(),
        isPrivate: _isPrivate,
      );

      widget.onSaved?.call();
      if (mounted) Navigator.of(context).pop(true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 헤더
        Row(
          children: [
            GestureDetector(onTap: widget.onBack, child: Icon(Icons.arrow_back, color: AppColors.textSecondary)),
            const SizedBox(width: AppSpacing.sm),
            Text('영상 기억', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),

        // 영상 선택 영역
        if (_videoPath == null) ...[
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: _picking ? null : _pickVideo,
                  child: Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.glassSurface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.glassBorder),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.video_library_outlined, color: AppColors.textSecondary, size: 32),
                        const SizedBox(height: 6),
                        Text('갤러리', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: GestureDetector(
                  onTap: _picking ? null : _captureVideo,
                  child: Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.glassSurface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.glassBorder),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.videocam_outlined, color: AppColors.textSecondary, size: 32),
                        const SizedBox(height: 6),
                        Text('카메라', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_picking) ...[
            const SizedBox(height: AppSpacing.sm),
            Center(child: CircularProgressIndicator(color: AppColors.primary)),
          ],
        ] else ...[
          // 선택 후: 썸네일 이미지 미리보기
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // 썸네일 이미지 (정적 프레임)
                  _thumbPath != null
                      ? Image.file(File(_thumbPath!), fit: BoxFit.cover)
                      : Container(color: AppColors.bgSurface),
                  // 재생 아이콘 (시각적 힌트)
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.play_arrow, color: Colors.white, size: 32),
                    ),
                  ),
                  // 길이 배지
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _formatDuration(_durationSeconds),
                        style: const TextStyle(color: Colors.white, fontSize: 11),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextButton.icon(
            onPressed: _pickVideo,
            icon: Icon(Icons.swap_horiz, size: 16, color: AppColors.primary),
            label: Text('다시 선택', style: TextStyle(color: AppColors.primary, fontSize: 13)),
          ),
        ],

        const SizedBox(height: AppSpacing.md),

        // 제목 입력 (영상 선택 후에만 표시)
        if (_videoPath != null) ...[
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
          const SizedBox(height: AppSpacing.md),

          // 공개 범위 토글
          GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 2),
            child: Row(
              children: [
                Icon(
                  _isPrivate ? Icons.lock_outline : Icons.public,
                  color: _isPrivate ? AppColors.accent : AppColors.primary,
                  size: 18,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    _isPrivate ? '나만 보기' : '가족과 공유',
                    style: TextStyle(fontSize: 14, color: AppColors.textPrimary),
                  ),
                ),
                Switch(
                  value: _isPrivate,
                  onChanged: (v) => setState(() => _isPrivate = v),
                  activeThumbColor: AppColors.accent,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          SizedBox(
            width: double.infinity,
            child: PrimaryGlassButton(
              label: '저장',
              isLoading: _saving,
              onPressed: _save,
            ),
          ),
        ],
      ],
    );
  }
}

// ── 메모 폼 ──────────────────────────────────────────────────────────────────

class _NoteForm extends StatelessWidget {
  const _NoteForm({
    required this.titleCtrl,
    required this.noteCtrl,
    required this.saving,
    required this.emotionTag,
    required this.isPrivate,
    required this.onEmotionChanged,
    required this.onPrivateChanged,
    required this.onSave,
    required this.onBack,
  });

  final TextEditingController titleCtrl;
  final TextEditingController noteCtrl;
  final bool saving;
  final EmotionTag? emotionTag;
  final bool isPrivate;
  final void Function(EmotionTag?) onEmotionChanged;
  final void Function(bool) onPrivateChanged;
  final VoidCallback onSave;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            GestureDetector(onTap: onBack, child: Icon(Icons.arrow_back, color: AppColors.textSecondary)),
            const SizedBox(width: AppSpacing.sm),
            Text('메모 기억', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),

        GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
          child: Row(
            children: [
              Icon(Icons.title, color: AppColors.primary, size: 18),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: TextField(
                  controller: titleCtrl,
                  style: TextStyle(fontSize: 14, color: AppColors.textPrimary),
                  decoration: InputDecoration(
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
        const SizedBox(height: AppSpacing.sm),

        GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Icon(Icons.notes_outlined, color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: TextField(
                  controller: noteCtrl,
                  maxLines: 6,
                  style: TextStyle(fontSize: 14, color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: '내용을 입력하세요...',
                    hintStyle: TextStyle(fontSize: 14, color: AppColors.textTertiary),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // 감정 태그 선택
        Text(
          '감정 태그',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.xs),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: EmotionTag.values.map((tag) {
            final selected = emotionTag == tag;
            return GestureDetector(
              onTap: () => onEmotionChanged(selected ? null : tag),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: selected
                      ? AppColors.primary.withAlpha(30)
                      : AppColors.glassSurface,
                  border: Border.all(
                    color: selected ? AppColors.primary : AppColors.glassBorder,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  '${tag.emoji} ${tag.label}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    color: selected ? AppColors.primary : AppColors.textSecondary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: AppSpacing.md),

        // 공개 범위 토글
        GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 2),
          child: Row(
            children: [
              Icon(
                isPrivate ? Icons.lock_outline : Icons.public,
                color: isPrivate ? AppColors.accent : AppColors.primary,
                size: 18,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  isPrivate ? '개인 전용 메모' : '가족 공유 메모',
                  style: TextStyle(fontSize: 14, color: AppColors.textPrimary),
                ),
              ),
              Switch(
                value: isPrivate,
                onChanged: onPrivateChanged,
                activeThumbColor: AppColors.accent,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),

        SizedBox(
          width: double.infinity,
          child: PrimaryGlassButton(label: '저장', isLoading: saving, onPressed: onSave),
        ),
      ],
    );
  }
}
