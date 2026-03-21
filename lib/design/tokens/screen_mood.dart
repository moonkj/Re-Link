import 'package:flutter/material.dart';
import 'app_colors.dart';

/// 화면별 무드 컬러 시스템 — Z세대 다이나믹 UI
enum ScreenMood {
  canvas,    // 홈/캔버스 — 연결/관계
  memories,  // 기억 — 따뜻함/향수
  family,    // 가족 — 유대/함께
  explore,   // 탐색 — 발견/호기심
  settings,  // 설정 — 차분/기능적
}

/// ScreenMood별 컬러 토큰
abstract final class MoodColors {
  /// 무드별 그라디언트 (버튼, FAB, 인디케이터 등)
  static List<Color> gradient(ScreenMood mood) {
    if (AppColors.isDark) {
      return switch (mood) {
        ScreenMood.canvas   => [const Color(0xFFA78BFA), const Color(0xFF22D3EE)], // Violet→Cyan
        ScreenMood.memories => [const Color(0xFFFB7185), const Color(0xFFF472B6)], // Rose→Pink
        ScreenMood.family   => [const Color(0xFF8B5CF6), const Color(0xFF6366F1)], // Purple→Indigo
        ScreenMood.explore  => [const Color(0xFFFBBF24), const Color(0xFFF97316)], // Amber→Orange
        ScreenMood.settings => [const Color(0xFF64748B), const Color(0xFF475569)], // Slate→Cool Gray
      };
    } else {
      return switch (mood) {
        ScreenMood.canvas   => [const Color(0xFF7C3AED), const Color(0xFF0891B2)], // Violet-600→Cyan-600
        ScreenMood.memories => [const Color(0xFFE11D48), const Color(0xFFDB2777)], // Rose-600→Pink-600
        ScreenMood.family   => [const Color(0xFF7C3AED), const Color(0xFF4F46E5)], // Violet-600→Indigo-600
        ScreenMood.explore  => [const Color(0xFFD97706), const Color(0xFFEA580C)], // Amber-600→Orange-600
        ScreenMood.settings => [const Color(0xFF475569), const Color(0xFF334155)], // Slate-600→Slate-700
      };
    }
  }

  /// 무드별 메인 액센트 컬러 (아이콘, 텍스트 하이라이트)
  static Color accent(ScreenMood mood) => gradient(mood).first;

  /// 배경 틴트용 (5% opacity RadialGradient 상단에 적용)
  static Color bgTint(ScreenMood mood) {
    final base = accent(mood);
    return base.withAlpha(AppColors.isDark ? 18 : 13); // ~7% / ~5%
  }

  /// 네비 인디케이터 필 (20% opacity gradient)
  static List<Color> indicatorGradient(ScreenMood mood) {
    final colors = gradient(mood);
    return [colors[0].withAlpha(51), colors[1].withAlpha(31)]; // 20% / 12%
  }

  /// 네비 인디케이터 테두리
  static Color indicatorBorder(ScreenMood mood) {
    return accent(mood).withAlpha(77); // 30%
  }

  /// 네비 인디케이터 그림자 (neutral)
  static Color indicatorGlow(ScreenMood mood) {
    return const Color(0x20000000); // neutral shadow
  }

  /// 탭 인덱스 → ScreenMood 매핑
  static ScreenMood fromTabIndex(int index) => switch (index) {
    0 => ScreenMood.canvas,
    1 => ScreenMood.memories,
    2 => ScreenMood.family,
    3 => ScreenMood.explore,
    4 => ScreenMood.settings,
    _ => ScreenMood.canvas,
  };
}
