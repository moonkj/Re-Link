import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../core/router/app_router.dart';
import '../../../design/glass/app_glass.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../design/tokens/app_spacing.dart';
import '../../../shared/models/user_plan.dart';
import '../../../shared/repositories/profile_repository.dart';
import '../../../shared/repositories/settings_repository.dart';
import '../../backup/providers/backup_notifier.dart';
import '../../export/presentation/heritage_export_screen.dart';
import '../providers/elderly_mode_notifier.dart';

/// 설정 화면
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.bgBase,
      appBar: AppBar(
        title: const Text(
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
          _BackupSection(),
          SizedBox(height: AppSpacing.xl),
          _AccessibilitySection(),
          SizedBox(height: AppSpacing.xl),
          _ExportSection(),
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
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (profile?.nickname != null)
                          Text(
                            profile!.nickname!,
                            style: const TextStyle(
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
          const Text(
            '프로필 편집',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            controller: _nameCtrl,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(
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
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(
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
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          '노드 ${plan.isUnlimited ? "무제한" : "${plan.maxNodes}개"} · '
                          '사진 ${plan.isUnlimited ? "무제한" : "${plan.maxPhotos}장"}',
                          style: const TextStyle(
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
                title: const Text('마지막 백업',
                    style: TextStyle(
                        fontSize: 15, color: AppColors.textPrimary)),
                subtitle: Text(
                  backupState.lastBackupAt == null
                      ? '백업 기록 없음'
                      : _formatDate(backupState.lastBackupAt!),
                  style: const TextStyle(
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
              const Divider(color: AppColors.glassBorder, height: 1),
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
                    title: const Text('자동 백업',
                        style: TextStyle(
                            fontSize: 15, color: AppColors.textPrimary)),
                    subtitle: const Text('24시간마다 자동 저장',
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

// ── 접근성 섹션 (어르신 모드, Privacy Layer) ────────────────────────────────────

class _AccessibilitySection extends ConsumerWidget {
  const _AccessibilitySection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ElderlyModeNotifier로 반응형 구독 (토글 즉시 앱 전역 반영)
    final elderlyAsync = ref.watch(elderlyModeNotifierProvider);
    final elderlyEnabled = elderlyAsync.valueOrNull ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel(label: '접근성 & 개인 보호'),
        const SizedBox(height: AppSpacing.sm),
        GlassCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              // 어르신 모드 — ElderlyModeNotifier 반응형
              Semantics(
                label: '어르신 모드',
                hint: '큰 글씨와 넓은 터치 영역을 사용합니다',
                toggled: elderlyEnabled,
                child: SwitchListTile(
                  secondary: const Icon(Icons.accessibility_new,
                      color: AppColors.secondary),
                  title: const Text('어르신 모드',
                      style: TextStyle(
                          fontSize: 15, color: AppColors.textPrimary)),
                  subtitle: const Text('큰 글씨 · 넓은 터치 영역',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
                  value: elderlyEnabled,
                  onChanged: (v) => ref
                      .read(elderlyModeNotifierProvider.notifier)
                      .setEnabled(v),
                  activeThumbColor: AppColors.secondary,
                ),
              ),
              const Divider(color: AppColors.glassBorder, height: 1),
              // Privacy Layer
              FutureBuilder<bool>(
                future: ref.read(settingsRepositoryProvider).isPrivacyEnabled(),
                builder: (context, snap) {
                  final enabled = snap.data ?? false;
                  return Semantics(
                    label: '개인 메모 잠금',
                    hint: 'Face ID 또는 Touch ID로 개인 메모를 보호합니다',
                    toggled: enabled,
                    child: SwitchListTile(
                      secondary: const Icon(Icons.lock_outline,
                          color: AppColors.accent),
                      title: const Text('개인 메모 잠금',
                          style: TextStyle(
                              fontSize: 15, color: AppColors.textPrimary)),
                      subtitle: const Text('Face ID / Touch ID로 보호',
                          style: TextStyle(
                              fontSize: 12, color: AppColors.textSecondary)),
                      value: enabled,
                      onChanged: (v) => ref
                          .read(settingsRepositoryProvider)
                          .setPrivacyEnabled(v),
                      activeThumbColor: AppColors.accent,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── 내보내기 섹션 ──────────────────────────────────────────────────────────────

class _ExportSection extends StatelessWidget {
  const _ExportSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel(label: '내보내기'),
        const SizedBox(height: AppSpacing.sm),
        GlassCard(
          padding: EdgeInsets.zero,
          child: ListTile(
            leading:
                const Icon(Icons.photo_size_select_large, color: AppColors.primary),
            title: const Text('가계도 포스터 내보내기',
                style: TextStyle(fontSize: 15, color: AppColors.textPrimary)),
            subtitle: const Text('고해상도 PNG · SNS/A4/A2',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            trailing: const Icon(Icons.chevron_right, color: AppColors.textTertiary),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                  builder: (_) => const HeritageExportScreen()),
            ),
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
                    title: const Text('버전',
                        style: TextStyle(
                            fontSize: 15, color: AppColors.textPrimary)),
                    trailing: Text(
                      info != null
                          ? '${info.version}+${info.buildNumber}'
                          : '-',
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.textSecondary),
                    ),
                  );
                },
              ),
              const Divider(color: AppColors.glassBorder, height: 1),
              ListTile(
                leading: const Icon(Icons.article_outlined,
                    color: AppColors.primary),
                title: const Text('오픈소스 라이선스',
                    style: TextStyle(
                        fontSize: 15, color: AppColors.textPrimary)),
                trailing: const Icon(Icons.chevron_right,
                    color: AppColors.textTertiary),
                onTap: () => showLicensePage(
                  context: context,
                  applicationName: 'Re-Link',
                  applicationLegalese: '© 2026 Re-Link',
                ),
              ),
              const Divider(color: AppColors.glassBorder, height: 1),
              ListTile(
                leading: const Icon(Icons.favorite_outline,
                    color: AppColors.accent),
                title: const Text('Re-Link',
                    style: TextStyle(
                        fontSize: 15, color: AppColors.textPrimary)),
                subtitle: const Text('가족의 기억을 잇다',
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

// ── 공통 섹션 레이블 ──────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
      ),
    );
  }
}
