import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../core/router/app_router.dart';
import '../../../core/services/privacy/privacy_service.dart';
import '../../../design/glass/app_glass.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../design/tokens/app_spacing.dart';
import '../../../shared/models/user_plan.dart';
import '../../../shared/repositories/profile_repository.dart';
import '../../../shared/repositories/settings_repository.dart';
import '../../backup/providers/backup_notifier.dart';
import '../providers/elderly_mode_notifier.dart';
import '../providers/haptic_notifier.dart';
import '../providers/reduce_motion_notifier.dart';
import '../providers/spouse_snap_notifier.dart';
import '../providers/theme_mode_notifier.dart';

/// 설정 화면
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.bgBase,
      appBar: AppBar(
        title: Text(
          '설정',
          style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        children: const [
          _ProfileSection(),
          SizedBox(height: AppSpacing.xl),
          _PlanSection(),
          SizedBox(height: AppSpacing.xl),
          _ThemeSection(),
          SizedBox(height: AppSpacing.xl),
          _BackupSection(),
          SizedBox(height: AppSpacing.xl),
          _AccessibilitySection(),
          SizedBox(height: AppSpacing.xl),
          _PrivacyPromiseSection(),
          SizedBox(height: AppSpacing.xl),
          _FeedbackSection(),
          SizedBox(height: AppSpacing.xl),
          _AppInfoSection(),
          SizedBox(height: AppSpacing.xxxl),
        ],
      ),
    );
  }
}

// ── 프로필 섹션 ────────────────────────────────────────────────────────────────

class _ProfileSection extends ConsumerWidget {
  const _ProfileSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder(
      future: ref.read(profileRepositoryProvider).getProfile(),
      builder: (context, snap) {
        final profile = snap.data;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionLabel(label: '내 프로필'),
            const SizedBox(height: AppSpacing.sm),
            GlassCard(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  // 아바타
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.glassSurface,
                      border:
                          Border.all(color: AppColors.primary, width: 2),
                      image: profile?.photoPath != null
                          ? DecorationImage(
                              image: FileImage(File(profile!.photoPath!)),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: profile?.photoPath == null
                        ? Center(
                            child: Text(
                              profile?.name.isNotEmpty == true
                                  ? profile!.name[0]
                                  : '?',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile?.name ?? '프로필 없음',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (profile?.nickname != null)
                          Text(
                            profile!.nickname!,
                            style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary),
                          ),
                      ],
                    ),
                  ),
                  GlassButton(
                    onPressed: () => _openEditProfile(context, ref),
                    child: const Text(
                      '편집',
                      style: TextStyle(
                          fontSize: 13,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _openEditProfile(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ProfileEditSheet(),
    );
  }
}

// ── 프로필 편집 바텀시트 ───────────────────────────────────────────────────────

class _ProfileEditSheet extends ConsumerStatefulWidget {
  const _ProfileEditSheet();

  @override
  ConsumerState<_ProfileEditSheet> createState() => _ProfileEditSheetState();
}

class _ProfileEditSheetState extends ConsumerState<_ProfileEditSheet> {
  final _nameCtrl = TextEditingController();
  final _nicknameCtrl = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile =
        await ref.read(profileRepositoryProvider).getProfile();
    if (!mounted) return;
    _nameCtrl.text = profile?.name ?? '';
    _nicknameCtrl.text = profile?.nickname ?? '';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _nicknameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GlassBottomSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '프로필 편집',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            controller: _nameCtrl,
            style: TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              labelText: '이름 *',
              labelStyle: TextStyle(color: AppColors.textSecondary),
              enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.glassBorder)),
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primary)),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _nicknameCtrl,
            style: TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              labelText: '별명 (선택)',
              labelStyle: TextStyle(color: AppColors.textSecondary),
              enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.glassBorder)),
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primary)),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            width: double.infinity,
            child: GlassButton(
              onPressed: _loading ? null : _save,
              child: _loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.primary))
                  : const Text(
                      '저장',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    setState(() => _loading = true);
    await ref.read(profileRepositoryProvider).saveProfile(
          name: name,
          nickname:
              _nicknameCtrl.text.trim().isEmpty ? null : _nicknameCtrl.text.trim(),
        );
    if (!mounted) return;
    Navigator.of(context).pop();
  }
}

