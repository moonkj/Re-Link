/// SyncService 실제 코드 테스트 (MockDatabase + MockClient)
/// 커버: sync_service.dart — sync, enqueue, cleanUp, _pull, _push
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:re_link/core/database/app_database.dart';
import 'package:re_link/core/services/sync/sync_service.dart';
import 'package:re_link/core/services/auth/auth_http_client.dart';
import 'package:re_link/core/services/auth/auth_token_storage.dart';
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

/// Helper to read the SyncService from a container
SyncService readSyncService(ProviderContainer container) {
  return container.read(syncServiceProvider);
}

void main() {
  // Register fallback values for mocktail
  setUpAll(() {
    registerFallbackValue(DateTime(2020));
    registerFallbackValue(const NodesTableCompanion());
    registerFallbackValue(const NodeEdgesTableCompanion());
    registerFallbackValue(const MemoriesTableCompanion());
  });

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

  /// Helper to create a container with overridden providers
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

  // ── SyncResult ──────────────────────────────────────────────────────────

  group('SyncResult', () {
    test('constructor', () {
      // Initialize container for tearDown
      final mockHttpClient = MockClient((request) async {
        return http.Response('{}', 200);
      });
      container = createContainer(httpClient: mockHttpClient);

      const r = SyncResult(pulled: 5, pushed: 3);
      expect(r.pulled, 5);
      expect(r.pushed, 3);
    });
  });

  // ── sync (Pull → Push) ─────────────────────────────────────────────────

  group('SyncService.sync', () {
    test('pull empty + push empty → SyncResult(0, 0)', () async {
      final mockHttpClient = MockClient((request) async {
        if (request.url.path == '/sync/pull') {
          return http.Response(
            jsonEncode({'nodes': [], 'edges': [], 'memories': []}),
            200,
          );
        }
        return http.Response('{}', 200);
      });

      container = createContainer(httpClient: mockHttpClient);
      final syncService = readSyncService(container);

      when(() => mockSettings.getLastSyncAt()).thenAnswer((_) async => null);
      when(() => mockSettings.setLastSyncAt(any())).thenAnswer((_) async {});
      when(() => mockDb.getPendingSyncItems(limit: 50))
          .thenAnswer((_) async => []);

      final result = await syncService.sync();
      expect(result.pulled, 0);
      expect(result.pushed, 0);
    });

    test('pull with nodes', () async {
      final mockHttpClient = MockClient((request) async {
        if (request.url.path == '/sync/pull') {
          return http.Response(
            jsonEncode({
              'nodes': [
                {
                  'id': 'n1',
                  'name': 'TestNode',
                  'is_ghost': 0,
                  'temperature': 3,
                  'position_x': 10.0,
                  'position_y': 20.0,
                  'tags_json': '[]',
                },
              ],
              'edges': [],
              'memories': [],
            }),
            200,
          );
        }
        return http.Response('{}', 200);
      });

      container = createContainer(httpClient: mockHttpClient);
      final syncService = readSyncService(container);

      when(() => mockSettings.getLastSyncAt()).thenAnswer((_) async => null);
      when(() => mockSettings.setLastSyncAt(any())).thenAnswer((_) async {});
      when(() => mockDb.upsertNode(any())).thenAnswer((_) async {});
      when(() => mockDb.getPendingSyncItems(limit: 50))
          .thenAnswer((_) async => []);

      final result = await syncService.sync();
      expect(result.pulled, 1);
      expect(result.pushed, 0);

      verify(() => mockDb.upsertNode(any())).called(1);
    });

    test('pull with deleted node', () async {
      final mockHttpClient = MockClient((request) async {
        if (request.url.path == '/sync/pull') {
          return http.Response(
            jsonEncode({
              'nodes': [
                {'id': 'n1', 'name': 'Del', 'is_deleted': 1},
              ],
              'edges': [],
              'memories': [],
            }),
            200,
          );
        }
        return http.Response('{}', 200);
      });

      container = createContainer(httpClient: mockHttpClient);
      final syncService = readSyncService(container);

      when(() => mockSettings.getLastSyncAt()).thenAnswer((_) async => null);
      when(() => mockSettings.setLastSyncAt(any())).thenAnswer((_) async {});
      when(() => mockDb.deleteNode(any())).thenAnswer((_) async => 1);
      when(() => mockDb.getPendingSyncItems(limit: 50))
          .thenAnswer((_) async => []);

      final result = await syncService.sync();
      expect(result.pulled, 1);
      verify(() => mockDb.deleteNode('n1')).called(1);
    });

    test('pull with edges', () async {
      final mockHttpClient = MockClient((request) async {
        if (request.url.path == '/sync/pull') {
          return http.Response(
            jsonEncode({
              'nodes': [],
              'edges': [
                {
                  'id': 'e1',
                  'from_node_id': 'n1',
                  'to_node_id': 'n2',
                  'relation': 'parent',
                },
              ],
              'memories': [],
            }),
            200,
          );
        }
        return http.Response('{}', 200);
      });

      container = createContainer(httpClient: mockHttpClient);
      final syncService = readSyncService(container);

      when(() => mockSettings.getLastSyncAt()).thenAnswer((_) async => null);
      when(() => mockSettings.setLastSyncAt(any())).thenAnswer((_) async {});
      when(() => mockDb.upsertEdge(any())).thenAnswer((_) async {});
      when(() => mockDb.getPendingSyncItems(limit: 50))
          .thenAnswer((_) async => []);

      final result = await syncService.sync();
      expect(result.pulled, 1);
      verify(() => mockDb.upsertEdge(any())).called(1);
    });

    test('pull with memories', () async {
      final mockHttpClient = MockClient((request) async {
        if (request.url.path == '/sync/pull') {
          return http.Response(
            jsonEncode({
              'nodes': [],
              'edges': [],
              'memories': [
                {
                  'id': 'm1',
                  'node_id': 'n1',
                  'type': 'photo',
                  'tags_json': '[]',
                },
              ],
            }),
            200,
          );
        }
        return http.Response('{}', 200);
      });

      container = createContainer(httpClient: mockHttpClient);
      final syncService = readSyncService(container);

      when(() => mockSettings.getLastSyncAt()).thenAnswer((_) async => null);
      when(() => mockSettings.setLastSyncAt(any())).thenAnswer((_) async {});
      when(() => mockDb.upsertMemory(any())).thenAnswer((_) async {});
      when(() => mockDb.getPendingSyncItems(limit: 50))
          .thenAnswer((_) async => []);

      final result = await syncService.sync();
      expect(result.pulled, 1);
      verify(() => mockDb.upsertMemory(any())).called(1);
    });

    test('pull server error → 0 pulled', () async {
      final mockHttpClient = MockClient((request) async {
        if (request.url.path == '/sync/pull') {
          return http.Response('{"error":"server"}', 500);
        }
        return http.Response('{}', 200);
      });

      container = createContainer(httpClient: mockHttpClient);
      final syncService = readSyncService(container);

      when(() => mockSettings.getLastSyncAt()).thenAnswer((_) async => null);
      when(() => mockSettings.setLastSyncAt(any())).thenAnswer((_) async {});
      when(() => mockDb.getPendingSyncItems(limit: 50))
          .thenAnswer((_) async => []);

      final result = await syncService.sync();
      expect(result.pulled, 0);
    });

    test('concurrent sync calls → second returns (0, 0)', () async {
      final mockHttpClient = MockClient((request) async {
        await Future.delayed(const Duration(milliseconds: 100));
        if (request.url.path == '/sync/pull') {
          return http.Response(
            jsonEncode({'nodes': [], 'edges': [], 'memories': []}),
            200,
          );
        }
        return http.Response('{}', 200);
      });

      container = createContainer(httpClient: mockHttpClient);
      final syncService = readSyncService(container);

      when(() => mockSettings.getLastSyncAt()).thenAnswer((_) async => null);
      when(() => mockSettings.setLastSyncAt(any())).thenAnswer((_) async {});
      when(() => mockDb.getPendingSyncItems(limit: 50))
          .thenAnswer((_) async => []);

      // Start first sync
      final future1 = syncService.sync();
      // Start second sync while first is in progress
      final future2 = syncService.sync();

      final result2 = await future2;
      expect(result2.pulled, 0);
      expect(result2.pushed, 0);

      await future1; // wait for first to complete
    });
  });

  // ── enqueue ─────────────────────────────────────────────────────────────

  group('SyncService.enqueue', () {
    test('enqueues sync item to DB', () async {
      final mockHttpClient = MockClient((request) async {
        return http.Response('{}', 200);
      });

      container = createContainer(httpClient: mockHttpClient);
      final syncService = readSyncService(container);

      when(() => mockDb.enqueueSyncItem(
            targetTable: any(named: 'targetTable'),
            recordId: any(named: 'recordId'),
            operation: any(named: 'operation'),
            payloadJson: any(named: 'payloadJson'),
          )).thenAnswer((_) async {});

      await syncService.enqueue(
        targetTable: 'nodes',
        recordId: 'n1',
        operation: 'upsert',
        payload: {'id': 'n1', 'name': 'Test'},
      );

      verify(() => mockDb.enqueueSyncItem(
            targetTable: 'nodes',
            recordId: 'n1',
            operation: 'upsert',
            payloadJson: any(named: 'payloadJson'),
          )).called(1);
    });
  });

  // ── cleanUp ─────────────────────────────────────────────────────────────

  group('SyncService.cleanUp', () {
    test('calls cleanSyncedItems on DB', () async {
      final mockHttpClient = MockClient((request) async {
        return http.Response('{}', 200);
      });

      container = createContainer(httpClient: mockHttpClient);
      final syncService = readSyncService(container);

      when(() => mockDb.cleanSyncedItems()).thenAnswer((_) async {});

      await syncService.cleanUp();

      verify(() => mockDb.cleanSyncedItems()).called(1);
    });
  });

  // ── push ───────────────────────────────────────────────────────────────

  group('SyncService push logic', () {
    SyncQueueEntry makeSyncEntry({
      required String id,
      required String targetTable,
      required String recordId,
      required String operation,
      required String payloadJson,
    }) =>
        SyncQueueEntry(
          id: id,
          targetTable: targetTable,
          recordId: recordId,
          operation: operation,
          payloadJson: payloadJson,
          createdAtMs: DateTime.now().millisecondsSinceEpoch,
          isSynced: false,
          retryCount: 0,
        );

    test('push with pending items — success marks synced', () async {
      final pendingEntry = makeSyncEntry(
        id: 'sq1',
        targetTable: 'nodes',
        recordId: 'n1',
        operation: 'upsert',
        payloadJson: jsonEncode({'id': 'n1', 'name': 'Test'}),
      );

      final mockHttpClient = MockClient((request) async {
        if (request.url.path == '/sync/pull') {
          return http.Response(
            jsonEncode({'nodes': [], 'edges': [], 'memories': []}),
            200,
          );
        }
        if (request.url.path == '/sync/push') {
          return http.Response('{}', 200);
        }
        return http.Response('{}', 200);
      });

      container = createContainer(httpClient: mockHttpClient);
      final syncService = readSyncService(container);

      when(() => mockSettings.getLastSyncAt()).thenAnswer((_) async => null);
      when(() => mockSettings.setLastSyncAt(any())).thenAnswer((_) async {});
      when(() => mockSettings.getDeviceId())
          .thenAnswer((_) async => 'device_1');
      when(() => mockDb.getPendingSyncItems(limit: 50))
          .thenAnswer((_) async => [pendingEntry]);
      when(() => mockDb.getNode(any())).thenAnswer((_) async => null);
      when(() => mockDb.markSyncedItems(any())).thenAnswer((_) async {});

      final result = await syncService.sync();
      expect(result.pushed, 1);
      verify(() => mockDb.markSyncedItems(['sq1'])).called(1);
    });

    test('push with server failure — increments retry', () async {
      final pendingEntry = makeSyncEntry(
        id: 'sq2',
        targetTable: 'memories',
        recordId: 'm1',
        operation: 'upsert',
        payloadJson: jsonEncode({'id': 'm1', 'node_id': 'n1', 'type': 'photo'}),
      );

      final mockHttpClient = MockClient((request) async {
        if (request.url.path == '/sync/pull') {
          return http.Response(
            jsonEncode({'nodes': [], 'edges': [], 'memories': []}),
            200,
          );
        }
        if (request.url.path == '/sync/push') {
          return http.Response('error', 500);
        }
        return http.Response('{}', 200);
      });

      container = createContainer(httpClient: mockHttpClient);
      final syncService = readSyncService(container);

      when(() => mockSettings.getLastSyncAt()).thenAnswer((_) async => null);
      when(() => mockSettings.setLastSyncAt(any())).thenAnswer((_) async {});
      when(() => mockSettings.getDeviceId())
          .thenAnswer((_) async => 'device_1');
      when(() => mockDb.getPendingSyncItems(limit: 50))
          .thenAnswer((_) async => [pendingEntry]);
      when(() => mockDb.getMemory(any())).thenAnswer((_) async => null);
      when(() => mockDb.incrementRetryCount(any())).thenAnswer((_) async {});

      final result = await syncService.sync();
      expect(result.pushed, 0); // push failed
      verify(() => mockDb.incrementRetryCount('sq2')).called(1);
    });

    test('push with network error — increments retry', () async {
      final pendingEntry = makeSyncEntry(
        id: 'sq3',
        targetTable: 'nodes',
        recordId: 'n1',
        operation: 'delete',
        payloadJson: jsonEncode({'id': 'n1'}),
      );

      var pullDone = false;
      final mockHttpClient = MockClient((request) async {
        if (request.url.path == '/sync/pull') {
          pullDone = true;
          return http.Response(
            jsonEncode({'nodes': [], 'edges': [], 'memories': []}),
            200,
          );
        }
        if (request.url.path == '/sync/push' && pullDone) {
          throw Exception('Network error');
        }
        return http.Response('{}', 200);
      });

      container = createContainer(httpClient: mockHttpClient);
      final syncService = readSyncService(container);

      when(() => mockSettings.getLastSyncAt()).thenAnswer((_) async => null);
      when(() => mockSettings.setLastSyncAt(any())).thenAnswer((_) async {});
      when(() => mockSettings.getDeviceId())
          .thenAnswer((_) async => 'device_1');
      when(() => mockDb.getPendingSyncItems(limit: 50))
          .thenAnswer((_) async => [pendingEntry]);
      when(() => mockDb.getNode(any())).thenAnswer((_) async => null);
      when(() => mockDb.incrementRetryCount(any())).thenAnswer((_) async {});

      final result = await syncService.sync();
      expect(result.pushed, 0);
      verify(() => mockDb.incrementRetryCount('sq3')).called(1);
    });

    test('push with null deviceId → defaults to unknown', () async {
      final pendingEntry = makeSyncEntry(
        id: 'sq4',
        targetTable: 'node_edges',
        recordId: 'e1',
        operation: 'upsert',
        payloadJson: jsonEncode({
          'id': 'e1',
          'from_node_id': 'n1',
          'to_node_id': 'n2',
          'relation': 'parent',
        }),
      );

      Map<String, dynamic>? capturedBody;
      final mockHttpClient = MockClient((request) async {
        if (request.url.path == '/sync/pull') {
          return http.Response(
            jsonEncode({'nodes': [], 'edges': [], 'memories': []}),
            200,
          );
        }
        if (request.url.path == '/sync/push') {
          capturedBody = jsonDecode(request.body) as Map<String, dynamic>;
          return http.Response('{}', 200);
        }
        return http.Response('{}', 200);
      });

      container = createContainer(httpClient: mockHttpClient);
      final syncService = readSyncService(container);

      when(() => mockSettings.getLastSyncAt()).thenAnswer((_) async => null);
      when(() => mockSettings.setLastSyncAt(any())).thenAnswer((_) async {});
      when(() => mockSettings.getDeviceId()).thenAnswer((_) async => null);
      when(() => mockDb.getPendingSyncItems(limit: 50))
          .thenAnswer((_) async => [pendingEntry]);
      when(() => mockDb.markSyncedItems(any())).thenAnswer((_) async {});

      await syncService.sync();
      expect(capturedBody?['device_id'], 'unknown');
    });

    test('push memory with R2 key enrichment', () async {
      final pendingEntry = makeSyncEntry(
        id: 'sq5',
        targetTable: 'memories',
        recordId: 'm1',
        operation: 'upsert',
        payloadJson: jsonEncode({'id': 'm1', 'node_id': 'n1', 'type': 'photo'}),
      );

      List<dynamic>? capturedItems;
      final mockHttpClient = MockClient((request) async {
        if (request.url.path == '/sync/pull') {
          return http.Response(
            jsonEncode({'nodes': [], 'edges': [], 'memories': []}),
            200,
          );
        }
        if (request.url.path == '/sync/push') {
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          capturedItems = body['items'] as List<dynamic>;
          return http.Response('{}', 200);
        }
        return http.Response('{}', 200);
      });

      container = createContainer(httpClient: mockHttpClient);
      final syncService = readSyncService(container);

      when(() => mockSettings.getLastSyncAt()).thenAnswer((_) async => null);
      when(() => mockSettings.setLastSyncAt(any())).thenAnswer((_) async {});
      when(() => mockSettings.getDeviceId())
          .thenAnswer((_) async => 'dev1');
      when(() => mockDb.getPendingSyncItems(limit: 50))
          .thenAnswer((_) async => [pendingEntry]);
      when(() => mockDb.getMemory('m1')).thenAnswer((_) async {
        return MemoriesTableData(
          id: 'm1',
          nodeId: 'n1',
          type: 'photo',
          r2FileKey: 'grp/usr/photos/m1.webp',
          r2ThumbnailKey: 'grp/usr/thumbs/m1.webp',
          createdAt: DateTime(2026),
          tagsJson: '[]',
          isPrivate: false,
        );
      });
      when(() => mockDb.markSyncedItems(any())).thenAnswer((_) async {});

      await syncService.sync();

      expect(capturedItems, isNotNull);
      final memData =
          (capturedItems![0] as Map<String, dynamic>)['data'] as Map<String, dynamic>;
      expect(memData['file_r2_key'], 'grp/usr/photos/m1.webp');
      expect(memData['thumbnail_r2_key'], 'grp/usr/thumbs/m1.webp');
    });

    test('pull with deleted edge', () async {
      final mockHttpClient = MockClient((request) async {
        if (request.url.path == '/sync/pull') {
          return http.Response(
            jsonEncode({
              'nodes': [],
              'edges': [
                {'id': 'e1', 'is_deleted': 1},
              ],
              'memories': [],
            }),
            200,
          );
        }
        return http.Response('{}', 200);
      });

      container = createContainer(httpClient: mockHttpClient);
      final syncService = readSyncService(container);

      when(() => mockSettings.getLastSyncAt()).thenAnswer((_) async => null);
      when(() => mockSettings.setLastSyncAt(any())).thenAnswer((_) async {});
      when(() => mockDb.deleteEdge(any())).thenAnswer((_) async => 1);
      when(() => mockDb.getPendingSyncItems(limit: 50))
          .thenAnswer((_) async => []);

      final result = await syncService.sync();
      expect(result.pulled, 1);
      verify(() => mockDb.deleteEdge('e1')).called(1);
    });

    test('pull with deleted memory', () async {
      final mockHttpClient = MockClient((request) async {
        if (request.url.path == '/sync/pull') {
          return http.Response(
            jsonEncode({
              'nodes': [],
              'edges': [],
              'memories': [
                {'id': 'm1', 'is_deleted': 1},
              ],
            }),
            200,
          );
        }
        return http.Response('{}', 200);
      });

      container = createContainer(httpClient: mockHttpClient);
      final syncService = readSyncService(container);

      when(() => mockSettings.getLastSyncAt()).thenAnswer((_) async => null);
      when(() => mockSettings.setLastSyncAt(any())).thenAnswer((_) async {});
      when(() => mockDb.deleteMemory(any())).thenAnswer((_) async => 1);
      when(() => mockDb.getPendingSyncItems(limit: 50))
          .thenAnswer((_) async => []);

      final result = await syncService.sync();
      expect(result.pulled, 1);
      verify(() => mockDb.deleteMemory('m1')).called(1);
    });

    test('pull with lastSyncAt set', () async {
      final mockHttpClient = MockClient((request) async {
        if (request.url.path == '/sync/pull') {
          // Verify the since parameter
          expect(request.url.queryParameters['since'], isNotNull);
          return http.Response(
            jsonEncode({'nodes': [], 'edges': [], 'memories': []}),
            200,
          );
        }
        return http.Response('{}', 200);
      });

      container = createContainer(httpClient: mockHttpClient);
      final syncService = readSyncService(container);

      final lastSync = DateTime(2026, 3, 1);
      when(() => mockSettings.getLastSyncAt())
          .thenAnswer((_) async => lastSync);
      when(() => mockSettings.setLastSyncAt(any())).thenAnswer((_) async {});
      when(() => mockDb.getPendingSyncItems(limit: 50))
          .thenAnswer((_) async => []);

      await syncService.sync();
    });
  });
}
