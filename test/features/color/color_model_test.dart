import 'package:flutter_test/flutter_test.dart';
import 'package:point_hue/features/color/color_model.dart';

void main() {
  group('ColorModel', () {
    const testColor = ColorModel(
      hex: '#FF0000',
      r: 255,
      g: 0,
      b: 0,
      name: 'Red',
    );

    test('toJson and fromJson should be consistent', () {
      final json = testColor.toJson();
      final fromJson = ColorModel.fromJson(json);
      expect(fromJson, testColor);
    });

    test('toColor should return correct Flutter Color', () {
      final color = testColor.toColor();
      expect(color.r, 1.0);
      expect(color.g, 0.0);
      expect(color.b, 0.0);
      expect(color.a, 1.0);
    });

    test('rgbString should be formatted correctly', () {
      expect(testColor.rgbString, 'RGB(255, 0, 0)');
    });

    test('copyWith should update fields correctly', () {
      final updated = testColor.copyWith(isLocked: true);
      expect(updated.isLocked, true);
      expect(updated.hex, testColor.hex);
    });
  });
}
