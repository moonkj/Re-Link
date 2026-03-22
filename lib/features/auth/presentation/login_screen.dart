import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../../../core/router/app_router.dart';
import '../../../core/services/auth/auth_service.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../design/tokens/app_radius.dart';
import '../../../design/tokens/app_spacing.dart';
import '../../../core/services/auth/auth_token_storage.dart';
import '../../../core/services/auth/kakao_auth_helper.dart';
import '../../../shared/repositories/settings_repository.dart';
import '../providers/auth_notifier.dart';

/// 로그인 화면
/// - Apple Sign-In (iOS HIG 준수)
/// - Google Sign-In
/// - "나중에 하기" 스킵 옵션
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _isAppleLoading = false;
  bool _isGoogleLoading = false;
  bool _isKakaoLoading = false;

  final _googleSignIn = GoogleSignIn(scopes: ['email']);

  bool get _isAnyLoading => _isAppleLoading || _isGoogleLoading || _isKakaoLoading;

  /// Apple 로그인 (직접 HTTP — AuthHttpClient iOS 26 beta 호환성 우회)
  Future<void> _onAppleSignIn() async {
    if (_isAnyLoading) return;
    setState(() => _isAppleLoading = true);
    try {
      // Step 1: Apple ID 자격 증명 획득
      debugPrint('[AppleLogin] Step 1: Starting Apple Sign-In...');
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final idToken = credential.identityToken;
      if (idToken == null) {
        debugPrint('[AppleLogin] No identity token — aborting');
        return;
      }
      debugPrint('[AppleLogin] Step 2: Got Apple ID token');

      if (!mounted) return;

      // Step 2: 서버 인증 (직접 HTTP 호출 — AuthHttpClient 우회)
      final body = <String, dynamic>{
        'id_token': idToken,
        if (credential.authorizationCode.isNotEmpty)
          'authorization_code': credential.authorizationCode,
        if (credential.givenName != null)
          'given_name': credential.givenName,
        if (credential.familyName != null)
          'family_name': credential.familyName,
      };

      try {
        final serverResponse = await http.post(
          Uri.parse('https://relink-api.relink-app.workers.dev/auth/apple'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        ).timeout(const Duration(seconds: 15));

        if (!mounted) return;

        if (serverResponse.statusCode == 200 || serverResponse.statusCode == 201) {
          final data = jsonDecode(serverResponse.body) as Map<String, dynamic>;
          final accessToken = data['access_token'] as String?;
          final refreshToken = data['refresh_token'] as String?;
          final userData = data['user'] as Map<String, dynamic>?;

          if (accessToken != null && refreshToken != null && userData != null) {
            final tokenStorage = ref.read(authTokenStorageProvider);
            await tokenStorage.saveTokens(
              accessToken: accessToken,
              refreshToken: refreshToken,
              userId: userData['id'] as String?,
            );

            ref.invalidate(authNotifierProvider);
            await ref.read(authNotifierProvider.future);

            if (!mounted) return;
            _navigateAfterAuth();
          } else {
            _showError('서버 응답 형식 오류');
          }
        } else {
          final errBody = jsonDecode(serverResponse.body) as Map<String, dynamic>;
          _showError(errBody['message'] as String? ?? '서버 인증 실패');
        }
      } catch (e) {
        if (!mounted) return;
        _showError('서버 연결 실패: $e');
      }
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        // 사용자가 직접 취소 — 에러 아님
        debugPrint('[AppleLogin] User cancelled Apple Sign-In');
        return;
      }
      if (!mounted) return;
      _showError('Apple 로그인 실패: ${e.message}');
    } catch (e, st) {
      debugPrint('[AppleLogin] Exception: $e');
      debugPrint('[AppleLogin] Stack: $st');
      if (!mounted) return;
      _showError(e is AuthException ? e.message : '로그인 실패: $e');
    } finally {
      if (mounted) setState(() => _isAppleLoading = false);
    }
  }

  /// Google 로그인 (직접 HTTP — AuthHttpClient iOS 26 beta 호환성 우회)
  Future<void> _onGoogleSignIn() async {
    if (_isAnyLoading) return;
    setState(() => _isGoogleLoading = true);
    try {
      // Step 1: Google 계정 선택 + 인증
      debugPrint('[GoogleLogin] Step 1: Starting Google Sign-In...');
      final account = await _googleSignIn.signIn();
      if (account == null) {
        // 사용자가 직접 취소 — 에러 아님
        debugPrint('[GoogleLogin] User cancelled Google Sign-In');
        return;
      }

      final auth = await account.authentication;
      final idToken = auth.idToken;
      if (idToken == null) {
        debugPrint('[GoogleLogin] No ID token — aborting');
        return;
      }
      debugPrint('[GoogleLogin] Step 2: Got Google ID token');

      if (!mounted) return;

      // Step 2: 서버 인증 (직접 HTTP 호출 — AuthHttpClient 우회)
      try {
        final serverResponse = await http.post(
          Uri.parse('https://relink-api.relink-app.workers.dev/auth/google'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'id_token': idToken}),
        ).timeout(const Duration(seconds: 15));

        if (!mounted) return;

        if (serverResponse.statusCode == 200 || serverResponse.statusCode == 201) {
          final data = jsonDecode(serverResponse.body) as Map<String, dynamic>;
          final accessToken = data['access_token'] as String?;
          final refreshToken = data['refresh_token'] as String?;
          final userData = data['user'] as Map<String, dynamic>?;

          if (accessToken != null && refreshToken != null && userData != null) {
            final tokenStorage = ref.read(authTokenStorageProvider);
            await tokenStorage.saveTokens(
              accessToken: accessToken,
              refreshToken: refreshToken,
              userId: userData['id'] as String?,
            );

            ref.invalidate(authNotifierProvider);
            await ref.read(authNotifierProvider.future);

            if (!mounted) return;
            _navigateAfterAuth();
          } else {
            _showError('서버 응답 형식 오류');
          }
        } else {
          final errBody = jsonDecode(serverResponse.body) as Map<String, dynamic>;
          _showError(errBody['message'] as String? ?? '서버 인증 실패');
        }
      } catch (e) {
        if (!mounted) return;
        _showError('서버 연결 실패: $e');
      }
    } catch (e, st) {
      debugPrint('[GoogleLogin] Exception: $e');
      debugPrint('[GoogleLogin] Stack: $st');
      if (!mounted) return;
      _showError(e is AuthException ? e.message : '로그인 실패: $e');
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  /// 카카오 로그인
  Future<void> _onKakaoSignIn() async {
    if (_isAnyLoading) return;
    setState(() => _isKakaoLoading = true);
    try {
      // 카카오 인앱 WebView 로그인
      debugPrint('[KakaoLogin] Step 1: Starting Kakao WebView login...');
      final kakaoAccessToken = await KakaoAuthHelper.login(context);
      debugPrint('[KakaoLogin] Step 2: Got Kakao token: ${kakaoAccessToken.substring(0, 10.clamp(0, kakaoAccessToken.length))}...');
      if (!mounted) {
        debugPrint('[KakaoLogin] ⚠ Widget not mounted after Kakao login — aborting');
        return;
      }

      // 카카오 토큰 → 서버 인증 (직접 HTTP 호출 — AuthHttpClient 호환성 문제 우회)
      if (!mounted) return;
      try {
        final serverResponse = await http.post(
          Uri.parse('https://relink-api.relink-app.workers.dev/auth/kakao'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'access_token': kakaoAccessToken}),
        ).timeout(const Duration(seconds: 15));

        if (!mounted) return;

        if (serverResponse.statusCode == 200 || serverResponse.statusCode == 201) {
          // 서버 응답에서 JWT 토큰 직접 파싱 + 저장
          final data = jsonDecode(serverResponse.body) as Map<String, dynamic>;
          final accessToken = data['access_token'] as String?;
          final refreshToken = data['refresh_token'] as String?;
          final userData = data['user'] as Map<String, dynamic>?;

          if (accessToken != null && refreshToken != null && userData != null) {
            // 토큰 저장 (로그인 유지)
            final tokenStorage = ref.read(authTokenStorageProvider);
            await tokenStorage.saveTokens(
              accessToken: accessToken,
              refreshToken: refreshToken,
              userId: userData['id'] as String?,
            );

            // AuthNotifier 상태 갱신 — 토큰 저장 후 재초기화하면 tryAutoLogin이 성공
            ref.invalidate(authNotifierProvider);
            // tryAutoLogin이 저장된 토큰으로 자동 로그인하도록 대기
            await ref.read(authNotifierProvider.future);

            if (!mounted) return;
            _navigateAfterAuth();
          } else {
            _showError('서버 응답 형식 오류');
          }
        } else {
          final errBody = jsonDecode(serverResponse.body) as Map<String, dynamic>;
          _showError(errBody['message'] as String? ?? '서버 인증 실패');
        }
      } catch (e) {
        if (!mounted) return;
        _showError('서버 연결 실패: $e');
      }
    } catch (e, st) {
      debugPrint('[KakaoLogin] ✗ Exception: $e');
      debugPrint('[KakaoLogin] Stack: $st');
      if (!mounted) {
        debugPrint('[KakaoLogin] ⚠ Widget not mounted in catch — error swallowed');
        return;
      }
      _showError(e is AuthException ? e.message : '로그인 실패: $e');
    } finally {
      if (mounted) setState(() => _isKakaoLoading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusSm),
        margin: const EdgeInsets.all(AppSpacing.lg),
      ),
    );
  }

  Future<void> _navigateAfterAuth() async {
    if (!mounted) return;

    // authUserId를 설정에 저장 (#8)
    final authUser = ref.read(authNotifierProvider).valueOrNull;
    if (authUser != null) {
      await ref.read(settingsRepositoryProvider).setAuthUserId(authUser.id);
    }

    if (!mounted) return;

    // redirect 쿼리 파라미터 확인 (#10)
    final redirectPath = GoRouterState.of(context)
        .uri
        .queryParameters['redirect'];

    if (redirectPath != null && redirectPath.isNotEmpty) {
      final decoded = Uri.decodeComponent(redirectPath);
      context.go(decoded);
      return;
    }

    // 온보딩 완료 여부 확인 (#7)
    final onboardingDone =
        await ref.read(settingsRepositoryProvider).isOnboardingDone();
    if (!mounted) return;

    if (!onboardingDone) {
      context.go(AppRoutes.profileSetup);
      return;
    }

    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop(true);
    } else {
      context.go(AppRoutes.canvas);
    }
  }

  void _onSkip() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop(false);
    } else {
      context.go(AppRoutes.canvas);
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.platformBrightnessOf(context);
    final isLight = brightness == Brightness.light;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isLight
                ? const [Color(0xFF6EC6CA), Color(0xFF4A9EBF), Color(0xFF3D7CA8)]
                : const [Color(0xFF0F0F1A), Color(0xFF1A1A3E), Color(0xFF0F0F1A)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                // ── 상단 스킵 버튼 ─────────────────────────────────────
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.md),
                    child: GestureDetector(
                      onTap: _onSkip,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                          ),
                        ),
                        child: const Text(
                          '건너뛰기',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const Spacer(flex: 2),

                // ── 로고 ───────────────────────────────────────────────
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Icon(
                    CupertinoIcons.link,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Re-Link',
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '가족의 기억을 잇다',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withValues(alpha: 0.8),
                    letterSpacing: 0.5,
                  ),
                ),

                const SizedBox(height: 36),

                // ── 혜택 카드 ─────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '로그인하면',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                      const SizedBox(height: 14),
                      _BenefitRow(
                        icon: CupertinoIcons.cloud_upload,
                        text: '클라우드 동기화 · 20GB 자동 백업',
                      ),
                      const SizedBox(height: 10),
                      _BenefitRow(
                        icon: CupertinoIcons.person_3,
                        text: '가족 실시간 공유 · 최대 6명',
                      ),
                      const SizedBox(height: 10),
                      _BenefitRow(
                        icon: CupertinoIcons.infinite,
                        text: '무제한 노드 · 사진 · 음성',
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 3),

                // ── Apple Sign-In ─────────────────────────────────────
                _SignInButton(
                  onPressed: _isAnyLoading ? null : _onAppleSignIn,
                  isLoading: _isAppleLoading,
                  backgroundColor: Colors.white,
                  textColor: Colors.black,
                  icon: const Icon(Icons.apple, color: Colors.black, size: 22),
                  label: 'Apple로 계속하기',
                ),

                const SizedBox(height: 12),

                // ── Google Sign-In ────────────────────────────────────
                _SignInButton(
                  onPressed: _isAnyLoading ? null : _onGoogleSignIn,
                  isLoading: _isGoogleLoading,
                  backgroundColor: Colors.white.withValues(alpha: 0.15),
                  textColor: Colors.white,
                  borderColor: Colors.white.withValues(alpha: 0.3),
                  icon: _GoogleLogo(),
                  label: 'Google로 계속하기',
                ),

                const SizedBox(height: 12),

                // ── Kakao Sign-In ────────────────────────────────────
                _SignInButton(
                  onPressed: _isAnyLoading ? null : _onKakaoSignIn,
                  isLoading: _isKakaoLoading,
                  backgroundColor: const Color(0xFFFEE500),
                  textColor: const Color(0xFF191919),
                  icon: const _KakaoLogo(),
                  label: '카카오로 계속하기',
                ),

                const SizedBox(height: 24),

                // ── 약관 ─────────────────────────────────────────────
                Text(
                  '로그인 시 이용약관 및 개인정보처리방침에 동의합니다',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.45),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── 혜택 행 ──────────────────────────────────────────────────────────────────

