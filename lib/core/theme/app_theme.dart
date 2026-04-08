import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color accentGreen = Color(0xFF4CAF50);

class AppTheme {
  // Colors
  static const Color primaryDark = Color(0xFF1A1A1A);
  static const Color backgroundDark = Color(0xFF2D2D2D);
  static const Color white = Colors.white;
  static const Color lightGray = Color(0xFFF5F5F5);
  static const Color mediumGray = Color(0xFFE0E0E0);
  static const Color darkGray = Color(0xFF757575);
  static const Color black = Colors.black;
  static const Color errorRed = Color(0xFFD32F2F);

  // Text Styles - Using Inter for modern clean look
  static TextStyle get logoStyle => GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: white,
        letterSpacing: 1,
      );

  static TextStyle get headlineStyle => GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: white,
        height: 1.2,
      );

  static TextStyle get titleStyle => GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: black,
        letterSpacing: 0.5,
      );

  static TextStyle get bodyStyle => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: darkGray,
      );

  static TextStyle get buttonTextStyle => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: black,
      );

  static TextStyle get buttonTextStyleWhite => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: white,
      );

  static TextStyle get labelStyle => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: darkGray,
      );

  static TextStyle get errorStyle => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: errorRed,
      );

  // Border Radius
  static BorderRadius get cardRadius => BorderRadius.circular(24);
  static BorderRadius get buttonRadius => BorderRadius.circular(30);
  static BorderRadius get bottomSheetRadius => const BorderRadius.only(
        topLeft: Radius.circular(32),
        topRight: Radius.circular(32),
      );

  // Shadows
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: black.withValues(alpha: 0.1),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ];

  // ThemeData
  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: primaryDark,
        colorScheme: const ColorScheme.dark(
          primary: white,
          secondary: lightGray,
          surface: lightGray,
          error: errorRed,
        ),
      );
}
