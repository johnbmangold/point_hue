import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:point_hue/features/color/color_model.dart';

void main() {
  group('ColorModel', () {
    test('supports value equality', () {
      const color1 = ColorModel(
        hex: '#FFFFFF',
        r: 255,
        g: 255,
        b: 255,
        name: 'White',
      );
      const color2 = ColorModel(
        hex: '#FFFFFF',
        r: 255,
        g: 255,
        b: 255,
        name: 'White',
      );
      expect(color1, equals(color2));
    });

    test('toColor returns correct Color object', () {
      const model = ColorModel(hex: '#FF0000', r: 255, g: 0, b: 0, name: 'Red');
      expect(model.toColor(), const Color(0xFFFF0000));
    });

    test('rgbString returns correct string format', () {
      const model = ColorModel(
        hex: '#00FF00',
        r: 0,
        g: 255,
        b: 0,
        name: 'Green',
      );
      expect(model.rgbString, 'RGB(0, 255, 0)');
    });

    test('hslString returns correct format', () {
      const red = ColorModel(hex: '#FF0000', r: 255, g: 0, b: 0, name: 'Red');
      // Red is HSL(0°, 100%, 50%)
      expect(red.hslString, contains('0°'));
      expect(red.hslString, contains('100%'));
      expect(red.hslString, contains('50%'));
    });

    test('hsvString returns correct format', () {
      const red = ColorModel(hex: '#FF0000', r: 255, g: 0, b: 0, name: 'Red');
      // Red is HSV(0°, 100%, 100%)
      expect(red.hsvString, contains('0°'));
      expect(red.hsvString, contains('100%'));
    });

    test('contrastForeground returns black for light colors', () {
      const white = ColorModel(
        hex: '#FFFFFF',
        r: 255,
        g: 255,
        b: 255,
        name: 'White',
      );
      expect(white.contrastForeground, Colors.black);
    });

    test('contrastForeground returns white for dark colors', () {
      const black = ColorModel(hex: '#000000', r: 0, g: 0, b: 0, name: 'Black');
      expect(black.contrastForeground, Colors.white);
    });

    test('complementary returns opposite color', () {
      const red = ColorModel(hex: '#FF0000', r: 255, g: 0, b: 0, name: 'Red');
      final comp = red.complementary;
      // Complementary of red is cyan-ish
      expect((comp.r * 255.0).round().clamp(0, 255), 0);
      expect((comp.g * 255.0).round().clamp(0, 255), 255);
      expect((comp.b * 255.0).round().clamp(0, 255), 255);
    });

    test('distanceTo calculates correctly', () {
      const black = ColorModel(hex: '#000000', r: 0, g: 0, b: 0, name: 'Black');
      const white = ColorModel(
        hex: '#FFFFFF',
        r: 255,
        g: 255,
        b: 255,
        name: 'White',
      );
      // sqrt(255^2 * 3) ≈ 441.67
      expect(black.distanceTo(white), closeTo(441.67, 0.1));
    });

    test('fromJson creates correct instance', () {
      final json = {
        'hex': '#0000FF',
        'r': 0,
        'g': 0,
        'b': 255,
        'name': 'Blue',
        'isLocked': false,
      };
      final model = ColorModel.fromJson(json);
      expect(model.hex, '#0000FF');
      expect(model.r, 0);
      expect(model.g, 0);
      expect(model.b, 255);
      expect(model.name, 'Blue');
      expect(model.isLocked, false);
    });
  });
}
