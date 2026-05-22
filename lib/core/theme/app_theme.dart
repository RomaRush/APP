import 'package:flutter/material.dart';

class AppTheme {
  // ── Core palette ──────────────────────────────────────────────────────────
  static const Color primaryDark    = Color(0xFF080810);
  static const Color backgroundDark = Color(0xFF0F0F1A);
  static const Color surfaceDark    = Color(0xFF16162A);
  static const Color surfaceMid     = Color(0xFF1E1E30);

  // ── Accents ───────────────────────────────────────────────────────────────
  static const Color accentGreen  = Color(0xFF34D399);   // emerald
  static const Color accentBlue   = Color(0xFF60A5FA);   // sky blue
  static const Color accentGold   = Color(0xFFFBBF24);   // amber
  static const Color accentIndigo = Color(0xFF818CF8);   // indigo
  static const Color accentPink   = Color(0xFFF472B6);   // pink
  static const Color accentPurple = Color(0xFFA78BFA);   // violet
  static const Color errorRed     = Color(0xFFF87171);   // rose

  // ── Neutral ────────────────────────────────────────────────────────────────
  static const Color white    = Colors.white;
  static const Color white90  = Color(0xE6FFFFFF);
  static const Color white70  = Colors.white70;
  static const Color white54  = Colors.white54;
  static const Color white38  = Colors.white38;
  static const Color white12  = Colors.white12;
  static const Color white08  = Color(0x33000000); // 20% black for darker glass blocks
  static const Color white05  = Color(0x0DFFFFFF);
  static const Color glassWhite = Color(0x1AFFFFFF);
  static const Color black      = Colors.black;
  static const Color mediumGray = Color(0xFF8E8E93);
  static const Color darkGray   = Color(0xFF636366);
  static const Color lightGray  = Color(0xFFAEAEB2);

  // ── Gradients ──────────────────────────────────────────────────────────────
  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient indigoGradient = LinearGradient(
    colors: [Color(0xFF818CF8), Color(0xFF6366F1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient emeraldGradient = LinearGradient(
    colors: [Color(0xFF34D399), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Text Styles ────────────────────────────────────────────────────────────
  static TextStyle get logoStyle => TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w800,
        color: white,
        letterSpacing: -1.5,
      );

  static TextStyle get headlineStyle => TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: white,
        height: 1.1,
        letterSpacing: -0.8,
      );

  static TextStyle get titleStyle => TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: white,
        letterSpacing: -0.3,
      );

  static TextStyle get bodyStyle => TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: white70,
        height: 1.55,
      );

  static TextStyle get captionStyle => TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: white38,
        letterSpacing: 0.1,
      );

  static TextStyle get labelStyle => TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: white38,
        letterSpacing: 1.0,
      );

  static TextStyle get buttonTextStyle => TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: primaryDark,
        letterSpacing: -0.2,
      );

  static TextStyle get buttonTextStyleWhite => TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: white,
        letterSpacing: -0.2,
      );

  static TextStyle get errorStyle => TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: errorRed,
        letterSpacing: 0.1,
      );

  // ── Layout ─────────────────────────────────────────────────────────────────
  static const double cardPadding   = 20.0;
  static const double screenPadding = 20.0;

  static BorderRadius get cardRadius   => BorderRadius.circular(24);
  static BorderRadius get buttonRadius => BorderRadius.circular(18);
  static BorderRadius get chipRadius   => BorderRadius.circular(12);
  static BorderRadius get bottomSheetRadius => BorderRadius.circular(32);

  // ── Shadows & Effects ──────────────────────────────────────────────────────
  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.25),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> glowShadow(Color color) => [
    BoxShadow(
      color: color.withValues(alpha: 0.3),
      blurRadius: 20,
      spreadRadius: -4,
    ),
  ];

  // ── Theme Data ─────────────────────────────────────────────────────────────
  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: primaryDark,
        colorScheme: const ColorScheme.dark(
          primary: accentIndigo,
          secondary: accentGreen,
          surface: surfaceDark,
          error: errorRed,
        ),
        textTheme: TextTheme(
          displayLarge: headlineStyle,
          titleLarge: titleStyle,
          bodyLarge: bodyStyle,
          bodySmall: captionStyle,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: white05,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          hintStyle: TextStyle(color: white38, fontSize: 14),
        ),
      );
}
