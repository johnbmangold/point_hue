import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'color_model.freezed.dart';
part 'color_model.g.dart';

/// Represents a detected or saved color with both the raw
/// sampled values and the closest named-color match.
@freezed
abstract class ColorModel with _$ColorModel {
  const factory ColorModel({
    required String hex,
    required int r,
    required int g,
    required int b,
    required String name,
    @Default(false) bool isLocked,
    DateTime? timestamp,
  }) = _ColorModel;

  factory ColorModel.fromJson(Map<String, dynamic> json) =>
      _$ColorModelFromJson(json);

  const ColorModel._();

  /// Reconstructs a [Color] from the stored RGB values.
  Color toColor() => Color.fromARGB(255, r, g, b);

  /// Formatted RGB string for display.
  String get rgbString => 'RGB($r, $g, $b)';

  /// Converts to HSL and returns a formatted string.
  String get hslString {
    final hsl = HSLColor.fromColor(toColor());
    return 'HSL('
        '${hsl.hue.round()}°, '
        '${(hsl.saturation * 100).round()}%, '
        '${(hsl.lightness * 100).round()}%)';
  }

  /// Converts to HSV and returns a formatted string.
  String get hsvString {
    final hsv = HSVColor.fromColor(toColor());
    return 'HSV('
        '${hsv.hue.round()}°, '
        '${(hsv.saturation * 100).round()}%, '
        '${(hsv.value * 100).round()}%)';
  }

  /// Returns the HSL hue (0–360).
  double get hue => HSLColor.fromColor(toColor()).hue;

  /// Returns the HSL saturation (0.0–1.0).
  double get saturation => HSLColor.fromColor(toColor()).saturation;

  /// Returns the HSL lightness (0.0–1.0).
  double get lightness => HSLColor.fromColor(toColor()).lightness;

  /// Generates a complementary color.
  Color get complementary {
    final hsl = HSLColor.fromColor(toColor());
    return hsl.withHue((hsl.hue + 180) % 360).toColor();
  }

  /// Estimated luminance — useful for choosing
  /// contrasting text.
  double get relativeLuminance => toColor().computeLuminance();

  /// Returns [Colors.white] or [Colors.black] depending
  /// on which provides better contrast.
  Color get contrastForeground =>
      relativeLuminance > 0.5 ? Colors.black : Colors.white;

  /// Euclidean distance to [other] in RGB space.
  double distanceTo(ColorModel other) {
    final dr = r - other.r;
    final dg = g - other.g;
    final db = b - other.b;
    return math.sqrt(dr * dr + dg * dg + db * db);
  }
}
