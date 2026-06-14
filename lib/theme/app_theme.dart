import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const primary = Color(0xFF6366F1);
  static const secondary = Color(0xFF3B82F6);
  static const surface = Color(0xFFFFFFFF);
  static const background = Color(0xFFF8FAFC);
  static const error = Color(0xFFEF4444);
  static const success = Color(0xFF22C55E);
  static const warning = Color(0xFFF59E0B);
  static const info = Color(0xFF3B82F6);
  static const danger = Color(0xFFEF4444);

  static const indigo50 = Color(0xFFEEF2FF);
  static const indigo100 = Color(0xFFE0E7FF);
  static const indigo200 = Color(0xFFC7D2FE);
  static const indigo600 = Color(0xFF4F46E5);

  static const blue50 = Color(0xFFEFF6FF);
  static const blue100 = Color(0xFFDBEAFE);
  static const blue600 = Color(0xFF2563EB);

  static const green50 = Color(0xFFF0FDF4);
  static const green100 = Color(0xFFDCFCE7);
  static const green600 = Color(0xFF16A34A);

  static const amber50 = Color(0xFFFFFBEB);
  static const amber100 = Color(0xFFFEF3C7);
  static const amber600 = Color(0xFFD97706);

  static const red50 = Color(0xFFFEF2F2);
  static const red100 = Color(0xFFFEE2E2);
  static const red600 = Color(0xFFDC2626);

  static const gray50 = Color(0xFFF9FAFB);
  static const gray100 = Color(0xFFF3F4F6);
  static const gray200 = Color(0xFFE5E7EB);
  static const gray300 = Color(0xFFD1D5DB);
  static const gray400 = Color(0xFF9CA3AF);
  static const gray500 = Color(0xFF6B7280);
  static const gray600 = Color(0xFF4B5563);
  static const gray700 = Color(0xFF374151);
  static const gray800 = Color(0xFF1F2937);
  static const gray900 = Color(0xFF111827);
  static const slate900 = Color(0xFF0F172A);

  static const purple500 = Color(0xFF8B5CF6);
  static const orange500 = Color(0xFFF97316);
}

class AppTheme {
  static ThemeData get theme {
    final colorScheme = ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.surface,
      error: AppColors.error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.gray900,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w800),
        headlineMedium: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700),
        titleLarge: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700),
        titleMedium: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700),
        bodyLarge: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w400),
        bodyMedium: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400),
        bodySmall: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w400),
        labelSmall: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600),
      ),
      cardTheme: CardThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
        color: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.gray200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.gray200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      chipTheme: ChipThemeData(
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
    );
  }

  static BoxDecoration get cardDecoration => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: AppColors.gray100),
    boxShadow: const [
      BoxShadow(
        color: Color(0x0D000000),
        offset: Offset(0, 2),
        blurRadius: 8,
      ),
    ],
  );
}
