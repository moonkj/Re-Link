import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/haptic_service.dart';
import '../../../design/glass/app_glass.dart';
import '../../../design/motion/app_motion.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../design/tokens/app_spacing.dart';
import '../providers/welcome_capsule_notifier.dart';

/// 수신자 첫 실행 시 보여지는 풀스크린 환영 오버레이
/// Glassmorphism 배경 + 타이프라이터 텍스트 + 음성 자동재생
class WelcomePlayback extends ConsumerStatefulWidget {
  const WelcomePlayback({super.key});

  @override
  ConsumerState<WelcomePlayback> createState() => _WelcomePlaybackState();
}

class _WelcomePlaybackState extends ConsumerState<WelcomePlayback>
    with TickerProviderStateMixin {
  // 페이드인 애니메이션
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  // 타이프라이터
  String _displayedText = '';
  String _fullText = '';
  int _charIndex = 0;
  Timer? _typeTimer;

  // 음성
  PlayerController? _playerCtrl;
  String? _audioPath;
  bool _audioReady = false;

  // CTA 버튼 표시 여부
  bool _showCta = false;

  @override
  void initState() {
    super.initState();

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: AppMotion.tier3Max,
    );
    _fadeAnim = CurvedAnimation(
      parent: _fadeCtrl,
      curve: AppMotion.enter,
    );

    _loadAndPlay();
  }

  Future<void> _loadAndPlay() async {
    final notifier = ref.read(welcomeCapsuleNotifierProvider.notifier);
    final data = await notifier.loadWelcomeData();

    _fullText = data.message ?? '';
    _audioPath = data.audioPath;

    // 페이드인 시작
    _fadeCtrl.forward();

    // 잠시 후 타이프라이터 시작
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    _startTypewriter();

    // 음성이 있으면 자동 재생
    if (_audioPath != null && _audioPath!.isNotEmpty) {
      final file = File(_audioPath!);
      if (await file.exists()) {
        await _prepareAudio(_audioPath!);
      }
    }
  }

  void _startTypewriter() {
    if (_fullText.isEmpty) {
      // 텍스트 없으면 바로 CTA 표시
      _revealCta();
      return;
    }

    _typeTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_charIndex < _fullText.length) {
        setState(() {
          _charIndex++;
          _displayedText = _fullText.substring(0, _charIndex);
        });
      } else {
        timer.cancel();
        // 타이핑 완료 후 CTA
        Future<void>.delayed(const Duration(milliseconds: 400), () {
          if (mounted) _revealCta();
        });
      }
    });
  }

  Future<void> _prepareAudio(String path) async {
    _playerCtrl = PlayerController();
    await _playerCtrl!.preparePlayer(
      path: path,
      shouldExtractWaveform: true,
    );
    _playerCtrl!.onPlayerStateChanged.listen((state) {
      if (mounted) setState(() {});
    });
    if (mounted) {
      setState(() => _audioReady = true);
      // 자동 재생
      await _playerCtrl!.startPlayer();
    }
  }

  void _revealCta() {
    if (mounted) {
      setState(() => _showCta = true);
    }
  }

  @override
  void dispose() {
    _typeTimer?.cancel();
    _fadeCtrl.dispose();
    _playerCtrl?.stopPlayer();
    _playerCtrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: FadeTransition(
        opacity: _fadeAnim,
        child: Stack(
          children: [
            // ── Glassmorphism 배경 ─────────────────────────────────────────────
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: isDark
                          ? [
                              const Color(0xE60D1117),
                              const Color(0xF01E2840),
                            ]
                          : [
                              const Color(0xE6F5F7FA),
                              const Color(0xF0FFFFFF),
                            ],
                    ),
                  ),
                ),
              ),
            ),

            // ── 콘텐츠 ────────────────────────────────────────────────────────
            Positioned.fill(
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.pagePadding),
                  child: Column(
                    children: [
                      const Spacer(flex: 2),

                      // 환영 아이콘
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.primaryMint,
                              AppColors.primaryBlue,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryMint.withAlpha(80),
                              blurRadius: 30,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.favorite_rounded,
                          color: Colors.white,
                          size: 36,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxl),

                      // "가족에게서 온 메시지" 라벨
                      Text(
                        '가족에게서 온 메시지',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxl),

                      // ── 타이프라이터 텍스트 ──────────────────────────────────
                      if (_fullText.isNotEmpty)
                        GlassCard(
                          padding: const EdgeInsets.all(AppSpacing.xxl),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: 80,
                              maxWidth: size.width - AppSpacing.pagePadding * 2,
                            ),
                            child: Text(
                              _displayedText,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                                height: 1.6,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),

                      const SizedBox(height: AppSpacing.xxl),

                      // ── 음성 웨이브폼 ────────────────────────────────────────
                      if (_audioReady && _playerCtrl != null)
                        GlassCard(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xl,
                            vertical: AppSpacing.lg,
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.graphic_eq_rounded,
                                    size: 18,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Text(
                                    '음성 메시지',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const Spacer(),
                                  // 재생/일시정지
                                  GestureDetector(
                                    onTap: _toggleAudio,
                                    child: Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.primary.withAlpha(25),
                                      ),
                                      child: Icon(
                                        _playerCtrl?.playerState ==
                                                PlayerState.playing
                                            ? Icons.pause_rounded
                                            : Icons.play_arrow_rounded,
                                        color: AppColors.primary,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.md),
                              RepaintBoundary(
                                child: SizedBox(
                                  height: 50,
                                  child: AudioFileWaveforms(
                                    playerController: _playerCtrl!,
                                    size: Size(
                                      size.width - AppSpacing.pagePadding * 2 - AppSpacing.xl * 2,
                                      50,
                                    ),
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
                            ],
                          ),
                        ),

                      const Spacer(flex: 3),

                      // ── CTA 버튼 ─────────────────────────────────────────────
                      AnimatedOpacity(
                        opacity: _showCta ? 1.0 : 0.0,
                        duration: AppMotion.slow,
                        curve: AppMotion.enter,
                        child: AnimatedSlide(
                          offset: _showCta ? Offset.zero : const Offset(0, 0.2),
                          duration: AppMotion.slow,
                          curve: AppMotion.enter,
                          child: SizedBox(
                            width: double.infinity,
                            child: PrimaryGlassButton(
                              label: '가족 트리 보러 가기',
                              icon: const Icon(
                                Icons.account_tree_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                              onPressed: _showCta ? _goToCanvas : null,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // 건너뛰기 (타이핑 중에도 사용 가능)
                      if (!_showCta)
                        GestureDetector(
                          onTap: _skipAndGo,
                          child: Text(
                            '건너뛰기',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textTertiary,
                              decoration: TextDecoration.underline,
                              decorationColor: AppColors.textTertiary,
                            ),
                          ),
                        ),

                      const SizedBox(height: AppSpacing.xxl),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleAudio() async {
    if (_playerCtrl == null) return;
    HapticService.light();
    if (_playerCtrl!.playerState == PlayerState.playing) {
      await _playerCtrl!.pausePlayer();
    } else {
      await _playerCtrl!.startPlayer();
    }
    setState(() {});
  }

  Future<void> _goToCanvas() async {
    HapticService.celebration();
    await ref.read(welcomeCapsuleNotifierProvider.notifier).markAsPlayed();
    if (!mounted) return;
    context.go(AppRoutes.canvas);
  }

  void _skipAndGo() {
    _typeTimer?.cancel();
    _playerCtrl?.stopPlayer();
    _goToCanvas();
  }
}
