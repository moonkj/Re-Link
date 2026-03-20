import 'package:drift/drift.dart';

/// 앱 설정 (key-value 형태)
class SettingsTable extends Table {
  @override
  String get tableName => 'settings';

  TextColumn get key => text()();
  TextColumn get value => text()();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {key};
}

/// 설정 키 상수
abstract final class SettingsKey {
  static const String userPlan = 'user_plan';           // free / basic / premium
  static const String autoBackup = 'auto_backup';       // true / false
  static const String backupFrequency = 'backup_freq';  // daily / weekly
  static const String lastBackupAt = 'last_backup_at';  // ISO8601
  static const String lastBackupSize = 'last_backup_size'; // bytes
  static const String cloudProvider = 'cloud_provider'; // icloud / google / none
  static const String encryptionKeyHint = 'enc_key_hint'; // 암호화 키 힌트
  static const String onboardingDone = 'onboarding_done'; // true / false
  static const String canvasOffsetX = 'canvas_offset_x';
  static const String canvasOffsetY = 'canvas_offset_y';
  static const String canvasScale = 'canvas_scale';

  // ── UX 모드 ────────────────────────────────────────────────────────────────
  static const String elderlyMode = 'elderly_mode';       // true / false
  static const String privacyEnabled = 'privacy_enabled'; // true / false
  static const String darkMode = 'dark_mode';             // true / false
  static const String themeMode = 'theme_mode';           // system / light / dark
  static const String hapticEnabled = 'haptic_enabled';   // true / false
  static const String reduceMotion = 'reduce_motion';     // true / false

  // ── 캔버스 ────────────────────────────────────────────────────────────────
  static const String spouseSnap = 'spouse_snap';         // true / false
}
