import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/services/backup/backup_format.dart';
import '../../../core/services/backup/backup_service.dart';
import '../../../design/glass/app_glass.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../design/tokens/app_spacing.dart';
import '../../../shared/repositories/settings_repository.dart';
import '../providers/backup_notifier.dart';

/// 백업 & 복원 화면
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
    final state = ref.watch(backupNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.bgBase,
      appBar: AppBar(
        title: Text('백업 & 복원',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
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
              // 마지막 백업 상태 카드
              _StatusCard(state: state),
              const SizedBox(height: AppSpacing.lg),

              // 지금 백업
              _ActionTile(
                icon: Icons.backup_outlined,
                title: '지금 백업',
                subtitle: Platform.isIOS ? 'iCloud Drive에 저장' : 'Google Drive에 저장',
                loading: state.isLoading,
                onTap: _backup,
              ),
              const SizedBox(height: AppSpacing.md),

              // 파일로 내보내기
              _ActionTile(
                icon: Icons.ios_share_outlined,
                title: '파일로 내보내기',
                subtitle: 'AirDrop / 카카오 등으로 가족과 공유',
                onTap: _exportFile,
              ),
              const SizedBox(height: AppSpacing.md),

              // 파일에서 가져오기
              _ActionTile(
                icon: Icons.file_download_outlined,
                title: '파일에서 가져오기',
                subtitle: '.rlink 백업 파일에서 복원',
                onTap: _importFile,
                isDestructive: true,
              ),

              // 클라우드 백업 목록
              if (state.cloudBackups.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xxl),
                Text(
                  '클라우드 백업 목록',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                ...state.cloudBackups.map((b) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: _BackupListTile(
                        backup: b,
                        onRestore: () => _restoreFromCloud(b),
                      ),
                    )),
              ],

              // 에러
              if (state.error != null) ...[
                const SizedBox(height: AppSpacing.md),
                Text(
                  '오류: ${state.error}',
                  style: const TextStyle(fontSize: 12, color: AppColors.error),
                ),
              ],

              const SizedBox(height: AppSpacing.xxxl),

              // 자동 백업 토글
              _AutoBackupToggle(),

              const SizedBox(height: AppSpacing.lg),
              Text(
                '• 백업 파일(.rlink)에는 모든 인물 정보, 사진, 음성이 포함됩니다\n'
                '• 파일로 내보내기를 통해 가족과 트리를 공유할 수 있습니다\n'
                '• 복원 시 현재 데이터가 덮어쓰여집니다',
                style: TextStyle(fontSize: 12, color: AppColors.textTertiary, height: 1.8),
              ),
            ],
          ),

          // 로딩 오버레이
          if (state.isLoading)
            Container(
              color: Colors.black38,
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _backup() async {
    final file = await ref.read(backupNotifierProvider.notifier).backup();
    if (!mounted) return;
    if (file != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('백업 완료: ${file.path.split('/').last}'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      final err = ref.read(backupNotifierProvider).error;
      if (err != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('백업 실패: $err'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _exportFile() async {
    try {
      final file = await ref.read(backupServiceProvider).createBackup();
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Re-Link 가족 트리 백업',
        text: 'Re-Link 앱에서 열어주세요 (.rlink)',
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('내보내기 실패: $e'), backgroundColor: AppColors.error),
      );
    }
  }

  Future<void> _importFile() async {
    final confirmed = await _confirmRestore();
    if (!confirmed) return;

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['rlink'],
      );
      if (result == null || result.files.isEmpty) return;

      final path = result.files.first.path;
      if (path == null) return;

      final manifest = await ref
          .read(backupNotifierProvider.notifier)
          .restoreFromFile(File(path));

      if (!mounted) return;
      if (manifest != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '복원 완료 — 노드 ${manifest.nodeCount}개, 기억 ${manifest.memoryCount}개\n앱을 재시작합니다.',
            ),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 4),
          ),
        );
      } else {
        final err = ref.read(backupNotifierProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('복원 실패: $err'), backgroundColor: AppColors.error),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('파일 선택 실패: $e'), backgroundColor: AppColors.error),
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? '복원 완료 — 앱을 재시작합니다.' : '복원 실패'),
        backgroundColor: ok ? AppColors.success : AppColors.error,
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
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('취소')),
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

// ── 상태 카드 ──────────────────────────────────────────────────────────────────

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.state});
  final BackupState state;

  @override
  Widget build(BuildContext context) {
    final providerLabel = switch (state.cloudProvider) {
      'icloud' => 'iCloud Drive',
      'google' => 'Google Drive',
      _ => '클라우드 미연결',
    };
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Icon(
            state.cloudProvider == 'none' ? Icons.cloud_off_outlined : Icons.cloud_done_outlined,
            color: state.cloudProvider == 'none' ? AppColors.textTertiary : AppColors.primary,
            size: 32,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('마지막 백업', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                Text(
                  state.lastBackupAt == null
                      ? '아직 백업이 없습니다'
                      : _formatDate(state.lastBackupAt!),
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
                Text(providerLabel, style: TextStyle(fontSize: 12, color: AppColors.secondary)),
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

// ── 백업 목록 타일 ─────────────────────────────────────────────────────────────

class _BackupListTile extends StatelessWidget {
  const _BackupListTile({required this.backup, required this.onRestore});
  final BackupInfo backup;
  final VoidCallback onRestore;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
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
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
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
            child: Text('복원', style: TextStyle(color: AppColors.primary, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

// ── 자동 백업 토글 ─────────────────────────────────────────────────────────────

class _AutoBackupToggle extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<bool>(
      future: ref.read(settingsRepositoryProvider).isAutoBackupEnabled(),
      builder: (context, snap) {
        final enabled = snap.data ?? true;
        return GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          child: Row(
            children: [
              Icon(Icons.schedule_outlined, color: AppColors.primary, size: 24),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('자동 백업', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    Text('24시간마다 자동으로 백업', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              Switch(
                value: enabled,
                onChanged: (v) => ref.read(settingsRepositoryProvider).setAutoBackup(v),
                activeThumbColor: AppColors.primary,
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── 액션 타일 ──────────────────────────────────────────────────────────────────

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
          Icon(icon, color: isDestructive ? AppColors.error : AppColors.primary, size: 28),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDestructive ? AppColors.error : AppColors.textPrimary,
                  ),
                ),
                Text(subtitle, style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          if (loading)
            SizedBox(width: 20, height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))
          else
            Icon(Icons.chevron_right, color: AppColors.textTertiary),
        ],
      ),
    );
  }
}
