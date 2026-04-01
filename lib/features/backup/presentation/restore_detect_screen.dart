import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../core/services/backup/backup_service.dart';
import '../../../core/services/backup/backup_format.dart';
import '../../../core/services/cloud/cloud_backup_provider.dart';
import '../../../core/services/cloud/icloud_backup.dart';
import '../../../core/services/cloud/google_drive_backup.dart';
import '../../../shared/repositories/db_provider.dart';
import '../../../shared/repositories/settings_repository.dart';
import '../../canvas/providers/canvas_notifier.dart';
import '../../../design/glass/app_glass.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../design/tokens/app_spacing.dart';

/// 복원 감지 화면
///
/// 앱 첫 실행 시(프로필 없음) 클라우드에 기존 백업이 있는지 자동 감지.
/// - 로딩 중: "이전 데이터를 찾고 있어요..."
/// - 백업 발견: 복원/새로 시작 선택
/// - 미발견: 자동으로 온보딩 이동
class RestoreDetectScreen extends ConsumerStatefulWidget {
  const RestoreDetectScreen({super.key});

  @override
  ConsumerState<RestoreDetectScreen> createState() =>
      _RestoreDetectScreenState();
}

enum _DetectState { searching, found, notFound, restoring, error }

class _RestoreDetectScreenState extends ConsumerState<RestoreDetectScreen>
    with SingleTickerProviderStateMixin {
  _DetectState _state = _DetectState.searching;
  List<BackupInfo> _backups = [];
  String? _errorMessage;
  Timer? _autoNavTimer;

  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _detectBackups();
    });
  }

  @override
  void dispose() {
    _autoNavTimer?.cancel();
    _fadeCtrl.dispose();
    super.dispose();
  }

  // ── 클라우드 백업 탐지 ────────────────────────────────────────────────────

  Future<void> _detectBackups() async {
    try {
      CloudBackupProvider? provider;
      if (Platform.isIOS) {
        provider = ICloudBackup();
      } else if (Platform.isAndroid) {
        provider = GoogleDriveBackup();
      }

      if (provider == null) {
        _goToNotFound();
        return;
      }

      final available = await provider.isAvailable().timeout(
            const Duration(seconds: 5),
            onTimeout: () => false,
          );

      if (!available) {
        _goToNotFound();
        return;
      }

      final allBackups = await provider.listBackups().timeout(
            const Duration(seconds: 10),
            onTimeout: () => <BackupInfo>[],
          );

      if (!mounted) return;

      // 5KB 미만은 손상된 백업으로 간주하여 필터링
      final backups = allBackups.where((b) => b.sizeBytes > 5000).toList();

      if (backups.isEmpty) {
        _goToNotFound();
      } else {
        setState(() {
          _state = _DetectState.found;
          _backups = backups;
        });
      }
    } catch (e) {
      if (!mounted) return;
      _goToNotFound();
    }
  }

  void _goToNotFound() {
    if (!mounted) return;
    // 백업 미발견 → 즉시 온보딩으로 이동
    context.go(AppRoutes.onboarding);
  }

  // ── 복원 실행 ──────────────────────────────────────────────────────────────

  Future<void> _restore(BackupInfo backup) async {
    setState(() => _state = _DetectState.restoring);

    try {
      CloudBackupProvider? provider;
      if (Platform.isIOS) {
        provider = ICloudBackup();
      } else if (Platform.isAndroid) {
        provider = GoogleDriveBackup();
      }

      if (provider == null) {
        _showError('클라우드 서비스에 접근할 수 없습니다.');
        return;
      }

      debugPrint('[RestoreDetect] 다운로드 시작: ${backup.filename}');
      final file = await provider.download(backup.filename);
      debugPrint('[RestoreDetect] 다운로드 완료: ${file.path}, 크기: ${await file.length()} bytes');
      final service = ref.read(backupServiceProvider);
      await service.restoreBackup(file);
      debugPrint('[RestoreDetect] 복원 완료');

      // 복원 후 DB가 닫힌 상태 — 프로바이더 갱신 필수
      _invalidateIfRestored(service);

      if (!mounted) return;

      // 복원 성공 → 캔버스 이동
      context.go(AppRoutes.canvas);
    } catch (e) {
      // DB가 이미 닫힌 상태일 수 있으므로 프로바이더 갱신 시도
      try {
        final service = ref.read(backupServiceProvider);
        _invalidateIfRestored(service);
      } catch (_) {}
      if (!mounted) return;
      debugPrint('[RestoreDetect] 복원 실패 상세: $e');
      _showError('복원 실패: ${backup.filename}\n\n$e');
    }
  }

  void _invalidateIfRestored(BackupService service) {
    if (!service.restoreCompleted) return;
    ref.invalidate(appDatabaseProvider);
    ref.invalidate(backupServiceProvider);
    ref.invalidate(settingsRepositoryProvider);
    ref.invalidate(canvasNotifierProvider);
  }

  void _showError(String message) {
    setState(() {
      _state = _DetectState.error;
      _errorMessage = message;
    });
  }

  void _startFresh() {
    _autoNavTimer?.cancel();
    context.go(AppRoutes.onboarding);
  }

  // ── UI ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgBase,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.pagePadding,
            ),
            child: switch (_state) {
              _DetectState.searching => _buildSearching(),
              _DetectState.found => _buildFound(),
              _DetectState.notFound => _buildNotFound(),
              _DetectState.restoring => _buildRestoring(),
              _DetectState.error => _buildError(),
            },
          ),
        ),
      ),
    );
  }

  // ── 탐색 중 ───────────────────────────────────────────────────────────────

  Widget _buildSearching() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 32,
          height: 32,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        Text(
          '이전 데이터를 찾고 있어요...',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          '클라우드에 저장된 가족 트리를 확인하고 있습니다',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  // ── 백업 발견 ──────────────────────────────────────────────────────────────

  Widget _buildFound() {
    final latest = _backups.first;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 아이콘
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary.withAlpha(20),
          ),
          child: Icon(
            Icons.cloud_done_outlined,
            size: 32,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),

        Text(
          '이전 가족 트리가 발견되었습니다!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          '기존 데이터를 복원하면\n모든 기억이 되살아납니다.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),

        // 백업 정보 카드
        GlassCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    latest.source == 'icloud'
                        ? Icons.cloud_outlined
                        : Icons.cloud_outlined,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      latest.source == 'icloud'
                          ? 'iCloud Drive'
                          : 'Google Drive',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Text(
                    latest.formattedSize,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Icon(Icons.access_time, size: 14,
                      color: AppColors.textTertiary),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    _formatDate(latest.createdAt),
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),

        // 복원 버튼
        SizedBox(
          width: double.infinity,
          child: PrimaryGlassButton(
            label: '복원하기',
            icon: Icon(Icons.restore, color: AppColors.onPrimary, size: 18),
            onPressed: () => _restore(latest),
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // 새로 시작
        SizedBox(
          width: double.infinity,
          child: GlassButton(
            onPressed: _startFresh,
            child: Center(
              child: Text(
                '새로 시작하기',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── 미발견 ─────────────────────────────────────────────────────────────────

  Widget _buildNotFound() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.cloud_off_outlined,
          size: 40,
          color: AppColors.textTertiary,
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          '이전 데이터가 없습니다',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          '새로운 가족 트리를 시작합니다...',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }

  // ── 복원 중 ────────────────────────────────────────────────────────────────

  Widget _buildRestoring() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        Text(
          '가족 트리를 복원하고 있어요...',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          '잠시만 기다려 주세요',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  // ── 에러 ───────────────────────────────────────────────────────────────────

  Widget _buildError() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.error_outline,
          size: 40,
          color: AppColors.error,
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          '복원에 실패했습니다',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        if (_errorMessage != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.xxl),

        // 다시 시도
        SizedBox(
          width: double.infinity,
          child: PrimaryGlassButton(
            label: '다시 시도',
            onPressed: () {
              setState(() {
                _state = _DetectState.searching;
                _errorMessage = null;
              });
              _detectBackups();
            },
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // 새로 시작
        SizedBox(
          width: double.infinity,
          child: GlassButton(
            onPressed: _startFresh,
            child: Center(
              child: Text(
                '새로 시작하기',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
