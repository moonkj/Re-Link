import 'package:flutter/material.dart';
import '../../features/badges/models/badge_definition.dart';
import 'app_colors.dart';

/// MZ-Style 배지 컬러 시스템 — Collectible Trading Card 느낌
///
/// 레어리티 티어별 시각적 임팩트 레벨:
///   Common   → 깔끔한 홀로그래픽 / 소프트 그라디언트
///   Rare     → 블루-시안 에너지, 눈에 띄게 쿨한 느낌
///   Epic     → 퍼플-바이올렛 Discord Nitro 바이브
///   Legendary → 골드-오렌지 네온, 가챠 전설 카드 느낌
abstract final class BadgeColors {
  static bool get _isDark => AppColors.isDark;

  // ════════════════════════════════════════════════════════════════════════════
  // ── RARITY ACCENT (아이콘, 텍스트, 필 배경에 사용) ───────────────────────────
  // ════════════════════════════════════════════════════════════════════════════

  static Color rarityAccent(BadgeRarity rarity) => switch (rarity) {
        BadgeRarity.common => _isDark
            ? const Color(0xFFB8C4D8) // cool silver-blue
            : const Color(0xFF6B7A8D),
        BadgeRarity.rare => _isDark
            ? const Color(0xFF00D4FF) // electric cyan
            : const Color(0xFF0099CC),
        BadgeRarity.epic => _isDark
            ? const Color(0xFFB388FF) // bright violet
            : const Color(0xFF7C4DFF),
        BadgeRarity.legendary => _isDark
            ? const Color(0xFFFFD740) // vivid gold
            : const Color(0xFFE6A800),
      };

  // ════════════════════════════════════════════════════════════════════════════
  // ── EARNED CARD — Gradient Background ──────────────────────────────────────
  // ════════════════════════════════════════════════════════════════════════════

  /// 카드 배경 그라디언트 (topLeft → bottomRight)
  static LinearGradient earnedGradient(BadgeRarity rarity) {
    final (Color start, Color end) = switch (rarity) {
      // Common: Steel holographic — indigo-tinted
      BadgeRarity.common => _isDark
          ? (const Color(0xFF1E2040), const Color(0xFF22223C))
          : (const Color(0xFFECEFF4), const Color(0xFFF4F6FA)),

      // Rare: Blue → Cyan energy pulse on indigo
      BadgeRarity.rare => _isDark
          ? (const Color(0xFF0F1A3A), const Color(0xFF0F2A3E))
          : (const Color(0xFFE0F2FE), const Color(0xFFD4F5FD)),

      // Epic: Deep purple → magenta glow on indigo
      BadgeRarity.epic => _isDark
          ? (const Color(0xFF1A0F3E), const Color(0xFF2D1254))
          : (const Color(0xFFF0E6FF), const Color(0xFFF8ECFF)),

      // Legendary: Dark gold → ember orange on indigo
      BadgeRarity.legendary => _isDark
          ? (const Color(0xFF2A1A08), const Color(0xFF3D2408))
          : (const Color(0xFFFFF8E1), const Color(0xFFFFECCC)),
    };
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [start, end],
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // ── EARNED CARD — Border ───────────────────────────────────────────────────
  // ════════════════════════════════════════════════════════════════════════════

  static Border earnedBorder(BadgeRarity rarity) {
    final (Color color, double width) = switch (rarity) {
      // Common: subtle silver shimmer
      BadgeRarity.common => _isDark
          ? (const Color(0xFF5A6A80), 1.0)
          : (const Color(0xFFB0BEC5), 1.0),

      // Rare: electric blue edge
      BadgeRarity.rare => _isDark
          ? (const Color(0xFF0091EA), 1.5)
          : (const Color(0xFF29B6F6), 1.5),

      // Epic: neon purple border
      BadgeRarity.epic => _isDark
          ? (const Color(0xFF9C27B0), 1.5)
          : (const Color(0xFFBA68C8), 1.5),

      // Legendary: blazing gold double-weight
      BadgeRarity.legendary => _isDark
          ? (const Color(0xFFFFAB00), 2.0)
          : (const Color(0xFFFFB300), 2.0),
    };
    return Border.all(color: color, width: width);
  }

  // ════════════════════════════════════════════════════════════════════════════
  // ── EARNED CARD — Glow (BoxShadow) ─────────────────────────────────────────
  // ════════════════════════════════════════════════════════════════════════════

  static List<BoxShadow> earnedGlow(BadgeRarity rarity) => switch (rarity) {
        // Common: subtle elevation
        BadgeRarity.common => const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],

        // Rare: medium elevation
        BadgeRarity.rare => const [
            BoxShadow(
              color: Color(0x26000000),
              blurRadius: 12,
              offset: Offset(0, 3),
            ),
          ],

        // Epic: higher elevation
        BadgeRarity.epic => const [
            BoxShadow(
              color: Color(0x30000000),
              blurRadius: 16,
              offset: Offset(0, 4),
            ),
          ],

        // Legendary: highest elevation
        BadgeRarity.legendary => const [
            BoxShadow(
              color: Color(0x40000000),
              blurRadius: 20,
              offset: Offset(0, 6),
            ),
          ],
      };

