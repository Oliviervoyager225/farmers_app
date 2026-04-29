import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // Primary palette — matches HTML design system exactly
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color primaryDark = Color(0xFF1B5E20);
  static const Color primaryLight = Color(0xFF66BB6A);

  // Semantic colours
  static const Color accentOrange = Color(0xFFF57C00);
  static const Color creditRed = Color(0xFFC62828);
  static const Color cashGreen = Color(0xFF388E3C);

  // Surface / background
  static const Color background = Color(0xFFFAFAF8);
  static const Color foreground = Color(0xFF1A1A1A);
  static const Color cardColor = Colors.white;
  static const Color muted = Color(0xFFF5F5F5);
  static const Color mutedFg = Color(0xFF757575);
  static const Color borderColor = Color(0x14000000); // rgba(0,0,0,0.08)

  // Legacy alias kept for backward compat
  static const Color bgLight = background;

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryGreen,
          primary: primaryGreen,
          secondary: accentOrange,
          error: creditRed,
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: background,
        textTheme: GoogleFonts.interTextTheme(),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: foreground,
          elevation: 0,
          centerTitle: false,
          surfaceTintColor: Colors.transparent,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryGreen,
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            minimumSize: const Size(0, 44),
          ),
        ),
        cardTheme: const CardThemeData(
          elevation: 0,
          color: Colors.white,
          margin: EdgeInsets.zero,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: borderColor),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      );
}
