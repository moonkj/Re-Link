import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/auth/auth_service.dart';
import '../../../design/glass/app_glass.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../design/tokens/app_radius.dart';
import '../../../design/tokens/app_spacing.dart';
import '../providers/auth_notifier.dart';

/// 로그인 화면
/// - Apple Sign-In (iOS HIG 준수)
/// - Google Sign-In
/// - "나중에 하기" 스킵 옵션
///
/// 패밀리 플랜 전용 기능(클라우드 동기화, 가족 공유) 진입 시 표시
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _isAppleLoading = false;
  bool _isGoogleLoading = false;

  bool get _isAnyLoading => _isAppleLoading || _isGoogleLoading;

  // ── Apple Sign-In ──────────────────────────────────────────────────────

  Future<void> _onAppleSignIn() async {
    if (_isAnyLoading) return;
    setState(() => _isAppleLoading = true);

    try {
      await ref.read(authNotifierProvider.notifier).signInWithApple();

      if (!mounted) return;
      final authState = ref.read(authNotifierProvider);
      authState.when(
        data: (user) {
          if (user != null) {
            // 로그인 성공 → 화면 닫기
            Navigator.of(context).pop(true);
          }
        },
        error: (e, _) => _showError(e is AuthException ? e.message : '로그인에 실패했습니다. 다시 시도해 주세요.'),
        loading: () {},
      );
    } catch (e) {
      if (!mounted) return;
      final message = e is AuthException ? e.message : '로그인에 실패했습니다. 다시 시도해 주세요.';
      _showError(message);
    } finally {
      if (mounted) setState(() => _isAppleLoading = false);
    }
  }

  // ── Google Sign-In ─────────────────────────────────────────────────────

  Future<void> _onGoogleSignIn() async {
    if (_isAnyLoading) return;
    setState(() => _isGoogleLoading = true);

    try {
      await ref.read(authNotifierProvider.notifier).signInWithGoogle();

      if (!mounted) return;
      final authState = ref.read(authNotifierProvider);
      authState.when(
        data: (user) {
          if (user != null) {
            Navigator.of(context).pop(true);
          }
        },
        error: (e, _) => _showError(e is AuthException ? e.message : '로그인에 실패했습니다. 다시 시도해 주세요.'),
        loading: () {},
      );
    } catch (e) {
      if (!mounted) return;
      final message = e is AuthException ? e.message : '로그인에 실패했습니다. 다시 시도해 주세요.';
      _showError(message);
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  // ── 에러 스낵바 ────────────────────────────────────────────────────────

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.radiusSm,
        ),
        margin: const EdgeInsets.all(AppSpacing.lg),
      ),
    );
  }

  // ── 나중에 하기 ────────────────────────────────────────────────────────

  void _onSkip() {
    Navigator.of(context).pop(false);
  }

  // ── UI ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgBase,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.bgBase,
              AppColors.nightSurface.withValues(alpha: 0.6),
              AppColors.bgBase,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.pagePadding,
            ),
            child: Column(
              children: [
                // ── 상단 닫기 버튼 ───────────────────────────────────────
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.md),
                    child: GestureDetector(
                      onTap: _onSkip,
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: AppColors.nightElevated.withValues(alpha: 0.6),
                          borderRadius: AppRadius.radiusFull,
                        ),
                        child: Icon(
                          CupertinoIcons.xmark,
                          color: AppColors.textSecondary,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ),

                const Spacer(flex: 2),

                // ── 로고 영역 ─────────────────────────────────────────────
                _LogoSection(),

                const SizedBox(height: AppSpacing.xxxl),

                // ── 혜택 카드 ─────────────────────────────────────────────
                _BenefitsCard(),

                const Spacer(flex: 3),

                // ── 로그인 버튼들 ─────────────────────────────────────────
                _SignInButtons(
                  isAppleLoading: _isAppleLoading,
                  isGoogleLoading: _isGoogleLoading,
                  onApple: _onAppleSignIn,
                  onGoogle: _onGoogleSignIn,
                ),

                const SizedBox(height: AppSpacing.xxl),

                // ── 나중에 하기 ───────────────────────────────────────────
                TextButton(
                  onPressed: _isAnyLoading ? null : _onSkip,
                  child: Text(
                    '나중에 하기',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textTertiary,
                      decoration: TextDecoration.underline,
                      decorationColor: AppColors.textTertiary,
                    ),
                  ),
                ),

                // ── 약관 ──────────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.only(
                    top: AppSpacing.sm,
                    bottom: AppSpacing.lg,
                  ),
                  child: Text(
                    '로그인 시 이용약관 및 개인정보처리방침에 동의하게 됩니다.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textTertiary,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── 로고 섹션 ────────────────────────────────────────────────────────────────

class _LogoSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 아이콘
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primaryMint, AppColors.primaryBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: AppRadius.radiusXxl,
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryMint.withValues(alpha: 0.35),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            CupertinoIcons.link,
            color: Colors.white,
            size: 36,
          ),
        ),

        const SizedBox(height: AppSpacing.lg),

        // 앱 이름
        Text(
          'Re-Link',
          style: TextStyle(
            fontSize: 44,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: -1.5,
          ),
        ),

        const SizedBox(height: AppSpacing.sm),

        // 설명
        Text(
          '패밀리 플랜을 시작하려면 로그인이 필요합니다',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

// ── 혜택 카드 ────────────────────────────────────────────────────────────────

class _BenefitsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '패밀리 플랜 혜택',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _BenefitRow(
            icon: CupertinoIcons.cloud_upload,
            color: AppColors.primaryBlue,
            title: '클라우드 동기화',
            subtitle: '20GB 자동 백업 · iCloud/Google Drive',
          ),
          const SizedBox(height: AppSpacing.md),
          _BenefitRow(
            icon: CupertinoIcons.person_3,
            color: AppColors.primaryMint,
            title: '가족 실시간 공유',
            subtitle: '최대 6명이 함께 기억을 쌓아요',
          ),
          const SizedBox(height: AppSpacing.md),
          _BenefitRow(
            icon: CupertinoIcons.memories,
            color: AppColors.accentWarm,
            title: '무제한 노드 · 사진 · 음성',
            subtitle: '제한 없이 가족 트리를 완성하세요',
          ),
        ],
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  const _BenefitRow({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: AppRadius.radiusSm,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── 로그인 버튼 묶음 ─────────────────────────────────────────────────────────

class _SignInButtons extends StatelessWidget {
  const _SignInButtons({
    required this.isAppleLoading,
    required this.isGoogleLoading,
    required this.onApple,
    required this.onGoogle,
  });

  final bool isAppleLoading;
  final bool isGoogleLoading;
  final VoidCallback onApple;
  final VoidCallback onGoogle;

  bool get _isAnyLoading => isAppleLoading || isGoogleLoading;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Apple Sign-In (검은 배경 — iOS HIG 준수)
        _AppleSignInButton(
          isLoading: isAppleLoading,
          isDisabled: _isAnyLoading && !isAppleLoading,
          onPressed: onApple,
        ),

        const SizedBox(height: AppSpacing.md),

        // Google Sign-In (흰 배경)
        _GoogleSignInButton(
          isLoading: isGoogleLoading,
          isDisabled: _isAnyLoading && !isGoogleLoading,
          onPressed: onGoogle,
        ),
      ],
    );
  }
}

