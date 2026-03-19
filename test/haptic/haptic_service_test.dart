import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:re_link/core/utils/haptic_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // HapticFeedback은 플랫폼 채널 — 테스트 환경에서는 예외 없이 완료되는지 검증
  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async => null,
    );
  });

  group('HapticService — 예외 없이 실행', () {
    test('light() 정상 완료', () async {
      await expectLater(HapticService.light(), completes);
    });

    test('medium() 정상 완료', () async {
      await expectLater(HapticService.medium(), completes);
    });

    test('heavy() 정상 완료', () async {
      await expectLater(HapticService.heavy(), completes);
    });

    test('selection() 정상 완료', () async {
      await expectLater(HapticService.selection(), completes);
    });
  });
}
