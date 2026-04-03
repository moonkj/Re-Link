/// SettingsRepository 전체 메서드 단위 테스트 (커버리지 100% 목표)
/// 커버: settings_repository.dart — 미커버 메서드 (auth, sync, streak freeze,
///        invite, auto sync, theme, haptic, reduce motion, spouse snap, pin 등)
import 'dart:convert';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:re_link/core/database/app_database.dart';
import 'package:re_link/core/database/tables/settings_table.dart';
import 'package:re_link/shared/repositories/settings_repository.dart';

void main() {
  late AppDatabase db;
  late SettingsRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = SettingsRepository(db);
  });

  tearDown(() => db.close());

  // ── setBool (간접 테스트) ──────────────────────────────────────────────────

  group('setAutoBackup (setBool 경로)', () {
    test('true → false → true 왕복', () async {
      expect(await repo.isAutoBackupEnabled(), isTrue);
      await repo.setAutoBackup(false);
      expect(await repo.isAutoBackupEnabled(), isFalse);
      await repo.setAutoBackup(true);
      expect(await repo.isAutoBackupEnabled(), isTrue);
    });
  });

  // ── 테마 모드 ─────────────────────────────────────────────────────────────

  group('테마 모드', () {
    test('getThemeMode 기본값 = system', () async {
      expect(await repo.getThemeMode(), 'system');
    });

    test('setThemeMode → getThemeMode', () async {
      await repo.setThemeMode('dark');
      expect(await repo.getThemeMode(), 'dark');
    });

    test('light 모드 설정', () async {
      await repo.setThemeMode('light');
      expect(await repo.getThemeMode(), 'light');
    });
  });

  // ── 햅틱 ──────────────────────────────────────────────────────────────────

  group('햅틱', () {
    test('isHapticEnabled 기본값 = true', () async {
      expect(await repo.isHapticEnabled(), isTrue);
    });

    test('setHapticEnabled(false)', () async {
      await repo.setHapticEnabled(false);
      expect(await repo.isHapticEnabled(), isFalse);
    });

    test('setHapticEnabled(true) 복원', () async {
      await repo.setHapticEnabled(false);
      await repo.setHapticEnabled(true);
      expect(await repo.isHapticEnabled(), isTrue);
    });
  });

  // ── 애니메이션 줄이기 ────────────────────────────────────────────────────

  group('애니메이션 줄이기', () {
    test('isReduceMotion 기본값 = false', () async {
      expect(await repo.isReduceMotion(), isFalse);
    });

    test('setReduceMotion(true)', () async {
      await repo.setReduceMotion(true);
      expect(await repo.isReduceMotion(), isTrue);
    });

    test('setReduceMotion(false) 복원', () async {
      await repo.setReduceMotion(true);
      await repo.setReduceMotion(false);
      expect(await repo.isReduceMotion(), isFalse);
    });
  });

  // ── 부부 자석 스냅 ───────────────────────────────────────────────────────

  group('부부 자석 스냅', () {
    test('isSpouseSnapEnabled 기본값 = true', () async {
      expect(await repo.isSpouseSnapEnabled(), isTrue);
    });

    test('setSpouseSnap(false)', () async {
      await repo.setSpouseSnap(false);
      expect(await repo.isSpouseSnapEnabled(), isFalse);
    });

    test('setSpouseSnap(true) 복원', () async {
      await repo.setSpouseSnap(false);
      await repo.setSpouseSnap(true);
      expect(await repo.isSpouseSnapEnabled(), isTrue);
    });
  });

  // ── 내 노드 ──────────────────────────────────────────────────────────────

  group('내 노드', () {
    test('getMyNodeId 초기 → null', () async {
      expect(await repo.getMyNodeId(), isNull);
    });

    test('setMyNodeId → getMyNodeId', () async {
      await repo.setMyNodeId('node-123');
      expect(await repo.getMyNodeId(), 'node-123');
    });

    test('clearMyNodeId → null', () async {
      await repo.setMyNodeId('node-123');
      await repo.clearMyNodeId();
      expect(await repo.getMyNodeId(), isNull);
    });

    test('빈 문자열 → null 처리', () async {
      await repo.set(SettingsKey.myNodeId, '');
      expect(await repo.getMyNodeId(), isNull);
    });
  });

  // ── 내 노드 PIN ──────────────────────────────────────────────────────────

  group('내 노드 PIN', () {
    test('getMyNodePin 초기 → null', () async {
      expect(await repo.getMyNodePin(), isNull);
    });

    test('setMyNodePin → getMyNodePin', () async {
      await repo.setMyNodePin('1234');
      expect(await repo.getMyNodePin(), '1234');
    });

    test('clearMyNodePin → null', () async {
      await repo.setMyNodePin('1234');
      await repo.clearMyNodePin();
      expect(await repo.getMyNodePin(), isNull);
    });

    test('빈 문자열 → null 처리', () async {
      await repo.set(SettingsKey.myNodePin, '');
      expect(await repo.getMyNodePin(), isNull);
    });
  });

  // ── 스트릭 프리즈 ─────────────────────────────────────────────────────────

  group('스트릭 프리즈', () {
    test('getStreakFreezeCount 초기 → 0', () async {
      expect(await repo.getStreakFreezeCount(), 0);
    });

    test('setStreakFreezeCount → getStreakFreezeCount', () async {
      await repo.setStreakFreezeCount(3);
      expect(await repo.getStreakFreezeCount(), 3);
    });

    test('getStreakFreezeUsedMonth 초기 → null', () async {
      expect(await repo.getStreakFreezeUsedMonth(), isNull);
    });

    test('setStreakFreezeUsedMonth → getStreakFreezeUsedMonth', () async {
      await repo.setStreakFreezeUsedMonth('2026-04');
      expect(await repo.getStreakFreezeUsedMonth(), '2026-04');
    });

    test('스트릭 카운트 파싱 불가 → 0 반환', () async {
      await repo.set(SettingsKey.streakFreezeCount, 'not_a_number');
      expect(await repo.getStreakFreezeCount(), 0);
    });
  });

  // ── 초대 코드 ─────────────────────────────────────────────────────────────

  group('초대 코드', () {
    test('getInviteCode 초기 → null', () async {
      expect(await repo.getInviteCode(), isNull);
    });

    test('setInviteCode → getInviteCode', () async {
      await repo.setInviteCode('ABC123');
      expect(await repo.getInviteCode(), 'ABC123');
    });
  });

  // ── 인증 / 클라우드 동기화 ──────────────────────────────────────────────

  group('인증 데이터', () {
    test('getAuthUserId 초기 → null', () async {
      expect(await repo.getAuthUserId(), isNull);
    });

    test('setAuthUserId → getAuthUserId', () async {
      await repo.setAuthUserId('user-uuid-1');
      expect(await repo.getAuthUserId(), 'user-uuid-1');
    });

    test('getFamilyGroupId 초기 → null', () async {
      expect(await repo.getFamilyGroupId(), isNull);
    });

    test('setFamilyGroupId → getFamilyGroupId', () async {
      await repo.setFamilyGroupId('family-uuid-1');
      expect(await repo.getFamilyGroupId(), 'family-uuid-1');
    });

    test('clearAuthData — 인증/가족/동기화 초기화', () async {
      await repo.setAuthUserId('u1');
      await repo.setFamilyGroupId('f1');
      await repo.setLastSyncAt(DateTime(2026, 4, 1));

      await repo.clearAuthData();

      expect(await repo.getAuthUserId(), '');
      expect(await repo.getFamilyGroupId(), '');
      final lastSync = await repo.getLastSyncAt();
      expect(lastSync, isNull); // 빈 문자열은 null로 처리됨
    });
  });

  // ── 동기화 시간 ───────────────────────────────────────────────────────────

  group('동기화 시간', () {
    test('getLastSyncAt 초기 → null', () async {
      expect(await repo.getLastSyncAt(), isNull);
    });

    test('setLastSyncAt → getLastSyncAt', () async {
      final dt = DateTime(2026, 4, 1, 12, 30);
      await repo.setLastSyncAt(dt);
      final restored = await repo.getLastSyncAt();
      expect(restored, isNotNull);
      expect(restored!.year, 2026);
      expect(restored.month, 4);
      expect(restored.day, 1);
      expect(restored.hour, 12);
      expect(restored.minute, 30);
    });

    test('빈 문자열 lastSyncAt → null', () async {
      await repo.set(SettingsKey.lastSyncAt, '');
      expect(await repo.getLastSyncAt(), isNull);
    });
  });

  // ── 자동 동기화 ───────────────────────────────────────────────────────────

  group('자동 동기화', () {
    test('isAutoSyncEnabled 기본값 = true', () async {
      expect(await repo.isAutoSyncEnabled(), isTrue);
    });

    test('setAutoSync(false)', () async {
      await repo.setAutoSync(false);
      expect(await repo.isAutoSyncEnabled(), isFalse);
    });

    test('setAutoSync(true) 복원', () async {
      await repo.setAutoSync(false);
      await repo.setAutoSync(true);
      expect(await repo.isAutoSyncEnabled(), isTrue);
    });
  });

  // ── 기기 ID ───────────────────────────────────────────────────────────────

  group('기기 ID', () {
    test('첫 호출 시 UUID 자동 생성', () async {
      final id = await repo.getDeviceId();
      expect(id, isNotNull);
      expect(id!.length, greaterThan(10));
    });

    test('두 번째 호출 — 동일 UUID 반환', () async {
      final first = await repo.getDeviceId();
      final second = await repo.getDeviceId();
      expect(first, second);
    });

    test('빈 문자열 deviceId → 새 UUID 생성', () async {
      await repo.set(SettingsKey.deviceId, '');
      final id = await repo.getDeviceId();
      expect(id, isNotNull);
      expect(id!.isNotEmpty, isTrue);
    });
  });

  // ── BackupVersionEntry 모델 ───────────────────────────────────────────────

  group('BackupVersionEntry', () {
    test('fromJson → toJson 왕복', () {
      const entry = BackupVersionEntry(
        version: 1,
        date: '2026-04-01T10:00:00.000',
        fileName: 'v1.rlink',
        sizeBytes: 1024,
      );
      final json = entry.toJson();
      final restored = BackupVersionEntry.fromJson(json);
      expect(restored.version, 1);
      expect(restored.date, '2026-04-01T10:00:00.000');
      expect(restored.fileName, 'v1.rlink');
      expect(restored.sizeBytes, 1024);
    });

    test('dateTime getter', () {
      const entry = BackupVersionEntry(
        version: 1,
        date: '2026-04-01T10:30:00.000',
        fileName: 'test.rlink',
        sizeBytes: 0,
      );
      final dt = entry.dateTime;
      expect(dt.year, 2026);
      expect(dt.month, 4);
      expect(dt.hour, 10);
      expect(dt.minute, 30);
    });

    test('formattedDate', () {
      const entry = BackupVersionEntry(
        version: 1,
        date: '2026-04-03T09:05:00.000',
        fileName: 'test.rlink',
        sizeBytes: 0,
      );
      expect(entry.formattedDate, '2026.04.03 09:05');
    });

    test('formattedSize — KB', () {
      const entry = BackupVersionEntry(
        version: 1,
        date: '2026-04-01T00:00:00.000',
        fileName: 'test.rlink',
        sizeBytes: 512 * 1024, // 512 KB
      );
      expect(entry.formattedSize, '512.0 KB');
    });

    test('formattedSize — MB', () {
      const entry = BackupVersionEntry(
        version: 1,
        date: '2026-04-01T00:00:00.000',
        fileName: 'test.rlink',
        sizeBytes: 5 * 1024 * 1024, // 5 MB
      );
      expect(entry.formattedSize, '5.0 MB');
    });

    test('formattedSize — 경계값 (1 MB 미만)', () {
      const entry = BackupVersionEntry(
        version: 1,
        date: '2026-04-01T00:00:00.000',
        fileName: 'test.rlink',
        sizeBytes: 1024 * 1024 - 1, // just under 1 MB
      );
      expect(entry.formattedSize, endsWith('KB'));
    });

    test('formattedSize — 경계값 (1 MB)', () {
      const entry = BackupVersionEntry(
        version: 1,
        date: '2026-04-01T00:00:00.000',
        fileName: 'test.rlink',
        sizeBytes: 1024 * 1024, // exactly 1 MB
      );
      expect(entry.formattedSize, '1.0 MB');
    });
  });

  // ── 백업 버전 히스토리 ────────────────────────────────────────────────────

  group('백업 버전 히스토리', () {
    test('잘못된 JSON → 빈 리스트', () async {
      await repo.set(SettingsKey.backupVersionHistory, 'invalid_json{');
      final history = await repo.getBackupVersionHistory();
      expect(history, isEmpty);
    });

    test('최대 5개 유지', () async {
      for (int i = 1; i <= 7; i++) {
        await repo.addBackupVersion(BackupVersionEntry(
          version: i,
          date: '2026-04-0${i % 9 + 1}T10:00:00.000',
          fileName: 'v$i.rlink',
          sizeBytes: i * 100,
        ));
      }
      final history = await repo.getBackupVersionHistory();
      expect(history.length, 5);
    });

    test('최신순 정렬', () async {
      await repo.addBackupVersion(const BackupVersionEntry(
        version: 1,
        date: '2026-04-01T10:00:00.000',
        fileName: 'v1.rlink',
        sizeBytes: 100,
      ));
      await repo.addBackupVersion(const BackupVersionEntry(
        version: 3,
        date: '2026-04-03T10:00:00.000',
        fileName: 'v3.rlink',
        sizeBytes: 300,
      ));
      await repo.addBackupVersion(const BackupVersionEntry(
        version: 2,
        date: '2026-04-02T10:00:00.000',
        fileName: 'v2.rlink',
        sizeBytes: 200,
      ));
      final history = await repo.getBackupVersionHistory();
      expect(history[0].version, greaterThanOrEqualTo(history[1].version));
    });
  });

  // ── getNextBackupVersion ──────────────────────────────────────────────────

  group('getNextBackupVersion', () {
    test('파싱 불가 값 → 1 반환', () async {
      await repo.set(SettingsKey.backupVersionCounter, 'not_a_number');
      expect(await repo.getNextBackupVersion(), 1);
    });
  });

  // ── getStreakCount 엣지 케이스 ─────────────────────────────────────────────

  group('getStreakCount 엣지 케이스', () {
    test('파싱 불가 값 → 0', () async {
      await repo.set(SettingsKey.streakCount, 'abc');
      expect(await repo.getStreakCount(), 0);
    });
  });

  // ── getStreakLastDate 엣지 케이스 ──────────────────────────────────────────

  group('getStreakLastDate 엣지 케이스', () {
    test('파싱 불가 값 → null', () async {
      await repo.set(SettingsKey.streakLastDate, 'not-a-date');
      expect(await repo.getStreakLastDate(), isNull);
    });
  });

  // ── getLastBackupAt 엣지 케이스 ───────────────────────────────────────────

  group('getLastBackupAt 엣지 케이스', () {
    test('파싱 불가 값 → null', () async {
      await repo.set(SettingsKey.lastBackupAt, 'bad-date');
      expect(await repo.getLastBackupAt(), isNull);
    });
  });
}
