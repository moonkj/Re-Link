import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/services/backup/backup_format.dart';
import '../../../core/services/backup/backup_service.dart';
import '../../../core/services/cloud/icloud_backup.dart';
import '../../../core/services/cloud/google_drive_backup.dart';
import '../../../core/services/cloud/cloud_backup_provider.dart';
import '../../../shared/repositories/db_provider.dart';
import '../../../shared/repositories/settings_repository.dart';
import '../../canvas/providers/canvas_notifier.dart';

part 'backup_notifier.g.dart';

/// 백업 UI 상태
class BackupState {
  const BackupState({
    this.isLoading = false,
    this.lastBackupAt,
    this.cloudBackups = const [],
    this.cloudProvider = 'none',
    this.versionHistory = const [],
    this.error,
  });

  final bool isLoading;
  final DateTime? lastBackupAt;
  final List<BackupInfo> cloudBackups;
  final String cloudProvider; // 'icloud' | 'google' | 'none'
  final List<BackupVersionEntry> versionHistory;
  final String? error;

  BackupState copyWith({
    bool? isLoading,
    DateTime? lastBackupAt,
    List<BackupInfo>? cloudBackups,
    String? cloudProvider,
    List<BackupVersionEntry>? versionHistory,
    String? error,
    bool clearError = false,
  }) =>
      BackupState(
        isLoading: isLoading ?? this.isLoading,
        lastBackupAt: lastBackupAt ?? this.lastBackupAt,
        cloudBackups: cloudBackups ?? this.cloudBackups,
        cloudProvider: cloudProvider ?? this.cloudProvider,
        versionHistory: versionHistory ?? this.versionHistory,
        error: clearError ? null : (error ?? this.error),
      );
}

@riverpod
class BackupNotifier extends _$BackupNotifier {
  CloudBackupProvider? _cloudProvider;

  @override
  BackupState build() {
    _initCloud();
    _loadInfo();
    return const BackupState();
  }

  void _initCloud() {
    if (Platform.isIOS) {
      _cloudProvider = ICloudBackup();
    } else if (Platform.isAndroid) {
      _cloudProvider = GoogleDriveBackup();
    }
  }

  Future<void> _loadInfo() async {
    final settings = ref.read(settingsRepositoryProvider);
    final lastAt = await settings.getLastBackupAt();
    final provider = await settings.getCloudProvider();
    final history = await settings.getBackupVersionHistory();
    state = state.copyWith(
      lastBackupAt: lastAt,
      cloudProvider: provider,
      versionHistory: history,
    );
  }

  // ── 클라우드 백업 목록 조회 ────────────────────────────────────────────────

