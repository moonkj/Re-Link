import 'package:drift/drift.dart';

/// R2 미디어 업로드 대기열
/// 로컬 파일 → R2 업로드 추적 (패밀리/패밀리플러스 전용)
@DataClassName('MediaUploadQueueEntry')
class MediaUploadQueueTable extends Table {
  @override
  String get tableName => 'media_upload_queue';

  TextColumn get id => text()();                     // UUID
  TextColumn get memoryId => text().nullable()();    // 연관 memory ID (사진/음성/영상)
  TextColumn get nodeId => text().nullable()();      // 연관 node ID (프로필 사진)
  TextColumn get localPath => text()();              // 로컬 파일 경로
  TextColumn get r2FileKey => text().nullable()();   // R2 업로드 완료 후 키
  TextColumn get category => text()();               // photo / voice / video / thumbnail
  TextColumn get contentType => text()();            // MIME type (image/webp, audio/mp4 등)
  IntColumn get fileSizeBytes => integer()();        // 파일 크기 (bytes)
  TextColumn get status => text().withDefault(const Constant('pending'))(); // pending / uploading / completed / failed
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get completedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
