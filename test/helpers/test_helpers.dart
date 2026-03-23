import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:re_link/core/database/app_database.dart';
import 'package:re_link/core/services/sync/media_upload_queue_service.dart';
import 'package:re_link/shared/repositories/node_repository.dart';
import 'package:re_link/shared/repositories/settings_repository.dart';

/// 테스트용 NodeRepository 생성 헬퍼
/// uploadQueue / settings 의존성을 Noop으로 주입
NodeRepository createTestNodeRepository(AppDatabase db) => NodeRepository(
      db,
      uploadQueue: _NoopMediaUploadQueueService(),
      settings: SettingsRepository(db),
    );

/// 업로드 큐 Noop 구현 (테스트 전용)
class _NoopMediaUploadQueueService extends MediaUploadQueueService {
  _NoopMediaUploadQueueService() : super(_FakeRef());

  @override
  Future<String> enqueue({
    String? memoryId,
    String? nodeId,
    required String localPath,
    required String category,
    required String contentType,
  }) async =>
      'noop-id';

  @override
  Future<void> processQueue() async {}
}

/// 최소 Ref 스텁 (테스트 전용, 실제 호출되지 않음)
class _FakeRef implements Ref {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
