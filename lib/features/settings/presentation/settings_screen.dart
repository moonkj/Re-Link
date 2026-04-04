import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../core/database/tables/settings_table.dart';
import '../../../core/router/app_router.dart';
import '../../../core/services/privacy/privacy_service.dart';
import '../../../core/utils/path_utils.dart';
import '../../../design/glass/app_glass.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../design/tokens/app_radius.dart';
import '../../../design/tokens/app_spacing.dart';
import '../../../shared/models/user_plan.dart';
import '../../../shared/repositories/profile_repository.dart';
import '../../../shared/repositories/settings_repository.dart';
import '../../backup/providers/backup_notifier.dart';
import '../../subscription/providers/plan_notifier.dart';
import '../providers/elderly_mode_notifier.dart';
import '../providers/haptic_notifier.dart';
import '../providers/reduce_motion_notifier.dart';
import '../providers/spouse_snap_notifier.dart';
import '../../../shared/widgets/section_label.dart';
import '../providers/theme_mode_notifier.dart';
import '../../auth/providers/auth_notifier.dart';
import '../../canvas/providers/my_node_provider.dart';
import '../../../core/utils/pin_recovery_helper.dart';
import '../../../shared/repositories/node_repository.dart';

/// 관리자 모드 활성화 여부 (DB 연동)
final _adminEnabledProvider = FutureProvider<bool>((ref) async {
  return ref.read(settingsRepositoryProvider)
      .getBool(SettingsKey.adminModeEnabled);
});

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
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        children: [
          const _ProfileSection(),
          const SizedBox(height: AppSpacing.xl),
          const _AccountSection(),
          const SizedBox(height: AppSpacing.xl),
          const _PlanSection(),
          const SizedBox(height: AppSpacing.xl),
          const _ThemeSection(),
          const SizedBox(height: AppSpacing.xl),
          const _BackupSection(),
          const SizedBox(height: AppSpacing.xl),
          const _AccessibilitySection(),
          const SizedBox(height: AppSpacing.xl),
          const _PrivacyPromiseSection(),
          const SizedBox(height: AppSpacing.xl),
          const _FeedbackSection(),
          const SizedBox(height: AppSpacing.xl),
          const _AppInfoSection(),
          const SizedBox(height: AppSpacing.xl),
          const _AdminModeSection(),
          const SizedBox(height: AppSpacing.xxxl),
        ],
      ),
    );
  }
}

// ── 프로필 섹션 ────────────────────────────────────────────────────────────────

class _ProfileSection extends ConsumerStatefulWidget {
  const _ProfileSection();

  @override
  ConsumerState<_ProfileSection> createState() => _ProfileSectionState();
}

class _ProfileSectionState extends ConsumerState<_ProfileSection> {
  String? _profileName;
  String? _profileNickname;
  String? _profilePhotoPath;

  @override
  void initState() {
    super.initState();
    _reloadProfile();
  }

  Future<void> _reloadProfile() async {
    final profile = await ref.read(profileRepositoryProvider).getProfile();
    if (!mounted) return;
    setState(() {
      _profileName = profile?.name;
      _profileNickname = profile?.nickname;
      _profilePhotoPath = profile?.photoPath;
    });
  }

  void _openEditProfile(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ProfileEditSheet(),
    ).then((_) => _reloadProfile());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionLabel(label: '내 프로필'),
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
                  image: _profilePhotoPath != null
                      ? DecorationImage(
                          image: PathUtils.resolveFileImage(_profilePhotoPath) ??
                              FileImage(File(_profilePhotoPath!)),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _profilePhotoPath == null
                    ? Center(
                        child: Text(
                          _profileName?.isNotEmpty == true
                              ? _profileName![0]
                              : '?',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
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
                      _profileName ?? '프로필 없음',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (_profileNickname != null)
                      Text(
                        _profileNickname!,
                        style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary),
                      ),
                  ],
                ),
              ),
              GlassButton(
                onPressed: () => _openEditProfile(context),
                child: Text(
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
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.primary))
                  : Text(
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
    // 프로필 이름 → 내 노드 이름 동기화
    try {
      final myNodeId = await ref.read(settingsRepositoryProvider).getMyNodeId();
      if (myNodeId != null && myNodeId.isNotEmpty) {
        final nodeRepo = ref.read(nodeRepositoryProvider);
        final myNode = await nodeRepo.getById(myNodeId);
        if (myNode != null && myNode.name != name) {
          final updated = myNode.copyWith(name: name, updatedAt: DateTime.now());
          await nodeRepo.update(updated);
        }
      }
    } catch (_) {
      // 노드 동기화 실패는 무시 (프로필 저장은 성공)
    }
    if (!mounted) return;
    Navigator.of(context).pop();
  }
}

