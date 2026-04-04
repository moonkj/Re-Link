/// 플랜 제한 단위 테스트
/// — UserPlan enum 검증 + DB 저장 / 노드 카운트 제한
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:re_link/core/database/app_database.dart';
import 'package:re_link/shared/models/user_plan.dart';
import 'package:re_link/shared/repositories/node_repository.dart';
import 'package:re_link/shared/repositories/settings_repository.dart';
import '../helpers/test_helpers.dart';

void main() {
  late AppDatabase db;
  late NodeRepository nodeRepo;
  late SettingsRepository settingsRepo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    nodeRepo = createTestNodeRepository(db);
    settingsRepo = SettingsRepository(db);
  });

  tearDown(() => db.close());

  group('UserPlan 제한값', () {
    test('Free — maxNodes 15, 사진 50, 음성 5분, 광고 있음', () {
      expect(UserPlan.free.maxNodes, 10);
      expect(UserPlan.free.maxPhotos, 50);
      expect(UserPlan.free.hasVoice, isTrue);
      expect(UserPlan.free.maxVoiceMinutes, 5);
      expect(UserPlan.free.hasAds, isTrue);
      expect(UserPlan.free.isUnlimited, isFalse);
      expect(UserPlan.free.hasVideo, isFalse);
      expect(UserPlan.free.hasCloud, isFalse);
    });

    test('Plus — 무제한, 음성 무제한, 광고 없음, 비디오 30초', () {
      expect(UserPlan.plus.maxNodes, greaterThan(10000));
      expect(UserPlan.plus.maxPhotos, greaterThan(10000));
      expect(UserPlan.plus.hasVoice, isTrue);
      expect(UserPlan.plus.maxVoiceMinutes, greaterThan(10000));
      expect(UserPlan.plus.hasAds, isFalse);
      expect(UserPlan.plus.isUnlimited, isTrue);
      expect(UserPlan.plus.hasVideo, isTrue);
      expect(UserPlan.plus.maxVideoSeconds, 30);
      expect(UserPlan.plus.hasCloud, isFalse);
    });

    test('Family — 무제한, 클라우드 20GB, 가족 6명, 비디오 3분', () {
      expect(UserPlan.family.isUnlimited, isTrue);
      expect(UserPlan.family.hasVoice, isTrue);
      expect(UserPlan.family.hasAds, isFalse);
      expect(UserPlan.family.hasVideo, isTrue);
      expect(UserPlan.family.maxVideoSeconds, 180);
      expect(UserPlan.family.hasCloud, isTrue);
      expect(UserPlan.family.cloudStorageGB, 20);
      expect(UserPlan.family.maxFamilyMembers, 6);
    });

    test('FamilyPlus — 무제한, 클라우드 100GB, 가족 무제한, 비디오 10분', () {
      expect(UserPlan.familyPlus.isUnlimited, isTrue);
      expect(UserPlan.familyPlus.hasVoice, isTrue);
      expect(UserPlan.familyPlus.hasAds, isFalse);
      expect(UserPlan.familyPlus.hasVideo, isTrue);
      expect(UserPlan.familyPlus.maxVideoSeconds, 600);
      expect(UserPlan.familyPlus.hasCloud, isTrue);
      expect(UserPlan.familyPlus.cloudStorageGB, 100);
      expect(UserPlan.familyPlus.maxFamilyMembers, greaterThan(100));
    });
  });

  group('플랜 DB 저장/읽기', () {
    test('기본 플랜 = Free', () async {
      final plan = await settingsRepo.getUserPlan();
      expect(plan, UserPlan.free);
    });

    test('Plus 업그레이드 후 DB 반영', () async {
      await settingsRepo.setUserPlan(UserPlan.plus);
      expect(await settingsRepo.getUserPlan(), UserPlan.plus);
    });

    test('Family 업그레이드 후 DB 반영', () async {
      await settingsRepo.setUserPlan(UserPlan.family);
      expect(await settingsRepo.getUserPlan(), UserPlan.family);
    });

    test('FamilyPlus 업그레이드 후 DB 반영', () async {
      await settingsRepo.setUserPlan(UserPlan.familyPlus);
      expect(await settingsRepo.getUserPlan(), UserPlan.familyPlus);
    });
  });

  group('노드 개수 제한 (PlanGuard)', () {
    test('노드 10개 생성 → Free 한도 도달', () async {
      for (var i = 0; i < 15; i++) {
        await nodeRepo.create(
          name: '인물$i',
          positionX: (i * 110).toDouble(),
          positionY: 0,
        );
      }
      final count = await nodeRepo.count();
      expect(count, 15);
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
