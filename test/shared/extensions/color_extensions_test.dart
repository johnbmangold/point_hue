import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:point_hue/shared/extensions/color_extensions.dart';

void main() {
  group('ColorNames', () {
    test('identifies exact matches correctly', () {
      expect(ColorNames.matchColor(const Color(0xFFFF0000)).name, 'Red');
      expect(ColorNames.matchColor(const Color(0xFF0000FF)).name, 'Blue');
      expect(
        ColorNames.matchColor(const Color(0xFF008000)).name,
        'Ao',
      ); // Was Green, now Ao is exact match
      expect(ColorNames.matchColor(const Color(0xFFFFFFFF)).name, 'White');
      expect(ColorNames.matchColor(const Color(0xFF000000)).name, 'Black');

      // New colors from the expanded list
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

      // A mix that is visually close to Teal
      expect(
        ColorNames.matchColor(const Color(0xFF008081)).name,
        'Stormcloud',
      ); // Was Teal, Stormcloud is closer
    });

    test('distinguishes between similar colors', () {
      // Lime vs Green
      expect(
        ColorNames.matchColor(const Color(0xFF00FF00)).name,
        'Electric green',
      ); // Was Lime, Electric green is exact match
      expect(
        ColorNames.matchColor(const Color(0xFF008000)).name,
        'Ao',
      ); // Was Green, Ao is exact match

      // Cyan vs Sky Blue
      expect(
        ColorNames.matchColor(const Color(0xFF00FFFF)).name,
        'Aqua',
      ); // Cyan and Aqua are #00FFFF, Aqua is alphabetically first or preferred in this list
      // Sky Blue is 0xFF87CEEB
      expect(ColorNames.matchColor(const Color(0xFF87CEEB)).name, 'Sky blue');
    });
  });
}