// ── 요금제 섹션 ────────────────────────────────────────────────────────────────

class _PlanSection extends ConsumerWidget {
  const _PlanSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan = ref.watch(planNotifierProvider).valueOrNull ?? UserPlan.free;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionLabel(label: '요금제'),
        const SizedBox(height: AppSpacing.sm),
        GlassCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Icon(
                plan == UserPlan.familyPlus
                    ? Icons.workspace_premium
                    : plan == UserPlan.family
                        ? Icons.family_restroom
                        : plan == UserPlan.plus
                            ? Icons.star_outline
                            : Icons.person_outline,
                color: plan == UserPlan.familyPlus
                    ? AppColors.planFamilyPlus
                    : plan == UserPlan.family
                        ? AppColors.planFamily
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
              if (plan != UserPlan.familyPlus)
                GlassButton(
                  onPressed: () => context.push(AppRoutes.subscription),
                  child: Text(
                    '업그레이드',
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
  }
}

// ── 백업 섹션 ─────────────────────────────────────────────────────────────────

class _BackupSection extends ConsumerWidget {
  const _BackupSection();

  String _formatDate(DateTime dt) =>
      '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')} '
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final backupState = ref.watch(backupNotifierProvider);
    final planAsync = ref.watch(planNotifierProvider);
    final currentPlan = planAsync.valueOrNull ?? UserPlan.free;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionLabel(label: '데이터 관리'),
        const SizedBox(height: AppSpacing.sm),
        GlassCard(
          padding: EdgeInsets.zero,
          child: ListTile(
            leading: Icon(Icons.cloud_done_outlined,
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
              child: Text(
                '데이터 관리',
                style: TextStyle(fontSize: 13, color: AppColors.primary),
              ),
            ),
          ),
        ),
        // 패밀리 플랜 데이터 보관 안내
        if (currentPlan.isSubscription)
          Padding(
            padding: const EdgeInsets.only(
              top: AppSpacing.xs,
              left: AppSpacing.sm,
              right: AppSpacing.sm,
            ),
            child: Text(
              '패밀리 플랜 해지 시 서버 데이터는 30일 후 삭제됩니다',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textTertiary,
              ),
            ),
          ),
      ],
    );
  }
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
        const SectionLabel(label: '테마'),
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
            borderRadius: AppRadius.radiusMd,
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
        const SectionLabel(label: '접근성 & 개인 보호'),
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
                  secondary: Icon(Icons.accessibility_new,
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
                  secondary: Icon(Icons.vibration,
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
                  secondary: Icon(Icons.animation,
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
                  secondary: Icon(Icons.compare_arrows,
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
              Divider(color: AppColors.glassBorder, height: 1),
              // PIN 초기화
              const _PinResetTile(),
            ],
          ),
        ),
      ],
    );
  }
}

// ── "나 설정 PIN 초기화" 타일 ───────────────────────────────────────────────

class _PinResetTile extends ConsumerStatefulWidget {
  const _PinResetTile();

  @override
  ConsumerState<_PinResetTile> createState() => _PinResetTileState();
}

