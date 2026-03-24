import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/router/app_router.dart';
import '../../../core/services/backup/backup_format.dart';
import '../../../core/services/sync/media_upload_queue_service.dart';
import '../../../core/services/sync/r2_media_service.dart';
import '../../../design/glass/app_glass.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../design/tokens/app_spacing.dart';
import '../../../shared/models/user_plan.dart';
import '../../../shared/repositories/settings_repository.dart';
import '../../family_sync/providers/family_sync_notifier.dart';
import '../../subscription/providers/plan_notifier.dart';
import '../providers/backup_notifier.dart';

/// 백업 & 복원 화면 — 4섹션 구성
/// 섹션 1: 로컬 백업 (모든 플랜)
/// 섹션 2: 클라우드 백업 (패밀리/패밀리플러스)
/// 섹션 3: 서버 동기화 (패밀리/패밀리플러스)
/// 섹션 4: 버전 관리 (패밀리플러스)
class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(backupNotifierProvider.notifier).loadCloudBackups();
    });
  }

  @override
  Widget build(BuildContext context) {
    final backupState = ref.watch(backupNotifierProvider);
    final planAsync = ref.watch(planNotifierProvider);
    final currentPlan = planAsync.valueOrNull ?? UserPlan.free;

    return Scaffold(
      backgroundColor: AppColors.bgBase,
      appBar: AppBar(
        title: Text(
          '백업 & 복원',
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
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(AppSpacing.pagePadding),
            children: [
              // ── 섹션 1: 로컬 백업 (모든 플랜) ──────────────────────────
              _SectionHeader(
                icon: Icons.inventory_2_outlined,
                title: '로컬 백업',
                subtitle: '기기 내 파일로 저장/복원',
                iconColor: AppColors.primary,
              ),
              const SizedBox(height: AppSpacing.sm),
              _ActionTile(
                icon: Icons.ios_share_outlined,
                title: '파일로 내보내기',
                subtitle: '.rlink 파일로 저장/공유 (AirDrop, 카카오 등)',
                onTap: _exportFile,
              ),
              const SizedBox(height: AppSpacing.sm),
              _ActionTile(
                icon: Icons.file_download_outlined,
                title: '파일에서 가져오기',
                subtitle: '.rlink 백업 파일에서 복원',
                onTap: _importFile,
                isDestructive: true,
              ),

              const SizedBox(height: AppSpacing.xxl),

              // ── 섹션 2: 클라우드 백업 (패밀리/패밀리플러스) ────────────
              if (currentPlan.hasCloud) ...[
                _SectionHeader(
                  icon: Icons.cloud_outlined,
                  title: '클라우드 백업',
                  subtitle: Platform.isIOS ? 'iCloud Drive' : 'Google Drive',
                  iconColor: AppColors.info,
                  badge: currentPlan.displayName,
                  badgeColor: currentPlan == UserPlan.familyPlus
                      ? AppColors.planFamilyPlus
                      : AppColors.planFamily,
                ),
                const SizedBox(height: AppSpacing.sm),

                // 마지막 백업 상태
                _CloudBackupStatusCard(state: backupState),
                const SizedBox(height: AppSpacing.sm),

                // 지금 백업
                _ActionTile(
                  icon: Icons.backup_outlined,
                  title: '지금 백업',
                  subtitle: Platform.isIOS
                      ? 'iCloud Drive에 전체 백업'
                      : 'Google Drive에 전체 백업',
                  loading: backupState.isLoading,
                  onTap: _backup,
                ),
                const SizedBox(height: AppSpacing.sm),

                // 클라우드 백업 목록
                if (backupState.cloudBackups.isNotEmpty)
                  _ActionTile(
                    icon: Icons.folder_outlined,
                    title: '클라우드 백업 목록',
                    subtitle: '${backupState.cloudBackups.length}개 — 이전 백업에서 복원',
                    onTap: () => _showCloudBackupList(backupState),
                  ),
                if (backupState.cloudBackups.isNotEmpty)
                  const SizedBox(height: AppSpacing.sm),

                // 자동 백업 토글
                _AutoBackupToggle(),

                const SizedBox(height: AppSpacing.xxl),
              ] else ...[
                // 업그레이드 유도 — 클라우드 백업
                _UpgradeBanner(
                  icon: Icons.cloud_outlined,
                  title: '클라우드 백업',
                  description: 'iCloud/Google Drive에 자동 백업하고\n이전 백업에서 복원할 수 있습니다.',
                  requiredPlan: '패밀리 플랜',
                ),
                const SizedBox(height: AppSpacing.xxl),
              ],

              // ── 섹션 3: 가족 클라우드 동기화 (패밀리/패밀리플러스) ──────
              if (currentPlan.hasCloud) ...[
                _SectionHeader(
                  icon: Icons.sync_outlined,
                  title: '가족 클라우드 동기화',
                  subtitle: '가족 구성원 간 데이터 업로드/다운로드',
                  iconColor: AppColors.success,
                  badge: currentPlan.displayName,
                  badgeColor: currentPlan == UserPlan.familyPlus
                      ? AppColors.planFamilyPlus
                      : AppColors.planFamily,
                ),
                const SizedBox(height: AppSpacing.sm),
                _ServerSyncSection(
                  plan: currentPlan,
                ),

                const SizedBox(height: AppSpacing.xxl),
              ] else ...[
                // 업그레이드 유도 — 가족 클라우드 동기화
                _UpgradeBanner(
                  icon: Icons.sync_outlined,
                  title: '가족 클라우드 동기화',
                  description: '가족과 데이터를 클라우드에 업로드하고\n다른 기기에서 다운로드할 수 있습니다.',
                  requiredPlan: '패밀리 플랜',
                ),
                const SizedBox(height: AppSpacing.xxl),
              ],

              // ── 섹션 4: 버전 관리 (패밀리플러스) ──────────────────────
              if (currentPlan.hasVersionedBackup) ...[
                _SectionHeader(
                  icon: Icons.history_outlined,
                  title: '버전 관리 백업',
                  subtitle: '최근 5개 버전 보관',
                  iconColor: AppColors.planFamilyPlus,
                  badge: '패밀리플러스',
                  badgeColor: AppColors.planFamilyPlus,
                ),
                const SizedBox(height: AppSpacing.sm),
                _VersionHistorySection(
                  versionHistory: backupState.versionHistory,
                  onRestore: _restoreFromVersion,
                ),

                const SizedBox(height: AppSpacing.xxl),
              ] else if (currentPlan.hasCloud) ...[
                // 패밀리 사용자에게 패밀리플러스 유도
                _UpgradeBanner(
                  icon: Icons.history_outlined,
                  title: '버전 관리 백업',
                  description: '최근 5개 버전의 백업 이력을 보관합니다.\n실수로 덮어쓴 데이터를 복구할 수 있습니다.',
                  requiredPlan: '패밀리플러스',
                ),
                const SizedBox(height: AppSpacing.xxl),
              ],

              // ── 에러 메시지 ────────────────────────────────────────────
              if (backupState.error != null) ...[
                GlassCard(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: AppColors.error, size: 20),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          backupState.error!,
                          style: TextStyle(fontSize: 12, color: AppColors.error),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],

              // ── 안내 문구 ──────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                child: Text(
                  '${String.fromCharCode(0x2022)} 백업 파일(.rlink)에는 모든 인물 정보, 사진, 음성이 포함됩니다\n'
                  '${String.fromCharCode(0x2022)} 파일로 내보내기를 통해 가족과 트리를 공유할 수 있습니다\n'
                  '${String.fromCharCode(0x2022)} 복원 시 현재 데이터가 덮어쓰여집니다',
                  style: TextStyle(fontSize: 12, color: AppColors.textTertiary, height: 1.8),
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),
            ],
          ),

          // 로딩 오버레이 (터치 이벤트 차단)
          if (backupState.isLoading)
            AbsorbPointer(
              child: Container(
                color: Colors.black38,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: AppColors.primary),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        '처리 중...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── 액션 핸들러 ──────────────────────────────────────────────────────────

  Future<void> _backup() async {
    final file = await ref.read(backupNotifierProvider.notifier).backup();
    if (!mounted) return;

    final err = ref.read(backupNotifierProvider).error;
    if (file != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            err != null
                ? '로컬 백업 완료 (클라우드 업로드에 문제가 있습니다)'
                : '백업 완료: ${file.path.split('/').last}',
          ),
          backgroundColor: err != null ? AppColors.warning : AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err ?? '백업에 실패했습니다.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _exportFile() async {
    final notifier = ref.read(backupNotifierProvider.notifier);
    try {
      // BackupNotifier를 통해 백업 생성 (로딩 상태 표시)
      final file = await notifier.backup();
      if (!mounted || file == null) return;
      final box = context.findRenderObject() as RenderBox?;
      final origin = box != null
          ? box.localToGlobal(Offset.zero) & box.size
          : const Rect.fromLTWH(0, 0, 100, 100);
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Re-Link 가족 트리 백업',
        text: 'Re-Link 앱에서 열어주세요 (.rlink)',
        sharePositionOrigin: origin,
      );
      // 내보내기 완료 후 안내 메시지
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            '백업 파일이 공유되었습니다.\n'
            '공유받은 분은 Re-Link 앱에서\n'
            '\'파일에서 가져오기\'로 복원할 수 있습니다.',
          ),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('내보내기 실패: $e'), backgroundColor: AppColors.error),
      );
    }
  }

  Future<void> _importFile() async {
    // 먼저 파일을 선택하고, 확인 후 복원 (파일 선택을 먼저 하면 사용자가 취소할 수 있음)
    try {
      // iOS에서 .rlink 커스텀 확장자가 인식되지 않는 문제 대비:
      // FileType.any로 모든 파일을 표시하고 선택 후 확장자를 검증
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
      );
      if (result == null || result.files.isEmpty) return;

      final path = result.files.first.path;
      if (path == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('파일 경로를 가져올 수 없습니다.'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      // 확장자 검증: .rlink 파일만 허용
      if (!path.toLowerCase().endsWith('.rlink')) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('.rlink 파일만 가져올 수 있습니다.\nRe-Link 백업 파일을 선택해주세요.'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
        return;
      }

      // 파일 선택 후 확인 대화상자
      final confirmed = await _confirmRestore();
      if (!confirmed) return;

      final manifest = await ref
          .read(backupNotifierProvider.notifier)
          .restoreFromFile(File(path));

      if (!mounted) return;
      if (manifest != null) {
        _showRestoreSuccessAndRestart(
          '복원 완료 -- 노드 ${manifest.nodeCount}개, 기억 ${manifest.memoryCount}개',
        );
      } else {
        final err = ref.read(backupNotifierProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(err ?? '복원에 실패했습니다.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('파일 선택 실패: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _restoreFromCloud(BackupInfo backup) async {
    final confirmed = await _confirmRestore();
    if (!confirmed) return;

    final ok = await ref
        .read(backupNotifierProvider.notifier)
        .restoreFromCloud(backup);

    if (!mounted) return;
    if (ok) {
      _showRestoreSuccessAndRestart('클라우드 백업 복원 완료');
    } else {
      final err = ref.read(backupNotifierProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err ?? '복원에 실패했습니다.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _restoreFromVersion(BackupVersionEntry entry) async {
    final confirmed = await _confirmRestore();
    if (!confirmed) return;

    final manifest = await ref
        .read(backupNotifierProvider.notifier)
        .restoreFromVersion(entry);

    if (!mounted) return;
    if (manifest != null) {
      _showRestoreSuccessAndRestart(
        '버전 ${entry.version} 복원 완료 -- 노드 ${manifest.nodeCount}개, 기억 ${manifest.memoryCount}개',
      );
    } else {
      final err = ref.read(backupNotifierProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err ?? '복원에 실패했습니다.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showCloudBackupList(BackupState state) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _CloudBackupListSheet(
        backups: state.cloudBackups,
        onRestore: (backup) {
          Navigator.of(ctx).pop();
          _restoreFromCloud(backup);
        },
      ),
    );
  }

  /// 복원 성공 후 앱 재시작 안내 대화상자 표시
  void _showRestoreSuccessAndRestart(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgElevated,
        title: Row(
          children: [
            Icon(Icons.check_circle_outline, color: AppColors.success, size: 24),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                '복원 완료',
                style: TextStyle(color: AppColors.textPrimary, fontSize: 16),
              ),
            ),
          ],
        ),
        content: Text(
          '$message\n\n데이터를 적용하려면 앱을 재시작해야 합니다.',
          style: TextStyle(color: AppColors.textSecondary, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              // 앱 최상위로 이동하여 DB 재연결 유도
              context.go('/');
            },
            child: Text('확인', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  Future<bool> _confirmRestore() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgElevated,
        title: Text('복원 확인', style: TextStyle(color: AppColors.textPrimary)),
        content: Text(
          '현재 데이터가 백업 파일로 덮어쓰여집니다.\n계속하시겠습니까?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('복원', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    return result == true;
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// ── 섹션 헤더 ─────────────────────────────────────────────────────────────────
// ══════════════════════════════════════════════════════════════════════════════

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
    this.badge,
    this.badgeColor,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;
  final String? badge;
  final Color? badgeColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (badge != null) ...[
                      const SizedBox(width: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: (badgeColor ?? AppColors.primary).withAlpha(30),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: (badgeColor ?? AppColors.primary).withAlpha(60),
                          ),
                        ),
                        child: Text(
                          badge!,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: badgeColor ?? AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 11, color: AppColors.textTertiary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// ── 클라우드 백업 상태 카드 ──────────────────────────────────────────────────
// ══════════════════════════════════════════════════════════════════════════════

class _CloudBackupStatusCard extends StatelessWidget {
  const _CloudBackupStatusCard({required this.state});
  final BackupState state;

  @override
  Widget build(BuildContext context) {
    final providerLabel = switch (state.cloudProvider) {
      'icloud' => 'iCloud Drive',
      'google' => 'Google Drive',
      _ => '클라우드 미연결',
    };
    final hasBackup = state.lastBackupAt != null;

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: (hasBackup ? AppColors.success : AppColors.textTertiary).withAlpha(20),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              hasBackup ? Icons.cloud_done_outlined : Icons.cloud_off_outlined,
              color: hasBackup ? AppColors.success : AppColors.textTertiary,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '마지막 백업',
                  style: TextStyle(fontSize: 11, color: AppColors.textTertiary),
                ),
                const SizedBox(height: 2),
                Text(
                  hasBackup
                      ? _formatDate(state.lastBackupAt!)
                      : '아직 백업이 없습니다',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  providerLabel,
                  style: TextStyle(fontSize: 11, color: AppColors.info),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) =>
      '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')} '
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}

// ══════════════════════════════════════════════════════════════════════════════
// ── 서버 동기화 섹션 ─────────────────────────────────────────────────────────
// ══════════════════════════════════════════════════════════════════════════════

class _ServerSyncSection extends ConsumerStatefulWidget {
  const _ServerSyncSection({required this.plan});
  final UserPlan plan;

  @override
  ConsumerState<_ServerSyncSection> createState() => _ServerSyncSectionState();
}

class _ServerSyncSectionState extends ConsumerState<_ServerSyncSection> {
  int _cloudUsageBytes = 0;
  int _pendingUploadCount = 0;
  DateTime? _lastSyncAt;
  bool _loadingUsage = true;

  @override
  void initState() {
    super.initState();
    _loadSyncInfo();
  }

  Future<void> _loadSyncInfo() async {
    try {
      final r2Service = ref.read(r2MediaServiceProvider);
      final queueService = ref.read(mediaUploadQueueServiceProvider);
      final settings = ref.read(settingsRepositoryProvider);

      // 병렬로 조회
      final results = await Future.wait([
        r2Service.getCloudUsageBytes(),
        queueService.getQueueStatus(),
        settings.getLastSyncAt(),
      ]);

      final usageBytes = results[0] as int;
      final queueStatus = results[1] as Map<String, int>;
      final lastSync = results[2] as DateTime?;

      final pending = (queueStatus['pending'] ?? 0) + (queueStatus['uploading'] ?? 0);

      if (mounted) {
        setState(() {
          _cloudUsageBytes = usageBytes;
          _pendingUploadCount = pending;
          _lastSyncAt = lastSync;
          _loadingUsage = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loadingUsage = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final syncState = ref.watch(familySyncNotifierProvider);
    final limitGB = widget.plan.cloudStorageGB;
    final usedGB = _cloudUsageBytes / (1024 * 1024 * 1024);
    final usagePercent = limitGB > 0 ? (usedGB / limitGB).clamp(0.0, 1.0) : 0.0;

    return Column(
      children: [
        // 동기화 상태 + 저장 공간
        GlassCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 동기화 상태
              Row(
                children: [
                  _SyncStatusDot(status: syncState.status),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      _syncStatusLabel(syncState),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.lg),

              // 저장 공간
              Row(
                children: [
                  Icon(Icons.storage_outlined, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    '저장 공간',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const Spacer(),
                  if (_loadingUsage)
                    SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.5,
                        color: AppColors.textTertiary,
                      ),
                    )
                  else
                    Text(
                      '${usedGB.toStringAsFixed(1)} GB / $limitGB GB',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              // 프로그레스 바
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: usagePercent,
                  backgroundColor: AppColors.bgElevated,
                  valueColor: AlwaysStoppedAnimation(
                    usagePercent > 0.85
                        ? AppColors.error
                        : usagePercent > 0.6
                            ? AppColors.warning
                            : AppColors.success,
                  ),
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '${(usagePercent * 100).toStringAsFixed(0)}% 사용 중',
                style: TextStyle(fontSize: 10, color: AppColors.textTertiary),
              ),

              // 업로드 대기
              if (_pendingUploadCount > 0) ...[
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withAlpha(15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.warning.withAlpha(40)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.cloud_upload_outlined, size: 16, color: AppColors.warning),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        '업로드 대기: $_pendingUploadCount개 파일',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.warning,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.sm),

        // 지금 동기화 버튼 (업로드 + 다운로드)
        _ActionTile(
          icon: Icons.sync_outlined,
          title: '지금 동기화',
          subtitle: '내 변경사항 업로드 + 가족 변경사항 다운로드',
          loading: syncState.isSyncing,
          onTap: _triggerSync,
        ),

        const SizedBox(height: AppSpacing.sm),

        // 자동 동기화 토글
        _AutoSyncToggle(),

        // 동기화 에러
        if (syncState.errorMessage != null) ...[
          const SizedBox(height: AppSpacing.sm),
          GlassCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Icon(Icons.warning_amber_outlined, size: 16, color: AppColors.error),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    syncState.errorMessage!,
                    style: TextStyle(fontSize: 11, color: AppColors.error),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  String _syncStatusLabel(FamilySyncState state) {
    if (state.isSyncing) return '업로드/다운로드 동기화 중...';

    final syncTime = _lastSyncAt ?? state.lastSyncAt;
    if (syncTime != null) {
      final diff = DateTime.now().difference(syncTime);
      if (diff.inMinutes < 1) return '방금 동기화 완료';
      if (diff.inMinutes < 60) return '${diff.inMinutes}분 전 동기화 완료';
      if (diff.inHours < 24) return '${diff.inHours}시간 전 동기화 완료';
      return '${diff.inDays}일 전 동기화 완료';
    }

    if (state.status == SyncStatus.error) return '동기화 오류 발생';
    return '아직 동기화한 적 없음';
  }

  Future<void> _triggerSync() async {
    // 1. 서버 동기화 (Pull: 가족 변경사항 다운로드 → Push: 내 변경사항 업로드)
    await ref.read(familySyncNotifierProvider.notifier).sync();

    // 2. 업로드 큐 처리 (미디어 파일 업로드)
    try {
      await ref.read(mediaUploadQueueServiceProvider).processQueue();
    } catch (e) {
      debugPrint('[BackupScreen] 미디어 업로드 큐 처리 오류: $e');
    }

    // 3. 상태 갱신
    if (mounted) {
      _loadSyncInfo();
    }
  }
}

// ── 동기화 상태 점 ──────────────────────────────────────────────────────────

class _SyncStatusDot extends StatelessWidget {
  const _SyncStatusDot({required this.status});
  final SyncStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      SyncStatus.idle => AppColors.textTertiary,
      SyncStatus.syncing => AppColors.info,
      SyncStatus.success => AppColors.success,
      SyncStatus.error => AppColors.error,
    };

    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// ── 자동 백업 토글 ──────────────────────────────────────────────────────────
// ══════════════════════════════════════════════════════════════════════════════

class _AutoBackupToggle extends ConsumerStatefulWidget {
  @override
  ConsumerState<_AutoBackupToggle> createState() => _AutoBackupToggleState();
}

class _AutoBackupToggleState extends ConsumerState<_AutoBackupToggle> {
  bool _enabled = true;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadValue();
  }

  Future<void> _loadValue() async {
    final value = await ref.read(settingsRepositoryProvider).isAutoBackupEnabled();
    if (mounted) {
      setState(() {
        _enabled = value;
        _loaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Icon(Icons.schedule_outlined, color: AppColors.info, size: 22),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '자동 백업',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '24시간마다 자동으로 클라우드에 백업',
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: _enabled,
            onChanged: _loaded
                ? (v) {
                    setState(() => _enabled = v);
                    ref.read(settingsRepositoryProvider).setAutoBackup(v);
                  }
                : null,
            activeTrackColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// ── 자동 동기화 토글 ────────────────────────────────────────────────────────
// ══════════════════════════════════════════════════════════════════════════════

class _AutoSyncToggle extends ConsumerStatefulWidget {
  @override
  ConsumerState<_AutoSyncToggle> createState() => _AutoSyncToggleState();
}

class _AutoSyncToggleState extends ConsumerState<_AutoSyncToggle> {
  bool _enabled = true;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadValue();
  }

  Future<void> _loadValue() async {
    final value = await ref.read(settingsRepositoryProvider).isAutoSyncEnabled();
    if (mounted) {
      setState(() {
        _enabled = value;
        _loaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Icon(Icons.autorenew_outlined, color: AppColors.success, size: 22),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '자동 동기화',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '앱 사용 중 자동으로 업로드/다운로드',
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: _enabled,
            onChanged: _loaded
                ? (v) {
                    setState(() => _enabled = v);
                    ref.read(settingsRepositoryProvider).setAutoSync(v);
                  }
                : null,
            activeTrackColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// ── 클라우드 백업 목록 바텀시트 ─────────────────────────────────────────────
// ══════════════════════════════════════════════════════════════════════════════

class _CloudBackupListSheet extends StatelessWidget {
  const _CloudBackupListSheet({
    required this.backups,
    required this.onRestore,
  });

  final List<BackupInfo> backups;
  final void Function(BackupInfo) onRestore;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 핸들
        Container(
          margin: const EdgeInsets.only(top: 12, bottom: 8),
          width: 36,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.textTertiary.withAlpha(80),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.pagePadding,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              Icon(Icons.folder_outlined, color: AppColors.info, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '클라우드 백업 목록',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                '${backups.length}개',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Flexible(
          child: ListView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.all(AppSpacing.pagePadding),
            itemCount: backups.length,
            itemBuilder: (ctx, i) {
              final backup = backups[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _BackupListTile(
                  backup: backup,
                  onRestore: () => onRestore(backup),
                ),
              );
            },
          ),
        ),
        SizedBox(height: MediaQuery.of(context).padding.bottom + AppSpacing.lg),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// ── 백업 목록 타일 ──────────────────────────────────────────────────────────
// ══════════════════════════════════════════════════════════════════════════════

class _BackupListTile extends StatelessWidget {
  const _BackupListTile({required this.backup, required this.onRestore});
  final BackupInfo backup;
  final VoidCallback onRestore;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Icon(Icons.folder_zip_outlined, color: AppColors.secondary, size: 24),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  backup.filename,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  backup.formattedSize,
                  style: TextStyle(fontSize: 11, color: AppColors.textTertiary),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onRestore,
            child: Text(
              '복원',
              style: TextStyle(color: AppColors.primary, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// ── 업그레이드 유도 배너 ────────────────────────────────────────────────────
// ══════════════════════════════════════════════════════════════════════════════

class _UpgradeBanner extends StatelessWidget {
  const _UpgradeBanner({
    required this.icon,
    required this.title,
    required this.description,
    required this.requiredPlan,
  });

  final IconData icon;
  final String title;
  final String description;
  final String requiredPlan;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          Icon(icon, size: 36, color: AppColors.textTertiary),
          const SizedBox(height: AppSpacing.md),
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: GlassButton(
              onPressed: () => context.push(AppRoutes.subscription),
              backgroundColor: AppColors.primary.withAlpha(15),
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.rocket_launch_outlined, size: 16, color: AppColors.primary),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    '$requiredPlan으로 업그레이드',
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
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// ── 액션 타일 ───────────────────────────────────────────────────────────────
// ══════════════════════════════════════════════════════════════════════════════

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.loading = false,
    this.isDestructive = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool loading;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: loading ? null : onTap,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Icon(
            icon,
            color: isDestructive ? AppColors.error : AppColors.primary,
            size: 24,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDestructive ? AppColors.error : AppColors.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          if (loading)
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            )
          else
            Icon(Icons.chevron_right, color: AppColors.textTertiary, size: 20),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// ── 버전 관리 백업 섹션 (패밀리플러스 전용) ─────────────────────────────────
// ══════════════════════════════════════════════════════════════════════════════

class _VersionHistorySection extends StatelessWidget {
  const _VersionHistorySection({
    required this.versionHistory,
    required this.onRestore,
  });

  final List<BackupVersionEntry> versionHistory;
  final void Function(BackupVersionEntry) onRestore;

  @override
  Widget build(BuildContext context) {
    if (versionHistory.isEmpty) {
      return GlassCard(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.inventory_2_outlined, size: 32, color: AppColors.textTertiary),
              const SizedBox(height: AppSpacing.sm),
              Text(
                '아직 버전 관리 백업이 없습니다',
                style: TextStyle(fontSize: 13, color: AppColors.textTertiary),
              ),
              const SizedBox(height: 4),
              Text(
                '백업을 생성하면 자동으로 버전이 기록됩니다.',
                style: TextStyle(fontSize: 11, color: AppColors.textTertiary),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: versionHistory
          .map((entry) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _VersionEntryTile(
                  entry: entry,
                  onRestore: () => onRestore(entry),
                ),
              ))
          .toList(),
    );
  }
}

// ── 버전 항목 타일 ──────────────────────────────────────────────────────────

class _VersionEntryTile extends StatelessWidget {
  const _VersionEntryTile({
    required this.entry,
    required this.onRestore,
  });

  final BackupVersionEntry entry;
  final VoidCallback onRestore;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          // 버전 번호 배지
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.planFamilyPlus.withAlpha(25),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.planFamilyPlus.withAlpha(60)),
            ),
            child: Center(
              child: Text(
                'v${entry.version}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.planFamilyPlus,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.formattedDate,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  entry.formattedSize,
                  style: TextStyle(fontSize: 11, color: AppColors.textTertiary),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onRestore,
            child: Text(
              '복원',
              style: TextStyle(color: AppColors.primary, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
