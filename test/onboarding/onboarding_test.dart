import 'package:flutter_test/flutter_test.dart';
import 'package:re_link/shared/repositories/settings_repository.dart';
import 'package:re_link/core/database/app_database.dart';
import 'package:drift/native.dart';

void main() {
  late AppDatabase db;
  late SettingsRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = SettingsRepository(db);
  });

  tearDown(() async => db.close());

  group('Onboarding 플로우', () {
    test('초기 상태: onboarding_done = false', () async {
      final done = await repo.isOnboardingDone();
      expect(done, isFalse);
    });

    test('setOnboardingDone() 후: onboarding_done = true', () async {
      await repo.setOnboardingDone();
      final done = await repo.isOnboardingDone();
      expect(done, isTrue);
    });

    test('두 번 호출해도 true 유지', () async {
      await repo.setOnboardingDone();
      await repo.setOnboardingDone();
      final done = await repo.isOnboardingDone();
      expect(done, isTrue);
    });
  });

  group('어르신 모드', () {
    test('기본값 = false', () async {
      final enabled = await repo.isElderlyMode();
      expect(enabled, isFalse);
    });

    test('setElderlyMode(true) 저장 확인', () async {
      await repo.setElderlyMode(true);
      expect(await repo.isElderlyMode(), isTrue);
    });

    test('setElderlyMode(false) 토글 확인', () async {
      await repo.setElderlyMode(true);
      await repo.setElderlyMode(false);
      expect(await repo.isElderlyMode(), isFalse);
    });
  });

  group('Privacy Layer 설정', () {
    test('기본값 = false', () async {
      final enabled = await repo.isPrivacyEnabled();
      expect(enabled, isFalse);
    });

    test('setPrivacyEnabled(true) 저장 확인', () async {
      await repo.setPrivacyEnabled(true);
      expect(await repo.isPrivacyEnabled(), isTrue);
    });
  });
}
