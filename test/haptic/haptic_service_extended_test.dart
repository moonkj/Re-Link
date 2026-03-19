/// HapticService 확장 단위 테스트
/// 커버: haptic_service.dart 미커버 라인 (26-55)
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:re_link/core/utils/haptic_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async => null);
  });

  // HapticFeedback는 실기기에서만 작동하지만 completes 검증으로 코드 경로 커버

  group('HapticService 명명 메서드', () {
    test('ghostFill() — heavyImpact×2 completes', () async {
      await expectLater(HapticService.ghostFill(), completes);
    });

    test('heritageExport() — heavyImpact×2 completes', () async {
      await expectLater(HapticService.heritageExport(), completes);
    });

    test('vibeMeterStep() — selectionClick completes', () async {
      await expectLater(HapticService.vibeMeterStep(), completes);
    });

    test('connectionMade() — mediumImpact completes', () async {
      await expectLater(HapticService.connectionMade(), completes);
    });

    test('memoryAdded() — mediumImpact completes', () async {
      await expectLater(HapticService.memoryAdded(), completes);
    });

    test('nodeDeleted() — heavyImpact completes', () async {
      await expectLater(HapticService.nodeDeleted(), completes);
    });

    test('planLimitReached() — heavyImpact completes', () async {
      await expectLater(HapticService.planLimitReached(), completes);
    });

    test('backupComplete() — lightImpact completes', () async {
      await expectLater(HapticService.backupComplete(), completes);
    });
  });

  group('HapticService 기본 티어', () {
    test('light() completes', () async {
      await expectLater(HapticService.light(), completes);
    });
    test('medium() completes', () async {
      await expectLater(HapticService.medium(), completes);
    });
    test('heavy() completes', () async {
      await expectLater(HapticService.heavy(), completes);
    });
    test('selection() completes', () async {
      await expectLater(HapticService.selection(), completes);
    });
  });
}
