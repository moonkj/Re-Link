import 'package:flutter/material.dart';

/// Re-Link 반경(Border Radius) 토큰
/// 디자인 문서 4.5 — Component-specific Corner Radius
abstract final class AppRadius {
  // ── 기본 스케일 ──────────────────────────────────────────────────────────
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 14.0;    // TextField: 14dp
  static const double lg = 16.0;    // Action Button: 16dp
  static const double xl = 20.0;    // Node Card Small, Voice Capsule: 20dp
  static const double xxl = 24.0;   // Icon Button, Dialog: 24dp
  static const double xxxl = 28.0;  // Node Card Large, Bottom Sheet: 28dp
  static const double chip = 100.0; // Chip: 100dp
  static const double full = 999.0; // Avatar: 999dp

  // ── BorderRadius ──────────────────────────────────────────────────────────
  static const BorderRadius radiusXs = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius radiusSm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius radiusMd = BorderRadius.all(Radius.circular(md));
  static const BorderRadius radiusLg = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius radiusXl = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius radiusXxl = BorderRadius.all(Radius.circular(xxl));
  static const BorderRadius radiusXxxl = BorderRadius.all(Radius.circular(xxxl));
  static const BorderRadius radiusChip = BorderRadius.all(Radius.circular(chip));
  static const BorderRadius radiusFull = BorderRadius.all(Radius.circular(full));

  // ── 컴포넌트별 (디자인 문서 4.5) ────────────────────────────────────────
  static const BorderRadius nodeCard = radiusXl;           // 20dp
  static const BorderRadius nodeCardLarge = radiusXxxl;     // 28dp
  static const BorderRadius glassCard = radiusXxxl;         // 28dp
  static const BorderRadius card = radiusXl;                // 20dp
  static const BorderRadius button = radiusLg;              // Action Button 16dp
  static const BorderRadius iconButton = radiusXxl;         // 24dp
  static const BorderRadius dialog = radiusXxl;             // 24dp
  static const BorderRadius voiceCapsule = radiusXl;        // 20dp
  static const BorderRadius input = radiusMd;               // TextField 14dp
  static const BorderRadius bottomSheet = BorderRadius.only(
    topLeft: Radius.circular(xxxl),   // 28dp
    topRight: Radius.circular(xxxl),
  );
  static const BorderRadius chipRadius = radiusChip;        // 100dp
}
