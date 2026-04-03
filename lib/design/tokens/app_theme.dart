import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'app_radius.dart';

/// Re-Link Material 3 테마 설정
abstract final class AppTheme {
  // ── Light Theme ───────────────────────────────────────────────────────────
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.light(
          primary: AppColors.primary800,     // Violet-600
          secondary: AppColors.primary900,   // Cyan-600
          tertiary: AppColors.accentWarm,    // Rose-400
          surface: AppColors.daySurface,
          error: AppColors.error,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: AppColors.dayTextPrimary,
          onError: Colors.white,
        ),
        scaffoldBackgroundColor: AppColors.dayBg,
        fontFamily: 'Pretendard',
        textTheme: TextTheme(
          displayLarge: AppTypography.displayLarge.copyWith(color: AppColors.dayTextPrimary),
          displayMedium: AppTypography.displayMedium.copyWith(color: AppColors.dayTextPrimary),
          displaySmall: AppTypography.displaySmall.copyWith(color: AppColors.dayTextPrimary),
          headlineLarge: AppTypography.headlineLarge.copyWith(color: AppColors.dayTextPrimary),
          headlineMedium: AppTypography.headlineMedium.copyWith(color: AppColors.dayTextPrimary),
          headlineSmall: AppTypography.headlineSmall.copyWith(color: AppColors.dayTextPrimary),
          titleLarge: AppTypography.titleLarge.copyWith(color: AppColors.dayTextPrimary),
          titleMedium: AppTypography.titleMedium.copyWith(color: AppColors.dayTextPrimary),
          titleSmall: AppTypography.titleSmall.copyWith(color: AppColors.dayTextPrimary),
          bodyLarge: AppTypography.bodyLarge.copyWith(color: AppColors.dayTextPrimary),
          bodyMedium: AppTypography.bodyMedium.copyWith(color: AppColors.dayTextPrimary),
          bodySmall: AppTypography.bodySmall.copyWith(color: AppColors.dayTextSecondary),
          labelLarge: AppTypography.labelLarge.copyWith(color: AppColors.dayTextPrimary),
          labelMedium: AppTypography.labelMedium.copyWith(color: AppColors.dayTextSecondary),
          labelSmall: AppTypography.labelSmall.copyWith(color: AppColors.dayTextSecondary),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          foregroundColor: AppColors.dayTextPrimary,
        ),
        cardTheme: const CardThemeData(
          color: AppColors.daySurface,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.dayTextSecondary,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            textStyle: AppTypography.labelLarge,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.dayBg,
          border: OutlineInputBorder(
            borderRadius: AppRadius.radiusMd,
            borderSide: BorderSide(color: AppColors.dayTextSecondary.withAlpha(40)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppRadius.radiusMd,
            borderSide: BorderSide(color: AppColors.dayTextSecondary.withAlpha(40)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppRadius.radiusMd,
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: BorderSide(color: AppColors.primary),
            shape: const RoundedRectangleBorder(
              borderRadius: AppRadius.button,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          ),
        ),
        dividerTheme: DividerThemeData(
          color: AppColors.dayTextSecondary.withAlpha(30),
          thickness: 0.5,
        ),
        iconTheme: IconThemeData(
          color: AppColors.dayTextSecondary,
          size: 24,
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.daySurface,
          contentTextStyle: AppTypography.bodyMedium,
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.radiusMd,
          ),
          behavior: SnackBarBehavior.floating,
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        dialogTheme: const DialogThemeData(
          backgroundColor: AppColors.daySurface,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.dialog),
        ),
      );

  // ── Dark Theme ────────────────────────────────────────────────────────────
  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.dark(
          primary: AppColors.primaryMint,    // Violet-400
          secondary: AppColors.primaryBlue,  // Cyan-400
          tertiary: AppColors.accentWarm,    // Rose-400
          surface: AppColors.nightSurface,
          error: AppColors.error,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: AppColors.nightTextPrimary,
          onError: Colors.white,
        ),
        scaffoldBackgroundColor: AppColors.nightBg,
        fontFamily: 'Pretendard',
        textTheme: TextTheme(
          displayLarge: AppTypography.displayLarge,
          displayMedium: AppTypography.displayMedium,
          displaySmall: AppTypography.displaySmall,
          headlineLarge: AppTypography.headlineLarge,
          headlineMedium: AppTypography.headlineMedium,
          headlineSmall: AppTypography.headlineSmall,
          titleLarge: AppTypography.titleLarge,
          titleMedium: AppTypography.titleMedium,
          titleSmall: AppTypography.titleSmall,
          bodyLarge: AppTypography.bodyLarge,
          bodyMedium: AppTypography.bodyMedium,
          bodySmall: AppTypography.bodySmall,
          labelLarge: AppTypography.labelLarge,
          labelMedium: AppTypography.labelMedium,
          labelSmall: AppTypography.labelSmall,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          foregroundColor: AppColors.textPrimary,
        ),
        cardTheme: CardThemeData(
          color: AppColors.bgSurface,
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.card,
          ),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textTertiary,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: const RoundedRectangleBorder(
              borderRadius: AppRadius.button,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            textStyle: AppTypography.labelLarge,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: BorderSide(color: AppColors.primary),
            shape: const RoundedRectangleBorder(
              borderRadius: AppRadius.button,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.glassSurface,
          border: OutlineInputBorder(
            borderRadius: AppRadius.radiusMd,
            borderSide: BorderSide(color: AppColors.glassBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppRadius.radiusMd,
            borderSide: BorderSide(color: AppColors.glassBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppRadius.radiusMd,
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
          hintStyle: AppTypography.bodyMedium.copyWith(
            color: AppColors.textTertiary,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        dividerTheme: DividerThemeData(
          color: AppColors.glassBorder,
          thickness: 0.5,
        ),
        iconTheme: IconThemeData(
          color: AppColors.textSecondary,
          size: 24,
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.bgElevated,
          contentTextStyle: AppTypography.bodyMedium,
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.radiusMd,
          ),
          behavior: SnackBarBehavior.floating,
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: AppColors.bgElevated,
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.dialog,
          ),
        ),
      );
}
