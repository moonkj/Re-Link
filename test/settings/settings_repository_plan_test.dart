/// SettingsRepository 플랜 마이그레이션 로직 단위 테스트
/// 커버: settings_repository.dart — getUserPlan() 마이그레이션 (basic→plus, premium→familyPlus)
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:re_link/core/database/app_database.dart';
import 'package:re_link/core/database/tables/settings_table.dart';
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

  // ── 마이그레이션: 기존 3-tier → 새 4-tier ────────────────────────────────

  group('getUserPlan 마이그레이션', () {
    test('basic → plus 마이그레이션', () async {
      await repo.set(SettingsKey.userPlan, 'basic');
      final plan = await repo.getUserPlan();
      expect(plan, UserPlan.plus);

      // DB에 마이그레이션된 값이 저장됨
      final raw = await repo.get(SettingsKey.userPlan);
      expect(raw, 'plus');
    });

    test('premium → familyPlus 마이그레이션', () async {
      await repo.set(SettingsKey.userPlan, 'premium');
      final plan = await repo.getUserPlan();
      expect(plan, UserPlan.familyPlus);

      // DB에 마이그레이션된 값이 저장됨
      final raw = await repo.get(SettingsKey.userPlan);
      expect(raw, 'familyPlus');
    });

    test('unknown 값 → free 폴백', () async {
      await repo.set(SettingsKey.userPlan, 'nonexistent_plan');
      final plan = await repo.getUserPlan();
      expect(plan, UserPlan.free);
    });

    test('빈 문자열 → free 폴백', () async {
      await repo.set(SettingsKey.userPlan, '');
      final plan = await repo.getUserPlan();
      expect(plan, UserPlan.free);
    });

    test('null (미설정) → free 폴백', () async {
      // 아무것도 설정하지 않음
      final plan = await repo.getUserPlan();
      expect(plan, UserPlan.free);
    });
  });

  // ── 정상 값 패스스루 ──────────────────────────────────────────────────────

  group('getUserPlan 정상 값', () {
    test('free → free 그대로', () async {
      await repo.set(SettingsKey.userPlan, 'free');
      expect(await repo.getUserPlan(), UserPlan.free);
    });

    test('plus → plus 그대로', () async {
      await repo.set(SettingsKey.userPlan, 'plus');
      expect(await repo.getUserPlan(), UserPlan.plus);
    });

    test('family → family 그대로', () async {
      await repo.set(SettingsKey.userPlan, 'family');
      expect(await repo.getUserPlan(), UserPlan.family);
    });

    test('familyPlus → familyPlus 그대로', () async {
      await repo.set(SettingsKey.userPlan, 'familyPlus');
      expect(await repo.getUserPlan(), UserPlan.familyPlus);
    });
  });

  // ── setUserPlan → getUserPlan 왕복 ────────────────────────────────────────

  group('setUserPlan / getUserPlan 왕복', () {
    for (final plan in UserPlan.values) {
      test('${plan.name} 저장 후 조회', () async {
        await repo.setUserPlan(plan);
        expect(await repo.getUserPlan(), plan);
      });
    }
  });

  // ── 마이그레이션 후 재조회 시 안정성 ──────────────────────────────────────

  group('마이그레이션 후 재조회', () {
    test('basic → plus 마이그레이션 후 다시 조회해도 plus', () async {
      await repo.set(SettingsKey.userPlan, 'basic');
      await repo.getUserPlan(); // 마이그레이션 발생
      final plan = await repo.getUserPlan(); // 두 번째 조회
      expect(plan, UserPlan.plus);
    });

    test('premium → familyPlus 마이그레이션 후 다시 조회해도 familyPlus', () async {
      await repo.set(SettingsKey.userPlan, 'premium');
      await repo.getUserPlan(); // 마이그레이션 발생
      final plan = await repo.getUserPlan(); // 두 번째 조회
      expect(plan, UserPlan.familyPlus);
    });
  });

  // ── 백업 버전 관리 ────────────────────────────────────────────────────────

  group('getNextBackupVersion', () {
    test('초기 호출 → 1 반환', () async {
      expect(await repo.getNextBackupVersion(), 1);
    });

    test('연속 호출 → 증가', () async {
      expect(await repo.getNextBackupVersion(), 1);
      expect(await repo.getNextBackupVersion(), 2);
      expect(await repo.getNextBackupVersion(), 3);
    });
  });

  group('BackupVersionEntry 히스토리', () {
    test('초기 히스토리 → 빈 리스트', () async {
      final history = await repo.getBackupVersionHistory();
      expect(history, isEmpty);
    });

    test('항목 추가 후 조회', () async {
      await repo.addBackupVersion(const BackupVersionEntry(
        version: 1,
        date: '2026-04-01T10:00:00.000',
        fileName: 'v1.rlink',
        sizeBytes: 1024,
      ));

      final history = await repo.getBackupVersionHistory();
      expect(history.length, 1);
      expect(history[0].version, 1);
      expect(history[0].fileName, 'v1.rlink');
    });

    test('최대 5개 유지', () async {
      for (int i = 1; i <= 7; i++) {
        await repo.addBackupVersion(BackupVersionEntry(
          version: i,
          date: '2026-04-0${i < 10 ? i : 1}T10:00:00.000',
          fileName: 'v$i.rlink',
          sizeBytes: i * 1024,
        ));
      }

      final history = await repo.getBackupVersionHistory();
      expect(history.length, 5);
      // 최신순 정렬
      expect(history[0].version, greaterThanOrEqualTo(history[1].version));
    });
  });

  // ── 인증 데이터 초기화 ────────────────────────────────────────────────────

  group('clearAuthData', () {
    test('인증 데이터 설정 후 초기화', () async {
      await repo.set(SettingsKey.authUserId, 'user-123');
      await repo.set(SettingsKey.familyGroupId, 'family-456');
      await repo.set(SettingsKey.lastSyncAt, '2026-04-01T00:00:00.000');

      await repo.clearAuthData();

      // clearAuthData는 빈 문자열로 설정함 (삭제가 아닌 덮어쓰기)
      // getAuthUserId/getFamilyGroupId는 raw get()을 사용하므로 빈 문자열 반환
      expect(await repo.getAuthUserId(), '');
      expect(await repo.getFamilyGroupId(), '');
    });
  });

  // ── 스트릭 ────────────────────────────────────────────────────────────────

  group('스트릭', () {
    test('초기 streakCount → 0', () async {
      expect(await repo.getStreakCount(), 0);
    });

    test('setStreakCount → getStreakCount', () async {
      await repo.setStreakCount(7);
      expect(await repo.getStreakCount(), 7);
    });

    test('초기 streakLastDate → null', () async {
      expect(await repo.getStreakLastDate(), isNull);
    });

    test('setStreakLastDate → getStreakLastDate', () async {
      final date = DateTime(2026, 4, 3);
      await repo.setStreakLastDate(date);
      final restored = await repo.getStreakLastDate();
      expect(restored, isNotNull);
      expect(restored!.year, 2026);
      expect(restored.month, 4);
      expect(restored.day, 3);
    });
  });

  // ── 기기 ID ───────────────────────────────────────────────────────────────

  group('deviceId', () {
    test('초기 호출 → UUID 자동 생성', () async {
      final id = await repo.getDeviceId();
      expect(id, isNotNull);
      expect(id!.length, greaterThan(0));
    });

    test('두 번째 호출 → 동일 값 반환', () async {
      final first = await repo.getDeviceId();
      final second = await repo.getDeviceId();
      expect(first, second);
    });
  });
}
