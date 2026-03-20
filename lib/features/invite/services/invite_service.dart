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
}
