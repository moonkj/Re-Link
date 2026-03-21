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

  // Brand — Primary (Violet)
  static const Color primaryMint = Color(0xFF8B5CF6);   // Violet-500 (dark mode primary, 선명)
  static const Color primaryBlue = Color(0xFF06B6D4);   // Cyan-500 (secondary, 선명)

  // Brand — Accent
  static const Color accentMint = Color(0xFF06B6D4);    // Cyan-500
  static const Color accentWarm = Color(0xFFF43F5E);    // Rose-500 (선명)

  // Day Background
  static const Color dayBg = Color(0xFFF8FAFC);         // 배경
  static const Color daySurface = Color(0xFFFFFFFF);     // 카드 표면
  static const Color dayElevated = Color(0xFFF1F5F9);    // 상승 표면
  static const Color dayTextPrimary = Color(0xFF0F172A); // deep slate 텍스트
  static const Color dayTextSecondary = Color(0xFF475569); // medium slate
  static const Color dayTextTertiary = Color(0xFF94A3B8);  // light slate
  static const Color dayTextDisabled = Color(0xFFCBD5E1);  // very light slate

  // Day Glass — solid (no transparency)
  static const Color dayGlassSurface = Color(0xFFFFFFFF); // SOLID white
  static const Color dayGlassBorder = Color(0x1A000000);  // 10% black border

  // ══════════════════════════════════════════════════════════════════════════
  // ── Night Palette (Dark Mode) ─────────────────────────────────────────────
  // ══════════════════════════════════════════════════════════════════════════

  static const Color nightBg = Color(0xFF0F0F1A);        // deep indigo-black 최심층 배경
  static const Color nightSurface = Color(0xFF1E2040);   // dark indigo 카드 배경
  static const Color nightElevated = Color(0xFF2C2D52);   // medium indigo 상승 표면
  static const Color nightNavy = Color(0xFF2C2D52);      // Navy (matches elevated)
  static const Color nightViolet = Color(0xFF8B5CF6);    // Violet-500
  static const Color nightMintBright = Color(0xFF06B6D4); // Cyan-500
  static const Color nightCoral = Color(0xFFF43F5E);      // Rose-500
  static const Color nightTextPrimary = Color(0xFFF8FAFC); // slightly warm white
  static const Color nightTextSecondary = Color(0xB3F8FAFC); // 70% warm white

  // Night Glass — solid (no transparency)
  static const Color nightGlassSurface = Color(0xFF1E2040); // SOLID nightSurface
  static const Color nightGlassBorder = Color(0x33FFFFFF);   // 20% white border

  // ══════════════════════════════════════════════════════════════════════════
  // ── Shared Aliases (밝기 적응형) ──────────────────────────────────────────
  // ══════════════════════════════════════════════════════════════════════════

  /// primary — 앱 전반에서 사용되는 메인 색상 (밝기 적응형)
  /// Light: primary800 (#7C3AED) Violet-600 — WCAG AA on white
  /// Dark:  primaryMint (#A78BFA) Violet-400
  static Color get primary => isDark ? primaryMint : primary800;
  static Color get secondary => isDark ? primaryBlue : primary900;
  static const Color accent = accentWarm;

  // ── Primary Shades (Violet 기반) ─────────────────────────────────────────
  static const Color primary50 = Color(0xFFF5F3FF);
  static const Color primary100 = Color(0xFFEDE9FE);
  static const Color primary200 = Color(0xFFDDD6FE);
  static const Color primary300 = Color(0xFFC4B5FD);
  static const Color primary400 = Color(0xFFA78BFA);
  static const Color primary500 = Color(0xFF8B5CF6);
  static const Color primary600 = Color(0xFF7C3AED);
  static const Color primary700 = Color(0xFF6D28D9);
  static const Color primary800 = Color(0xFF6D28D9);   // Violet-700 for light mode (더 선명)
  static const Color primary900 = Color(0xFF0E7490);   // Cyan-700 for light mode secondary

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
  static const Color tempIcy = Color(0xFF38BDF8);        // Sky-400 (냉담)
  static const Color tempCool = Color(0xFF34D399);       // Emerald-400 (쌀쌀)
  static const Color tempNeutral = Color(0xFFFBBF24);    // Amber-400 (보통)
  static const Color tempWarm = Color(0xFFFB923C);       // Orange-400 (따뜻)
  static const Color tempHot = Color(0xFFF43F5E);        // Rose-500 (뜨거움)
  static const Color tempFire = Color(0xFFEF4444);       // Red-500 (열정)

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
  static const Color success = Color(0xFF10B981);   // Emerald-500 (선명)
  static const Color warning = Color(0xFFF59E0B);   // Amber-500 (선명)
  static const Color error = Color(0xFFE11D48);     // Rose-600 (선명)
  static const Color info = Color(0xFF06B6D4);      // Cyan-500

  // ── Text (밝기 적응형) ──────────────────────────────────────────────────
  static Color get textPrimary => isDark ? nightTextPrimary : dayTextPrimary;
  static Color get textSecondary => isDark
      ? const Color(0xB3F8FAFC)
      : dayTextSecondary;
  static Color get textTertiary => isDark
      ? const Color(0x80F8FAFC)
      : dayTextTertiary;
  static Color get textDisabled => isDark
      ? const Color(0x4DF8FAFC)
      : dayTextDisabled;
  static Color get textInverse => isDark
      ? const Color(0xFF0F0F1A)
      : const Color(0xFFF8FAFC);

  /// primary 컬러 배경 위 텍스트/아이콘 (버튼, 아바타 등)
  static Color get onPrimary => isDark
      ? const Color(0xFFF8FAFC)
      : const Color(0xFFFFFFFF);

  // ── Node ──────────────────────────────────────────────────────────────────
  static const Color nodeDefault = primaryMint;
  static Color get nodeGhost => isDark
      ? const Color(0x4DFFFFFF)
      : const Color(0x4D000000);
  static Color get nodeBorderGhost => isDark
      ? const Color(0x80FFFFFF)
      : const Color(0x40000000);
  static const Color nodeSelected = Color(0xFFFBBF24);    // Amber-400 선택된 노드

  // ── Edge (관계선) ─────────────────────────────────────────────────────────
  static const Color edgeParent = primaryBlue;     // Cyan-500
  static const Color edgeSpouse = accentWarm;      // Rose-500
  static const Color edgeSibling = primaryMint;    // Violet-500
  static Color get edgeOther => isDark
      ? const Color(0x61FFFFFF)
      : const Color(0x61000000);

  // ── Plan ─────────────────────────────────────────────────────────────────
  static const Color planFree = Color(0xFF64748B);        // Slate-500
  static const Color planPlus = primaryMint;               // Violet-500 (primary)
  static const Color planFamily = Color(0xFF7C3AED);       // Violet-600
  static const Color planFamilyPlus = Color(0xFFF59E0B);   // Amber-500 Gold
}
