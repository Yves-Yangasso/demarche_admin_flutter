import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design System SunuDekk — fidèle à la maquette
class AppTheme {
  AppTheme._();

  // ─── Couleurs ────────────────────────────────────────────────────────────
  static const Color primary      = Color(0xFF176848);
  static const Color primaryLight = Color(0xFF1E8259);
  static const Color primaryDark  = Color(0xFF0F4F34);

  static const Color background   = Color(0xFFEBF0F5); // fond gris-bleu clair de la maquette
  static const Color surface      = Colors.white;
  static const Color surfaceGrey  = Color(0xFFF1F5F9);

  static const Color textDark     = Color(0xFF0F172A);
  static const Color textMedium   = Color(0xFF475569);
  static const Color textMuted    = Color(0xFF94A3B8);
  static const Color textLight    = Color(0xFFCBD5E1);

  static const Color border       = Color(0xFFE2E8F0);
  static const Color error        = Color(0xFFEF4444);
  static const Color success      = Color(0xFF10B981);
  static const Color warning      = Color(0xFFF59E0B);
  static const Color info         = Color(0xFF6366F1);

  // ─── Border Radius ───────────────────────────────────────────────────────
  static const double radiusSmall  = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge  = 16.0;
  static const double radiusXL     = 24.0;
  static const double radiusPill   = 50.0;  // inputs et boutons → pill

  // ─── Ombres ──────────────────────────────────────────────────────────────
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: const Color(0xFF0F172A).withValues(alpha: 0.06),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> get primaryShadow => [
    BoxShadow(
      color: primary.withValues(alpha: 0.35),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> get tabShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.06),
      blurRadius: 6,
      offset: const Offset(0, 2),
    ),
  ];

  // ─── Décorations réutilisables ────────────────────────────────────────────
  static BoxDecoration get pageBackground => const BoxDecoration(
    color: background,
  );

  static BoxDecoration get cardDecoration => BoxDecoration(
    color: surface,
    borderRadius: BorderRadius.circular(radiusXL),
    boxShadow: cardShadow,
  );

  static BoxDecoration get pillInputDecoration => BoxDecoration(
    color: surface,
    borderRadius: BorderRadius.circular(radiusPill),
    border: Border.all(color: primary, width: 1.5),
  );

  // ─── ThemeData complet ────────────────────────────────────────────────────
  static ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        surface: background,
        onSurface: textDark,
      ),
      scaffoldBackgroundColor: background,
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: const TextStyle(
          fontSize: 28, fontWeight: FontWeight.w900,
          color: textDark, letterSpacing: -0.5,
        ),
        titleLarge: const TextStyle(
          fontSize: 20, fontWeight: FontWeight.w800,
          color: textDark,
        ),
        titleMedium: const TextStyle(
          fontSize: 16, fontWeight: FontWeight.w700,
          color: textDark,
        ),
        bodyLarge: const TextStyle(fontSize: 15, color: textDark),
        bodyMedium: const TextStyle(fontSize: 13, color: textMedium),
        labelLarge: const TextStyle(
          fontSize: 15, fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      // ── Cards ────────────────────────────────────────────────
      cardTheme: CardThemeData(
        elevation: 0,
        color: surface,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusXL),
        ),
      ),
      // ── Inputs : pill shape ────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        hintStyle: const TextStyle(
          fontSize: 14, color: textMuted, fontWeight: FontWeight.w400,
        ),
        prefixIconColor: textMuted,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusPill),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusPill),
          borderSide: const BorderSide(color: border, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusPill),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusPill),
          borderSide: const BorderSide(color: error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusPill),
          borderSide: const BorderSide(color: error, width: 2),
        ),
      ),
      // ── Boutons : pill shape ───────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: primary.withValues(alpha: 0.5),
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusPill),
          ),
          textStyle: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 54),
          foregroundColor: primary,
          side: const BorderSide(color: primary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusPill),
          ),
          textStyle: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.w700,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: const TextStyle(
            fontSize: 14, fontWeight: FontWeight.w700,
          ),
        ),
      ),
      // ── AppBar ────────────────────────────────────────────────
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        foregroundColor: textDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          fontSize: 20, fontWeight: FontWeight.w900,
          color: textDark, fontFamily: 'Inter',
        ),
      ),
      // ── Divider ───────────────────────────────────────────────
      dividerTheme: const DividerThemeData(color: border, thickness: 1),
      // ── SnackBar ──────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusMedium)),
        backgroundColor: textDark,
        contentTextStyle: const TextStyle(color: Colors.white, fontSize: 13),
      ),
    );
  }
}
