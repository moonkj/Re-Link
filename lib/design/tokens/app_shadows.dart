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

  // ── Glass 그림자 (빛나는 효과) ────────────────────────────────────────────
  static const List<BoxShadow> glass = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 20,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x0DFFFFFF),
      blurRadius: 1,
      offset: Offset(0, 1),
      spreadRadius: -1,
    ),
  ];

  // ── Primary Glow ──────────────────────────────────────────────────────────
  static const List<BoxShadow> primaryGlow = [
    BoxShadow(
      color: Color(0x4D6C63FF),
      blurRadius: 20,
      offset: Offset(0, 4),
      spreadRadius: -2,
    ),
  ];

  // ── Node 그림자 ───────────────────────────────────────────────────────────
  static const List<BoxShadow> node = [
    BoxShadow(
      color: Color(0x336C63FF),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> nodeSelected = [
    BoxShadow(
      color: Color(0x80FFD700),
      blurRadius: 24,
      offset: Offset(0, 4),
      spreadRadius: 2,
    ),
  ];
}