// ── Apple Sign-In 버튼 ───────────────────────────────────────────────────────

class _AppleSignInButton extends StatelessWidget {
  const _AppleSignInButton({
    required this.isLoading,
    required this.isDisabled,
    required this.onPressed,
  });

  final bool isLoading;
  final bool isDisabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (isLoading || isDisabled) ? null : onPressed,
      child: AnimatedOpacity(
        opacity: isDisabled ? 0.4 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Container(
          width: double.infinity,
          height: 54,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: AppRadius.radiusLg,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                )
              else ...[
                const Icon(
                  Icons.apple,
                  color: Colors.white,
                  size: 22,
                ),
                const SizedBox(width: AppSpacing.sm),
                const Text(
                  'Apple로 계속하기',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ── Google Sign-In 버튼 ──────────────────────────────────────────────────────

class _GoogleSignInButton extends StatelessWidget {
  const _GoogleSignInButton({
    required this.isLoading,
    required this.isDisabled,
    required this.onPressed,
  });

  final bool isLoading;
  final bool isDisabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (isLoading || isDisabled) ? null : onPressed,
      child: AnimatedOpacity(
        opacity: isDisabled ? 0.4 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Container(
          width: double.infinity,
          height: 54,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppRadius.radiusLg,
            border: Border.all(
              color: const Color(0xFFDDE1E7),
              width: 1.0,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Color(0xFF4285F4)),
                  ),
                )
              else ...[
                _GoogleLogo(),
                const SizedBox(width: AppSpacing.sm),
                const Text(
                  'Google로 계속하기',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F1F1F),
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Google 'G' 로고 (패키지 없이 CustomPaint로 구현)
class _GoogleLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(20, 20),
      painter: _GoogleLogoPainter(),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // G 로고 4색 원호 (간략화 버전)
    final colors = [
      const Color(0xFF4285F4), // Blue
      const Color(0xFF34A853), // Green
      const Color(0xFFFBBC05), // Yellow
      const Color(0xFFEA4335), // Red
    ];

    final sweepAngle = 3.14159 / 2; // 90도

    for (var i = 0; i < 4; i++) {
      final paint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.18;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius * 0.72),
        (sweepAngle * i) - 3.14159 / 4,
        sweepAngle,
        false,
        paint,
      );
    }

    // 중앙 흰 원 (G자 컷아웃)
    canvas.drawCircle(
      center,
      radius * 0.38,
      Paint()..color = Colors.white,
    );

    // G 가로선 (오른쪽)
    canvas.drawRect(
      Rect.fromLTWH(
        center.dx,
        center.dy - size.height * 0.09,
        radius * 0.7,
        size.height * 0.18,
      ),
      Paint()..color = const Color(0xFF4285F4),
    );
  }

  @override
  bool shouldRepaint(_GoogleLogoPainter oldDelegate) => false;
}
