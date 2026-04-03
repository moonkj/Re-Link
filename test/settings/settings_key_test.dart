/// SettingsKey 상수 테스트
/// 커버: settings_table.dart — SettingsKey 상수 정의
import 'package:flutter_test/flutter_test.dart';
import 'package:re_link/core/database/tables/settings_table.dart';

void main() {
  group('SettingsKey constants', () {
    test('userPlan key', () {
      expect(SettingsKey.userPlan, 'user_plan');
    });

    test('autoBackup key', () {
      expect(SettingsKey.autoBackup, 'auto_backup');
    });

    test('backupFrequency key', () {
      expect(SettingsKey.backupFrequency, 'backup_freq');
    });

    test('lastBackupAt key', () {
      expect(SettingsKey.lastBackupAt, 'last_backup_at');
    });

    test('cloudProvider key', () {
      expect(SettingsKey.cloudProvider, 'cloud_provider');
    });

    test('onboardingDone key', () {
      expect(SettingsKey.onboardingDone, 'onboarding_done');
    });

    test('elderlyMode key', () {
      expect(SettingsKey.elderlyMode, 'elderly_mode');
    });

    test('privacyEnabled key', () {
      expect(SettingsKey.privacyEnabled, 'privacy_enabled');
    });

    test('themeMode key', () {
      expect(SettingsKey.themeMode, 'theme_mode');
    });

    test('hapticEnabled key', () {
      expect(SettingsKey.hapticEnabled, 'haptic_enabled');
    });

    test('reduceMotion key', () {
      expect(SettingsKey.reduceMotion, 'reduce_motion');
    });

    test('spouseSnap key', () {
      expect(SettingsKey.spouseSnap, 'spouse_snap');
    });

    test('myNodeId key', () {
      expect(SettingsKey.myNodeId, 'my_node_id');
    });

    test('myNodePin key', () {
      expect(SettingsKey.myNodePin, 'my_node_pin');
    });

    test('streakCount key', () {
      expect(SettingsKey.streakCount, 'streak_count');
    });

    test('streakLastDate key', () {
      expect(SettingsKey.streakLastDate, 'streak_last_date');
    });

    test('treeGrowthStage key', () {
      expect(SettingsKey.treeGrowthStage, 'tree_growth_stage');
    });

    test('authUserId key', () {
      expect(SettingsKey.authUserId, 'auth_user_id');
    });

    test('familyGroupId key', () {
      expect(SettingsKey.familyGroupId, 'family_group_id');
    });

    test('deviceId key', () {
      expect(SettingsKey.deviceId, 'device_id');
    });

    test('lastSyncAt key', () {
      expect(SettingsKey.lastSyncAt, 'last_sync_at');
    });

    test('inviteCode key', () {
      expect(SettingsKey.inviteCode, 'invite_code');
    });

    test('all keys are non-empty strings', () {
      final keys = [
        SettingsKey.userPlan,
        SettingsKey.autoBackup,
        SettingsKey.backupFrequency,
        SettingsKey.lastBackupAt,
        SettingsKey.cloudProvider,
        SettingsKey.onboardingDone,
        SettingsKey.elderlyMode,
        SettingsKey.privacyEnabled,
        SettingsKey.themeMode,
        SettingsKey.hapticEnabled,
        SettingsKey.reduceMotion,
        SettingsKey.spouseSnap,
        SettingsKey.myNodeId,
        SettingsKey.myNodePin,
        SettingsKey.streakCount,
        SettingsKey.streakLastDate,
        SettingsKey.treeGrowthStage,
        SettingsKey.authUserId,
        SettingsKey.familyGroupId,
        SettingsKey.deviceId,
        SettingsKey.lastSyncAt,
        SettingsKey.inviteCode,
        SettingsKey.earnedBadges,
        SettingsKey.welcomeCapsulePlayed,
        SettingsKey.adminModeEnabled,
        SettingsKey.backupVersionHistory,
      ];
      for (final key in keys) {
        expect(key, isNotEmpty, reason: 'Key should not be empty');
      }
    });

    test('all keys are unique', () {
      final keys = [
        SettingsKey.userPlan,
        SettingsKey.autoBackup,
        SettingsKey.backupFrequency,
        SettingsKey.lastBackupAt,
        SettingsKey.cloudProvider,
        SettingsKey.onboardingDone,
        SettingsKey.elderlyMode,
        SettingsKey.privacyEnabled,
        SettingsKey.themeMode,
        SettingsKey.hapticEnabled,
        SettingsKey.reduceMotion,
        SettingsKey.spouseSnap,
        SettingsKey.myNodeId,
        SettingsKey.myNodePin,
        SettingsKey.streakCount,
        SettingsKey.streakLastDate,
        SettingsKey.treeGrowthStage,
        SettingsKey.authUserId,
        SettingsKey.familyGroupId,
        SettingsKey.deviceId,
        SettingsKey.lastSyncAt,
        SettingsKey.inviteCode,
      ];
      expect(keys.toSet().length, keys.length);
    });
  });
}
