import 'package:flutter/material.dart';

/// Re-Link 디자인 시스템 색상 토큰
/// Chapter 04 — Day/Night Palette + Vibe Meter
/// brightness-aware: bgBase/textPrimary 등은 글로벌 밝기에 따라 자동 전환
abstract final class AppColors {
  // ══════════════════════════════════════════════════════════════════════════
  // ── 글로벌 밝기 상태 ─────────────────────────────────────────────────────
  // ══════════════════════════════════════════════════════════════════════════

  static Brightness _brightness = Brightness.dark;

  /// app.dart에서 매 빌드 시 호출하여 밝기 동기화
  static void updateBrightness(Brightness b) => _brightness = b;

  static bool get isDark => _brightness == Brightness.dark;

  // ══════════════════════════════════════════════════════════════════════════
  // ── Day Palette (Light Mode) ──────────────────────────────────────────────
  // ══════════════════════════════════════════════════════════════════════════

  // Brand — Primary
  static const Color primaryMint = Color(0xFF6EC6CA);   // Primary Mint
  static const Color primaryBlue = Color(0xFF4A9EBF);   // Primary Blue

  // Brand — Accent
  static const Color accentMint = Color(0xFF5BBFBE);    // Accent Mint
  static const Color accentWarm = Color(0xFFF4845F);    // Accent Warm (Coral)

  // Day Background
  static const Color dayBg = Color(0xFFF5F7FA);         // 배경
  static const Color daySurface = Color(0xFFFFFFFF);     // 카드 표면
  static const Color dayElevated = Color(0xFFF0F2F5);    // 상승 표면
  static const Color dayTextPrimary = Color(0xFF1A1A2E); // 텍스트
  static const Color dayTextSecondary = Color(0xFF6B7280);
  static const Color dayTextTertiary = Color(0xFF9CA3AF);
  static const Color dayTextDisabled = Color(0xFFD1D5DB);

  // Day Glass
  static const Color dayGlassSurface = Color(0x1A000000); // 10% 검
  static const Color dayGlassBorder = Color(0x20000000);  // 12% 검

  // ══════════════════════════════════════════════════════════════════════════
  // ── Night Palette (Dark Mode) ─────────────────────────────────────────────
  // ══════════════════════════════════════════════════════════════════════════

  static const Color nightBg = Color(0xFF0D1117);        // 최심층 배경
  static const Color nightSurface = Color(0xFF1E2840);   // 카드 배경
  static const Color nightElevated = Color(0xFF253350);   // 상승 표면
  static const Color nightNavy = Color(0xFF2D6B8A);      // Navy
  static const Color nightViolet = Color(0xFF3B4D8B);    // Violet
  static const Color nightMintBright = Color(0xFF64D4D4); // Mint Bright
  static const Color nightCoral = Color(0xFFFF9970);      // Coral
  static const Color nightTextPrimary = Color(0xFFFFFFFF);
  static const Color nightTextSecondary = Color(0xB3FFFFFF); // 70%

  // Night Glass
  static const Color nightGlassSurface = Color(0x1AFFFFFF); // 10% 흰
  static const Color nightGlassBorder = Color(0x33FFFFFF);   // 20% 흰

  // ══════════════════════════════════════════════════════════════════════════
  // ── Shared Aliases (밝기 적응형) ──────────────────────────────────────────
  // ══════════════════════════════════════════════════════════════════════════

  /// primary — 앱 전반에서 사용되는 메인 색상 (밝기 불변)
  static const Color primary = primaryMint;
  static const Color secondary = primaryBlue;
  static const Color accent = accentWarm;

