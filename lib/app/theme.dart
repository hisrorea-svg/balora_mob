import 'package:flutter/material.dart';

/// Balora brand & semantic color tokens aligned with Balora Desktop.
abstract final class BaloraColors {
  // --- Primary (Clinical Pharmacy Teal) ---
  static const Color primary = Color(0xFF0F5E5B);
  static const Color primaryLight = Color(0xFF147A76);
  static const Color primaryDark = Color(0xFF0A4341);
  static const Color primarySoft = Color(0xFFE6F2F1);

  // --- Secondary (Slate Teal) ---
  static const Color secondary = Color(0xFF2B6CB0);

  // --- Semantic ---
  static const Color success = Color(0xFF14634F);
  static const Color successSoft = Color(0xFFE5F2EC);
  static const Color warning = Color(0xFFB45309);
  static const Color warningSoft = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFA23B2E);
  static const Color errorSoft = Color(0xFFF7E9E6);
  static const Color info = Color(0xFF1E4E8C);

  // --- Neutral ---
  static const Color surface = Color(0xFFF5F7F6);
  static const Color surfaceSubtle = Color(0xFFEDF1F0);
  static const Color surfaceDark = Color(0xFF0F1716);
  static const Color card = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF182221);
  static const Color textPrimary = Color(0xFF1D2726);
  static const Color textSecondary = Color(0xFF5D6B69);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFD8E0DE);
  static const Color borderDark = Color(0xFF2B3937);

  // --- Scanner ---
  static const Color scanOverlay = Color(0x99000000);
  static const Color scanFrame = Color(0xFF0F5E5B);
  static const Color scanSuccess = Color(0xFF14634F);
}

/// Balora theme configuration.
abstract final class BaloraTheme {
  static ThemeData light() {
    final baseScheme = ColorScheme.fromSeed(
      seedColor: BaloraColors.primary,
      brightness: Brightness.light,
      primary: BaloraColors.primary,
      onPrimary: BaloraColors.textOnPrimary,
      surface: BaloraColors.surface,
      onSurface: BaloraColors.textPrimary,
      error: BaloraColors.error,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: baseScheme,
      scaffoldBackgroundColor: BaloraColors.surface,
      dividerColor: BaloraColors.border,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: BaloraColors.card,
        foregroundColor: BaloraColors.textPrimary,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: BaloraColors.textPrimary,
          fontSize: 17,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: BaloraColors.card,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: BaloraColors.border),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: BaloraColors.primary,
          foregroundColor: BaloraColors.textOnPrimary,
          minimumSize: const Size(double.infinity, 48),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: BaloraColors.textPrimary,
          minimumSize: const Size(double.infinity, 48),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          side: const BorderSide(color: BaloraColors.border),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: BaloraColors.card,
        labelStyle: const TextStyle(
          color: BaloraColors.textSecondary,
          fontSize: 14,
        ),
        hintStyle: const TextStyle(
          color: BaloraColors.textSecondary,
          fontSize: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: BaloraColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: BaloraColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: BaloraColors.primary,
            width: 1.8,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: BaloraColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 13,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  static ThemeData dark() {
    final baseScheme = ColorScheme.fromSeed(
      seedColor: BaloraColors.primary,
      brightness: Brightness.dark,
      primary: BaloraColors.primaryLight,
      onPrimary: Colors.white,
      surface: BaloraColors.surfaceDark,
      onSurface: Colors.white,
      error: BaloraColors.error,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: baseScheme,
      scaffoldBackgroundColor: BaloraColors.surfaceDark,
      dividerColor: BaloraColors.borderDark,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: BaloraColors.cardDark,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 17,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: BaloraColors.cardDark,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: BaloraColors.borderDark),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: BaloraColors.primaryLight,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 48),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: BaloraColors.cardDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: BaloraColors.borderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: BaloraColors.borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: BaloraColors.primaryLight,
            width: 1.8,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 13,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
