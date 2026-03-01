import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A professional, elegant dark theme for the AI Chat App.
class AppTheme {
  AppTheme._();

  // ── Colors ──────────────────────────────────────────────
  static const Color black = Color(0xFF000000); // Pure Black
  static const Color surfaceDark = Color(
    0xFF0D0D15,
  ); // Deep dark with royal blue tint
  static const Color surfaceLight = Color(0xFF151520); // Darker card background

  static const Color accentColor = Color(
    0xFFFFFFFF,
  ); // High contrast white for primary actions
  static const Color accentDim = Color(0xFF8E8E93); // Secondary text/icons

  static const Color primaryBrand = Color(0xFF7C3AED); // Royal Purple - Premium
  static const Color primaryBrandDark = Color(
    0xFF5B21B6,
  ); // Darker Royal Purple
  static const Color royalCyan = Color(0xFF0EA5E9); // Deep Sky Blue
  static const Color luxeGold = Color(0xFFFBBA72); // Premium Gold Accent
  static const Color orionPurple = Color(0xFF7C3AED); // Royal Purple

  static const Color textPrimary = Color(0xFFFAFAFA);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color textTertiary = Color(0xFF4B5563);

  static const Color dividerColor = Color(0xFF1F2937);

  // ── Dimensions ──────────────────────────────────────────
  static const double borderRadiusL = 24.0;
  static const double borderRadiusM = 16.0;
  static const double borderRadiusS = 12.0;

  // ── Text Styles ─────────────────────────────────────────
  // Display Fonts - Premium Headings (Syne Font)
  static TextStyle get displayLarge => GoogleFonts.syne(
    fontSize: 40,
    fontWeight: FontWeight.w700,
    color: textPrimary,
    letterSpacing: -1.2,
  );

  static TextStyle get displayMedium => GoogleFonts.syne(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: textPrimary,
    letterSpacing: -0.8,
  );

  // Heading Fonts - Bold Titles (Syne)
  static TextStyle get titleLarge => GoogleFonts.syne(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: textPrimary,
    letterSpacing: -0.6,
  );

  static TextStyle get titleMedium => GoogleFonts.syne(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: textPrimary,
    letterSpacing: -0.4,
  );

  static TextStyle get titleSmall => GoogleFonts.syne(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    letterSpacing: -0.2,
  );

  // Body Fonts - Content (Inter for readability)
  static TextStyle get bodyLarge => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: textPrimary,
    height: 1.6,
    letterSpacing: 0.2,
  );

  static TextStyle get bodyMedium => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: textSecondary,
    height: 1.5,
    letterSpacing: 0.15,
  );

  static TextStyle get bodySmall => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: textSecondary,
    height: 1.4,
    letterSpacing: 0.1,
  );

  // Label Fonts - Buttons, Tags (Syne)
  static TextStyle get labelLarge => GoogleFonts.syne(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    letterSpacing: 0.5,
  );

  static TextStyle get labelMedium => GoogleFonts.syne(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: textSecondary,
    letterSpacing: 0.4,
  );

  static TextStyle get labelSmall => GoogleFonts.syne(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: textSecondary,
    letterSpacing: 0.3,
  );

  // Caption - Small Details (Inter)
  static TextStyle get captionLarge => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: textTertiary,
    letterSpacing: 0.2,
  );

  static TextStyle get captionSmall => GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: textTertiary,
    letterSpacing: 0.1,
  );

  // ── Theme Data ──────────────────────────────────────────
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: black,
      primaryColor: primaryBrand,

      colorScheme: const ColorScheme.dark(
        primary: primaryBrand,
        secondary: royalCyan,
        surface: surfaceDark,
        onSurface: textPrimary,
      ),

      textTheme: TextTheme(
        displayLarge: displayLarge,
        displayMedium: displayMedium,
        headlineLarge: titleLarge,
        headlineMedium: titleMedium,
        headlineSmall: titleSmall,
        titleLarge: titleLarge,
        titleMedium: titleMedium,
        titleSmall: titleSmall,
        bodyLarge: bodyLarge,
        bodyMedium: bodyMedium,
        bodySmall: bodySmall,
        labelLarge: labelLarge,
        labelMedium: labelMedium,
        labelSmall: labelSmall,
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: black,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: titleSmall.copyWith(fontSize: 16),
        iconTheme: const IconThemeData(color: textPrimary),
      ),

      dividerColor: dividerColor,
      dividerTheme: const DividerThemeData(
        color: dividerColor,
        thickness: 0.5,
        space: 1,
      ),

      iconTheme: const IconThemeData(color: textSecondary, size: 24),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceLight,
        hintStyle: bodyMedium.copyWith(color: textTertiary),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusL),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusL),
          borderSide: const BorderSide(color: textTertiary, width: 0.5),
        ),
      ),
    );
  }
}
