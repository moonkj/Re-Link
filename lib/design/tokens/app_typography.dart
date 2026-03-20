import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Re-Link 타이포그래피 토큰
/// 디자인 문서 4.4:
///   Display — Noto Serif KR (T1: 40sp Bold)
///   Heading — Pretendard  (T2: 28sp Bold, T3: 22sp SemiBold)
///   Body    — Pretendard  (T4: 17sp Medium, T5: 15sp Regular)
///   Caption — Pretendard  (T6: 12sp Regular)
///   Code    — JetBrains Mono
abstract final class AppTypography {
  static const String _pretendard = 'Pretendard';
  static const String _monospace = '.SF Mono';

  /// Noto Serif KR — Google Fonts 런타임 로드 (CJK 폰트 24MB 번들 방지)
  static String get _notoSerifKR => GoogleFonts.notoSerifKr().fontFamily ?? 'Pretendard';

  // ══════════════════════════════════════════════════════════════════════════
  // ── T1 — Display (Noto Serif KR) ─────────────────────────────────────────
  // ══════════════════════════════════════════════════════════════════════════
  static TextStyle get t1 => TextStyle(
    fontFamily: _notoSerifKR,
    fontSize: 40,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.3,
    color: AppColors.textPrimary,
  );

  // ══════════════════════════════════════════════════════════════════════════
  // ── T2 — Heading Large (Pretendard) ──────────────────────────────────────
  // ══════════════════════════════════════════════════════════════════════════
  static final TextStyle t2 = TextStyle(
    fontFamily: _pretendard,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.25,
    height: 1.35,
    color: AppColors.textPrimary,
  );

  // ══════════════════════════════════════════════════════════════════════════
  // ── T3 — Heading Small (Pretendard) ──────────────────────────────────────
  // ══════════════════════════════════════════════════════════════════════════
  static final TextStyle t3 = TextStyle(
    fontFamily: _pretendard,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.4,
    color: AppColors.textPrimary,
  );

  // ══════════════════════════════════════════════════════════════════════════
  // ── T4 — Body Large (Pretendard) ─────────────────────────────────────────
  // ══════════════════════════════════════════════════════════════════════════
  static final TextStyle t4 = TextStyle(
    fontFamily: _pretendard,
    fontSize: 17,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    height: 1.5,
    color: AppColors.textPrimary,
  );

  // ══════════════════════════════════════════════════════════════════════════
  // ── T5 — Body Regular (Pretendard) ───────────────────────────────────────
  // ══════════════════════════════════════════════════════════════════════════
  static final TextStyle t5 = TextStyle(
    fontFamily: _pretendard,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.5,
    color: AppColors.textPrimary,
  );

  // ══════════════════════════════════════════════════════════════════════════
  // ── T6 — Caption (Pretendard) ────────────────────────────────────────────
  // ══════════════════════════════════════════════════════════════════════════
  static final TextStyle t6 = TextStyle(
    fontFamily: _pretendard,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.2,
    height: 1.4,
    color: AppColors.textSecondary,
  );

  // ══════════════════════════════════════════════════════════════════════════
  // ── Code (JetBrains Mono) ────────────────────────────────────────────────
  // ══════════════════════════════════════════════════════════════════════════
  static final TextStyle code = TextStyle(
    fontFamily: _monospace,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.5,
    color: AppColors.textPrimary,
  );

  // ══════════════════════════════════════════════════════════════════════════
  // ── Material Design 매핑 (ThemeData 호환) ────────────────────────────────
  // ══════════════════════════════════════════════════════════════════════════

  // Display
  static TextStyle get displayLarge => t1;
  static TextStyle get displayMedium => TextStyle(
    fontFamily: _notoSerifKR,
    fontSize: 34,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.25,
    color: AppColors.textPrimary,
  );
  static TextStyle get displaySmall => TextStyle(
    fontFamily: _notoSerifKR,
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    color: AppColors.textPrimary,
  );

  // Headline
  static TextStyle get headlineLarge => t2;
  static final TextStyle headlineMedium = TextStyle(
    fontFamily: _pretendard,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    color: AppColors.textPrimary,
  );
  static final TextStyle headlineSmall = t3;

  // Title
  static final TextStyle titleLarge = t3;
  static final TextStyle titleMedium = TextStyle(
    fontFamily: _pretendard,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    color: AppColors.textPrimary,
  );
  static final TextStyle titleSmall = TextStyle(
    fontFamily: _pretendard,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    color: AppColors.textPrimary,
  );

  // Body
  static final TextStyle bodyLarge = t4;
  static final TextStyle bodyMedium = t5;
  static final TextStyle bodySmall = t6;

  // Label
  static final TextStyle labelLarge = TextStyle(
    fontFamily: _pretendard,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    color: AppColors.textPrimary,
  );
  static final TextStyle labelMedium = TextStyle(
    fontFamily: _pretendard,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    color: AppColors.textPrimary,
  );
  static final TextStyle labelSmall = TextStyle(
    fontFamily: _pretendard,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    color: AppColors.textSecondary,
  );
}
