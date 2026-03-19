import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_filex/open_filex.dart';
import '../../../core/services/backup/backup_service.dart';
import '../../../design/glass/app_glass.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../design/tokens/app_spacing.dart';
import '../../../shared/repositories/settings_repository.dart';

/// 백업 / 복원 화면
class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  bool _backing = false;
  bool _restoring = false;
  DateTime? _lastBackup;
  String? _cloudProvider;

  @override
  void initState() {
    super.initState();
    _loadInfo();
  }

  Future<void> _loadInfo() async {
    final settings = ref.read(settingsRepositoryProvider);
    final last = await settings.getLastBackupAt();
    final provider = await settings.getCloudProvider();
    if (!mounted) return;
    setState(() {
      _lastBackup = last;
      _cloudProvider = provider;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgBase,
      appBar: AppBar(
        title: const Text('백업 & 복원'),
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        children: [
          // 마지막 백업 상태
          GlassCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                const Icon(Icons.cloud_done, color: AppColors.primary, size: 32),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '마지막 백업',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        _lastBackup == null
                            ? '아직 백업이 없습니다'
                            : _formatDate(_lastBackup!),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (_cloudProvider != null && _cloudProvider != 'none')
                        Text(
                          _cloudProvider == 'icloud' ? 'iCloud Drive' : 'Google Drive',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.secondary,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // 지금 백업
          _ActionTile(
            icon: Icons.backup,
            title: '지금 백업',
            subtitle: '${_cloudProvider == 'icloud' ? 'iCloud Drive' : 'Google Drive'}에 저장',
            loading: _backing,
            onTap: _backup,
          ),
          const SizedBox(height: AppSpacing.md),

          // 파일로 내보내기 (가족 공유)
          _ActionTile(
            icon: Icons.ios_share,
            title: '파일로 내보내기',
            subtitle: 'AirDrop / 카카오 등으로 가족과 공유',
            onTap: _exportFile,
          ),
          const SizedBox(height: AppSpacing.md),

          // 파일에서 복원
          _ActionTile(
            icon: Icons.restore,
            title: '파일에서 복원',
            subtitle: '.rlink 백업 파일로 복원',
            loading: _restoring,
            onTap: _restoreFromFile,
            isDestructive: true,
          ),

          const SizedBox(height: AppSpacing.xxxl),
          // 안내 문구
          const Text(
            '• 백업 파일(.rlink)에는 모든 인물 정보, 사진, 음성이 포함됩니다\n'
            '• 파일로 내보내기를 통해 가족과 트리를 공유할 수 있습니다\n'
            '• 복원 시 현재 데이터가 덮어쓰여집니다',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textTertiary,
              height: 1.8,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _backup() async {
    setState(() => _backing = true);
    try {
      final service = ref.read(backupServiceProvider);
      final file = await service.createBackup();
      // TODO: 클라우드 업로드 (Phase 2 — iCloud/Google Drive 연동)
      await _loadInfo();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('백업 완료: ${file.path.split('/').last}'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('백업 실패: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _backing = false);
    }
  }

  Future<void> _exportFile() async {
    setState(() => _backing = true);
    try {
      final service = ref.read(backupServiceProvider);
      final file = await service.createBackup();
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
    } finally {
      if (mounted) setState(() => _backing = false);
    }
  }

  Future<void> _restoreFromFile() async {
    // 확인 다이얼로그
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgElevated,
        title: const Text('복원 확인', style: TextStyle(color: AppColors.textPrimary)),
        content: const Text(
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
    if (confirmed != true) return;

    // TODO: 파일 피커로 .rlink 선택 (file_picker 패키지 추가 예정)
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Phase 1에서 파일 피커 연동 예정')),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

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
            size: 28,
          ),
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
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          if (loading)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
            )
          else
            const Icon(Icons.chevron_right, color: AppColors.textTertiary),
        ],
      ),
    );
  }
}
