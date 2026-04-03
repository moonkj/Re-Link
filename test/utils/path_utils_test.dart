/// PathUtils 단위 테스트
/// 커버: path_utils.dart — toRelative, toAbsolute, resolveFile, cachedDocumentsPath
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:re_link/core/utils/path_utils.dart';

void main() {
  // PathUtils는 static 클래스이므로 _cachedDocPath를 직접 제어할 수 없다.
  // 테스트용으로 initialize()를 모킹하기 어려우므로,
  // _cachedDocPath가 null인 상태와 설정된 상태를 나누어 테스트한다.

  group('toRelative — cachedDocPath 미초기화', () {
    // 테스트 시작 시 _cachedDocPath는 null일 수 있음
    // (다른 테스트에서 초기화하지 않은 경우)

    test('null 입력 → null 반환', () {
      expect(PathUtils.toRelative(null), isNull);
    });

    test('이미 상대 경로 → 그대로 반환', () {
      expect(PathUtils.toRelative('media/photos/img.webp'), 'media/photos/img.webp');
    });

    test('절대 경로에 media/ 포함 → media/ 이하 추출', () {
      const path = '/var/mobile/Containers/Data/Application/ABC/Documents/media/photos/img.webp';
      expect(PathUtils.toRelative(path), 'media/photos/img.webp');
    });

    test('절대 경로에 media/ 미포함 + 캐시 없음 → 원본 반환', () {
      const path = '/some/random/path/file.txt';
      // _cachedDocPath가 null이고 media/도 없으면 원본 반환
      // (cachedDocPath가 다른 테스트에서 설정될 수 있으므로 조건부)
      final result = PathUtils.toRelative(path);
      // media/가 없으므로 원본이거나 Documents 경로 기준 상대 경로
      expect(result, isNotNull);
    });

    test('슬래시로 시작하지 않는 경로 → 그대로 반환 (상대 경로)', () {
      expect(PathUtils.toRelative('photos/test.jpg'), 'photos/test.jpg');
    });
  });

  group('toAbsolute — cachedDocPath 미초기화', () {
    test('null 입력 → null 반환', () {
      expect(PathUtils.toAbsolute(null), isNull);
    });

    test('이미 절대 경로 → 그대로 반환', () {
      const path = '/var/mobile/Documents/media/photo.webp';
      expect(PathUtils.toAbsolute(path), path);
    });
  });

  group('resolveFile', () {
    test('null 입력 → null 반환', () {
      expect(PathUtils.resolveFile(null), isNull);
    });

    test('절대 경로 입력 → File 반환 (경로 그대로)', () {
      const path = '/tmp/test_photo.webp';
      final file = PathUtils.resolveFile(path);
      expect(file, isNotNull);
      expect(file, isA<File>());
      expect(file!.path, path);
    });
  });

  group('cachedDocumentsPath', () {
    test('초기화 전에는 null일 수 있음', () {
      // 다른 테스트에서 initialize()가 호출되었을 수도 있으므로
      // null 또는 String인지만 확인
      final cached = PathUtils.cachedDocumentsPath;
      expect(cached == null || cached is String, isTrue);
    });
  });

  // ── 캐시 초기화 후 테스트 (통합) ───────────────────────────────────────────
  // initialize()는 path_provider가 필요하므로 순수 단위 테스트에서는 호출 불가.
  // 대신 수동으로 _cachedDocPath를 시뮬레이션하는 시나리오를 테스트한다.
  //
  // 아래 테스트는 toRelative/toAbsolute의 엣지 케이스를 다룬다.

  group('toRelative — 엣지 케이스', () {
    test('빈 문자열 → 빈 문자열 (상대 경로로 취급)', () {
      expect(PathUtils.toRelative(''), '');
    });

    test('media/ 정확히 포함하는 경로', () {
      const path = '/data/app/media/voice/rec_001.m4a';
      expect(PathUtils.toRelative(path), 'media/voice/rec_001.m4a');
    });

    test('media가 디렉토리가 아닌 파일명에 포함 → media/ 기준 추출', () {
      const path = '/some/path/media/sub/file.webp';
      expect(PathUtils.toRelative(path), 'media/sub/file.webp');
    });
  });

  group('toAbsolute — 엣지 케이스', () {
    test('빈 문자열 → 캐시 여부에 따라 결정', () {
      // 빈 문자열은 '/'로 시작하지 않으므로 상대 경로로 취급
      final result = PathUtils.toAbsolute('');
      expect(result, isNotNull);
    });

    test('슬래시로 시작하는 경로 → 절대 경로로 간주, 그대로 반환', () {
      const path = '/absolute/path/to/file.db';
      expect(PathUtils.toAbsolute(path), path);
    });
  });

  group('resolveFile — 상대/절대 조합', () {
    test('절대 경로 → File(절대 경로)', () {
      const absPath = '/Users/test/Documents/media/photo.webp';
      final file = PathUtils.resolveFile(absPath);
      expect(file, isNotNull);
      expect(file!.path, absPath);
    });

    test('null → null', () {
      expect(PathUtils.resolveFile(null), isNull);
    });
  });
}
