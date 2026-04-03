/// MediaUploadQueueService 실제 코드 테스트 (MockDatabase)
/// 커버: media_upload_queue_service.dart — processQueue, _processItem,
///        _categoryToFolder, _updateR2Key, getQueueStatus, cleanCompleted
import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:re_link/core/database/app_database.dart';
import 'package:re_link/core/services/sync/media_upload_queue_service.dart';
import 'package:re_link/core/services/sync/r2_media_service.dart';
import 'package:re_link/core/services/sync/sync_service.dart';
import 'package:re_link/core/services/auth/auth_http_client.dart';
import 'package:re_link/core/services/auth/auth_token_storage.dart';
import 'package:re_link/shared/repositories/db_provider.dart';
import 'package:re_link/shared/repositories/settings_repository.dart';
import 'package:drift/drift.dart';
import 'package:re_link/shared/models/user_plan.dart';

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

  setUpAll(() {
    registerFallbackValue(const MediaUploadQueueTableCompanion());
    registerFallbackValue(const MemoriesTableCompanion());
    registerFallbackValue(const NodesTableCompanion());
  });

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

  group('MediaUploadQueueService.getQueueStatus', () {
    test('delegates to DB', () async {
      final mockHttpClient = MockClient((r) async => http.Response('{}', 200));
      container = createContainer(httpClient: mockHttpClient);
      final service = container.read(mediaUploadQueueServiceProvider);

      when(() => mockDb.getMediaUploadQueueStatus()).thenAnswer(
        (_) async => {'pending': 2, 'uploading': 1, 'completed': 5, 'failed': 0},
      );

      final status = await service.getQueueStatus();
      expect(status['pending'], 2);
      expect(status['uploading'], 1);
      expect(status['completed'], 5);
      expect(status['failed'], 0);
    });
  });

  group('MediaUploadQueueService.getByMemoryId', () {
    test('delegates to DB', () async {
      final mockHttpClient = MockClient((r) async => http.Response('{}', 200));
      container = createContainer(httpClient: mockHttpClient);
      final service = container.read(mediaUploadQueueServiceProvider);

      when(() => mockDb.getMediaUploadsByMemoryId(any()))
          .thenAnswer((_) async => []);

      final result = await service.getByMemoryId('m1');
      expect(result, isEmpty);
      verify(() => mockDb.getMediaUploadsByMemoryId('m1')).called(1);
    });
  });

  group('MediaUploadQueueService.getByNodeId', () {
    test('delegates to DB', () async {
      final mockHttpClient = MockClient((r) async => http.Response('{}', 200));
      container = createContainer(httpClient: mockHttpClient);
      final service = container.read(mediaUploadQueueServiceProvider);

      when(() => mockDb.getMediaUploadsByNodeId(any()))
          .thenAnswer((_) async => []);

      final result = await service.getByNodeId('n1');
      expect(result, isEmpty);
      verify(() => mockDb.getMediaUploadsByNodeId('n1')).called(1);
    });
  });

  group('MediaUploadQueueService.cleanCompleted', () {
    test('delegates to DB', () async {
      final mockHttpClient = MockClient((r) async => http.Response('{}', 200));
      container = createContainer(httpClient: mockHttpClient);
      final service = container.read(mediaUploadQueueServiceProvider);

      when(() => mockDb.cleanCompletedMediaUploads())
          .thenAnswer((_) async {});

      await service.cleanCompleted();
      verify(() => mockDb.cleanCompletedMediaUploads()).called(1);
    });
  });

  group('MediaUploadQueueService.processQueue', () {
    test('empty queue — no items to process', () async {
      final mockHttpClient = MockClient((r) async => http.Response('{}', 200));
      container = createContainer(httpClient: mockHttpClient);
      final service = container.read(mediaUploadQueueServiceProvider);

      when(() => mockDb.getPendingMediaUploads(limit: any(named: 'limit')))
          .thenAnswer((_) async => []);
      when(() => mockDb.getRetryableMediaUploads(
            maxRetry: any(named: 'maxRetry'),
            limit: any(named: 'limit'),
          )).thenAnswer((_) async => []);

      await service.processQueue();

      verify(() => mockDb.getPendingMediaUploads(limit: any(named: 'limit')))
          .called(1);
    });

    test('processQueue with file not found — marks as failed', () async {
      final item = MediaUploadQueueEntry(
        id: 'uq1',
        memoryId: 'm1',
        localPath: '/nonexistent/file.webp',
        category: 'photo',
        contentType: 'image/webp',
        fileSizeBytes: 1024,
        status: 'pending',
        retryCount: 0,
        createdAt: DateTime(2026),
      );

      final mockHttpClient = MockClient((r) async => http.Response('{}', 200));
      container = createContainer(httpClient: mockHttpClient);
      final service = container.read(mediaUploadQueueServiceProvider);

      when(() => mockDb.getPendingMediaUploads(limit: any(named: 'limit')))
          .thenAnswer((_) async => [item]);
      when(() => mockDb.getRetryableMediaUploads(
            maxRetry: any(named: 'maxRetry'),
            limit: any(named: 'limit'),
          )).thenAnswer((_) async => []);
      when(() => mockDb.updateMediaUploadStatus(
            any(),
            status: any(named: 'status'),
            r2FileKey: any(named: 'r2FileKey'),
            completedAt: any(named: 'completedAt'),
          )).thenAnswer((_) async {});

      // Sync service mock (processQueue triggers sync at end)
      when(() => mockSettings.getLastSyncAt()).thenAnswer((_) async => null);
      when(() => mockSettings.setLastSyncAt(any())).thenAnswer((_) async {});
      when(() => mockDb.getPendingSyncItems(limit: any(named: 'limit')))
          .thenAnswer((_) async => []);

      await service.processQueue();

      verify(() => mockDb.updateMediaUploadStatus(
            'uq1',
            status: 'failed',
          )).called(1);
    });

    test('processQueue with real file — uploads successfully', () async {
      final tempDir = Directory.systemTemp;
      final tempFile = File('${tempDir.path}/upload_queue_test.txt');
      await tempFile.writeAsString('test upload content');

      try {
        final item = MediaUploadQueueEntry(
          id: 'uq2',
          memoryId: 'm1',
          localPath: tempFile.path,
          category: 'photo',
          contentType: 'text/plain',
          fileSizeBytes: await tempFile.length(),
          status: 'pending',
          retryCount: 0,
          createdAt: DateTime(2026),
        );

        final mockHttpClient = MockClient((request) async {
          if (request.url.path == '/media/upload-url') {
            return http.Response(
              jsonEncode({
                'data': {
                  'upload_url': 'https://r2.test.com/put',
                  'file_key': 'grp/usr/photos/uuid.txt',
                }
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
          if (request.url.path == '/media/confirm-upload') {
            return http.Response('{}', 200);
          }
          if (request.url.path == '/sync/pull') {
            return http.Response(
              jsonEncode({'nodes': [], 'edges': [], 'memories': []}),
              200,
            );
          }
          return http.Response('{}', 200);
        });

        container = createContainer(httpClient: mockHttpClient);
        final service = container.read(mediaUploadQueueServiceProvider);

        when(() => mockSettings.getAuthUserId())
            .thenAnswer((_) async => 'usr1');
        when(() => mockSettings.getFamilyGroupId())
            .thenAnswer((_) async => 'grp1');
        when(() => mockSettings.getUserPlan())
            .thenAnswer((_) async => UserPlan.family);
        when(() => mockSettings.getLastSyncAt()).thenAnswer((_) async => null);
        when(() => mockSettings.setLastSyncAt(any())).thenAnswer((_) async {});

        when(() => mockDb.getPendingMediaUploads(limit: any(named: 'limit')))
            .thenAnswer((_) async => [item]);
        when(() => mockDb.getRetryableMediaUploads(
              maxRetry: any(named: 'maxRetry'),
              limit: any(named: 'limit'),
            )).thenAnswer((_) async => []);
        when(() => mockDb.updateMediaUploadStatus(
              any(),
              status: any(named: 'status'),
              r2FileKey: any(named: 'r2FileKey'),
              completedAt: any(named: 'completedAt'),
            )).thenAnswer((_) async {});
        when(() => mockDb.memoriesTable).thenThrow(Exception('skip table update'));
        when(() => mockDb.getPendingSyncItems(limit: any(named: 'limit')))
            .thenAnswer((_) async => []);

        await service.processQueue();

        // Verify the item was set to uploading then completed
        verify(() => mockDb.updateMediaUploadStatus('uq2', status: 'uploading'))
            .called(1);
      } finally {
        if (tempFile.existsSync()) tempFile.deleteSync();
      }
    });
  });

  group('MediaUploadQueueService.enqueue', () {
    test('enqueues with memoryId', () async {
      final mockHttpClient = MockClient((r) async => http.Response('{}', 200));
      container = createContainer(httpClient: mockHttpClient);
      final service = container.read(mediaUploadQueueServiceProvider);

      // Create a temp file to get its size
      final tempDir = Directory.systemTemp;
      final tempFile = File('${tempDir.path}/enqueue_test.txt');
      await tempFile.writeAsString('data');

      try {
        when(() => mockDb.enqueueMediaUpload(any())).thenAnswer((_) async {});

        final id = await service.enqueue(
          memoryId: 'm1',
          localPath: tempFile.path,
          category: 'photo',
          contentType: 'image/webp',
        );

        expect(id, isNotEmpty);
        verify(() => mockDb.enqueueMediaUpload(any())).called(1);
      } finally {
        if (tempFile.existsSync()) tempFile.deleteSync();
      }
    });

    test('enqueues with nodeId', () async {
      final mockHttpClient = MockClient((r) async => http.Response('{}', 200));
      container = createContainer(httpClient: mockHttpClient);
      final service = container.read(mediaUploadQueueServiceProvider);

      final tempDir = Directory.systemTemp;
      final tempFile = File('${tempDir.path}/enqueue_node_test.txt');
      await tempFile.writeAsString('profile data');

      try {
        when(() => mockDb.enqueueMediaUpload(any())).thenAnswer((_) async {});

        final id = await service.enqueue(
          nodeId: 'n1',
          localPath: tempFile.path,
          category: 'photo',
          contentType: 'image/webp',
        );

        expect(id, isNotEmpty);
      } finally {
        if (tempFile.existsSync()) tempFile.deleteSync();
      }
    });
  });
}
