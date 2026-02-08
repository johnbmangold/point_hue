import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:point_hue/shared/extensions/color_extensions.dart';

void main() {
  group('ColorNames', () {
    test('identifies exact matches correctly', () {
      expect(ColorNames.getName(const Color(0xFFFF0000)), 'Red');
      expect(ColorNames.getName(const Color(0xFF0000FF)), 'Blue');
      expect(ColorNames.getName(const Color(0xFF008000)), 'Green');
      expect(ColorNames.getName(const Color(0xFFFFFFFF)), 'White');
      expect(ColorNames.getName(const Color(0xFF000000)), 'Black');
    });

    test('identifies close matches correctly using CIELAB', () {
      // Slightly off-red should still be Red
      expect(ColorNames.getName(const Color(0xFFFE0101)), 'Red');

      // A mix that is visually close to Teal
      expect(ColorNames.getName(const Color(0xFF008081)), 'Teal');
    });

    test('distinguishes between similar colors', () {
      // Lime vs Green
      expect(ColorNames.getName(const Color(0xFF00FF00)), 'Lime');
      expect(ColorNames.getName(const Color(0xFF008000)), 'Green');

      // Cyan vs Sky Blue
      expect(ColorNames.getName(const Color(0xFF00FFFF)), 'Cyan');
      // Sky Blue is 0xFF87CEEB
      expect(ColorNames.getName(const Color(0xFF87CEEB)), 'Sky Blue');
    });
  });
}