  Future<void> loadCloudBackups() async {
    if (_cloudProvider == null) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final available = await _cloudProvider!.isAvailable();
      if (!available) {
        state = state.copyWith(isLoading: false, cloudBackups: []);
        return;
      }
      final backups = await _cloudProvider!.listBackups();
      state = state.copyWith(isLoading: false, cloudBackups: backups);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // ── 로컬 전용 백업 (파일 내보내기용, 클라우드 업로드 안 함) ──────────────

  Future<File?> createLocalBackup() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final service = ref.read(backupServiceProvider);
      final file = await service.createBackup();
      await _loadInfo();
      state = state.copyWith(isLoading: false);
      return file;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: '$e');
      return null;
    }
  }

  // ── 백업 생성 + 클라우드 업로드 ───────────────────────────────────────────

  Future<File?> backup() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final service = ref.read(backupServiceProvider);
      final settings = ref.read(settingsRepositoryProvider);
      final plan = await settings.getUserPlan();
      final file = await service.createBackup(
        versioned: plan.hasVersionedBackup,
      );

      // 클라우드 업로드 시도 (실패해도 로컬 백업은 성공)
      String? cloudError;
      if (_cloudProvider != null) {
        try {
          final available = await _cloudProvider!.isAvailable();
          if (available) {
            await _cloudProvider!.upload(file);
            await _cloudProvider!.pruneOldBackups();

            // 클라우드 제공자 저장
            final providerName = Platform.isIOS ? 'icloud' : 'google';
            await settings.set('cloud_provider', providerName);
          } else {
            cloudError = '클라우드 저장소에 접근할 수 없습니다. 로컬에만 저장되었습니다.';
          }
        } catch (e) {
          cloudError = '클라우드 업로드 실패: ${_userFriendlyError(e)}\n로컬 백업은 성공했습니다.';
          debugPrint('[BackupNotifier] 클라우드 업로드 실패: $e');
        }
      }

      await _loadInfo();
      await loadCloudBackups();
      state = state.copyWith(
        isLoading: false,
        error: cloudError,
      );
      return file;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '백업 생성 실패: ${_userFriendlyError(e)}',
      );
      return null;
    }
  }

  // ── 클라우드 백업 복원 ────────────────────────────────────────────────────

  Future<bool> restoreFromCloud(BackupInfo backup) async {
    if (_cloudProvider == null) {
      state = state.copyWith(
        error: '클라우드 연결이 설정되지 않았습니다.',
      );
      return false;
    }
    state = state.copyWith(isLoading: true, clearError: true);
    final service = ref.read(backupServiceProvider);
    try {
      final file = await _cloudProvider!.download(backup.filename);
      await service.restoreBackup(file);
      _invalidateAfterRestore(service);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      // DB가 이미 닫힌 상태라면 프로바이더 갱신 필수
      if (service.restoreCompleted) _invalidateAfterRestore(service);
      state = state.copyWith(
        isLoading: false,
        error: '클라우드 복원 실패: ${_userFriendlyError(e)}',
      );
      return false;
    }
  }

  // ── 파일에서 복원 ─────────────────────────────────────────────────────────

  Future<BackupManifest?> restoreFromFile(File file) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final service = ref.read(backupServiceProvider);
    try {
      final manifest = await service.restoreBackup(file);
      _invalidateAfterRestore(service);
      state = state.copyWith(isLoading: false);
      return manifest;
    } catch (e) {
      if (service.restoreCompleted) _invalidateAfterRestore(service);
      state = state.copyWith(
        isLoading: false,
        error: '복원 실패: ${_userFriendlyError(e)}',
      );
      return null;
    }
  }

  // ── 버전 관리 백업 복원 (패밀리플러스 전용) ──────────────────────────────

  Future<BackupManifest?> restoreFromVersion(BackupVersionEntry entry) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final service = ref.read(backupServiceProvider);
    try {
      // 1. 로컬 임시 디렉토리에서 해당 버전 파일 찾기
      final localBackups = await service.getLocalBackups();
      final match = localBackups.where((f) => f.path.endsWith(entry.fileName));

      File backupFile;
      if (match.isNotEmpty) {
        backupFile = match.first;
      } else if (_cloudProvider != null) {
        // 2. 클라우드에서 다운로드 시도
        try {
          backupFile = await _cloudProvider!.download(entry.fileName);
        } catch (e) {
          state = state.copyWith(
            isLoading: false,
            error: '버전 ${entry.version} 백업 파일을 클라우드에서 다운로드할 수 없습니다: ${_userFriendlyError(e)}',
          );
          return null;
        }
      } else {
        state = state.copyWith(
          isLoading: false,
          error: '버전 ${entry.version} 백업 파일을 찾을 수 없습니다.\n로컬 임시 파일이 삭제되었을 수 있습니다.',
        );
        return null;
      }

      final manifest = await service.restoreBackup(backupFile);
      _invalidateAfterRestore(service);
      state = state.copyWith(isLoading: false);
      return manifest;
    } catch (e) {
      if (service.restoreCompleted) _invalidateAfterRestore(service);
      state = state.copyWith(
        isLoading: false,
        error: '버전 복원 실패: ${_userFriendlyError(e)}',
      );
      return null;
    }
  }

  // ── 복원 후 프로바이더 갱신 (공통) ───────────────────────────────────────

  void _invalidateAfterRestore(BackupService service) {
    if (!service.restoreCompleted) return;
    ref.invalidate(appDatabaseProvider);
    ref.invalidate(backupServiceProvider);
    ref.invalidate(settingsRepositoryProvider);
    ref.invalidate(canvasNotifierProvider);
  }

  // ── 자동 백업 체크 (앱 포그라운드 진입 시 호출) ───────────────────────────

  Future<void> checkAutoBackup() async {
    try {
      final settings = ref.read(settingsRepositoryProvider);
      final autoEnabled = await settings.isAutoBackupEnabled();
      if (!autoEnabled) return;

      final lastAt = await settings.getLastBackupAt();
      final now = DateTime.now();
      if (lastAt == null || now.difference(lastAt).inHours >= 24) {
        debugPrint('[BackupNotifier] 자동 백업 시작');
        await backup();
      }
    } catch (e) {
      debugPrint('[BackupNotifier] 자동 백업 실패: $e');
    }
  }

  // ── Google Drive 로그인 ───────────────────────────────────────────────────

  Future<bool> signInGoogle() async {
    if (_cloudProvider is! GoogleDriveBackup) return false;
    return (_cloudProvider as GoogleDriveBackup).signIn();
  }

  // ── 에러 메시지 정리 ────────────────────────────────────────────────────

  /// Exception 메시지에서 "Exception: " 접두사를 제거하여 사용자 친화적으로 표시
  String _userFriendlyError(Object e) {
    final msg = e.toString();
    if (msg.startsWith('Exception: ')) {
      return msg.substring(11);
    }
    return msg;
  }
}
