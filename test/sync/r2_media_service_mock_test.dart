/// R2MediaService 실제 코드 테스트 (MockClient + MockSettings)
/// 커버: r2_media_service.dart — uploadFile, downloadFile, deleteFile,
///        _checkCloudQuota, getCloudUsageBytes
import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:re_link/core/database/app_database.dart';
import 'package:re_link/core/services/auth/auth_http_client.dart';
import 'package:re_link/core/services/auth/auth_token_storage.dart';
import 'package:re_link/core/services/sync/r2_media_service.dart';
import 'package:re_link/core/errors/app_error.dart';
import 'package:re_link/shared/models/user_plan.dart';
import 'package:re_link/shared/repositories/settings_repository.dart';
import 'package:re_link/shared/repositories/db_provider.dart';

class MockAppDatabase extends Mock implements AppDatabase {}

class MockSettingsRepository extends Mock implements SettingsRepository {}

class FakeTokenStorage implements AuthTokenStorage {
  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    String? userId,
  }) async {}

  @override
  Future<String?> getAccessToken() async => 'test_token';

  @override
  Future<String?> getRefreshToken() async => 'test_refresh';

  @override
  Future<String?> getUserId() async => null;

  @override
  Future<void> clearTokens() async {}

  @override
  Future<void> updateAccessToken(String accessToken) async {}
}

