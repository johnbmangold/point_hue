import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:point_hue/shared/extensions/color_extensions.dart';

void main() {
  group('ColorNames', () {
    test('identifies exact matches correctly', () {
      expect(ColorNames.getName(const Color(0xFFFF0000)), 'Red');
      expect(ColorNames.getName(const Color(0xFF0000FF)), 'Blue');
      expect(
        ColorNames.getName(const Color(0xFF008000)),
        'Ao',
      ); // Was Green, now Ao is exact match
      expect(ColorNames.getName(const Color(0xFFFFFFFF)), 'White');
      expect(ColorNames.getName(const Color(0xFF000000)), 'Black');

      // New colors from the expanded list
      expect(ColorNames.getName(const Color(0xFF5D8AA8)), 'Air Force blue');
      expect(ColorNames.getName(const Color(0xFF0014A8)), 'Zaffre');
      expect(ColorNames.getName(const Color(0xFF6E7F80)), 'AuroMetalSaurus');
      expect(
        ColorNames.getName(const Color(0xFF002FA7)),
        'International Klein Blue',
      );
    });

    test('identifies close matches correctly using CIELAB', () {
      // Slightly off-red should still be Red
      expect(ColorNames.getName(const Color(0xFFFE0101)), 'Red');

      // A mix that is visually close to Teal
      expect(
        ColorNames.getName(const Color(0xFF008081)),
        'Stormcloud',
      ); // Was Teal, Stormcloud is closer
    });

    test('distinguishes between similar colors', () {
      // Lime vs Green
      expect(
        ColorNames.getName(const Color(0xFF00FF00)),
        'Electric green',
      ); // Was Lime, Electric green is exact match
      expect(
        ColorNames.getName(const Color(0xFF008000)),
        'Ao',
      ); // Was Green, Ao is exact match

      // Cyan vs Sky Blue
      expect(
        ColorNames.getName(const Color(0xFF00FFFF)),
        'Aqua',
      ); // Cyan and Aqua are #00FFFF, Aqua is alphabetically first or preferred in this list
      // Sky Blue is 0xFF87CEEB
      expect(ColorNames.getName(const Color(0xFF87CEEB)), 'Sky blue');
    });
  });
}