class _PinResetTileState extends ConsumerState<_PinResetTile> {
  bool _hasPin = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPinState();
  }

  Future<void> _loadPinState() async {
    final pin = await ref.read(myNodeNotifierProvider.notifier).getPin();
    if (!mounted) return;
    setState(() {
      _hasPin = pin != null;
      _loading = false;
    });
  }

  Future<void> _onTap() async {
    if (!_hasPin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('등록된 PIN이 없습니다'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final user = ref.read(authNotifierProvider).valueOrNull;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('로그인 상태에서만 PIN을 초기화할 수 있습니다'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // 확인 다이얼로그
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('PIN 초기화'),
        content: Text(
          '${_providerLabel(user.provider)} 재인증 후 PIN을 초기화합니다.\n'
          '이후 새 PIN을 등록할 수 있습니다.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              '초기화',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final success = await PinRecoveryHelper.recover(
      context: context,
      ref: ref,
    );

    if (success && mounted) {
      _loadPinState(); // PIN 상태 갱신
    }
  }

  String _providerLabel(String provider) {
    switch (provider) {
      case 'apple':
        return 'Apple ID';
      case 'google':
        return 'Google';
      case 'kakao':
        return '카카오';
      default:
        return '소셜 로그인';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return ListTile(
        leading: const Icon(Icons.pin_outlined, color: AppColors.accent),
        title: const Text('나 설정 PIN 초기화'),
        trailing: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
        ),
      );
    }

    return ListTile(
      leading: Icon(
        Icons.pin_outlined,
        color: _hasPin ? AppColors.accent : AppColors.textDisabled,
      ),
      title: Text(
        '나 설정 PIN 초기화',
        style: TextStyle(
          fontSize: 15,
          color: _hasPin ? AppColors.textPrimary : AppColors.textDisabled,
        ),
      ),
      subtitle: Text(
        _hasPin ? '로그인 재인증으로 PIN 재설정' : 'PIN이 등록되어 있지 않습니다',
        style: TextStyle(
          fontSize: 12,
          color: AppColors.textSecondary,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: _hasPin ? AppColors.textSecondary : AppColors.textDisabled,
        size: 20,
      ),
      onTap: _hasPin ? _onTap : null,
    );
  }
}

// ── 프라이버시 약속 섹션 ──────────────────────────────────────────────────────

class _PrivacyPromiseSection extends ConsumerWidget {
  const _PrivacyPromiseSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan = ref.watch(planNotifierProvider).valueOrNull ?? UserPlan.free;
    final isCloudPlan =
        plan == UserPlan.family || plan == UserPlan.familyPlus;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionLabel(label: '프라이버시'),
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
                isCloudPlan
                    ? '당신의 가족 데이터를 팔지 않습니다.\n'
                      '광고 타겟팅에 사용하지 않습니다.\n'
                      'AI 학습에 사용하지 않습니다.\n'
                      '클라우드 동기화 데이터는 암호화되어 안전하게 전송됩니다.'
                    : '당신의 가족 데이터를 팔지 않습니다.\n'
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
                    isCloudPlan
                        ? '로컬 퍼스트 · 클라우드 동기화 활성'
                        : '100% 로컬 퍼스트 · 서버 없음',
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
        const SectionLabel(label: '개발자 소통'),
        const SizedBox(height: AppSpacing.sm),
        GlassCard(
          padding: EdgeInsets.zero,
          child: ListTile(
            leading: Icon(Icons.chat_bubble_outline,
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

class _AppInfoSection extends ConsumerStatefulWidget {
  const _AppInfoSection();

  @override
  ConsumerState<_AppInfoSection> createState() => _AppInfoSectionState();
}

class _AppInfoSectionState extends ConsumerState<_AppInfoSection> {
  int _tapCount = 0;
  Timer? _tapTimer;

  void _onVersionTap() {
    _tapCount++;
    _tapTimer?.cancel();
    _tapTimer = Timer(const Duration(seconds: 3), () => _tapCount = 0);

    if (_tapCount >= 7) {
      _tapCount = 0;
      _tapTimer?.cancel();
      HapticFeedback.heavyImpact();
      _enableAdminMode();
    }
  }

  Future<void> _enableAdminMode() async {
    final settings = ref.read(settingsRepositoryProvider);
    await settings.set(SettingsKey.adminModeEnabled, 'true');
    ref.invalidate(_adminEnabledProvider);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('개발자 모드 활성화됨'),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 2),
      ),
    );
    // 바로 Admin Console 열기
    context.push(AppRoutes.adminConsole);
  }

  @override
  void dispose() {
    _tapTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionLabel(label: '앱 정보'),
        const SizedBox(height: AppSpacing.sm),
        GlassCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              FutureBuilder<PackageInfo>(
                future: PackageInfo.fromPlatform(),
                builder: (context, snap) {
                  final info = snap.data;
                  return GestureDetector(
                    onTap: _onVersionTap,
                    child: ListTile(
                      leading: Icon(Icons.info_outline,
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
                    ),
                  );
                },
              ),
              Divider(color: AppColors.glassBorder, height: 1),
              ListTile(
                leading: Icon(Icons.privacy_tip_outlined,
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
                leading: Icon(Icons.description_outlined,
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
                leading: Icon(Icons.article_outlined,
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
      return ListTile(
        leading: const Icon(Icons.lock_outline, color: AppColors.accent),
        title: const Text('개인 메모 잠금'),
        trailing: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
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

// ── 관리자 모드 섹션 (admin_mode_enabled 시만 표시) ─────────────────────

class _AdminModeSection extends ConsumerWidget {
  const _AdminModeSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adminAsync = ref.watch(_adminEnabledProvider);
    final enabled = adminAsync.valueOrNull ?? false;
    if (!enabled) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionLabel(label: '개발자 모드'),
        const SizedBox(height: AppSpacing.sm),
        GlassCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.accent.withAlpha(15),
                  border: Border.all(
                      color: AppColors.accent.withAlpha(60), width: 1),
                  borderRadius: AppRadius.radiusSm,
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        color: AppColors.accent, size: 18),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      '개발자 전용 도구',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: GlassButton(
                  onPressed: () =>
                      context.push(AppRoutes.adminConsole),
                  backgroundColor: AppColors.accent.withAlpha(15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.admin_panel_settings,
                          color: AppColors.accent, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        'Admin Console 열기',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.accent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}


// ── 계정 섹션 ──────────────────────────────────────────────────────────────────

class _AccountSection extends ConsumerWidget {
  const _AccountSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authAsync = ref.watch(authNotifierProvider);
    final user = authAsync.valueOrNull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionLabel(label: '계정'),
        const SizedBox(height: AppSpacing.sm),
        GlassCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: user == null
              ? _buildSignInRow(context)
              : _buildSignedInContent(context, ref, user),
        ),
      ],
    );
  }

  Widget _buildSignInRow(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(20),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.person_outline, color: AppColors.primary, size: 24),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '로그인 안 됨',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '패밀리 플랜에서 클라우드 동기화 사용',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        GlassButton(
          onPressed: () => context.push(AppRoutes.login),
          child: Text(
            '로그인',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignedInContent(BuildContext context, WidgetRef ref, authUser) {
    final isFamily = authUser.hasFamilyPlan as bool;
    final providerStr = authUser.provider as String;
    final providerIcon = providerStr == 'apple'
        ? Icons.apple
        : providerStr == 'kakao'
            ? Icons.chat_bubble
            : Icons.account_circle_outlined;
    final email = authUser.email as String?;

    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: Icon(providerIcon, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    email ?? '로그인 됨',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    providerStr == 'apple'
                        ? 'Apple ID'
                        : providerStr == 'kakao'
                            ? '카카오 계정'
                            : 'Google 계정',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (isFamily) ...[
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: GlassButton(
              onPressed: () => context.push(AppRoutes.familyMembers),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.group_outlined, color: AppColors.primary, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    '가족 멤버 관리',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: GlassButton(
                onPressed: () => _confirmSignOut(context, ref),
                child: Text(
                  '로그아웃',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            GlassButton(
              onPressed: () => _confirmDeleteAccount(context, ref),
              child: Text(
                '계정 삭제',
                style: TextStyle(fontSize: 13, color: AppColors.error),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('로그아웃'),
        content: const Text('로그아웃하면 클라우드 동기화가 중단됩니다.\n로컬 데이터는 유지됩니다.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('취소')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('로그아웃', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await ref.read(authNotifierProvider.notifier).signOut();
  }

  Future<void> _confirmDeleteAccount(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('계정 삭제'),
        content: const Text(
          '계정을 삭제하면 서버의 모든 동기화 데이터가 영구 삭제됩니다.\n'
          '기기의 로컬 데이터는 유지됩니다.\n\n이 작업은 되돌릴 수 없습니다.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('취소')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('삭제', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await ref.read(authNotifierProvider.notifier).deleteAccount();
  }
}