  // ── Primary Shades (Mint 기반) ──────────────────────────────────────────
  static const Color primary50 = Color(0xFFE8F7F8);
  static const Color primary100 = Color(0xFFC5ECEE);
  static const Color primary200 = Color(0xFF9FE0E3);
  static const Color primary300 = Color(0xFF79D3D7);
  static const Color primary400 = Color(0xFF6EC6CA);
  static const Color primary500 = Color(0xFF5AB8BC);
  static const Color primary600 = Color(0xFF4A9EBF);
  static const Color primary700 = Color(0xFF3D8AA8);
  static const Color primary800 = Color(0xFF2D6B8A);
  static const Color primary900 = Color(0xFF1A4D6B);

  // ── Background (밝기 적응형) ────────────────────────────────────────────
  static Color get bgBase => isDark ? nightBg : dayBg;
  static Color get bgSurface => isDark ? nightSurface : daySurface;
  static Color get bgElevated => isDark ? nightElevated : dayElevated;

  // ── Glass (밝기 적응형) ─────────────────────────────────────────────────
  static Color get glassSurface => isDark ? nightGlassSurface : dayGlassSurface;
  static Color get glassBorder => isDark ? nightGlassBorder : dayGlassBorder;
  static const Color glassHighlight = Color(0x0DFFFFFF); // 5% 흰
  static const Color glassDark = Color(0x1A000000);      // 10% 검

  // ══════════════════════════════════════════════════════════════════════════
  // ── Temperature / Vibe Meter (디자인 문서 4.3) ────────────────────────────
  // ══════════════════════════════════════════════════════════════════════════
  static const Color tempIcy = Color(0xFF6B9FCC);        // Cold (냉담)
  static const Color tempCool = Color(0xFF5BBFBE);       // Cool (쌀쌀)
  static const Color tempNeutral = Color(0xFF7BC67A);    // Neutral (보통)
  static const Color tempWarm = Color(0xFFF4C05A);       // Warm (따뜻)
  static const Color tempHot = Color(0xFFF4845F);        // Hot (뜨거움)
  static const Color tempFire = Color(0xFFE8525A);       // Burning (열정)

  static Color tempColor(int level) {
    return switch (level) {
      0 => tempIcy,
      1 => tempCool,
      2 => tempNeutral,
      3 => tempWarm,
      4 => tempHot,
      5 => tempFire,
      _ => tempNeutral,
    };
  }

  // ── Semantic ──────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF52C77A);
  static const Color warning = Color(0xFFF4C05A);
  static const Color error = Color(0xFFFF6B6B);
  static const Color info = Color(0xFF4A9EBF);

  // ── Text (밝기 적응형) ──────────────────────────────────────────────────
  static Color get textPrimary => isDark ? nightTextPrimary : dayTextPrimary;
  static Color get textSecondary => isDark
      ? const Color(0xB3FFFFFF)
      : dayTextSecondary;
  static Color get textTertiary => isDark
      ? const Color(0x80FFFFFF)
      : dayTextTertiary;
  static Color get textDisabled => isDark
      ? const Color(0x4DFFFFFF)
      : dayTextDisabled;
  static Color get textInverse => isDark
      ? const Color(0xFF0D1117)
      : const Color(0xFFFFFFFF);

  // ── Node ──────────────────────────────────────────────────────────────────
  static const Color nodeDefault = primaryMint;
  static Color get nodeGhost => isDark
      ? const Color(0x4DFFFFFF)
      : const Color(0x4D000000);
  static Color get nodeBorderGhost => isDark
      ? const Color(0x80FFFFFF)
      : const Color(0x40000000);
  static const Color nodeSelected = Color(0xFFFFD700);    // 선택된 노드

  // ── Edge (관계선) ─────────────────────────────────────────────────────────
  static const Color edgeParent = primaryBlue;
  static const Color edgeSpouse = accentWarm;
  static const Color edgeSibling = primaryMint;
  static Color get edgeOther => isDark
      ? const Color(0x61FFFFFF)
      : const Color(0x61000000);

  // ── Plan ─────────────────────────────────────────────────────────────────
  static const Color planFree = Color(0xFF78909C);
  static const Color planBasic = primaryBlue;
  static const Color planPremium = Color(0xFFFFD700);
}
