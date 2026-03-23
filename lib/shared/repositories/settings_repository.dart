import 'dart:convert';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
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
    // 기존 3-tier 값 마이그레이션: basic→plus, premium→familyPlus
    final migrated = switch (v) {
      'basic' => 'plus',
      'premium' => 'familyPlus',
      _ => v,
    };
    // 마이그레이션된 값이 다르면 DB 업데이트
    if (migrated != v && migrated != null) {
      await set(SettingsKey.userPlan, migrated);
    }
    return UserPlan.values.firstWhere(
      (e) => e.name == migrated,
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

  // ── 내 노드 PIN ──────────────────────────────────────────────────────────

  Future<String?> getMyNodePin() async {
    final v = await get(SettingsKey.myNodePin);
    return (v == null || v.isEmpty) ? null : v;
  }

  Future<void> setMyNodePin(String pin) =>
      set(SettingsKey.myNodePin, pin);

  Future<void> clearMyNodePin() =>
      set(SettingsKey.myNodePin, '');

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

  // ── 초대 코드 ──────────────────────────────────────────────────────────────

  Future<String?> getInviteCode() async => get(SettingsKey.inviteCode);
  Future<void> setInviteCode(String code) => set(SettingsKey.inviteCode, code);

  // ── 인증 / 클라우드 동기화 ────────────────────────────────────────────────

  Future<String?> getAuthUserId() async => get(SettingsKey.authUserId);
  Future<void> setAuthUserId(String id) => set(SettingsKey.authUserId, id);

  Future<String?> getFamilyGroupId() async => get(SettingsKey.familyGroupId);
  Future<void> setFamilyGroupId(String id) => set(SettingsKey.familyGroupId, id);

  /// 기기 고유 UUID — 최초 실행 시 자동 생성 후 영구 저장
  Future<String?> getDeviceId() async {
    var id = await get(SettingsKey.deviceId);
    if (id == null || id.isEmpty) {
      id = const Uuid().v4();
      await set(SettingsKey.deviceId, id);
    }
    return id;
  }

  // ── 버전 관리 백업 (패밀리플러스 전용) ─────────────────────────────────

  /// 다음 백업 버전 번호 조회 및 증가
  Future<int> getNextBackupVersion() async {
    final v = await get(SettingsKey.backupVersionCounter);
    final current = v == null ? 0 : int.tryParse(v) ?? 0;
    final next = current + 1;
    await set(SettingsKey.backupVersionCounter, next.toString());
    return next;
  }

  /// 백업 버전 히스토리 조회 (최대 5개, 최신순)
  Future<List<BackupVersionEntry>> getBackupVersionHistory() async {
    final raw = await get(SettingsKey.backupVersionHistory);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((e) => BackupVersionEntry.fromJson(e as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => b.version.compareTo(a.version));
    } catch (_) {
      return [];
    }
  }

  /// 백업 버전 히스토리에 항목 추가 (최대 5개 유지)
  Future<void> addBackupVersion(BackupVersionEntry entry) async {
    final history = await getBackupVersionHistory();
    history.insert(0, entry);
    // 최대 5개 유지 — 오래된 항목 삭제
    final trimmed = history.length > 5 ? history.sublist(0, 5) : history;
    final json = jsonEncode(trimmed.map((e) => e.toJson()).toList());
    await set(SettingsKey.backupVersionHistory, json);
  }

  /// 인증 관련 데이터 초기화 (로그아웃 시 호출)
  Future<void> clearAuthData() async {
    await set(SettingsKey.authUserId, '');
    await set(SettingsKey.familyGroupId, '');
    await set(SettingsKey.lastSyncAt, '');
  }

  Future<DateTime?> getLastSyncAt() async {
    final v = await get(SettingsKey.lastSyncAt);
    if (v == null || v.isEmpty) return null;
    return DateTime.tryParse(v);
  }

  Future<void> setLastSyncAt(DateTime dt) =>
      set(SettingsKey.lastSyncAt, dt.toIso8601String());
}

// ── 백업 버전 엔트리 모델 ─────────────────────────────────────────────────────

/// 백업 버전 히스토리 항목
class BackupVersionEntry {
  const BackupVersionEntry({
    required this.version,
    required this.date,
    required this.fileName,
    required this.sizeBytes,
  });

  final int version;
  final String date; // ISO8601
  final String fileName;
  final int sizeBytes;

  factory BackupVersionEntry.fromJson(Map<String, dynamic> json) =>
      BackupVersionEntry(
        version: json['version'] as int,
        date: json['date'] as String,
        fileName: json['fileName'] as String,
        sizeBytes: json['size'] as int,
      );

  Map<String, dynamic> toJson() => {
        'version': version,
        'date': date,
        'fileName': fileName,
        'size': sizeBytes,
      };

  DateTime get dateTime => DateTime.parse(date);

  String get formattedDate {
    final dt = dateTime;
    return '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  String get formattedSize {
    if (sizeBytes < 1024 * 1024) {
      return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
