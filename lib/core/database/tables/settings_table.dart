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
  static const String userPlan = 'user_plan';           // free / plus / family / familyPlus
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

  // ── 내 노드 ──────────────────────────────────────────────────────────────
  static const String myNodeId = 'my_node_id';             // 나로 설정한 노드 ID

  // ── 스트릭 ────────────────────────────────────────────────────────────────
  static const String streakCount = 'streak_count';         // int as string
  static const String streakLastDate = 'streak_last_date';  // ISO8601 date
  static const String streakFreezeCount = 'streak_freeze_count'; // int as string
  static const String streakFreezeUsedMonth = 'streak_freeze_used_month'; // YYYY-MM

  // ── 배지 ─────────────────────────────────────────────────────────────────
  static const String earnedBadges = 'earned_badges'; // comma-separated badge IDs

  // ── 데일리 프롬프트 ──────────────────────────────────────────────────────
  static const String dailyPromptDismissedDate = 'daily_prompt_dismissed_date'; // YYYY-MM-DD

  // ── 가족 나무 성장 ──────────────────────────────────────────────────────
  static const String treeGrowthStage = 'tree_growth_stage'; // sprout / sapling / smallTree / bigTree / grandTree

  // ── 명절 배너 ──────────────────────────────────────────────────────────
  static const String holidayBannerDismissed = 'holiday_banner_dismissed'; // holiday_id:YYYY-MM-DD

  // ── 변경 로그 ──────────────────────────────────────────────────────────
  static const String lastSeenVersion = 'last_seen_version'; // 마지막으로 본 변경 로그 버전

  // ── 웰컴 캡슐 ──────────────────────────────────────────────────────────
  static const String welcomeCapsulePlayed = 'welcome_capsule_played'; // true / false
  static const String welcomeMessage = 'welcome_message';             // 환영 텍스트 (max 200)
  static const String welcomeAudioPath = 'welcome_audio_path';        // 환영 음성 파일 경로

  // ── 관리자 모드 ─────────────────────────────────────────────────────────
  static const String adminModeEnabled = 'admin_mode_enabled';         // true / false
  static const String adminPlanOverride = 'admin_plan_override';       // free / plus / family / familyPlus (null=실제 플랜)
  static const String adminAllBadges = 'admin_all_badges';             // true / false
  static const String adminDummyGenerated = 'admin_dummy_generated';   // true / false

  // ── 인증 / 클라우드 동기화 ────────────────────────────────────────────
  static const String authUserId     = 'auth_user_id';       // 인증된 사용자 UUID
  static const String authEmail      = 'auth_email';         // 인증 이메일
  static const String authProvider   = 'auth_provider';      // 'apple' | 'google'
  static const String familyGroupId  = 'family_group_id';    // 가족 그룹 UUID
  static const String deviceId       = 'device_id';          // 기기 고유 UUID
  static const String lastSyncAt     = 'last_sync_at';       // ISO8601
  static const String cloudPlan      = 'cloud_plan';         // 'family' | 'familyPlus'
}
