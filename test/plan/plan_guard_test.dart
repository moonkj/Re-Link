/// 플랜 제한 단위 테스트
/// — UserPlan enum 검증 + DB 저장 / 노드 카운트 제한
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:re_link/core/database/app_database.dart';
import 'package:re_link/shared/models/user_plan.dart';
import 'package:re_link/shared/repositories/node_repository.dart';
import 'package:re_link/shared/repositories/settings_repository.dart';

void main() {
  late AppDatabase db;
  late NodeRepository nodeRepo;
  late SettingsRepository settingsRepo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    nodeRepo = NodeRepository(db);
    settingsRepo = SettingsRepository(db);
  });

  tearDown(() => db.close());

  group('UserPlan 제한값', () {
    test('Free — maxNodes 30, 음성 미지원, 광고 있음', () {
      expect(UserPlan.free.maxNodes, 30);
      expect(UserPlan.free.maxPhotos, 50);
      expect(UserPlan.free.hasVoice, isFalse);
      expect(UserPlan.free.maxVoiceMinutes, 0);
      expect(UserPlan.free.hasAds, isTrue);
      expect(UserPlan.free.isUnlimited, isFalse);
    });

    test('Basic — maxNodes 200, 음성 30분, 광고 있음', () {
      expect(UserPlan.basic.maxNodes, 200);
      expect(UserPlan.basic.maxPhotos, 500);
      expect(UserPlan.basic.hasVoice, isTrue);
      expect(UserPlan.basic.maxVoiceMinutes, 30);
      expect(UserPlan.basic.hasAds, isTrue);
      expect(UserPlan.basic.isUnlimited, isFalse);
    });

    test('Premium — 무제한, 음성 300분, 광고 없음', () {
      expect(UserPlan.premium.isUnlimited, isTrue);
      expect(UserPlan.premium.hasVoice, isTrue);
      expect(UserPlan.premium.maxVoiceMinutes, 300);
      expect(UserPlan.premium.hasAds, isFalse);
    });
  });

  group('플랜 DB 저장/읽기', () {
    test('기본 플랜 = Free', () async {
      final plan = await settingsRepo.getUserPlan();
      expect(plan, UserPlan.free);
    });

    test('Basic 업그레이드 후 DB 반영', () async {
      await settingsRepo.setUserPlan(UserPlan.basic);
      expect(await settingsRepo.getUserPlan(), UserPlan.basic);
    });

    test('Premium 업그레이드 후 DB 반영', () async {
      await settingsRepo.setUserPlan(UserPlan.premium);
      expect(await settingsRepo.getUserPlan(), UserPlan.premium);
    });
  });

  group('노드 개수 제한 (PlanGuard)', () {
    test('노드 30개 생성 → Free 한도 도달', () async {
      for (var i = 0; i < 30; i++) {
        await nodeRepo.create(
          name: '인물$i',
          positionX: (i * 110).toDouble(),
          positionY: 0,
        );
      }
      final count = await nodeRepo.count();
      expect(count, 30);
      expect(count >= UserPlan.free.maxNodes, isTrue);
    });

    test('노드 0개 — Free 제한 미도달', () async {
      final count = await nodeRepo.count();
      expect(count < UserPlan.free.maxNodes, isTrue);
    });

    test('Ghost 노드도 카운트에 포함', () async {
      await nodeRepo.create(
        name: '미확인',
        positionX: 100,
        positionY: 100,
        isGhost: true,
      );
      final count = await nodeRepo.count();
      expect(count, 1);
    });
  });
}
