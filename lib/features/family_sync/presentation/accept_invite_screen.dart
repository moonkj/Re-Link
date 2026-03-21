import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../design/tokens/app_spacing.dart';
import '../../../design/glass/app_glass.dart';
import '../providers/family_members_notifier.dart';

/// 가족 초대 수락 화면
/// deep link: relink://invite/{token} 처리
class AcceptInviteScreen extends ConsumerStatefulWidget {
  const AcceptInviteScreen({super.key, required this.token});
  final String token;

  @override
  ConsumerState<AcceptInviteScreen> createState() => _AcceptInviteScreenState();
}

class _AcceptInviteScreenState extends ConsumerState<AcceptInviteScreen> {
  bool _isLoading = false;
  bool _isAccepting = false;

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
            child: _isLoading
                ? const _LoadingView()
                : _InviteContentView(
                    token: widget.token,
                    isAccepting: _isAccepting,
                    onAccept: _handleAccept,
                    onCancel: _handleCancel,
                  ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleAccept() async {
    setState(() => _isAccepting = true);
    try {
      final success = await ref
          .read(familyMembersNotifierProvider.notifier)
          .acceptInvite(widget.token);
      if (!mounted) return;
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('가족 그룹에 합류했습니다!'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('초대 수락에 실패했습니다. 링크가 만료되었을 수 있습니다.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('오류가 발생했습니다: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isAccepting = false);
    }
  }

  void _handleCancel() {
    if (!mounted) return;
    context.pop();
  }
}

// ── 로딩 뷰 ──────────────────────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          const SizedBox(height: AppSpacing.lg),
          Text(
            '초대 정보를 불러오는 중...',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

// ── 초대 콘텐츠 뷰 ────────────────────────────────────────────────────────────

class _InviteContentView extends StatelessWidget {
  const _InviteContentView({
    required this.token,
    required this.isAccepting,
    required this.onAccept,
    required this.onCancel,
  });
  final String token;
  final bool isAccepting;
  final VoidCallback onAccept;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(flex: 2),

        // 초대 아이콘
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary.withValues(alpha: 0.12),
          ),
          child: Icon(
            Icons.family_restroom_rounded,
            size: 48,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),

        // 제목
        Text(
          '가족 그룹 초대',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // 안내 문구
        Text(
          '가족이 Re-Link 그룹에 초대했습니다.\n합류하면 가족의 기억을 함께 공유할 수 있습니다.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
        const SizedBox(height: AppSpacing.xxxl),

        // 토큰 정보 카드
        GlassCard(
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          child: Row(
            children: [
              Icon(
                Icons.link_rounded,
                size: 20,
                color: AppColors.primary,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '초대 토큰',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textTertiary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      token.length > 20
                          ? '${token.substring(0, 20)}...'
                          : token,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textPrimary,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const Spacer(flex: 3),

        // 합류하기 버튼
        SizedBox(
          width: double.infinity,
          child: PrimaryGlassButton(
            label: '합류하기',
            icon: const Icon(Icons.check_rounded, color: Colors.white),
            isLoading: isAccepting,
            onPressed: isAccepting ? null : onAccept,
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // 취소 버튼
        SizedBox(
          width: double.infinity,
          child: GlassButton(
            onPressed: isAccepting ? null : onCancel,
            child: Center(
              child: Text(
                '취소',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}
