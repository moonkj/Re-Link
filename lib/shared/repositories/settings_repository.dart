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

  // ── 테마 모드 ───────────────────────────────────────────────────────────

  Future<String> getThemeMode() async =>
      (await get(SettingsKey.themeMode)) ?? 'system';

  Future<void> setThemeMode(String mode) =>
      set(SettingsKey.themeMode, mode);

  // ── 햅틱 ────────────────────────────────────────────────────────────────

  Future<bool> isHapticEnabled() =>
      getBool(SettingsKey.hapticEnabled, defaultValue: true);

  Future<void> setHapticEnabled(bool enabled) =>
      set(SettingsKey.hapticEnabled, enabled.toString());

  // ── 애니메이션 줄이기 ───────────────────────────────────────────────────

  Future<bool> isReduceMotion() =>
      getBool(SettingsKey.reduceMotion, defaultValue: false);

  Future<void> setReduceMotion(bool enabled) =>
      set(SettingsKey.reduceMotion, enabled.toString());

  // ── 부부 자석 스냅 ────────────────────────────────────────────────────────

  Future<bool> isSpouseSnapEnabled() =>
      getBool(SettingsKey.spouseSnap, defaultValue: true);

  Future<void> setSpouseSnap(bool enabled) =>
      set(SettingsKey.spouseSnap, enabled.toString());

  // ── 내 노드 ────────────────────────────────────────────────────────────────

  Future<String?> getMyNodeId() async {
    final v = await get(SettingsKey.myNodeId);
    return (v == null || v.isEmpty) ? null : v;
  }

  Future<void> setMyNodeId(String nodeId) =>
      set(SettingsKey.myNodeId, nodeId);

  Future<void> clearMyNodeId() =>
      set(SettingsKey.myNodeId, '');

  // ── 스트릭 ────────────────────────────────────────────────────────────────

  Future<int> getStreakCount() async {
    final v = await get(SettingsKey.streakCount);
    return v == null ? 0 : int.tryParse(v) ?? 0;
  }

  Future<void> setStreakCount(int count) =>
      set(SettingsKey.streakCount, count.toString());

  Future<DateTime?> getStreakLastDate() async {
    final v = await get(SettingsKey.streakLastDate);
    return v == null ? null : DateTime.tryParse(v);
  }

  Future<void> setStreakLastDate(DateTime date) =>
      set(SettingsKey.streakLastDate, date.toIso8601String());

  Future<int> getStreakFreezeCount() async {
    final v = await get(SettingsKey.streakFreezeCount);
    return v == null ? 0 : int.tryParse(v) ?? 0;
  }

  Future<void> setStreakFreezeCount(int count) =>
      set(SettingsKey.streakFreezeCount, count.toString());

  Future<String?> getStreakFreezeUsedMonth() =>
      get(SettingsKey.streakFreezeUsedMonth);

  Future<void> setStreakFreezeUsedMonth(String month) =>
      set(SettingsKey.streakFreezeUsedMonth, month);
}
