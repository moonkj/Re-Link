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
}
