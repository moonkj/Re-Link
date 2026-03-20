import 'dart:ui';

/// 족보 노드 자동 배치 서비스
///
/// 4000x4000 캔버스 위에 세대별로 노드를 정렬합니다.
/// - 세대 1(가장 위) → 세대 N(가장 아래)
/// - 같은 세대 내에서 수평 중앙 정렬
class JokboLayoutService {
  JokboLayoutService._();

  static const double generationSpacing = 200.0;
  static const double nodeSpacing = 180.0;
  static const Offset center = Offset(2000, 2000);

  /// 세대별 노드 ID 맵을 받아 캔버스 위치를 계산합니다.
  ///
  /// [generations] key: 세대 번호(1=최고 조상), value: 해당 세대의 tempId 목록
  /// 반환: Map<tempId, Offset> — 각 노드의 캔버스 좌표
  static Map<String, Offset> calculateLayout(
      Map<int, List<String>> generations) {
    final result = <String, Offset>{};
    if (generations.isEmpty) return result;

    final totalGens = generations.length;

    for (final entry in generations.entries) {
      final gen = entry.key;
      final ids = entry.value;
      if (ids.isEmpty) continue;

      // 세대 간 수직 배치: 중앙 기준으로 위아래 분산
      final y = center.dy - (totalGens / 2 - gen + 1) * generationSpacing;

      // 같은 세대 내 수평 배치: 중앙 기준으로 좌우 분산
      final startX = center.dx - (ids.length - 1) / 2 * nodeSpacing;

      for (int i = 0; i < ids.length; i++) {
        result[ids[i]] = Offset(
          (startX + i * nodeSpacing).clamp(100.0, 3900.0),
          y.clamp(100.0, 3900.0),
        );
      }
    }

    return result;
  }
}
