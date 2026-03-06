import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:point_hue/core/theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('PointHueTheme', () {
    test('brand colors are correctly defined', () {
      expect(PointHueTheme.darkCharcoal, const Color(0xFF121212));
      expect(PointHueTheme.galleryWhite, const Color(0xFFF5F5F5));
      expect(PointHueTheme.electricViolet, const Color(0xFF8F00FF));
      expect(PointHueTheme.vibrantCyan, const Color(0xFF00E5FF));
    });

    test('light theme is correctly configured', () {
      final theme = PointHueTheme.light;
      expect(theme.brightness, Brightness.light);
      expect(theme.colorScheme.primary, PointHueTheme.electricViolet);
      expect(theme.colorScheme.secondary, PointHueTheme.vibrantCyan);
      expect(theme.scaffoldBackgroundColor, PointHueTheme.galleryWhite);
      expect(theme.useMaterial3, isTrue);
      expect(
        theme.textTheme.bodyLarge?.fontFamily,
        GoogleFonts.outfit().fontFamily,
      );
    });

    test('dark theme is correctly configured', () {
      final theme = PointHueTheme.dark;
      expect(theme.brightness, Brightness.dark);
      expect(theme.colorScheme.primary, PointHueTheme.vibrantCyan);
      expect(theme.colorScheme.secondary, PointHueTheme.electricViolet);
      expect(theme.scaffoldBackgroundColor, PointHueTheme.darkCharcoal);
      expect(theme.useMaterial3, isTrue);
      expect(
        theme.textTheme.bodyLarge?.fontFamily,
        GoogleFonts.outfit().fontFamily,
      );
    });
  });
}
