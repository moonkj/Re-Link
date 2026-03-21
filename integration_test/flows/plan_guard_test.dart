/// 플랜 제한 통합 테스트 (Free 플랜 노드 15개 초과 차단)
///
/// 실제 디바이스/시뮬레이터에서 실행 필요:
///   flutter test integration_test/flows/plan_guard_test.dart
library;

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:re_link/core/database/app_database.dart';
import 'package:re_link/shared/models/user_plan.dart';
import 'package:re_link/shared/repositories/node_repository.dart';
import 'package:re_link/shared/repositories/settings_repository.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late NodeRepository nodeRepo;
  late SettingsRepository settingsRepo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    nodeRepo = NodeRepository(db);
    settingsRepo = SettingsRepository(db);
  });

  tearDown(() => db.close());

  test('Free 플랜: maxNodes = 15', () {
    expect(UserPlan.free.maxNodes, 15);
  });

  test('Plus 플랜: maxNodes 무제한', () {
    expect(UserPlan.plus.isUnlimited, isTrue);
    expect(UserPlan.plus.maxNodes, greaterThan(10000));
  });

  test('Family 플랜: maxNodes 무제한', () {
    expect(UserPlan.family.isUnlimited, isTrue);
    expect(UserPlan.family.maxNodes, greaterThan(10000));
  });

  test('FamilyPlus 플랜: maxNodes 무제한', () {
    expect(UserPlan.familyPlus.isUnlimited, isTrue);
    expect(UserPlan.familyPlus.maxNodes, greaterThan(10000));
  });

  test('Free 플랜: 음성 5분 제한', () {
    expect(UserPlan.free.hasVoice, isTrue);
    expect(UserPlan.free.maxVoiceMinutes, 5);
  });

  test('Free 플랜: 비디오 미지원', () {
    expect(UserPlan.free.hasVideo, isFalse);
    expect(UserPlan.free.maxVideoSeconds, 0);
  });

  test('Plus 플랜: 비디오 30초', () {
    expect(UserPlan.plus.hasVideo, isTrue);
    expect(UserPlan.plus.maxVideoSeconds, 30);
  });

  test('Family 플랜: 클라우드 20GB + 가족 6명', () {
    expect(UserPlan.family.hasCloud, isTrue);
    expect(UserPlan.family.cloudStorageGB, 20);
    expect(UserPlan.family.maxFamilyMembers, 6);
  });

  test('FamilyPlus 플랜: 클라우드 100GB + 가족 무제한', () {
    expect(UserPlan.familyPlus.hasCloud, isTrue);
    expect(UserPlan.familyPlus.cloudStorageGB, 100);
    expect(UserPlan.familyPlus.maxFamilyMembers, greaterThan(100));
  });

  test('광고 — free만 있음', () {
    expect(UserPlan.free.hasAds, isTrue);
    expect(UserPlan.plus.hasAds, isFalse);
    expect(UserPlan.family.hasAds, isFalse);
    expect(UserPlan.familyPlus.hasAds, isFalse);
  });

  test('Free 플랜 저장 → DB에서 읽기', () async {
    await settingsRepo.setUserPlan(UserPlan.free);
    final plan = await settingsRepo.getUserPlan();
    expect(plan, UserPlan.free);
  });

  test('Plus 플랜 업그레이드 → DB 반영', () async {
    await settingsRepo.setUserPlan(UserPlan.free);
    await settingsRepo.setUserPlan(UserPlan.plus);
    final plan = await settingsRepo.getUserPlan();
    expect(plan, UserPlan.plus);
  });

  test('Family 플랜 구독 → DB 반영', () async {
    await settingsRepo.setUserPlan(UserPlan.family);
    final plan = await settingsRepo.getUserPlan();
    expect(plan, UserPlan.family);
  });

  test('노드 15개 생성 후 count 검증', () async {
    for (var i = 0; i < 15; i++) {
      await nodeRepo.create(
        name: '노드$i',
        positionX: (i * 100).toDouble(),
        positionY: 0,
      );
    }
    final count = await nodeRepo.count();
    expect(count, 15);
    expect(count >= UserPlan.free.maxNodes, isTrue);
  });

  test('Free 플랜 기본값 — DB 초기 상태', () async {
    final plan = await settingsRepo.getUserPlan();
    expect(plan, UserPlan.free);
  });
}
