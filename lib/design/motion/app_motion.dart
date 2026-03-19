import 'package:flutter/material.dart';

/// Re-Link 애니메이션/모션 토큰
abstract final class AppMotion {
  // ── Duration ──────────────────────────────────────────────────────────────
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);
  static const Duration slower = Duration(milliseconds: 600);
  static const Duration slowest = Duration(milliseconds: 1000);

  // ── Curve ─────────────────────────────────────────────────────────────────
  static const Curve standard = Curves.easeInOut;
  static const Curve enter = Curves.easeOut;
  static const Curve exit = Curves.easeIn;
  static const Curve spring = Curves.elasticOut;
  static const Curve bounce = Curves.bounceOut;
  static const Curve decelerate = Curves.decelerate;
  static const Curve emphasized = Curves.easeInOutCubicEmphasized;

  // ── Page Transitions ──────────────────────────────────────────────────────
  static const Duration pageTransition = Duration(milliseconds: 300);
  static const Curve pageTransitionCurve = Curves.easeInOut;

  // ── Node 애니메이션 ───────────────────────────────────────────────────────
  static const Duration nodeAppear = Duration(milliseconds: 350);
  static const Curve nodeAppearCurve = Curves.easeOut;

  // ── 글래스 효과 ───────────────────────────────────────────────────────────
  static const Duration glassReveal = Duration(milliseconds: 400);
  static const Curve glassRevealCurve = Curves.easeOut;
}
