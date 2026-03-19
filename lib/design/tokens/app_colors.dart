import 'package:flutter/material.dart';

/// Re-Link 디자인 시스템 색상 토큰
/// Liquid Glass + Glassmorphism 2.0 기반
abstract final class AppColors {
  // ── Brand ────────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF6C63FF);    // 보라
  static const Color secondary = Color(0xFF48CAE4);  // 청록
  static const Color accent = Color(0xFFFF6B6B);     // 산호

  // ── Primary Shades ────────────────────────────────────────────────────────
  static const Color primary50 = Color(0xFFF0EFFF);
  static const Color primary100 = Color(0xFFDDDBFF);
  static const Color primary200 = Color(0xFFBBB7FF);
  static const Color primary300 = Color(0xFF9993FF);
  static const Color primary400 = Color(0xFF7770FF);
  static const Color primary500 = Color(0xFF6C63FF);
  static const Color primary600 = Color(0xFF5A52E0);
  static const Color primary700 = Color(0xFF4840C0);
  static const Color primary800 = Color(0xFF362FA0);
  static const Color primary900 = Color(0xFF241E80);

  // ── Background (Dark Theme Default) ──────────────────────────────────────
  static const Color bgBase = Color(0xFF0A0A1A);       // 최심층 배경
  static const Color bgSurface = Color(0xFF12122A);    // 카드 배경
  static const Color bgElevated = Color(0xFF1A1A3A);   // 상승 표면

  // ── Glass ─────────────────────────────────────────────────────────────────
  static const Color glassSurface = Color(0x1AFFFFFF); // 10% 흰
  static const Color glassBorder = Color(0x33FFFFFF);  // 20% 흰
  static const Color glassHighlight = Color(0x0DFFFFFF); // 5% 흰
  static const Color glassDark = Color(0x1A000000);    // 10% 검

  // ── Temperature / Vibe Meter ──────────────────────────────────────────────
  static const Color tempIcy = Color(0xFF4FC3F7);      // 냉담 (얼음)
  static const Color tempCool = Color(0xFF81C784);     // 쌀쌀
  static const Color tempNeutral = Color(0xFFFFD54F);  // 보통
  static const Color tempWarm = Color(0xFFFFB74D);     // 따뜻
  static const Color tempHot = Color(0xFFFF7043);      // 뜨거움
  static const Color tempFire = Color(0xFFE53935);     // 열정

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
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // ── Text ──────────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xB3FFFFFF); // 70%
  static const Color textTertiary = Color(0x80FFFFFF);  // 50%
  static const Color textDisabled = Color(0x4DFFFFFF);  // 30%
  static const Color textInverse = Color(0xFF0A0A1A);

  // ── Node ──────────────────────────────────────────────────────────────────
  static const Color nodeDefault = Color(0xFF6C63FF);
  static const Color nodeGhost = Color(0x4DFFFFFF);      // Ghost Node
  static const Color nodeBorderGhost = Color(0x80FFFFFF); // Ghost 테두리
  static const Color nodeSelected = Color(0xFFFFD700);   // 선택된 노드

  // ── Plan ─────────────────────────────────────────────────────────────────
  static const Color planFree = Color(0xFF78909C);
  static const Color planBasic = Color(0xFF42A5F5);
  static const Color planPremium = Color(0xFFFFD700);
}
