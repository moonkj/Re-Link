import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/haptic_service.dart';
import '../../../design/glass/app_glass.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../design/tokens/app_spacing.dart';
import '../providers/invite_notifier.dart';
import '../providers/welcome_capsule_notifier.dart';
import '../widgets/invite_code_card.dart';
import '../widgets/welcome_capsule_sheet.dart';

/// 가족 초대 화면 — 초대 코드 생성 + 환영 캡슐 + .rlink 공유
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
          icon: Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 20),
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

          // ── Step 2: 환영 메시지 (선택) ──────────────────────────────────────
          _StepHeader(
            number: '2',
            title: '환영 메시지 (선택)',
            isCompleted: inviteState.welcomeDone,
          ),
          const SizedBox(height: AppSpacing.md),

          if (inviteState.welcomeDone && inviteState.hasWelcome)
            // 완료 상태 — 요약 표시
            _WelcomeSummaryCard(
              message: inviteState.welcomeMessage,
              hasAudio: inviteState.welcomeAudioPath != null,
              onEdit: hasCode
                  ? () => _openWelcomeCapsuleSheet(context, ref)
                  : null,
            )
          else
            // 미완료 — 환영 메시지 작성 버튼
            SizedBox(
              width: double.infinity,
              child: GlassButton(
                onPressed: hasCode
                    ? () => _openWelcomeCapsuleSheet(context, ref)
                    : null,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.edit_note_rounded,
                      size: 20,
                      color: hasCode ? AppColors.primary : AppColors.textDisabled,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      inviteState.welcomeDone
                          ? '환영 메시지 건너뜀'
                          : '환영 메시지 작성하기',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: hasCode
                            ? AppColors.primary
                            : AppColors.textDisabled,
                      ),
                    ),
                  ],
                ),
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

          const SizedBox(height: AppSpacing.xxl),

          // ── Step 3: .rlink 파일 공유 ──────────────────────────────────────────
          _StepHeader(
            number: '3',
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
                  text: '환영 메시지를 작성하면 가족이 첫 실행 시 볼 수 있습니다',
                ),
                const SizedBox(height: AppSpacing.md),
                _InstructionRow(
                  number: '3',
                  text: '.rlink 파일을 공유하세요',
                ),
                const SizedBox(height: AppSpacing.md),
                _InstructionRow(
                  number: '4',
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

  /// WelcomeCapsuleSheet를 열고 결과를 InviteState에 반영
  Future<void> _openWelcomeCapsuleSheet(
    BuildContext context,
    WidgetRef ref,
  ) async {
    HapticService.light();
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: const WelcomeCapsuleSheet(),
      ),
    );

    if (result == true) {
      // 완료 — capsule state를 invite state에 반영
      final capsuleState = ref.read(welcomeCapsuleNotifierProvider);
      ref.read(inviteNotifierProvider.notifier).applyWelcomeCapsule(capsuleState);
    } else {
      // 건너뛰기 또는 닫기
      ref.read(inviteNotifierProvider.notifier).skipWelcomeCapsule();
    }
  }
}

/// 환영 메시지 요약 카드 (완료 후 표시)
class _WelcomeSummaryCard extends StatelessWidget {
  const _WelcomeSummaryCard({
    this.message,
    required this.hasAudio,
    this.onEdit,
  });

  final String? message;
  final bool hasAudio;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle, color: AppColors.success, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '환영 메시지 준비 완료',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.success,
                ),
              ),
              const Spacer(),
              if (onEdit != null)
                GestureDetector(
                  onTap: onEdit,
                  child: Text(
                    '수정',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
          if (message != null && message!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              message!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
          if (hasAudio) ...[
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Icon(Icons.graphic_eq_rounded, size: 16, color: AppColors.primary),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  '음성 메시지 포함',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
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