// ── 요금제 섹션 ────────────────────────────────────────────────────────────────

class _PlanSection extends ConsumerWidget {
  const _PlanSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel(label: '요금제'),
        const SizedBox(height: AppSpacing.sm),
        FutureBuilder<UserPlan>(
          future: ref.read(settingsRepositoryProvider).getUserPlan(),
          builder: (context, snap) {
            final plan = snap.data ?? UserPlan.free;
            return GlassCard(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  Icon(
                    plan == UserPlan.premium
                        ? Icons.workspace_premium
                        : plan == UserPlan.basic
                            ? Icons.star_outline
                            : Icons.person_outline,
                    color: plan == UserPlan.premium
                        ? AppColors.accent
                        : AppColors.primary,
                    size: 28,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plan.displayName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          '노드 ${plan.isUnlimited ? "무제한" : "${plan.maxNodes}개"} · '
                          '사진 ${plan.isUnlimited ? "무제한" : "${plan.maxPhotos}장"}',
                          style: TextStyle(
                              fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  if (plan != UserPlan.premium)
                    GlassButton(
                      onPressed: () => context.push(AppRoutes.subscription),
                      child: const Text(
                        '업그레이드',
                        style: TextStyle(
                            fontSize: 13,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

// ── 백업 섹션 ─────────────────────────────────────────────────────────────────

class _BackupSection extends ConsumerWidget {
  const _BackupSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final backupState = ref.watch(backupNotifierProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel(label: '백업'),
        const SizedBox(height: AppSpacing.sm),
        GlassCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              // 마지막 백업
              ListTile(
                leading: const Icon(Icons.cloud_done_outlined,
                    color: AppColors.primary),
                title: Text('마지막 백업',
                    style: TextStyle(
                        fontSize: 15, color: AppColors.textPrimary)),
                subtitle: Text(
                  backupState.lastBackupAt == null
                      ? '백업 기록 없음'
                      : _formatDate(backupState.lastBackupAt!),
                  style: TextStyle(
                      fontSize: 12, color: AppColors.textSecondary),
                ),
                trailing: GlassButton(
                  onPressed: () => context.push(AppRoutes.backup),
                  child: const Text(
                    '백업 화면',
                    style: TextStyle(fontSize: 13, color: AppColors.primary),
                  ),
                ),
              ),
              Divider(color: AppColors.glassBorder, height: 1),
              // 자동 백업 토글
              FutureBuilder<bool>(
                future: ref
                    .read(settingsRepositoryProvider)
                    .isAutoBackupEnabled(),
                builder: (context, snap) {
                  final enabled = snap.data ?? true;
                  return SwitchListTile(
                    secondary: const Icon(Icons.schedule_outlined,
                        color: AppColors.primary),
                    title: Text('자동 백업',
                        style: TextStyle(
                            fontSize: 15, color: AppColors.textPrimary)),
                    subtitle: Text('24시간마다 자동 저장',
                        style: TextStyle(
                            fontSize: 12, color: AppColors.textSecondary)),
                    value: enabled,
                    onChanged: (v) =>
                        ref.read(settingsRepositoryProvider).setAutoBackup(v),
                    activeThumbColor: AppColors.primary,
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime dt) =>
      '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')} '
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}

// ── 테마 섹션 ──────────────────────────────────────────────────────────────────

class _ThemeSection extends ConsumerWidget {
  const _ThemeSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeModeAsync = ref.watch(themeModeNotifierProvider);
    final currentMode = themeModeAsync.valueOrNull ?? ThemeMode.system;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel(label: '테마'),
        const SizedBox(height: AppSpacing.sm),
        GlassCard(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              _ThemeOption(
                icon: Icons.brightness_auto,
                label: '시스템',
                isSelected: currentMode == ThemeMode.system,
                onTap: () => ref
                    .read(themeModeNotifierProvider.notifier)
                    .setMode(ThemeMode.system),
              ),
              const SizedBox(width: AppSpacing.sm),
              _ThemeOption(
                icon: Icons.light_mode_outlined,
                label: '라이트',
                isSelected: currentMode == ThemeMode.light,
                onTap: () => ref
                    .read(themeModeNotifierProvider.notifier)
                    .setMode(ThemeMode.light),
              ),
              const SizedBox(width: AppSpacing.sm),
              _ThemeOption(
                icon: Icons.dark_mode_outlined,
                label: '다크',
                isSelected: currentMode == ThemeMode.dark,
                onTap: () => ref
                    .read(themeModeNotifierProvider.notifier)
                    .setMode(ThemeMode.dark),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: isSelected
                ? AppColors.primary.withAlpha(30)
                : Colors.transparent,
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.glassBorder,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Icon(icon,
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                  size: 22),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── 접근성 섹션 (어르신 모드, 햅틱, 애니메이션, Privacy Layer) ─────────────────

class _AccessibilitySection extends ConsumerWidget {
  const _AccessibilitySection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final elderlyAsync = ref.watch(elderlyModeNotifierProvider);
    final elderlyEnabled = elderlyAsync.valueOrNull ?? false;

    final hapticAsync = ref.watch(hapticNotifierProvider);
    final hapticEnabled = hapticAsync.valueOrNull ?? true;

    final reduceMotionAsync = ref.watch(reduceMotionNotifierProvider);
    final reduceMotion = reduceMotionAsync.valueOrNull ?? false;

    final spouseSnapAsync = ref.watch(spouseSnapNotifierProvider);
    final spouseSnap = spouseSnapAsync.valueOrNull ?? true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel(label: '접근성 & 개인 보호'),
        const SizedBox(height: AppSpacing.sm),
        GlassCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              // 어르신 모드
              Semantics(
                label: '어르신 모드',
                hint: '큰 글씨와 넓은 터치 영역을 사용합니다',
                toggled: elderlyEnabled,
                child: SwitchListTile(
                  secondary: const Icon(Icons.accessibility_new,
                      color: AppColors.secondary),
                  title: Text('어르신 모드',
                      style: TextStyle(
                          fontSize: 15, color: AppColors.textPrimary)),
                  subtitle: Text('큰 글씨 · 넓은 터치 영역',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
                  value: elderlyEnabled,
                  onChanged: (v) => ref
                      .read(elderlyModeNotifierProvider.notifier)
                      .setEnabled(v),
                  activeThumbColor: AppColors.secondary,
                ),
              ),
              Divider(color: AppColors.glassBorder, height: 1),
              // 햅틱 On/Off
              Semantics(
                label: '햅틱 피드백',
                hint: '진동 피드백을 끄거나 켭니다',
                toggled: hapticEnabled,
                child: SwitchListTile(
                  secondary: const Icon(Icons.vibration,
                      color: AppColors.primary),
                  title: Text('햅틱 피드백',
                      style: TextStyle(
                          fontSize: 15, color: AppColors.textPrimary)),
                  subtitle: Text('터치 시 진동 피드백',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
                  value: hapticEnabled,
                  onChanged: (v) => ref
                      .read(hapticNotifierProvider.notifier)
                      .setEnabled(v),
                  activeThumbColor: AppColors.primary,
                ),
              ),
              Divider(color: AppColors.glassBorder, height: 1),
              // 애니메이션 줄이기
              Semantics(
                label: '애니메이션 줄이기',
                hint: '모션 효과를 줄여 어지러움을 방지합니다',
                toggled: reduceMotion,
                child: SwitchListTile(
                  secondary: const Icon(Icons.animation,
                      color: AppColors.primary),
                  title: Text('애니메이션 줄이기',
                      style: TextStyle(
                          fontSize: 15, color: AppColors.textPrimary)),
                  subtitle: Text('모션 효과 최소화',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
                  value: reduceMotion,
                  onChanged: (v) => ref
                      .read(reduceMotionNotifierProvider.notifier)
                      .setEnabled(v),
                  activeThumbColor: AppColors.primary,
                ),
              ),
              Divider(color: AppColors.glassBorder, height: 1),
              // 부부 자석 스냅
              Semantics(
                label: '부부 자석 스냅',
                hint: '배우자 노드를 가까이 드래그하면 자동 정렬합니다',
                toggled: spouseSnap,
                child: SwitchListTile(
                  secondary: const Icon(Icons.compare_arrows,
                      color: AppColors.secondary),
                  title: Text('부부 자석 스냅',
                      style: TextStyle(
                          fontSize: 15, color: AppColors.textPrimary)),
                  subtitle: Text('배우자 노드 가까이 시 자동 정렬',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
                  value: spouseSnap,
                  onChanged: (v) => ref
                      .read(spouseSnapNotifierProvider.notifier)
                      .setEnabled(v),
                  activeThumbColor: AppColors.secondary,
                ),
              ),
              Divider(color: AppColors.glassBorder, height: 1),
              // Privacy Layer (생체인증 연동)
              _PrivacyToggle(),
            ],
          ),
        ),
      ],
    );
  }
}

// ── 프라이버시 약속 섹션 ──────────────────────────────────────────────────────

class _PrivacyPromiseSection extends StatelessWidget {
  const _PrivacyPromiseSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel(label: '프라이버시'),
        const SizedBox(height: AppSpacing.sm),
        GlassCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.shield_outlined,
                      color: AppColors.secondary, size: 22),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Re-Link의 약속',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                '당신의 가족 데이터를 팔지 않습니다.\n'
                '광고 타겟팅에 사용하지 않습니다.\n'
                'AI 학습에 사용하지 않습니다.\n'
                '모든 데이터는 오직 당신의 기기에만 저장됩니다.',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.7,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Icon(Icons.verified_outlined,
                      color: AppColors.primary, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '100% 로컬 퍼스트 · 서버 없음',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── 피드백 채널 섹션 ──────────────────────────────────────────────────────────

class _FeedbackSection extends StatelessWidget {
  const _FeedbackSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel(label: '개발자 소통'),
        const SizedBox(height: AppSpacing.sm),
        GlassCard(
          padding: EdgeInsets.zero,
          child: ListTile(
            leading: const Icon(Icons.chat_bubble_outline,
                color: AppColors.primary),
            title: Text('개발자에게 직접 제안',
                style: TextStyle(
                    fontSize: 15, color: AppColors.textPrimary)),
            subtitle: Text('새 기능, 버그 제보, 아이디어 공유',
                style: TextStyle(
                    fontSize: 12, color: AppColors.textSecondary)),
            trailing:
                Icon(Icons.chevron_right, color: AppColors.textTertiary),
            onTap: () => context.push(AppRoutes.feedback),
          ),
        ),
      ],
    );
  }
}

// ── 앱 정보 섹션 ──────────────────────────────────────────────────────────────

class _AppInfoSection extends StatelessWidget {
  const _AppInfoSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel(label: '앱 정보'),
        const SizedBox(height: AppSpacing.sm),
        GlassCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              FutureBuilder<PackageInfo>(
                future: PackageInfo.fromPlatform(),
                builder: (context, snap) {
                  final info = snap.data;
                  return ListTile(
                    leading: const Icon(Icons.info_outline,
                        color: AppColors.primary),
                    title: Text('버전',
                        style: TextStyle(
                            fontSize: 15, color: AppColors.textPrimary)),
                    trailing: Text(
                      info != null
                          ? '${info.version}+${info.buildNumber}'
                          : '-',
                      style: TextStyle(
                          fontSize: 13, color: AppColors.textSecondary),
                    ),
                  );
                },
              ),
              Divider(color: AppColors.glassBorder, height: 1),
              ListTile(
                leading: const Icon(Icons.privacy_tip_outlined,
                    color: AppColors.primary),
                title: Text('개인정보 처리방침',
                    style: TextStyle(
                        fontSize: 15, color: AppColors.textPrimary)),
                trailing: Icon(Icons.chevron_right,
                    color: AppColors.textTertiary),
                onTap: () => context.push(AppRoutes.privacyPolicy),
              ),
              Divider(color: AppColors.glassBorder, height: 1),
              ListTile(
                leading: const Icon(Icons.description_outlined,
                    color: AppColors.primary),
                title: Text('이용약관',
                    style: TextStyle(
                        fontSize: 15, color: AppColors.textPrimary)),
                trailing: Icon(Icons.chevron_right,
                    color: AppColors.textTertiary),
                onTap: () => context.push(AppRoutes.terms),
              ),
              Divider(color: AppColors.glassBorder, height: 1),
              ListTile(
                leading: const Icon(Icons.article_outlined,
                    color: AppColors.primary),
                title: Text('오픈소스 라이선스',
                    style: TextStyle(
                        fontSize: 15, color: AppColors.textPrimary)),
                trailing: Icon(Icons.chevron_right,
                    color: AppColors.textTertiary),
                onTap: () => showLicensePage(
                  context: context,
                  applicationName: 'Re-Link',
                  applicationLegalese: '© 2026 Re-Link',
                ),
              ),
              Divider(color: AppColors.glassBorder, height: 1),
              ListTile(
                leading: const Icon(Icons.favorite_outline,
                    color: AppColors.accent),
                title: Text('Re-Link',
                    style: TextStyle(
                        fontSize: 15, color: AppColors.textPrimary)),
                subtitle: Text('가족의 기억을 잇다',
                    style: TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Privacy Layer 토글 (생체인증 연동) ────────────────────────────────────────

class _PrivacyToggle extends ConsumerStatefulWidget {
  @override
  ConsumerState<_PrivacyToggle> createState() => _PrivacyToggleState();
}

class _PrivacyToggleState extends ConsumerState<_PrivacyToggle> {
  bool _enabled = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    final privacy = ref.read(privacyServiceProvider);
    final enabled = await privacy.isEnabled();
    if (!mounted) return;
    setState(() {
      _enabled = enabled;
      _loading = false;
    });
  }

  Future<void> _onChanged(bool newValue) async {
    final privacy = ref.read(privacyServiceProvider);

    // 생체인증 가용 여부 확인
    final available = await privacy.isAvailable();
    if (!mounted) return;

    if (!available) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('이 기기에서 생체인증을 사용할 수 없습니다'),
        ),
      );
      return;
    }

    // 활성화/비활성화 모두 생체인증 요구
    final reason = newValue
        ? '개인 메모 잠금을 활성화하려면 인증이 필요합니다'
        : '개인 메모 잠금을 해제하려면 인증이 필요합니다';

    // 세션 캐시 무시하고 반드시 인증 (설정 변경은 항상 인증)
    privacy.invalidateSession();
    final authenticated = await privacy.authenticate(reason: reason);
    if (!mounted) return;

    if (authenticated) {
      await privacy.setEnabled(newValue);
      if (!mounted) return;
      setState(() => _enabled = newValue);
    }
    // 인증 실패 시 토글 원복 (setState 호출 없이 유지)
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const ListTile(
        leading: Icon(Icons.lock_outline, color: AppColors.accent),
        title: Text('개인 메모 잠금'),
        trailing: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    return Semantics(
      label: '개인 메모 잠금',
      hint: 'Face ID 또는 Touch ID로 개인 메모를 보호합니다',
      toggled: _enabled,
      child: SwitchListTile(
        secondary: const Icon(Icons.lock_outline, color: AppColors.accent),
        title: Text('개인 메모 잠금',
            style: TextStyle(fontSize: 15, color: AppColors.textPrimary)),
        subtitle: Text('Face ID / Touch ID로 보호',
            style:
                TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        value: _enabled,
        onChanged: _onChanged,
        activeThumbColor: AppColors.accent,
      ),
    );
  }
}

// ── 공통 섹션 레이블 ──────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
      ),
    );
  }
}
