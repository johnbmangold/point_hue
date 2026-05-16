import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:point_hue/shared/extensions/color_extensions.dart';

void main() {
  group('ColorNames', () {
    test('identifies exact matches correctly', () {
      expect(ColorNames.matchColor(const Color(0xFFFF0000)).name, 'Red');
      expect(ColorNames.matchColor(const Color(0xFF0000FF)).name, 'Blue');
      expect(ColorNames.matchColor(const Color(0xFF008000)).name, 'Ao');
      expect(ColorNames.matchColor(const Color(0xFFFFFFFF)).name, 'White');
      expect(ColorNames.matchColor(const Color(0xFF000000)).name, 'Black');

      // Expanded list colors
      expect(
        ColorNames.matchColor(const Color(0xFF5D8AA8)).name,
        'Air Force blue',
      );
      expect(ColorNames.matchColor(const Color(0xFF0014A8)).name, 'Zaffre');
      expect(
        ColorNames.matchColor(const Color(0xFF6E7F80)).name,
        'AuroMetalSaurus',
      );
      expect(
        ColorNames.matchColor(const Color(0xFF002FA7)).name,
        'International Klein Blue',
      );
    });

    test('identifies close matches correctly using CIELAB', () {
      // Slightly off-red should still be Red
      expect(ColorNames.matchColor(const Color(0xFFFE0101)).name, 'Red');

      // Near teal — Teal is now the sole entry for
      // 0xFF008080 (Stormcloud was removed as duplicate)
      expect(ColorNames.matchColor(const Color(0xFF008081)).name, 'Teal');
    });

    test('distinguishes between similar colors', () {
      // 0xFF00FF00 — Green is the primary name now
      // (Electric green was removed as duplicate)
      expect(ColorNames.matchColor(const Color(0xFF00FF00)).name, 'Green');
      expect(ColorNames.matchColor(const Color(0xFF008000)).name, 'Ao');

      // Cyan vs Sky Blue
      expect(ColorNames.matchColor(const Color(0xFF00FFFF)).name, 'Aqua');
      expect(ColorNames.matchColor(const Color(0xFF87CEEB)).name, 'Sky blue');
    });

    test('handles edge cases correctly', () {
      // Pure black
      final black = ColorNames.matchColor(const Color(0xFF000000));
      expect(black.name, 'Black');
      expect(black.color, const Color(0xFF000000));

      // Pure white
      final white = ColorNames.matchColor(const Color(0xFFFFFFFF));
      expect(white.name, 'White');
      expect(white.color, const Color(0xFFFFFFFF));

      // Mid-gray
      final gray = ColorNames.matchColor(const Color(0xFF808080));
      expect(gray.name, 'Gray');
    });

    test('returns a NamedColor with matching color', () {
      final result = ColorNames.matchColor(const Color(0xFFFF0000));
      expect(result.name, isNotEmpty);
      expect(result.color, isNotNull);
    });
  });
}
