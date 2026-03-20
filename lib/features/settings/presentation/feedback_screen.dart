/// 개발자 피드백 & 크레딧 화면
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../design/glass/app_glass.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../design/tokens/app_spacing.dart';

class FeedbackScreen extends StatelessWidget {
  const FeedbackScreen({super.key});

  static const _devEmail = 'relink.app@gmail.com';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgBase,
      appBar: AppBar(
        backgroundColor: AppColors.bgBase,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios,
              color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '개발자에게 제안',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 피드백 섹션 ──────────────────────────────────────────────
            GlassCard(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.mail_outline, color: AppColors.primary, size: 24),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        '이메일로 제안하기',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    '새로운 기능 아이디어, 버그 제보, 개선 제안 무엇이든 환영합니다.\n'
                    '보내주신 의견은 직접 읽고, 가능한 빠르게 반영합니다.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  SizedBox(
                    width: double.infinity,
                    child: GlassButton(
                      onPressed: () => _sendEmail(context),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.send, color: AppColors.primary, size: 18),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            '이메일 보내기',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Clipboard.setData(const ClipboardData(text: _devEmail));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('이메일 주소가 복사되었습니다'),
                            backgroundColor: AppColors.primary,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      child: Text(
                        _devEmail,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textTertiary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // ── 약속 섹션 ──────────────────────────────────────────────
            GlassCard(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.handshake_outlined,
                          color: AppColors.secondary, size: 24),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        '개발자의 약속',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _PromiseItem(
                    icon: Icons.visibility_outlined,
                    text: '모든 피드백은 직접 읽습니다',
                  ),
                  _PromiseItem(
                    icon: Icons.update,
                    text: '좋은 아이디어는 다음 업데이트에 반영합니다',
                  ),
                  _PromiseItem(
                    icon: Icons.badge_outlined,
                    text: '아이디어가 반영되면 크레딧에 이름을 올립니다',
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // ── 크레딧 섹션 ──────────────────────────────────────────────
            Text(
              '크레딧',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            GlassCard(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CreditItem(
                    role: '기획 · 디자인 · 개발',
                    name: 'Re-Link Team',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Divider(color: AppColors.glassBorder),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    '사용자 아이디어 기여자',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    '아직 첫 번째 기여자를 기다리고 있습니다.\n'
                    '여러분의 아이디어가 반영되면 이곳에 이름이 올라갑니다!',
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.6,
                      color: AppColors.textTertiary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxxl),
          ],
        ),
      ),
    );
  }

  Future<void> _sendEmail(BuildContext context) async {
    final uri = Uri(
      scheme: 'mailto',
      path: _devEmail,
      queryParameters: {
        'subject': '[Re-Link] 사용자 제안',
        'body': '안녕하세요!\n\n[제안 내용을 여기에 적어주세요]\n\n---\n'
            '기기 정보가 자동으로 포함되지 않습니다.\n'
            '필요한 경우 기기 모델과 앱 버전을 알려주세요.',
      },
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('이메일 앱을 열 수 없습니다. 주소를 복사해주세요.'),
            backgroundColor: AppColors.accent,
          ),
        );
      }
    }
  }
}

class _PromiseItem extends StatelessWidget {
  const _PromiseItem({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Icon(icon, color: AppColors.secondary, size: 18),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CreditItem extends StatelessWidget {
  const _CreditItem({required this.role, required this.name});
  final String role;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                role,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textTertiary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                name,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
