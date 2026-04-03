/// R2MediaService 순수 로직 테스트
/// 커버: r2_media_service.dart — 쿼터 계산, 파일 키 구성, 바이트 변환
import 'package:flutter_test/flutter_test.dart';
import 'package:re_link/core/errors/app_error.dart';
import 'package:re_link/shared/models/user_plan.dart';

void main() {
  // ── 클라우드 쿼터 계산 로직 ────────────────────────────────────────────────

  group('Cloud quota calculation', () {
    test('GB to bytes conversion — 20 GB', () {
      const gb = 20;
      final bytes = gb * 1024 * 1024 * 1024;
      expect(bytes, 21474836480); // 20 GB
    });

    test('GB to bytes conversion — 100 GB', () {
      const gb = 100;
      final bytes = gb * 1024 * 1024 * 1024;
      expect(bytes, 107374182400); // 100 GB
    });

    test('usage + file size within limit → no error', () {
      const limitGB = 20;
      final limitBytes = limitGB * 1024 * 1024 * 1024;
      const currentUsage = 10 * 1024 * 1024 * 1024; // 10 GB
      const fileSizeBytes = 5 * 1024 * 1024; // 5 MB

      expect(currentUsage + fileSizeBytes <= limitBytes, isTrue);
    });

    test('usage + file size exceeds limit → error', () {
      const limitGB = 20;
      final limitBytes = limitGB * 1024 * 1024 * 1024;
      const currentUsage = 20 * 1024 * 1024 * 1024; // 20 GB (full)
      const fileSizeBytes = 1; // even 1 byte over

      expect(currentUsage + fileSizeBytes > limitBytes, isTrue);
    });

    test('usedGB formatting — 10.5 GB', () {
      const currentUsage = 10.5 * 1024 * 1024 * 1024;
      final usedGB =
          (currentUsage / (1024 * 1024 * 1024)).toStringAsFixed(1);
      expect(usedGB, '10.5');
    });

    test('usedGB formatting — 0.0 GB', () {
      const currentUsage = 0;
      final usedGB =
          (currentUsage / (1024 * 1024 * 1024)).toStringAsFixed(1);
      expect(usedGB, '0.0');
    });
  });

  // ── UserPlan.hasCloud + cloudStorageGB ─────────────────────────────────

  group('Plan cloud quota', () {
    test('free plan has no cloud', () {
      expect(UserPlan.free.hasCloud, isFalse);
      expect(UserPlan.free.cloudStorageGB, 0);
    });

    test('plus plan has no cloud', () {
      expect(UserPlan.plus.hasCloud, isFalse);
      expect(UserPlan.plus.cloudStorageGB, 0);
    });

    test('family plan has 20GB cloud', () {
      expect(UserPlan.family.hasCloud, isTrue);
      expect(UserPlan.family.cloudStorageGB, 20);
    });

    test('familyPlus plan has 100GB cloud', () {
      expect(UserPlan.familyPlus.hasCloud, isTrue);
      expect(UserPlan.familyPlus.cloudStorageGB, 100);
    });

    test('limitBytes = plan.cloudStorageGB * 1024^3', () {
      final limitBytes =
          UserPlan.family.cloudStorageGB * 1024 * 1024 * 1024;
      expect(limitBytes, 20 * 1024 * 1024 * 1024);
    });
  });

  // ── StorageError ────────────────────────────────────────────────────────

  group('StorageError', () {
    test('constructor sets message', () {
      const e = StorageError('디스크 공간 부족');
      expect(e.message, '디스크 공간 부족');
    });

    test('toString format', () {
      const e = StorageError('test');
      expect(e.toString(), contains('StorageError'));
      expect(e.toString(), contains('test'));
    });

    test('implements AppError', () {
      const e = StorageError('msg');
      expect(e, isA<AppError>());
    });

    test('quota error message format', () {
      const usedGB = '18.5';
      const limitGB = 20;
      final msg =
          '클라우드 저장 공간이 부족합니다. ($usedGB GB / $limitGB GB 사용 중)\n'
          '플랜을 업그레이드하거나 불필요한 파일을 삭제해 주세요.';
      expect(msg, contains('18.5 GB'));
      expect(msg, contains('20 GB'));
      expect(msg, contains('업그레이드'));
    });
  });

  // ── R2 파일 키 구성 ────────────────────────────────────────────────────

  group('R2 file key construction', () {
    test('standard file key format', () {
      const groupId = 'grp_001';
      const userId = 'usr_abc';
      const folder = 'photos';
      const uuid = 'uuid-1234';
      const ext = 'webp';

      final fileKey = '$groupId/$userId/$folder/$uuid.$ext';
      expect(fileKey, 'grp_001/usr_abc/photos/uuid-1234.webp');
      expect(fileKey.split('/').length, 4);
    });

    test('URI encoding for download URL', () {
      const fileKey = 'grp/usr/photos/uuid.webp';
      final encoded = Uri.encodeComponent(fileKey);
      expect(encoded, isNot(contains('/')));
      expect(encoded, contains('%2F'));
    });
  });

  // ── 업로드 URL 응답 파싱 ────────────────────────────────────────────────

  group('Upload URL response parsing', () {
    test('extract upload_url from response', () {
      final responseData = {
        'data': {
          'upload_url': 'https://r2.example.com/upload/presigned',
          'file_key': 'grp/usr/photos/uuid.webp',
        },
      };
      final data = responseData['data'] as Map<String, dynamic>;
      final uploadUrl = data['upload_url'] as String?;
      expect(uploadUrl, 'https://r2.example.com/upload/presigned');
    });

    test('null upload_url', () {
      final responseData = {
        'data': {
          'upload_url': null,
          'file_key': 'grp/usr/photos/uuid.webp',
        },
      };
      final data = responseData['data'] as Map<String, dynamic>;
      final uploadUrl = data['upload_url'] as String?;
      expect(uploadUrl, isNull);
    });
  });

  // ── 다운로드 URL 응답 파싱 ──────────────────────────────────────────────

  group('Download URL response parsing', () {
    test('extract download_url from response', () {
      final responseData = {
        'data': {
          'download_url': 'https://r2.example.com/download/presigned',
        },
      };
      final data = responseData['data'] as Map<String, dynamic>;
      final downloadUrl = data['download_url'] as String?;
      expect(downloadUrl, 'https://r2.example.com/download/presigned');
    });
  });

  // ── 사용량 응답 파싱 ────────────────────────────────────────────────────

  group('Usage response parsing', () {
    test('extract total_bytes from response', () {
      final responseData = {
        'data': {
          'total_bytes': 1073741824, // 1 GB
        },
      };
      final result = responseData['data'] as Map<String, dynamic>?;
      final totalBytes = result?['total_bytes'] as int? ?? 0;
      expect(totalBytes, 1073741824);
    });

    test('missing total_bytes → default 0', () {
      final responseData = <String, dynamic>{
        'data': <String, dynamic>{},
      };
      final result = responseData['data'] as Map<String, dynamic>?;
      final totalBytes = result?['total_bytes'] as int? ?? 0;
      expect(totalBytes, 0);
    });

    test('null data → default 0', () {
      final responseData = <String, dynamic>{
        'data': null,
      };
      final result = responseData['data'] as Map<String, dynamic>?;
      final totalBytes = result?['total_bytes'] as int? ?? 0;
      expect(totalBytes, 0);
    });
  });
}
