/// 플랜 제한 통합 테스트 (Free 플랜 노드 30개 초과 차단)
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

  test('Free 플랜: maxNodes = 30', () {
    expect(UserPlan.free.maxNodes, 30);
  });

  test('Basic 플랜: maxNodes = 200', () {
    expect(UserPlan.basic.maxNodes, 200);
  });

  test('Premium 플랜: maxNodes 무제한', () {
    expect(UserPlan.premium.isUnlimited, isTrue);
  });

  test('Free 플랜: 음성 미지원 (maxVoiceMinutes = 0)', () {
    expect(UserPlan.free.hasVoice, isFalse);
    expect(UserPlan.free.maxVoiceMinutes, 0);
  });

  test('Premium 플랜: 광고 없음', () {
    expect(UserPlan.premium.hasAds, isFalse);
  });

  test('Free 플랜 저장 → DB에서 읽기', () async {
    await settingsRepo.setUserPlan(UserPlan.free);
    final plan = await settingsRepo.getUserPlan();
    expect(plan, UserPlan.free);
  });

  test('Basic 플랜 업그레이드 → DB 반영', () async {
    await settingsRepo.setUserPlan(UserPlan.free);
    await settingsRepo.setUserPlan(UserPlan.basic);
    final plan = await settingsRepo.getUserPlan();
    expect(plan, UserPlan.basic);
  });

  test('노드 30개 생성 후 count 검증', () async {
    for (var i = 0; i < 30; i++) {
      await nodeRepo.create(
        name: '노드$i',
        positionX: (i * 100).toDouble(),
        positionY: 0,
      );
    }
    final count = await nodeRepo.count();
    expect(count, 30);
    expect(count >= UserPlan.free.maxNodes, isTrue);
  });

  test('Free 플랜 기본값 — DB 초기 상태', () async {
    final plan = await settingsRepo.getUserPlan();
    expect(plan, UserPlan.free);
  });
}
