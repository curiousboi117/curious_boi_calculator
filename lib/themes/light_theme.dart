import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/colors.dart';

ThemeData getLightTheme() {
  final baseTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primaryLight,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: const Color(0xFFF8F9FA),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
  );

  return baseTheme.copyWith(
    textTheme: GoogleFonts.outfitTextTheme(baseTheme.textTheme).copyWith(
      displayLarge: GoogleFonts.outfit(
        textStyle: baseTheme.textTheme.displayLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: const Color(0xFF1C1B1F),
        ),
      ),
      headlineMedium: GoogleFonts.outfit(
        textStyle: baseTheme.textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: const Color(0xFF49454F),
        ),
      ),
    ),
  );
}
