import 'dart:io';
import 'package:flutter/painting.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

/// 미디어 파일 경로 유틸리티
///
/// 앱 재설치/업데이트 시 iOS 컨테이너 경로가 바뀔 수 있으므로
/// DB에는 상대 경로만 저장하고, 표시할 때 절대 경로로 복원한다.
class PathUtils {
  static String? _cachedDocPath;

  /// Documents 디렉토리 경로 (캐시)
  static Future<String> get documentsPath async {
    if (_cachedDocPath != null) return _cachedDocPath!;
    final dir = await getApplicationDocumentsDirectory();
    _cachedDocPath = dir.path;
    return _cachedDocPath!;
  }

  /// 동기적으로 캐시된 Documents 경로 반환 (초기화 후 사용)
  /// 초기화 전이면 null 반환
  static String? get cachedDocumentsPath => _cachedDocPath;

  /// 앱 시작 시 한 번 호출하여 Documents 경로 캐시
  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    _cachedDocPath = dir.path;
  }

  /// 절대 경로를 Documents 기준 상대 경로로 변환
  ///
  /// 이미 상대 경로인 경우 그대로 반환
  /// null이면 null 반환
  static String? toRelative(String? absolutePath) {
    if (absolutePath == null) return null;
    if (!absolutePath.startsWith('/')) return absolutePath; // 이미 상대 경로

    final docPath = _cachedDocPath;
    if (docPath != null && absolutePath.startsWith(docPath)) {
      // Documents 경로 제거 + 선행 슬래시 제거
      final relative = absolutePath.substring(docPath.length);
      return relative.startsWith('/') ? relative.substring(1) : relative;
    }

    // Documents 경로가 캐시되지 않았거나, 다른 경로인 경우
    // media/ 이하 경로를 추출 시도
    final mediaIndex = absolutePath.indexOf('media/');
    if (mediaIndex >= 0) {
      return absolutePath.substring(mediaIndex);
    }

    return absolutePath;
  }

  /// 상대 경로를 Documents 기준 절대 경로로 복원
  ///
  /// 이미 절대 경로(레거시)인 경우 그대로 반환
  /// null이면 null 반환
  static String? toAbsolute(String? path) {
    if (path == null) return null;
    if (path.startsWith('/')) return path; // 이미 절대 경로 (레거시)

    final docPath = _cachedDocPath;
    if (docPath == null) return path; // 캐시 미초기화 시 원본 반환

    return p.join(docPath, path);
  }

  /// 비동기 버전: 상대 경로를 절대 경로로 복원
  static Future<String?> toAbsoluteAsync(String? path) async {
    if (path == null) return null;
    if (path.startsWith('/')) return path; // 이미 절대 경로 (레거시)

    final docPath = await documentsPath;
    return p.join(docPath, path);
  }

  /// 파일이 존재하는지 확인 (상대/절대 모두 지원)
  static Future<bool> fileExists(String? path) async {
    if (path == null) return false;
    final absolute = path.startsWith('/') ? path : await toAbsoluteAsync(path);
    if (absolute == null) return false;
    return File(absolute).exists();
  }

  /// photoPath에서 File 객체를 안전하게 생성
  /// 상대 경로면 절대 경로로 변환, 절대 경로(레거시)면 그대로 사용
  static File? resolveFile(String? path) {
    if (path == null) return null;
    final absolute = toAbsolute(path);
    if (absolute == null) return null;
    return File(absolute);
  }

  /// FileImage를 안전하게 생성 (상대/절대 경로 모두 지원)
  static FileImage? resolveFileImage(String? path) {
    final file = resolveFile(path);
    if (file == null) return null;
    return FileImage(file);
  }
}
