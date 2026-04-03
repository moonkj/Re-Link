/// AppColors 순수 로직 테스트
/// 커버: app_colors.dart — tempColor, brightness 전환, 색상 상수
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:re_link/design/tokens/app_colors.dart';

void main() {
  // ── tempColor switch ────────────────────────────────────────────────────

  group('AppColors.tempColor', () {
    test('level 0 → tempIcy', () {
      expect(AppColors.tempColor(0), AppColors.tempIcy);
    });

    test('level 1 → tempCool', () {
      expect(AppColors.tempColor(1), AppColors.tempCool);
    });

    test('level 2 → tempNeutral', () {
      expect(AppColors.tempColor(2), AppColors.tempNeutral);
    });

    test('level 3 → tempWarm', () {
      expect(AppColors.tempColor(3), AppColors.tempWarm);
    });

    test('level 4 → tempHot', () {
      expect(AppColors.tempColor(4), AppColors.tempHot);
    });

    test('level 5 → tempFire', () {
      expect(AppColors.tempColor(5), AppColors.tempFire);
    });

    test('level -1 (out of range) → tempNeutral (default)', () {
      expect(AppColors.tempColor(-1), AppColors.tempNeutral);
    });

    test('level 6 (out of range) → tempNeutral (default)', () {
      expect(AppColors.tempColor(6), AppColors.tempNeutral);
    });

    test('level 100 → tempNeutral (default)', () {
      expect(AppColors.tempColor(100), AppColors.tempNeutral);
    });

    test('all 6 temp colors are unique', () {
      final colors = [
        AppColors.tempIcy,
        AppColors.tempCool,
        AppColors.tempNeutral,
        AppColors.tempWarm,
        AppColors.tempHot,
        AppColors.tempFire,
      ];
      expect(colors.toSet().length, 6);
    });
  });

  // ── 밝기 전환 ──────────────────────────────────────────────────────────

  group('AppColors brightness switching', () {
    test('dark mode — isDark is true', () {
      AppColors.updateBrightness(Brightness.dark);
      expect(AppColors.isDark, isTrue);
    });

    test('light mode — isDark is false', () {
      AppColors.updateBrightness(Brightness.light);
      expect(AppColors.isDark, isFalse);
    });

    test('primary changes with brightness', () {
      AppColors.updateBrightness(Brightness.dark);
      final darkPrimary = AppColors.primary;

      AppColors.updateBrightness(Brightness.light);
      final lightPrimary = AppColors.primary;

      expect(darkPrimary, isNot(lightPrimary));
    });

    test('bgBase changes with brightness', () {
      AppColors.updateBrightness(Brightness.dark);
      final darkBg = AppColors.bgBase;

      AppColors.updateBrightness(Brightness.light);
      final lightBg = AppColors.bgBase;

      expect(darkBg, isNot(lightBg));
    });

    test('textPrimary changes with brightness', () {
      AppColors.updateBrightness(Brightness.dark);
      final darkText = AppColors.textPrimary;

      AppColors.updateBrightness(Brightness.light);
      final lightText = AppColors.textPrimary;

      expect(darkText, isNot(lightText));
    });

    test('glassSurface changes with brightness', () {
      AppColors.updateBrightness(Brightness.dark);
      final darkGlass = AppColors.glassSurface;

      AppColors.updateBrightness(Brightness.light);
      final lightGlass = AppColors.glassSurface;

      expect(darkGlass, isNot(lightGlass));
    });

    test('glassBorder changes with brightness', () {
      AppColors.updateBrightness(Brightness.dark);
      final darkBorder = AppColors.glassBorder;

      AppColors.updateBrightness(Brightness.light);
      final lightBorder = AppColors.glassBorder;

      expect(darkBorder, isNot(lightBorder));
    });
  });

  // ── Day palette constants ──────────────────────────────────────────────

  group('Day palette constants', () {
    test('dayBg is light', () {
      expect(AppColors.dayBg.computeLuminance(), greaterThan(0.9));
    });

    test('daySurface is white', () {
      expect(AppColors.daySurface, const Color(0xFFFFFFFF));
    });

    test('dayTextPrimary is dark', () {
      expect(AppColors.dayTextPrimary.computeLuminance(), lessThan(0.1));
    });
  });

  // ── Night palette constants ─────────────────────────────────────────────

  group('Night palette constants', () {
    test('nightBg is dark', () {
      expect(AppColors.nightBg.computeLuminance(), lessThan(0.05));
    });

    test('nightTextPrimary is light', () {
      expect(AppColors.nightTextPrimary.computeLuminance(), greaterThan(0.9));
    });
  });

  // ── Semantic colors ─────────────────────────────────────────────────────

  group('Semantic colors', () {
    test('success color is green-ish', () {
      // Emerald-500
      expect(AppColors.success.green, greaterThan(AppColors.success.red));
    });

    test('error color is red-ish', () {
      // Rose-600
      expect(AppColors.error.red, greaterThan(AppColors.error.blue));
    });

    test('warning color exists', () {
      expect(AppColors.warning, isNotNull);
    });

    test('info color exists', () {
      expect(AppColors.info, isNotNull);
    });
  });

  // ── Plan colors ───────────────────────────────────────────────────────

  group('Plan colors', () {
    test('planFree — Slate', () {
      expect(AppColors.planFree, isNotNull);
    });

    test('planPlus — matches primaryMint', () {
      expect(AppColors.planPlus, AppColors.primaryMint);
    });

    test('planFamily — Violet-600', () {
      expect(AppColors.planFamily, isNotNull);
    });

    test('planFamilyPlus — Amber gold', () {
      expect(AppColors.planFamilyPlus, isNotNull);
    });

    test('all plan colors are unique', () {
      final colors = [
        AppColors.planFree,
        AppColors.planPlus,
        AppColors.planFamily,
        AppColors.planFamilyPlus,
      ];
      expect(colors.toSet().length, 4);
    });
  });

  // Reset brightness to default for other tests
  tearDownAll(() {
    AppColors.updateBrightness(Brightness.dark);
  });
}