class _BenefitRow extends StatelessWidget {
  const _BenefitRow({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white.withValues(alpha: 0.7), size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.8),
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}

// ── 로그인 버튼 ──────────────────────────────────────────────────────────────

class _SignInButton extends StatelessWidget {
  const _SignInButton({
    required this.onPressed,
    required this.isLoading,
    required this.backgroundColor,
    required this.textColor,
    required this.icon,
    required this.label,
    this.borderColor,
  });

  final VoidCallback? onPressed;
  final bool isLoading;
  final Color backgroundColor;
  final Color textColor;
  final Widget icon;
  final String label;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: AnimatedOpacity(
        opacity: onPressed == null && !isLoading ? 0.4 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Container(
          width: double.infinity,
          height: 54,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(14),
            border: borderColor != null
                ? Border.all(color: borderColor!)
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading)
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(textColor),
                  ),
                )
              else ...[
                icon,
                const SizedBox(width: 10),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textColor,
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

// ── Google 로고 ──────────────────────────────────────────────────────────────

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

    final colors = [
      const Color(0xFF4285F4),
      const Color(0xFF34A853),
      const Color(0xFFFBBC05),
      const Color(0xFFEA4335),
    ];

    final sweepAngle = 3.14159 / 2;

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

    canvas.drawCircle(
      center,
      radius * 0.38,
      Paint()..color = Colors.white,
    );

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

// ── 카카오 로고 ──────────────────────────────────────────────────────────────

class _KakaoLogo extends StatelessWidget {
  const _KakaoLogo();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(20, 20),
      painter: _KakaoLogoPainter(),
    );
  }
}

/// 카카오 말풍선 로고 (카카오 브랜드 가이드라인 준수)
class _KakaoLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF191919)
      ..style = PaintingStyle.fill;

    // 말풍선 원형 바디
    final center = Offset(size.width / 2, size.height * 0.42);
    final rx = size.width * 0.45;
    final ry = size.height * 0.38;

    canvas.drawOval(
      Rect.fromCenter(center: center, width: rx * 2, height: ry * 2),
      paint,
    );

    // 하단 꼬리 삼각형
    final tailPath = Path()
      ..moveTo(size.width * 0.32, size.height * 0.7)
      ..lineTo(size.width * 0.22, size.height * 0.95)
      ..lineTo(size.width * 0.52, size.height * 0.72)
      ..close();

    canvas.drawPath(tailPath, paint);
  }

  @override
  bool shouldRepaint(_KakaoLogoPainter oldDelegate) => false;
}
