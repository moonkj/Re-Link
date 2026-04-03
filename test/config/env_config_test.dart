/// EnvConfig 순수 로직 테스트
/// 커버: env_config.dart — 상수값, isApiConfigured
import 'package:flutter_test/flutter_test.dart';
import 'package:re_link/core/config/env_config.dart';

void main() {
  group('EnvConfig constants', () {
    test('workersBaseUrl has default value', () {
      expect(EnvConfig.workersBaseUrl, isNotEmpty);
      expect(
        EnvConfig.workersBaseUrl,
        'https://relink-api.relink-app.workers.dev',
      );
    });

    test('isApiConfigured is true when workersBaseUrl is set', () {
      expect(EnvConfig.isApiConfigured, isTrue);
    });

    test('admobAppIdIos has test default', () {
      expect(EnvConfig.admobAppIdIos, contains('ca-app-pub'));
    });

    test('admobAppIdAndroid has test default', () {
      expect(EnvConfig.admobAppIdAndroid, contains('ca-app-pub'));
    });

    test('googleClientId has default value', () {
      expect(EnvConfig.googleClientId, contains('.apps.googleusercontent.com'));
    });
  });
}
