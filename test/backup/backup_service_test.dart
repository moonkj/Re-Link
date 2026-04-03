/// BackupService / BackupManifest / BackupInfo 단위 테스트
/// 커버: backup_format.dart — toJson/fromJson 왕복, currentVersion, BackupInfo 정렬
///       backup_service.dart 내 BackupVersionEntry 추가 테스트
import 'package:flutter_test/flutter_test.dart';
import 'package:re_link/core/services/backup/backup_format.dart';
import 'package:re_link/shared/repositories/settings_repository.dart';

void main() {
  // ── BackupManifest ────────────────────────────────────────────────────────

  group('BackupManifest.currentVersion', () {
    test('currentVersion은 정의되어 있고 양수', () {
      expect(BackupManifest.currentVersion, isA<int>());
      expect(BackupManifest.currentVersion, greaterThan(0));
    });
  });

  group('BackupManifest toJson / fromJson 왕복', () {
    test('모든 필드 포함 왕복', () {
      final now = DateTime(2026, 4, 3, 15, 30, 0);
      final manifest = BackupManifest(
        version: BackupManifest.currentVersion,
        createdAt: now,
        appVersion: '2.1.0+42',
        nodeCount: 25,
        memoryCount: 100,
        totalBytes: 1024 * 1024 * 5,
        checksum: 'sha256abc',
        senderNodeId: 'node-uuid-123',
        inviteCode: 'ABC123',
      );

      final json = manifest.toJson();
      final restored = BackupManifest.fromJson(json);

      expect(restored.version, manifest.version);
      expect(restored.createdAt.toIso8601String(), manifest.createdAt.toIso8601String());
      expect(restored.appVersion, '2.1.0+42');
      expect(restored.nodeCount, 25);
      expect(restored.memoryCount, 100);
      expect(restored.totalBytes, 1024 * 1024 * 5);
      expect(restored.checksum, 'sha256abc');
      expect(restored.senderNodeId, 'node-uuid-123');
      expect(restored.inviteCode, 'ABC123');
    });

    test('optional 필드 null → JSON에 키 미포함', () {
      final manifest = BackupManifest(
        version: 1,
        createdAt: DateTime(2026, 1, 1),
        appVersion: '1.0.0',
        nodeCount: 0,
        memoryCount: 0,
        totalBytes: 0,
      );

      final json = manifest.toJson();
      expect(json.containsKey('checksum'), isFalse);
      expect(json.containsKey('sender_node_id'), isFalse);
      expect(json.containsKey('invite_code'), isFalse);
    });

    test('optional 필드 null → fromJson에서 null 복원', () {
      final json = {
        'version': 1,
        'created_at': '2026-01-01T00:00:00.000',
        'app_version': '1.0.0',
        'node_count': 0,
        'memory_count': 0,
        'total_bytes': 0,
      };

      final manifest = BackupManifest.fromJson(json);
      expect(manifest.checksum, isNull);
      expect(manifest.senderNodeId, isNull);
      expect(manifest.inviteCode, isNull);
    });

    test('toJsonString은 유효한 JSON 문자열', () {
      final manifest = BackupManifest(
        version: 1,
        createdAt: DateTime(2026, 6, 15),
        appVersion: '1.2.3+10',
        nodeCount: 3,
        memoryCount: 7,
        totalBytes: 4096,
        senderNodeId: 'sender-1',
      );

      final str = manifest.toJsonString();
      expect(str, contains('"version":1'));
      expect(str, contains('"node_count":3'));
      expect(str, contains('"sender_node_id":"sender-1"'));
      expect(str, isNot(contains('"invite_code"'))); // null이므로 없어야 함
    });
  });

  group('BackupManifest.generateFilename', () {
    test('날짜에 따른 올바른 파일명', () {
      final dt = DateTime(2026, 12, 25, 10, 30, 45);
      expect(BackupManifest.generateFilename(dt), 'ReLink_backup_20261225.rlink');
    });

    test('한 자리 월/일에 0 패딩', () {
      final dt = DateTime(2026, 3, 5);
      expect(BackupManifest.generateFilename(dt), 'ReLink_backup_20260305.rlink');
    });
  });

  group('BackupManifest.generateVersionedFilename', () {
    test('버전 포함 파일명', () {
      final dt = DateTime(2026, 4, 3, 14, 30, 22);
      expect(
        BackupManifest.generateVersionedFilename(dt, 3),
        'backup_v3_20260403_143022.rlink',
      );
    });

    test('시/분/초 한 자리 → 0 패딩', () {
      final dt = DateTime(2026, 1, 2, 3, 4, 5);
      expect(
        BackupManifest.generateVersionedFilename(dt, 10),
        'backup_v10_20260102_030405.rlink',
      );
    });
  });

  // ── BackupInfo ──────────────────────────────────────────────────────────

  group('BackupInfo', () {
    test('필드 접근', () {
      final info = BackupInfo(
        filename: 'test.rlink',
        createdAt: DateTime(2026, 4, 1),
        sizeBytes: 2048,
        nodeCount: 10,
        memoryCount: 50,
        source: 'local',
      );

      expect(info.filename, 'test.rlink');
      expect(info.nodeCount, 10);
      expect(info.memoryCount, 50);
      expect(info.source, 'local');
    });

    test('formattedSize — 작은 파일 (KB)', () {
      final info = BackupInfo(
        filename: 'a.rlink',
        createdAt: DateTime.now(),
        sizeBytes: 100 * 1024, // 100 KB
        nodeCount: 1,
        memoryCount: 1,
        source: 'icloud',
      );
      expect(info.formattedSize, '100.0 KB');
    });

    test('formattedSize — 큰 파일 (MB)', () {
      final info = BackupInfo(
        filename: 'b.rlink',
        createdAt: DateTime.now(),
        sizeBytes: 5 * 1024 * 1024 + 512 * 1024, // 5.5 MB
        nodeCount: 1,
        memoryCount: 1,
        source: 'google',
      );
      expect(info.formattedSize, '5.5 MB');
    });

    test('formattedSize — 정확히 1MB 경계', () {
      final info = BackupInfo(
        filename: 'c.rlink',
        createdAt: DateTime.now(),
        sizeBytes: 1024 * 1024, // 정확히 1MB
        nodeCount: 0,
        memoryCount: 0,
        source: 'local',
      );
      expect(info.formattedSize, '1.0 MB');
    });

    test('formattedSize — 1MB 미만 경계', () {
      final info = BackupInfo(
        filename: 'd.rlink',
        createdAt: DateTime.now(),
        sizeBytes: 1024 * 1024 - 1, // 1MB 바로 아래
        nodeCount: 0,
        memoryCount: 0,
        source: 'local',
      );
      expect(info.formattedSize, contains('KB'));
    });

    test('소스 구분 — icloud / google / local', () {
      for (final src in ['icloud', 'google', 'local']) {
        final info = BackupInfo(
          filename: 'x.rlink',
          createdAt: DateTime.now(),
          sizeBytes: 1024,
          nodeCount: 0,
          memoryCount: 0,
          source: src,
        );
        expect(info.source, src);
      }
    });

    test('BackupInfo 리스트 정렬 (최신순)', () {
      final infos = [
        BackupInfo(
          filename: 'old.rlink',
          createdAt: DateTime(2025, 1, 1),
          sizeBytes: 100,
          nodeCount: 1,
          memoryCount: 1,
          source: 'local',
        ),
        BackupInfo(
          filename: 'new.rlink',
          createdAt: DateTime(2026, 6, 1),
          sizeBytes: 200,
          nodeCount: 2,
          memoryCount: 2,
          source: 'local',
        ),
        BackupInfo(
          filename: 'mid.rlink',
          createdAt: DateTime(2025, 6, 1),
          sizeBytes: 150,
          nodeCount: 1,
          memoryCount: 1,
          source: 'icloud',
        ),
      ];

      infos.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      expect(infos[0].filename, 'new.rlink');
      expect(infos[1].filename, 'mid.rlink');
      expect(infos[2].filename, 'old.rlink');
    });
  });

  // ── BackupVersionEntry ────────────────────────────────────────────────────

  group('BackupVersionEntry', () {
    test('toJson / fromJson 왕복', () {
      const entry = BackupVersionEntry(
        version: 5,
        date: '2026-04-03T10:30:00.000',
        fileName: 'backup_v5_20260403_103000.rlink',
        sizeBytes: 1024 * 1024 * 3,
      );

      final json = entry.toJson();
      final restored = BackupVersionEntry.fromJson(json);

      expect(restored.version, 5);
      expect(restored.date, '2026-04-03T10:30:00.000');
      expect(restored.fileName, 'backup_v5_20260403_103000.rlink');
      expect(restored.sizeBytes, 1024 * 1024 * 3);
    });

    test('dateTime 파싱', () {
      const entry = BackupVersionEntry(
        version: 1,
        date: '2026-04-03T10:30:00.000',
        fileName: 'test.rlink',
        sizeBytes: 100,
      );

      expect(entry.dateTime.year, 2026);
      expect(entry.dateTime.month, 4);
      expect(entry.dateTime.day, 3);
    });

    test('formattedDate 형식', () {
      const entry = BackupVersionEntry(
        version: 1,
        date: '2026-01-05T09:07:00.000',
        fileName: 'test.rlink',
        sizeBytes: 100,
      );

      expect(entry.formattedDate, '2026.01.05 09:07');
    });

    test('formattedSize — KB', () {
      const entry = BackupVersionEntry(
        version: 1,
        date: '2026-01-01T00:00:00.000',
        fileName: 'test.rlink',
        sizeBytes: 512 * 1024,
      );

      expect(entry.formattedSize, '512.0 KB');
    });

    test('formattedSize — MB', () {
      const entry = BackupVersionEntry(
        version: 1,
        date: '2026-01-01T00:00:00.000',
        fileName: 'test.rlink',
        sizeBytes: 3 * 1024 * 1024,
      );

      expect(entry.formattedSize, '3.0 MB');
    });

    test('리스트 정렬 (버전 내림차순)', () {
      final entries = [
        const BackupVersionEntry(version: 1, date: '2026-01-01T00:00:00.000', fileName: 'v1.rlink', sizeBytes: 100),
        const BackupVersionEntry(version: 3, date: '2026-01-03T00:00:00.000', fileName: 'v3.rlink', sizeBytes: 300),
        const BackupVersionEntry(version: 2, date: '2026-01-02T00:00:00.000', fileName: 'v2.rlink', sizeBytes: 200),
      ];

      entries.sort((a, b) => b.version.compareTo(a.version));

      expect(entries[0].version, 3);
      expect(entries[1].version, 2);
      expect(entries[2].version, 1);
    });
  });
}
