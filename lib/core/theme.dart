import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PointHueTheme {
  // Brand Colors
  static const Color darkCharcoal = Color(0xFF121212);
  static const Color galleryWhite = Color(0xFFF5F5F5);
  static const Color electricViolet = Color(0xFF8F00FF);
  static const Color vibrantCyan = Color(0xFF00E5FF);

  static ThemeData light = FlexThemeData.light(
    colors: const FlexSchemeColor(
      primary: electricViolet,
      primaryContainer: Color(0xFFD0E4FF),
      secondary: vibrantCyan,
      secondaryContainer: Color(0xFFFFDBAF),
      tertiary: Color(0xFF006875),
      tertiaryContainer: Color(0xFF95F0FF),
      appBarColor: galleryWhite,
      error: Color(0xFFB00020),
    ),
    surface: galleryWhite,
    scaffoldBackground: galleryWhite,
    usedColors: 2,
    surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
    blendLevel: 7,
    subThemesData: const FlexSubThemesData(
      blendOnLevel: 10,
      blendOnColors: false,
      useMaterial3Typography: true,
      useM2StyleDividerInM3: true,
      alignedDropdown: true,
      useInputDecoratorThemeInDialogs: true,
    ),
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    useMaterial3: true,
    fontFamily: GoogleFonts.outfit().fontFamily,
  );

  static ThemeData dark = FlexThemeData.dark(
    colors: const FlexSchemeColor(
      primary: vibrantCyan,
      primaryContainer: Color(0xFF00325B),
      secondary: electricViolet,
      secondaryContainer: Color(0xFF872100),
      tertiary: Color(0xFF86D2E1),
      tertiaryContainer: Color(0xFF004E59),
      appBarColor: darkCharcoal,
      error: Color(0xFFCF6679),
    ),
    surface: darkCharcoal,
    scaffoldBackground: darkCharcoal,
    usedColors: 2,
    surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
    blendLevel: 13,
    subThemesData: const FlexSubThemesData(
      blendOnLevel: 20,
      useMaterial3Typography: true,
      useM2StyleDividerInM3: true,
      alignedDropdown: true,
      useInputDecoratorThemeInDialogs: true,
    ),
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    useMaterial3: true,
    fontFamily: GoogleFonts.outfit().fontFamily,
  );
}
