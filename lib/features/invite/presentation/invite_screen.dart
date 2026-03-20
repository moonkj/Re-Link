import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/haptic_service.dart';
import '../../../design/glass/app_glass.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../design/tokens/app_spacing.dart';
import '../providers/invite_notifier.dart';
import '../widgets/invite_code_card.dart';

/// 가족 초대 화면 — 초대 코드 생성 + .rlink 공유
class InviteScreen extends ConsumerWidget {
  const InviteScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inviteState = ref.watch(inviteNotifierProvider);
    final hasCode = inviteState.code != null;

    return Scaffold(
      backgroundColor: AppColors.bgBase,
      appBar: AppBar(
        title: Text(
          '가족 초대',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        children: [
          // ── 헤더 설명 ─────────────────────────────────────────────────────────
          GlassCard(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [AppColors.primaryMint, AppColors.primaryBlue],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Icon(
                    Icons.family_restroom,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  '가족을 초대하세요',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '초대 코드와 백업 파일을 공유하면\n가족이 같은 가계도에 합류할 수 있습니다',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // ── Step 1: 초대 코드 생성 ────────────────────────────────────────────
          _StepHeader(
            number: '1',
            title: '초대 코드 생성',
            isCompleted: hasCode,
          ),
          const SizedBox(height: AppSpacing.md),

          if (!hasCode)
            SizedBox(
              width: double.infinity,
              child: PrimaryGlassButton(
                label: '초대 코드 생성',
                icon: const Icon(Icons.vpn_key_rounded, color: Colors.white, size: 20),
                isLoading: inviteState.isGenerating,
                onPressed: () {
                  HapticService.medium();
                  ref.read(inviteNotifierProvider.notifier).generateInvite();
                },
              ),
            )
          else
            InviteCodeCard(code: inviteState.code!),

          const SizedBox(height: AppSpacing.xxl),

          // ── Step 2: .rlink 파일 공유 ──────────────────────────────────────────
          _StepHeader(
            number: '2',
            title: '.rlink 파일 공유',
            isCompleted: inviteState.backupPath != null,
          ),
          const SizedBox(height: AppSpacing.md),

          SizedBox(
            width: double.infinity,
            child: PrimaryGlassButton(
              label: '가족 트리 공유하기',
              icon: const Icon(Icons.share_rounded, color: Colors.white, size: 20),
              isLoading: inviteState.isSharing,
              onPressed: hasCode
                  ? () {
                      HapticService.medium();
                      ref.read(inviteNotifierProvider.notifier).shareInvite();
                    }
                  : null,
            ),
          ),

          if (!hasCode) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              '먼저 초대 코드를 생성해주세요',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textTertiary,
              ),
            ),
          ],

          const SizedBox(height: AppSpacing.xxxl),

          // ── 안내 사항 ─────────────────────────────────────────────────────────
          GlassCard(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, size: 18, color: AppColors.info),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      '초대 방법',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                _InstructionRow(
                  number: '1',
                  text: '초대 코드를 가족에게 전달하세요',
                ),
                const SizedBox(height: AppSpacing.md),
                _InstructionRow(
                  number: '2',
                  text: '.rlink 파일을 공유하세요',
                ),
                const SizedBox(height: AppSpacing.md),
                _InstructionRow(
                  number: '3',
                  text: '가족이 앱 설치 후 파일을 열면 합류됩니다',
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // ── 에러 표시 ─────────────────────────────────────────────────────────
          if (inviteState.error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xl),
              child: GlassCard(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: AppColors.error, size: 20),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        inviteState.error!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: AppSpacing.xxxl),
        ],
      ),
    );
  }
}

/// 단계 헤더 (번호 원 + 제목 + 완료 체크)
class _StepHeader extends StatelessWidget {
  const _StepHeader({
    required this.number,
    required this.title,
    required this.isCompleted,
  });

  final String number;
  final String title;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted ? AppColors.success : AppColors.primary,
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, color: Colors.white, size: 16)
                : Text(
                    number,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

/// 안내 행 (번호 + 텍스트)
class _InstructionRow extends StatelessWidget {
  const _InstructionRow({
    required this.number,
    required this.text,
  });

  final String number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary.withAlpha(25),
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