void main() {
  late MockAppDatabase mockDb;
  late MockSettingsRepository mockSettings;
  late ProviderContainer container;

  setUp(() {
    mockDb = MockAppDatabase();
    mockSettings = MockSettingsRepository();
  });

  tearDown(() {
    container.dispose();
  });

  ProviderContainer createContainer({required http.Client httpClient}) {
    final tokenStorage = FakeTokenStorage();
    final authHttpClient = AuthHttpClient(
      tokenStorage: tokenStorage,
      baseUrl: 'https://api.test.com',
      httpClient: httpClient,
    );

    return ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(mockDb),
        settingsRepositoryProvider.overrideWithValue(mockSettings),
        authHttpClientProvider.overrideWithValue(authHttpClient),
      ],
    );
  }

  group('R2MediaService.getCloudUsageBytes', () {
    test('successful response → returns total_bytes', () async {
      final mockHttpClient = MockClient((request) async {
        if (request.url.path == '/media/usage') {
          return http.Response(
            jsonEncode({
              'data': {'total_bytes': 5368709120}
            }),
            200,
          );
        }
        return http.Response('{}', 200);
      });

      container = createContainer(httpClient: mockHttpClient);
      final service = container.read(r2MediaServiceProvider);

      final bytes = await service.getCloudUsageBytes();
      expect(bytes, 5368709120); // 5 GB
    });

    test('server error → returns 0', () async {
      final mockHttpClient = MockClient((request) async {
        return http.Response('error', 500);
      });

      container = createContainer(httpClient: mockHttpClient);
      final service = container.read(r2MediaServiceProvider);

      final bytes = await service.getCloudUsageBytes();
      expect(bytes, 0);
    });

    test('network error → returns 0', () async {
      final mockHttpClient = MockClient((request) async {
        throw Exception('No connection');
      });

      container = createContainer(httpClient: mockHttpClient);
      final service = container.read(r2MediaServiceProvider);

      final bytes = await service.getCloudUsageBytes();
      expect(bytes, 0);
    });

    test('response with null data → returns 0', () async {
      final mockHttpClient = MockClient((request) async {
        if (request.url.path == '/media/usage') {
          return http.Response(jsonEncode({'data': null}), 200);
        }
        return http.Response('{}', 200);
      });

      container = createContainer(httpClient: mockHttpClient);
      final service = container.read(r2MediaServiceProvider);

      final bytes = await service.getCloudUsageBytes();
      expect(bytes, 0);
    });
  });

  group('R2MediaService.deleteFile', () {
    test('successful deletion → returns true', () async {
      final mockHttpClient = MockClient((request) async {
        if (request.method == 'DELETE') {
          return http.Response('{}', 200);
        }
        return http.Response('{}', 200);
      });

      container = createContainer(httpClient: mockHttpClient);
      final service = container.read(r2MediaServiceProvider);

      final result = await service.deleteFile(fileKey: 'grp/usr/photos/test.webp');
      expect(result, isTrue);
    });

    test('server error → returns false', () async {
      final mockHttpClient = MockClient((request) async {
        return http.Response('error', 500);
      });

      container = createContainer(httpClient: mockHttpClient);
      final service = container.read(r2MediaServiceProvider);

      final result = await service.deleteFile(fileKey: 'grp/usr/photos/test.webp');
      expect(result, isFalse);
    });

    test('network error → returns false', () async {
      final mockHttpClient = MockClient((request) async {
        throw Exception('No connection');
      });

      container = createContainer(httpClient: mockHttpClient);
      final service = container.read(r2MediaServiceProvider);

      final result = await service.deleteFile(fileKey: 'any/key');
      expect(result, isFalse);
    });
  });

  group('R2MediaService.uploadFile', () {
    test('null userId → returns null', () async {
      final mockHttpClient = MockClient((request) async {
        return http.Response('{}', 200);
      });

      container = createContainer(httpClient: mockHttpClient);
      final service = container.read(r2MediaServiceProvider);

      when(() => mockSettings.getAuthUserId()).thenAnswer((_) async => null);
      when(() => mockSettings.getFamilyGroupId())
          .thenAnswer((_) async => 'grp1');

      final result = await service.uploadFile(
        localPath: '/tmp/test.webp',
        contentType: 'image/webp',
        folder: 'photos',
      );
      expect(result, isNull);
    });

    test('empty userId → returns null', () async {
      final mockHttpClient = MockClient((request) async {
        return http.Response('{}', 200);
      });

      container = createContainer(httpClient: mockHttpClient);
      final service = container.read(r2MediaServiceProvider);

      when(() => mockSettings.getAuthUserId()).thenAnswer((_) async => '');
      when(() => mockSettings.getFamilyGroupId())
          .thenAnswer((_) async => 'grp1');

      final result = await service.uploadFile(
        localPath: '/tmp/test.webp',
        contentType: 'image/webp',
        folder: 'photos',
      );
      expect(result, isNull);
    });

    test('null groupId → returns null', () async {
      final mockHttpClient = MockClient((request) async {
        return http.Response('{}', 200);
      });

      container = createContainer(httpClient: mockHttpClient);
      final service = container.read(r2MediaServiceProvider);

      when(() => mockSettings.getAuthUserId()).thenAnswer((_) async => 'usr1');
      when(() => mockSettings.getFamilyGroupId())
          .thenAnswer((_) async => null);

      final result = await service.uploadFile(
        localPath: '/tmp/test.webp',
        contentType: 'image/webp',
        folder: 'photos',
      );
      expect(result, isNull);
    });

    test('file not found → returns null', () async {
      final mockHttpClient = MockClient((request) async {
        return http.Response('{}', 200);
      });

      container = createContainer(httpClient: mockHttpClient);
      final service = container.read(r2MediaServiceProvider);

      when(() => mockSettings.getAuthUserId()).thenAnswer((_) async => 'usr1');
      when(() => mockSettings.getFamilyGroupId())
          .thenAnswer((_) async => 'grp1');
      when(() => mockSettings.getUserPlan())
          .thenAnswer((_) async => UserPlan.family);

      final result = await service.uploadFile(
        localPath: '/nonexistent/file/path.webp',
        contentType: 'image/webp',
        folder: 'photos',
      );
      expect(result, isNull);
    });

    test('upload-url returns null → returns null', () async {
      final tempDir = Directory.systemTemp;
      final tempFile = File('${tempDir.path}/r2_test_nullurl.txt');
      await tempFile.writeAsString('test content');

      try {
        final mockHttpClient = MockClient((request) async {
          if (request.url.path == '/media/upload-url') {
            return http.Response(
              jsonEncode({
                'data': {'upload_url': null}
              }),
              200,
            );
          }
          if (request.url.path == '/media/usage') {
            return http.Response(
              jsonEncode({'data': {'total_bytes': 0}}),
              200,
            );
          }
          return http.Response('{}', 200);
        });

        container = createContainer(httpClient: mockHttpClient);
        final service = container.read(r2MediaServiceProvider);

        when(() => mockSettings.getAuthUserId())
            .thenAnswer((_) async => 'usr1');
        when(() => mockSettings.getFamilyGroupId())
            .thenAnswer((_) async => 'grp1');
        when(() => mockSettings.getUserPlan())
            .thenAnswer((_) async => UserPlan.family);

        final result = await service.uploadFile(
          localPath: tempFile.path,
          contentType: 'text/plain',
          folder: 'photos',
        );

        expect(result, isNull);
      } finally {
        if (tempFile.existsSync()) tempFile.deleteSync();
      }
    });

    test('upload-url server error → returns null', () async {
      final tempDir = Directory.systemTemp;
      final tempFile = File('${tempDir.path}/r2_test_urlerr.txt');
      await tempFile.writeAsString('test content');

      try {
        final mockHttpClient = MockClient((request) async {
          if (request.url.path == '/media/upload-url') {
            return http.Response('error', 500);
          }
          if (request.url.path == '/media/usage') {
            return http.Response(
              jsonEncode({'data': {'total_bytes': 0}}),
              200,
            );
          }
          return http.Response('{}', 200);
        });

        container = createContainer(httpClient: mockHttpClient);
        final service = container.read(r2MediaServiceProvider);

        when(() => mockSettings.getAuthUserId())
            .thenAnswer((_) async => 'usr1');
        when(() => mockSettings.getFamilyGroupId())
            .thenAnswer((_) async => 'grp1');
        when(() => mockSettings.getUserPlan())
            .thenAnswer((_) async => UserPlan.family);

        final result = await service.uploadFile(
          localPath: tempFile.path,
          contentType: 'text/plain',
          folder: 'photos',
        );

        expect(result, isNull);
      } finally {
        if (tempFile.existsSync()) tempFile.deleteSync();
      }
    });

    test('quota exceeded → throws StorageError', () async {
      final tempDir = Directory.systemTemp;
      final tempFile = File('${tempDir.path}/r2_test_quota.txt');
      await tempFile.writeAsString('test');

      try {
        final mockHttpClient = MockClient((request) async {
          if (request.url.path == '/media/usage') {
            // Report 20GB used (at limit)
            return http.Response(
              jsonEncode({
                'data': {'total_bytes': 20 * 1024 * 1024 * 1024}
              }),
              200,
            );
          }
          return http.Response('{}', 200);
        });

        container = createContainer(httpClient: mockHttpClient);
        final service = container.read(r2MediaServiceProvider);

        when(() => mockSettings.getAuthUserId())
            .thenAnswer((_) async => 'usr1');
        when(() => mockSettings.getFamilyGroupId())
            .thenAnswer((_) async => 'grp1');
        when(() => mockSettings.getUserPlan())
            .thenAnswer((_) async => UserPlan.family); // 20GB limit

        try {
          await service.uploadFile(
            localPath: tempFile.path,
            contentType: 'text/plain',
            folder: 'photos',
          );
          fail('Should have thrown StorageError');
        } on StorageError catch (e) {
          expect(e.message, contains('부족'));
        }
      } finally {
        if (tempFile.existsSync()) tempFile.deleteSync();
      }
    });

    test('plan without cloud → throws StorageError', () async {
      final tempDir = Directory.systemTemp;
      final tempFile = File('${tempDir.path}/r2_test_nocloud.txt');
      await tempFile.writeAsString('test');

      try {
        final mockHttpClient = MockClient((request) async {
          return http.Response('{}', 200);
        });

        container = createContainer(httpClient: mockHttpClient);
        final service = container.read(r2MediaServiceProvider);

        when(() => mockSettings.getAuthUserId())
            .thenAnswer((_) async => 'usr1');
        when(() => mockSettings.getFamilyGroupId())
            .thenAnswer((_) async => 'grp1');
        when(() => mockSettings.getUserPlan())
            .thenAnswer((_) async => UserPlan.free); // no cloud

        try {
          await service.uploadFile(
            localPath: tempFile.path,
            contentType: 'text/plain',
            folder: 'photos',
          );
          fail('Should have thrown StorageError');
        } on StorageError catch (e) {
          expect(e.message, contains('패밀리'));
        }
      } finally {
        if (tempFile.existsSync()) tempFile.deleteSync();
      }
    });
  });

  group('R2MediaService.downloadFile', () {
    test('download-url server error → returns null', () async {
      final mockHttpClient = MockClient((request) async {
        return http.Response('error', 500);
      });

      container = createContainer(httpClient: mockHttpClient);
      final service = container.read(r2MediaServiceProvider);

      final result = await service.downloadFile(
        fileKey: 'grp/usr/photos/test.txt',
        localPath: '/tmp/no_download.txt',
      );
      expect(result, isNull);
    });

    test('download-url returns null url → returns null', () async {
      final mockHttpClient = MockClient((request) async {
        if (request.url.path.contains('/download-url')) {
          return http.Response(
            jsonEncode({'data': {'download_url': null}}),
            200,
          );
        }
        return http.Response('{}', 200);
      });

      container = createContainer(httpClient: mockHttpClient);
      final service = container.read(r2MediaServiceProvider);

      final result = await service.downloadFile(
        fileKey: 'grp/usr/photos/test.txt',
        localPath: '/tmp/no_download.txt',
      );
      expect(result, isNull);
    });

    test('network error → returns null', () async {
      final mockHttpClient = MockClient((request) async {
        throw Exception('No network');
      });

      container = createContainer(httpClient: mockHttpClient);
      final service = container.read(r2MediaServiceProvider);

      final result = await service.downloadFile(
        fileKey: 'any/key',
        localPath: '/tmp/test.txt',
      );
      expect(result, isNull);
    });
  });
}
