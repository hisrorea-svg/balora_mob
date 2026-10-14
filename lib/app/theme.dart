import 'package:flutter/material.dart';

/// Balora brand & semantic color tokens aligned with Balora Desktop Design System.
abstract final class BaloraColors {
  // --- Primary (Dark Teal - Balora Desktop Brand Core) ---
  static const Color primary = Color(0xFF0E4B5B);
  static const Color primaryLight = Color(0xFF146B76);
  static const Color primaryDark = Color(0xFF082F3A);
  static const Color primarySoft = Color(0xFFE0F2FE);
  static const Color primaryTint = Color(0xFFE6F4F7);

  // --- Brand Accents & Glows ---
  static const Color tealMint = Color(0xFF7CE0D1);
  static const Color emeraldGlow = Color(0xFF0CA596);
  static const Color secondary = Color(0xFF334155);

  // --- Semantic Feedback ---
  static const Color success = Color(0xFF059669);
  static const Color successSoft = Color(0xFFECFDF5);
  static const Color successBorder = Color(0xFFA7F3D0);

  static const Color warning = Color(0xFFD97706);
  static const Color warningSoft = Color(0xFFFEF3C7);
  static const Color warningBorder = Color(0xFFFDE68A);

  static const Color error = Color(0xFFDC2626);
  static const Color errorSoft = Color(0xFFFEE2E2);
  static const Color errorBorder = Color(0xFFFCA5A5);

  static const Color info = Color(0xFF0284C7);
  static const Color infoSoft = Color(0xFFE0F2FE);
  static const Color infoBorder = Color(0xFFBAE6FD);

  // --- Surfaces & Canvas ---
  static const Color surface = Color(0xFFF1F5F9);
  static const Color surfaceSubtle = Color(0xFFF8FAFC);
  static const Color surfaceMuted = Color(0xFFE2E8F0);
  static const Color surfaceDark = Color(0xFF0F172A);
  static const Color card = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF1E293B);

  // --- Text (High-contrast Slate) ---
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF334155);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // --- Borders ---
  static const Color border = Color(0xFFCBD5E1);
  static const Color borderSubtle = Color(0xFFE2E8F0);
  static const Color borderDark = Color(0xFF334155);

  // --- Scanner ---
  static const Color scanOverlay = Color(0x99000000);
  static const Color scanFrame = Color(0xFF0E4B5B);
  static const Color scanSuccess = Color(0xFF059669);
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
      dividerColor: BaloraColors.borderSubtle,
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
          side: const BorderSide(color: BaloraColors.borderSubtle),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: BaloraColors.primary,
          foregroundColor: BaloraColors.textOnPrimary,
          minimumSize: const Size(double.infinity, 48),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
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
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
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
          borderSide: const BorderSide(color: BaloraColors.primary, width: 1.8),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
