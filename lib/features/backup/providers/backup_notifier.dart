import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/services/backup/backup_format.dart';
import '../../../core/services/backup/backup_service.dart';
import '../../../core/services/cloud/icloud_backup.dart';
import '../../../core/services/cloud/google_drive_backup.dart';
import '../../../core/services/cloud/cloud_backup_provider.dart';
import '../../../shared/repositories/settings_repository.dart';

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

      // 클라우드 업로드 시도
      if (_cloudProvider != null) {
        final available = await _cloudProvider!.isAvailable();
        if (available) {
          await _cloudProvider!.upload(file);
          await _cloudProvider!.pruneOldBackups();

          // 클라우드 제공자 저장
          final providerName = Platform.isIOS ? 'icloud' : 'google';
          await ref.read(settingsRepositoryProvider).set('cloud_provider', providerName);
        }
      }

      await _loadInfo();
      await loadCloudBackups();
      state = state.copyWith(isLoading: false);
      return file;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }

  // ── 클라우드 백업 복원 ────────────────────────────────────────────────────

  Future<bool> restoreFromCloud(BackupInfo backup) async {
    if (_cloudProvider == null) return false;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final file = await _cloudProvider!.download(backup.filename);
      final service = ref.read(backupServiceProvider);
      await service.restoreBackup(file);
      await _loadInfo();
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  // ── 파일에서 복원 ─────────────────────────────────────────────────────────

  Future<BackupManifest?> restoreFromFile(File file) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final service = ref.read(backupServiceProvider);
      final manifest = await service.restoreBackup(file);
      await _loadInfo();
      state = state.copyWith(isLoading: false);
      return manifest;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }

  // ── 버전 관리 백업 복원 (패밀리플러스 전용) ──────────────────────────────

  Future<BackupManifest?> restoreFromVersion(BackupVersionEntry entry) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      // 로컬 임시 디렉토리에서 해당 버전 파일 찾기
      final service = ref.read(backupServiceProvider);
      final localBackups = await service.getLocalBackups();
      final match = localBackups.where((f) => f.path.endsWith(entry.fileName));

      if (match.isEmpty) {
        // 클라우드에서 다운로드 시도
        if (_cloudProvider != null) {
          try {
            final file = await _cloudProvider!.download(entry.fileName);
            final manifest = await service.restoreBackup(file);
            await _loadInfo();
            state = state.copyWith(isLoading: false);
            return manifest;
          } catch (_) {
            state = state.copyWith(
              isLoading: false,
              error: '버전 ${entry.version} 백업 파일을 찾을 수 없습니다.',
            );
            return null;
          }
        }
        state = state.copyWith(
          isLoading: false,
          error: '버전 ${entry.version} 백업 파일을 찾을 수 없습니다.',
        );
        return null;
      }

      final manifest = await service.restoreBackup(match.first);
      await _loadInfo();
      state = state.copyWith(isLoading: false);
      return manifest;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
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
}
