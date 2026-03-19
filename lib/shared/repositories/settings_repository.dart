import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/app_database.dart';
import '../../core/database/tables/settings_table.dart';
import '../../shared/models/user_plan.dart';
import 'db_provider.dart';

part 'settings_repository.g.dart';

@riverpod
SettingsRepository settingsRepository(Ref ref) =>
    SettingsRepository(ref.watch(appDatabaseProvider));

class SettingsRepository {
  SettingsRepository(this._db);
  final AppDatabase _db;

  Future<String?> get(String key) => _db.getSetting(key);

  Future<void> set(String key, String value) => _db.setSetting(key, value);

  Future<bool> getBool(String key, {bool defaultValue = false}) async {
    final v = await get(key);
    return v == null ? defaultValue : v == 'true';
  }

  Future<double> getDouble(String key, {double defaultValue = 0.0}) async {
    final v = await get(key);
    return v == null ? defaultValue : double.tryParse(v) ?? defaultValue;
  }

  // ── 플랜 ──────────────────────────────────────────────────────────────────

  Future<UserPlan> getUserPlan() async {
    final v = await get(SettingsKey.userPlan);
    return UserPlan.values.firstWhere(
      (e) => e.name == v,
      orElse: () => UserPlan.free,
    );
  }

  Future<void> setUserPlan(UserPlan plan) =>
      set(SettingsKey.userPlan, plan.name);

  // ── 백업 설정 ─────────────────────────────────────────────────────────────

  Future<bool> isAutoBackupEnabled() =>
      getBool(SettingsKey.autoBackup, defaultValue: true);

  Future<void> setAutoBackup(bool enabled) =>
      set(SettingsKey.autoBackup, enabled.toString());

  Future<String> getBackupFrequency() async =>
      (await get(SettingsKey.backupFrequency)) ?? 'daily';

  Future<void> setBackupFrequency(String freq) =>
      set(SettingsKey.backupFrequency, freq);

  Future<DateTime?> getLastBackupAt() async {
    final v = await get(SettingsKey.lastBackupAt);
    return v == null ? null : DateTime.tryParse(v);
  }

  Future<void> setLastBackupAt(DateTime dt) =>
      set(SettingsKey.lastBackupAt, dt.toIso8601String());

  Future<String> getCloudProvider() async =>
      (await get(SettingsKey.cloudProvider)) ?? 'none';

  // ── 온보딩 ────────────────────────────────────────────────────────────────

  Future<bool> isOnboardingDone() =>
      getBool(SettingsKey.onboardingDone, defaultValue: false);

  Future<void> setOnboardingDone() =>
      set(SettingsKey.onboardingDone, 'true');

  // ── 어르신 모드 ───────────────────────────────────────────────────────────

  Future<bool> isElderlyMode() =>
      getBool(SettingsKey.elderlyMode, defaultValue: false);

  Future<void> setElderlyMode(bool enabled) =>
      set(SettingsKey.elderlyMode, enabled.toString());

  // ── Privacy Layer ──────────────────────────────────────────────────────────

  Future<bool> isPrivacyEnabled() =>
      getBool(SettingsKey.privacyEnabled, defaultValue: false);

  Future<void> setPrivacyEnabled(bool enabled) =>
      set(SettingsKey.privacyEnabled, enabled.toString());
}
