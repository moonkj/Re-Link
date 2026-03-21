import 'package:flutter/material.dart';

/// Re-Link 그림자 토큰
abstract final class AppShadows {
  // ── 기본 그림자 ───────────────────────────────────────────────────────────
  static const List<BoxShadow> none = [];

  static const List<BoxShadow> sm = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> md = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> lg = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];

  // ── Card shadow (subtle elevation, no glow) ──────────────────────────────
  static const List<BoxShadow> glass = [
    BoxShadow(
      color: Color(0x14000000), // 8% black — subtle
      blurRadius: 12,
      offset: Offset(0, 2),
    ),
  ];

  // ── Primary shadow (neutral) ────────────────────────────────────────────
  static const List<BoxShadow> primaryGlow = [
    BoxShadow(
      color: Color(0x26000000),
      blurRadius: 12,
      offset: Offset(0, 3),
    ),
  ];

  // ── Node shadow (neutral) ─────────────────────────────────────────────
  static const List<BoxShadow> node = [
    BoxShadow(
      color: Color(0x1A000000), // 10% black
      blurRadius: 10,
      offset: Offset(0, 3),
    ),
  ];

  static const List<BoxShadow> nodeSelected = [
    BoxShadow(
      color: Color(0x40000000),
      blurRadius: 14,
      offset: Offset(0, 3),
    ),
  ];
}
