import 'dart:async';
import 'dart:io';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/path_utils.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../design/tokens/app_spacing.dart';
import '../../../design/motion/app_motion.dart';
import '../../../shared/models/memory_model.dart';
import '../../../shared/repositories/memory_repository.dart';
import '../../../shared/widgets/empty_state_widget.dart';

/// 추모 슬라이드쇼 — 고인의 사진 기억들을 자동 재생
///
/// - PageView + AutomaticKeepAliveClientMixin
/// - 3초 간격 자동 전환 (Timer.periodic)
/// - CrossFadeAnimation 전환 효과
/// - 하단에 고인 이름 + "그리운 기억들" 텍스트
/// - 음성 기억이 있으면 첫 번째 음성 자동 재생
class MemorialSlideshow extends ConsumerStatefulWidget {
  const MemorialSlideshow({
    super.key,
    required this.nodeId,
    required this.nodeName,
  });

  final String nodeId;
  final String nodeName;

  @override
  ConsumerState<MemorialSlideshow> createState() => _MemorialSlideshowState();
}

class _MemorialSlideshowState extends ConsumerState<MemorialSlideshow>
    with AutomaticKeepAliveClientMixin {
  final PageController _pageCtrl = PageController();
  Timer? _autoTimer;
  int _currentPage = 0;

  PlayerController? _bgmPlayer;
  bool _bgmReady = false;

  List<MemoryModel> _photos = [];
  MemoryModel? _firstVoice;

  bool _loading = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadMemories();
  }

  Future<void> _loadMemories() async {
    final memories =
        await ref.read(memoryRepositoryProvider).getForNode(widget.nodeId);

    if (!mounted) return;

    final photos =
        memories.where((m) => m.type == MemoryType.photo && m.filePath != null).toList();
    final voices =
        memories.where((m) => m.type == MemoryType.voice && m.filePath != null).toList();

    setState(() {
      _photos = photos;
      _firstVoice = voices.isNotEmpty ? voices.first : null;
      _loading = false;
    });

    if (_photos.length > 1) {
      _startAutoScroll();
    }

    if (_firstVoice != null) {
      _initBgmPlayer();
    }
  }

  void _startAutoScroll() {
    _autoTimer?.cancel();
    _autoTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted || _photos.isEmpty) return;
      final nextPage = (_currentPage + 1) % _photos.length;
      _pageCtrl.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 1000),
        curve: AppMotion.standard,
      );
    });
  }

  Future<void> _initBgmPlayer() async {
    if (_firstVoice?.filePath == null) return;
    try {
      _bgmPlayer = PlayerController();
      await _bgmPlayer!.preparePlayer(
        path: _firstVoice!.filePath!,
        shouldExtractWaveform: false,
      );
      if (!mounted) return;
      setState(() => _bgmReady = true);
      await _bgmPlayer!.startPlayer();
    } catch (_) {
      // 음성 재생 실패 시 무시 — 슬라이드쇼만 진행
    }
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    _pageCtrl.dispose();
    _bgmPlayer?.stopPlayer();
    _bgmPlayer?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_loading) {
      return const SizedBox(
        height: 300,
        child: Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (_photos.isEmpty) {
      return SizedBox(
        height: 300,
        child: EmptyStateWidget(
          icon: Icons.local_florist_outlined,
          title: '아직 기억이 없습니다',
          subtitle: '${widget.nodeName}의 소중한 사진을\n추가해 보세요.',
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── 슬라이드쇼 영역 ──────────────────────────────────────────
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SizedBox(
            height: 320,
            child: Stack(
              children: [
                // 사진 PageView (다음 2장 프리로드)
                PageView.builder(
                  controller: _pageCtrl,
                  itemCount: _photos.length,
                  onPageChanged: (i) {
                    if (mounted) setState(() => _currentPage = i);
                  },
                  itemBuilder: (_, i) {
                    // 다음 2장 이미지 프리캐시
                    if (i + 1 < _photos.length && _photos[i + 1].filePath != null) {
                      final img1 = PathUtils.resolveFileImage(_photos[i + 1].filePath);
                      if (img1 != null) precacheImage(img1, context);
                    }
                    if (i + 2 < _photos.length && _photos[i + 2].filePath != null) {
                      final img2 = PathUtils.resolveFileImage(_photos[i + 2].filePath);
                      if (img2 != null) precacheImage(img2, context);
                    }
                    return _SlideshowPage(
                      key: ValueKey(_photos[i].id),
                      memory: _photos[i],
                    );
                  },
                ),

                // 하단 그라디언트 + 텍스트
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.xxxl,
                      AppSpacing.lg,
                      AppSpacing.lg,
                    ),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black54],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.nodeName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          '그리운 기억들',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 페이지 인디케이터
                if (_photos.length > 1)
                  Positioned(
                    right: AppSpacing.lg,
                    top: AppSpacing.lg,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.isDark
                            ? Colors.black38
                            : Colors.black54,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_currentPage + 1} / ${_photos.length}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                // BGM 재생 인디케이터
                if (_bgmReady)
                  Positioned(
                    left: AppSpacing.lg,
                    top: AppSpacing.lg,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.isDark
                            ? Colors.black38
                            : Colors.black54,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.music_note, color: Colors.white70, size: 14),
                          SizedBox(width: 4),
                          Text(
                            '음성 재생 중',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),

        // ── 페이지 도트 인디케이터 ───────────────────────────────────
        if (_photos.length > 1) ...[
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _photos.length.clamp(0, 10), // 최대 10개 도트
              (i) => AnimatedContainer(
                duration: AppMotion.fast,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: i == _currentPage ? 16 : 6,
                height: 6,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  color: i == _currentPage
                      ? AppColors.primary
                      : AppColors.glassBorder,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// 개별 슬라이드 페이지
class _SlideshowPage extends StatelessWidget {
  const _SlideshowPage({super.key, required this.memory});
  final MemoryModel memory;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 1000),
      child: Image.file(
        File(memory.filePath!),
        key: ValueKey(memory.id),
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: AppColors.glassSurface,
          child: Center(
            child: Icon(
              Icons.broken_image_outlined,
              color: AppColors.primary,
              size: 48,
            ),
          ),
        ),
      ),
    );
  }
}