  // ════════════════════════════════════════════════════════════════════════════
  // ── EARNED CARD — Medallion (아이콘 원형 배경) ──────────────────────────────
  // ════════════════════════════════════════════════════════════════════════════

  static Color medallionBg(BadgeRarity rarity) => switch (rarity) {
        BadgeRarity.common => _isDark
            ? const Color(0xFF2C2D52) // dark indigo steel
            : const Color(0xFFDDE2EB),
        BadgeRarity.rare => _isDark
            ? const Color(0xFF0F2A48) // deep ocean blue on indigo
            : const Color(0xFFCCECFA),
        BadgeRarity.epic => _isDark
            ? const Color(0xFF28144E) // deep violet on indigo
            : const Color(0xFFE8D5FF),
        BadgeRarity.legendary => _isDark
            ? const Color(0xFF3D2A0A) // dark gold on indigo
            : const Color(0xFFFFE8A3),
      };

  // ════════════════════════════════════════════════════════════════════════════
  // ── UNEARNED CARD — Locked but stylish ─────────────────────────────────────
  // ════════════════════════════════════════════════════════════════════════════

  /// 미획득 카드 배경 — 어둡고 미스터리한 느낌
  static Color get unearnedBg => _isDark
      ? const Color(0xFF1E2040) // match nightSurface for contrast
      : const Color(0xFFECEDF1);

  /// 미획득 카드 테두리 — 은은한 존재감
  static Color get unearnedBorder => _isDark
      ? const Color(0xFF2C2D52) // match nightElevated
      : const Color(0xFFD8DBE2);

  /// 미획득 아이콘 색상 — 실루엣 느낌
  static Color get unearnedIcon => _isDark
      ? const Color(0xFF3A3A5C) // indigo-tinted ghost
      : const Color(0xFFBCC3CF);

  /// 미획득 이름 텍스트
  static Color get unearnedName => _isDark
      ? const Color(0xFF4A4A6A) // subtle but readable on indigo
      : const Color(0xFFA0A8B8);

  /// 미획득 희귀도 텍스트
  static Color get unearnedRarity => _isDark
      ? const Color(0xFF3A3A5C)
      : const Color(0xFFBBC2CC);

  /// 잠금 아이콘 배지 배경
  static Color get lockBadgeBg => _isDark
      ? const Color(0xFF2A1A4A) // mystical purple-indigo tint
      : const Color(0xFF6B5B7B);

  // ════════════════════════════════════════════════════════════════════════════
  // ── DIALOG — 배지 상세/획득 다이얼로그용 ────────────────────────────────────
  // ════════════════════════════════════════════════════════════════════════════

  /// 다이얼로그 아이콘 영역 그라디언트
  static List<Color> dialogIconGradient(BadgeRarity rarity) => switch (rarity) {
        BadgeRarity.common => _isDark
            ? [const Color(0xFF2C2D52), const Color(0xFF1E2040)]
            : [const Color(0xFFDDE2EB), const Color(0xFFECEFF4)],
        BadgeRarity.rare => _isDark
            ? [const Color(0xFF003366), const Color(0xFF0F2A48)]
            : [const Color(0xFFB3E5FC), const Color(0xFFCCECFA)],
        BadgeRarity.epic => _isDark
            ? [const Color(0xFF4A148C), const Color(0xFF28144E)]
            : [const Color(0xFFD1C4E9), const Color(0xFFE8D5FF)],
        BadgeRarity.legendary => _isDark
            ? [const Color(0xFF5D3F00), const Color(0xFF3D2A0A)]
            : [const Color(0xFFFFE082), const Color(0xFFFFE8A3)],
      };

  /// 다이얼로그 배경 그라디언트
  static LinearGradient dialogBgGradient(BadgeRarity rarity) {
    final (Color start, Color end) = switch (rarity) {
      BadgeRarity.common => _isDark
          ? (const Color(0xFF1E2040), const Color(0xFF0F0F1A))
          : (const Color(0xFFF8F9FC), const Color(0xFFFFFFFF)),
      BadgeRarity.rare => _isDark
          ? (const Color(0xFF0F1B34), const Color(0xFF0F0F1A))
          : (const Color(0xFFF0F8FF), const Color(0xFFFFFFFF)),
      BadgeRarity.epic => _isDark
          ? (const Color(0xFF1A0F34), const Color(0xFF0F0F1A))
          : (const Color(0xFFF8F0FF), const Color(0xFFFFFFFF)),
      BadgeRarity.legendary => _isDark
          ? (const Color(0xFF1E1808), const Color(0xFF0F0F1A))
          : (const Color(0xFFFFF8E8), const Color(0xFFFFFFFF)),
    };
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [start, end],
    );
  }
}

