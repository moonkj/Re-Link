import 'dart:math';

/// 가족 초대 코드 생성 서비스
class InviteService {
  /// 혼동 방지를 위해 0/O/1/I 제외
  static const _chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

  /// 6자리 영숫자 초대 코드 생성
  static String generateCode() {
    final random = Random.secure();
    return List.generate(6, (_) => _chars[random.nextInt(_chars.length)]).join();
  }

  /// 코드를 "ABC-DEF" 형식으로 포맷
  static String formatCode(String code) {
    if (code.length != 6) return code;
    return '${code.substring(0, 3)}-${code.substring(3)}';
  }

  /// 딥링크 URI에서 초대 코드를 추출
  ///
  /// 지원 형식:
  /// - `relink://invite/{code}`
  /// - `relink://invite/{ABC-DEF}` (하이픈 포함)
  ///
  /// 유효하지 않은 URI나 코드가 없는 경우 null 반환
  static String? parseDeepLink(Uri uri) {
    // 스킴 확인
    if (uri.scheme != 'relink') return null;

    // 경로 확인: invite/{code}
    if (uri.host != 'invite') return null;

    // 경로에서 코드 추출
    final segments = uri.pathSegments;
    if (segments.isEmpty) return null;

    // 하이픈 제거 후 코드 정규화
    final rawCode = segments.first.replaceAll('-', '').toUpperCase().trim();

    // 6자리 영숫자 검증
    if (rawCode.length != 6) return null;
    final validPattern = RegExp(r'^[A-Z0-9]{6}$');
    if (!validPattern.hasMatch(rawCode)) return null;

    return rawCode;
  }

  /// 딥링크 문자열에서 초대 코드를 추출 (편의 메서드)
  static String? parseDeepLinkString(String url) {
    try {
      return parseDeepLink(Uri.parse(url));
    } catch (_) {
      return null;
    }
  }
}
