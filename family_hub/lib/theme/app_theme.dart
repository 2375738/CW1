import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData get light {
    return FlexThemeData.light(
      colors: const FlexSchemeColor(
        primary: Color(0xFF1E40AF), // Blue 800
        primaryContainer: Color(0xFFDBEAFE), // Blue 100
        secondary: Color(0xFF334155), // Slate 700
        secondaryContainer: Color(0xFFF1F5F9), // Slate 100
        tertiary: Color(0xFF020617), // Slate 950
        tertiaryContainer: Color(0xFFE2E8F0), // Slate 200
        appBarColor: Colors.white,
        error: Color(0xFFDC2626),
      ),
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 3,
      subThemesData: const FlexSubThemesData(
        blendOnLevel: 10,
        blendOnColors: false,
        useM2StyleDividerInM3: true,
        alignedDropdown: true,
        useInputDecoratorThemeInDialogs: true,
        defaultRadius: 12.0,
        inputDecoratorRadius: 12.0,
        cardElevation: 1,
      ),
      keyColors: const FlexKeyColors(
        useSecondary: true,
        useTertiary: true,
      ),
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      useMaterial3: true,
      swapLegacyOnMaterial3: true,
      fontFamily: GoogleFonts.outfit().fontFamily,
      scaffoldBackground: const Color(0xFFF9FAFB), // Gray 50
    );
  }

  static ThemeData get dark {
    // Providing a better dark mode just in case, but user prefers light
    return FlexThemeData.dark(
      colors: const FlexSchemeColor(
        primary: Color(0xFF3B82F6), // Blue 500
        primaryContainer: Color(0xFF1E3A8A), // Blue 900
        secondary: Color(0xFF94A3B8), // Slate 400
        secondaryContainer: Color(0xFF1E293B), // Slate 800
        tertiary: Color(0xFFF8FAFC), // Slate 50
        tertiaryContainer: Color(0xFF334155), // Slate 700
        error: Color(0xFFEF4444),
      ),
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 13,
      subThemesData: const FlexSubThemesData(
        blendOnLevel: 20,
        defaultRadius: 12.0,
        inputDecoratorRadius: 12.0,
      ),
      keyColors: const FlexKeyColors(
        useSecondary: true,
        useTertiary: true,
      ),
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      useMaterial3: true,
      swapLegacyOnMaterial3: true,
      fontFamily: GoogleFonts.outfit().fontFamily,
    );
  }
}
