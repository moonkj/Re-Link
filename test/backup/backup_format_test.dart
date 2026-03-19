import 'package:flutter_test/flutter_test.dart';
import 'package:re_link/core/services/backup/backup_format.dart';

void main() {
  group('BackupManifest', () {
    test('generateFilename — 형식이 올바르다', () {
      final dt = DateTime(2026, 3, 19, 14, 30, 5);
      final name = BackupManifest.generateFilename(dt);
      expect(name, 'backup_20260319_143005.rlink');
    });

    test('generateFilename — 한 자리 월/일/시/분/초 패딩', () {
      final dt = DateTime(2026, 1, 5, 9, 3, 7);
      final name = BackupManifest.generateFilename(dt);
      expect(name, 'backup_20260105_090307.rlink');
    });

    test('toJson / fromJson 왕복', () {
      final dt = DateTime(2026, 3, 19, 14, 30, 0);
      final manifest = BackupManifest(
        version: 1,
        createdAt: dt,
        appVersion: '1.0.0+1',
        nodeCount: 10,
        memoryCount: 25,
        totalBytes: 1024 * 512,
        checksum: 'abc123',
      );

      final json = manifest.toJson();
      final restored = BackupManifest.fromJson(json);

      expect(restored.version, manifest.version);
      expect(restored.createdAt.toIso8601String(), manifest.createdAt.toIso8601String());
      expect(restored.appVersion, manifest.appVersion);
      expect(restored.nodeCount, manifest.nodeCount);
      expect(restored.memoryCount, manifest.memoryCount);
      expect(restored.totalBytes, manifest.totalBytes);
      expect(restored.checksum, manifest.checksum);
    });

    test('toJson — checksum null이면 키 미포함', () {
      final manifest = BackupManifest(
        version: 1,
        createdAt: DateTime.now(),
        appVersion: '1.0.0',
        nodeCount: 0,
        memoryCount: 0,
        totalBytes: 0,
      );
      final json = manifest.toJson();
      expect(json.containsKey('checksum'), isFalse);
    });

    test('toJsonString — JSON 문자열 반환', () {
      final manifest = BackupManifest(
        version: 1,
        createdAt: DateTime(2026, 1, 1),
        appVersion: '1.0.0',
        nodeCount: 5,
        memoryCount: 10,
        totalBytes: 2048,
      );
      final str = manifest.toJsonString();
      expect(str, contains('"version":1'));
      expect(str, contains('"node_count":5'));
    });
  });

  group('BackupInfo', () {
    test('formattedSize — KB 단위 (1MB 미만)', () {
      final info = BackupInfo(
        filename: 'backup.rlink',
        createdAt: DateTime.now(),
        sizeBytes: 512 * 1024, // 512KB
        nodeCount: 5,
        memoryCount: 10,
        source: 'icloud',
      );
      expect(info.formattedSize, '512.0 KB');
    });

    test('formattedSize — MB 단위 (1MB 이상)', () {
      final info = BackupInfo(
        filename: 'backup.rlink',
        createdAt: DateTime.now(),
        sizeBytes: 2 * 1024 * 1024, // 2MB
        nodeCount: 5,
        memoryCount: 10,
        source: 'google',
      );
      expect(info.formattedSize, '2.0 MB');
    });
  });
}
