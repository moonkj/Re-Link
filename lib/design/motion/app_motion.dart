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

  // ── Spring Descriptions ───────────────────────────────────────────────────
  /// 빠른 스냅: 툴팁, 칩 선택 (damping:15, stiffness:400)
  static const SpringDescription springSnappy = SpringDescription(
    mass: 1.0,
    stiffness: 400.0,
    damping: 15.0,
  );

  /// 기본 스프링: 바텀시트, 패널 (damping:20, stiffness:300)
  static const SpringDescription springDefault = SpringDescription(
    mass: 1.0,
    stiffness: 300.0,
    damping: 20.0,
  );

  /// 탄력 스프링: 노드 추가 팝인, FAB (damping:10, stiffness:500)
  static const SpringDescription springBouncy = SpringDescription(
    mass: 1.0,
    stiffness: 500.0,
    damping: 10.0,
  );

  /// 부드러운 스프링: Focus Mode 패널, 오버레이 (damping:25, stiffness:200)
  static const SpringDescription springGentle = SpringDescription(
    mass: 1.0,
    stiffness: 200.0,
    damping: 25.0,
  );

  /// 노드 드래그 릴리즈: 노드카드 위치 복원 (damping:18, stiffness:350)
  static const SpringDescription springNode = SpringDescription(
    mass: 1.0,
    stiffness: 350.0,
    damping: 18.0,
  );

  // ── Ghost 전환 ────────────────────────────────────────────────────────────
  static const Duration ghostFill = Duration(milliseconds: 300);
  static const Duration focusPanelSlide = Duration(milliseconds: 280);
  static const Duration vibeMeterStep = Duration(milliseconds: 180);

  // ══════════════════════════════════════════════════════════════════════════
  // ── 3-Tier Duration (디자인 문서 4.6) ─────────────────────────────────────
  // ══════════════════════════════════════════════════════════════════════════
  // Tier 1: Quick (100-200ms) — micro feedback
  static const Duration tier1Min = Duration(milliseconds: 100);
  static const Duration tier1Max = Duration(milliseconds: 200);
  // Tier 2: Standard (250-400ms) — panels, cards
  static const Duration tier2Min = Duration(milliseconds: 250);
  static const Duration tier2Max = Duration(milliseconds: 400);
  // Tier 3: Dramatic (500-800ms) — mode changes
  static const Duration tier3Min = Duration(milliseconds: 500);
  static const Duration tier3Max = Duration(milliseconds: 800);

  // ══════════════════════════════════════════════════════════════════════════
  // ── Haptic 매핑 (디자인 문서 4.6) ─────────────────────────────────────────
  // ══════════════════════════════════════════════════════════════════════════
  // HapticFeedback 호출 가이드:
  //   nodeTap       → HapticFeedback.lightImpact()
  //   nodeLongPress → HapticFeedback.mediumImpact()
  //   edgeConnect   → HapticFeedback.heavyImpact() (success notification)
  //   dragSnap      → HapticFeedback.selectionClick() (rigid)
  //   deleteAction  → HapticFeedback.heavyImpact() (warning)
  //   modeChange    → HapticFeedback.selectionClick()
  //   vibeMeterStep → HapticFeedback.selectionClick()
}
