/// SettingsRepository 확장 단위 테스트
/// 커버: settings_repository.dart — getBool, getDouble, getUserPlan, 백업 설정, 온보딩, UX 모드
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:re_link/core/database/app_database.dart';
import 'package:re_link/shared/models/user_plan.dart';
import 'package:re_link/shared/repositories/settings_repository.dart';

void main() {
  late AppDatabase db;
  late SettingsRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = SettingsRepository(db);
  });

  tearDown(() => db.close());

  // ── get / set ──────────────────────────────────────────────────────────────

  group('get / set 기본', () {
    test('존재하지 않는 키 → null', () async {
      expect(await repo.get('nonexistent'), isNull);
    });

    test('set 후 get → 저장된 값 반환', () async {
      await repo.set('test_key', 'hello');
      expect(await repo.get('test_key'), 'hello');
    });

    test('set 덮어쓰기', () async {
      await repo.set('k', 'first');
      await repo.set('k', 'second');
      expect(await repo.get('k'), 'second');
    });
  });

  // ── getBool ───────────────────────────────────────────────────────────────

  group('getBool', () {
    test('없을 때 defaultValue=false 반환', () async {
      expect(await repo.getBool('b_key'), isFalse);
    });

    test('없을 때 defaultValue=true 반환', () async {
      expect(await repo.getBool('b_key', defaultValue: true), isTrue);
    });

    test('"true" 저장 → true 반환', () async {
      await repo.set('b_key', 'true');
      expect(await repo.getBool('b_key'), isTrue);
    });

    test('"false" 저장 → false 반환', () async {
      await repo.set('b_key', 'false');
      expect(await repo.getBool('b_key', defaultValue: true), isFalse);
    });
  });

  // ── getDouble ─────────────────────────────────────────────────────────────

  group('getDouble', () {
    test('없을 때 defaultValue=0.0 반환', () async {
      expect(await repo.getDouble('d_key'), 0.0);
    });

    test('없을 때 커스텀 defaultValue 반환', () async {
      expect(await repo.getDouble('d_key', defaultValue: 3.14), 3.14);
    });

    test('"1.5" 저장 → 1.5 반환', () async {
      await repo.set('d_key', '1.5');
      expect(await repo.getDouble('d_key'), 1.5);
    });

    test('파싱 불가 값 → defaultValue 반환', () async {
      await repo.set('d_key', 'not_a_number');
      expect(await repo.getDouble('d_key', defaultValue: 9.9), 9.9);
    });
  });

  // ── UserPlan ──────────────────────────────────────────────────────────────

  group('getUserPlan / setUserPlan', () {
    test('초기 → free 반환', () async {
      expect(await repo.getUserPlan(), UserPlan.free);
    });

    test('plus 설정 후 getUserPlan → plus', () async {
      await repo.setUserPlan(UserPlan.plus);
      expect(await repo.getUserPlan(), UserPlan.plus);
    });

    test('family 설정 후 getUserPlan → family', () async {
      await repo.setUserPlan(UserPlan.family);
      expect(await repo.getUserPlan(), UserPlan.family);
    });

    test('familyPlus 설정 후 getUserPlan → familyPlus', () async {
      await repo.setUserPlan(UserPlan.familyPlus);
      expect(await repo.getUserPlan(), UserPlan.familyPlus);
    });

    test('unknown 값 → free (fallback)', () async {
      await repo.set('user_plan', 'unknown_plan');
      expect(await repo.getUserPlan(), UserPlan.free);
    });
  });

  // ── 백업 설정 ──────────────────────────────────────────────────────────────

  group('백업 설정', () {
    test('isAutoBackupEnabled 기본값 = true', () async {
      expect(await repo.isAutoBackupEnabled(), isTrue);
    });

    test('setAutoBackup(false) → isAutoBackupEnabled=false', () async {
      await repo.setAutoBackup(false);
      expect(await repo.isAutoBackupEnabled(), isFalse);
    });

    test('setAutoBackup(true) → isAutoBackupEnabled=true', () async {
      await repo.setAutoBackup(false);
      await repo.setAutoBackup(true);
      expect(await repo.isAutoBackupEnabled(), isTrue);
    });

    test('getBackupFrequency 기본값 = "daily"', () async {
      expect(await repo.getBackupFrequency(), 'daily');
    });

    test('setBackupFrequency → getBackupFrequency 반환', () async {
      await repo.setBackupFrequency('weekly');
      expect(await repo.getBackupFrequency(), 'weekly');
    });

    test('getLastBackupAt 초기 → null', () async {
      expect(await repo.getLastBackupAt(), isNull);
    });

    test('setLastBackupAt → getLastBackupAt 복원', () async {
      final dt = DateTime(2024, 6, 15, 10, 30);
      await repo.setLastBackupAt(dt);
      final restored = await repo.getLastBackupAt();
      expect(restored, isNotNull);
      expect(restored!.year, dt.year);
      expect(restored.month, dt.month);
      expect(restored.day, dt.day);
    });

    test('getCloudProvider 초기화됨 (비어있지 않음)', () async {
      final provider = await repo.getCloudProvider();
      expect(provider, isNotEmpty);
    });
  });

  // ── 온보딩 ────────────────────────────────────────────────────────────────

  group('온보딩', () {
    test('isOnboardingDone 초기 = false', () async {
      expect(await repo.isOnboardingDone(), isFalse);
    });

    test('setOnboardingDone → isOnboardingDone=true', () async {
      await repo.setOnboardingDone();
      expect(await repo.isOnboardingDone(), isTrue);
    });
  });

  // ── UX 모드 ───────────────────────────────────────────────────────────────

  group('어르신 모드', () {
    test('isElderlyMode 초기 = false', () async {
      expect(await repo.isElderlyMode(), isFalse);
    });

    test('setElderlyMode(true) → isElderlyMode=true', () async {
      await repo.setElderlyMode(true);
      expect(await repo.isElderlyMode(), isTrue);
    });

    test('setElderlyMode(false) → isElderlyMode=false', () async {
      await repo.setElderlyMode(true);
      await repo.setElderlyMode(false);
      expect(await repo.isElderlyMode(), isFalse);
    });
  });

  group('Privacy Layer', () {
    test('isPrivacyEnabled 초기 = false', () async {
      expect(await repo.isPrivacyEnabled(), isFalse);
    });

    test('setPrivacyEnabled(true) → isPrivacyEnabled=true', () async {
      await repo.setPrivacyEnabled(true);
      expect(await repo.isPrivacyEnabled(), isTrue);
    });

    test('setPrivacyEnabled(false) → isPrivacyEnabled=false', () async {
      await repo.setPrivacyEnabled(true);
      await repo.setPrivacyEnabled(false);
      expect(await repo.isPrivacyEnabled(), isFalse);
    });
  });
}
