import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../design/tokens/app_spacing.dart';
import '../../../design/glass/app_glass.dart';

/// 로그인 화면 (Phase 1: Kakao OAuth 구현 예정)
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.bgBase,
              AppColors.bgSurface,
              AppColors.bgBase,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.pagePadding),
            child: Column(
              children: [
                const Spacer(flex: 2),
                // 로고 + 태그라인
                Column(
                  children: [
                    Text(
                      'Re-Link',
                      style: TextStyle(
                        fontSize: 56,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        letterSpacing: -1,
                      ),
                    ),
                    SizedBox(height: AppSpacing.sm),
                    Text(
                      '가족의 기억을 잇다',
                      style: TextStyle(
                        fontSize: 18,
                        color: AppColors.textSecondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const Spacer(flex: 3),
                // 로그인 버튼들
                Column(
                  children: [
                    // Kakao 로그인
                    SizedBox(
                      width: double.infinity,
                      child: GestureDetector(
                        onTap: () => _onKakaoLogin(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEE500),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.chat_bubble, color: Color(0xFF3A1D1D)),
                              SizedBox(width: 8),
                              Text(
                                '카카오로 시작하기',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF3A1D1D),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    // 이메일 로그인
                    SizedBox(
                      width: double.infinity,
                      child: GlassButton(
                        onPressed: () => _onEmailLogin(context),
                        child: Center(
                          child: Text(
                            '이메일로 시작하기',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxl),
                // 약관 안내
                Text(
                  '시작하면 이용약관 및 개인정보처리방침에 동의하는 것으로 간주합니다.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onKakaoLogin(BuildContext context) {
    // TODO: Phase 1 — Supabase Kakao OAuth 구현
    context.go(AppRoutes.canvas);
  }

  void _onEmailLogin(BuildContext context) {
    // TODO: Phase 1 — 이메일 로그인 구현
    context.go(AppRoutes.canvas);
  }
}
