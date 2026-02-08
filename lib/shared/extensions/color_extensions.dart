import 'dart:math';
import 'package:flutter/material.dart';

class ColorNames {
  static String getName(Color color) {
    final lab = _rgbToLab(color);

    String closestName = 'Unknown';
    double minDistance = double.infinity;

    for (var entry in _namedColors.entries) {
      // Convert map RGB to Lab on the fly or pre-calculate?
      // For 140 items, on-the-fly is fine, but pre-calculation key would be better if this class was instantiated.
      // Since it's static, let's just do it on the fly for simplicity of code structure.
      // Optimization: we could store the map as <String, LabColor> if needed.
      final entryLab = _rgbToLab(entry.value);
      final distance = _labDistance(lab, entryLab);

      if (distance < minDistance) {
        minDistance = distance;
        closestName = entry.key;
      }
    }

    return closestName;
  }

  // CIELAB distance (Delta E 1976)
  static double _labDistance(_LabColor c1, _LabColor c2) {
    final dl = c1.l - c2.l;
    final da = c1.a - c2.a;
    final db = c1.b - c2.b;
    return sqrt(dl * dl + da * da + db * db);
  }

  static _LabColor _rgbToLab(Color color) {
    // 1. RGB to XYZ
    double r = color.r;
    double g = color.g;
    double b = color.b;

    // Linearize RGB
    if (r > 0.04045) {
      r = pow((r + 0.055) / 1.055, 2.4) as double;
    } else {
      r = r / 12.92;
    }
    if (g > 0.04045) {
      g = pow((g + 0.055) / 1.055, 2.4) as double;
    } else {
      g = g / 12.92;
    }
    if (b > 0.04045) {
      b = pow((b + 0.055) / 1.055, 2.4) as double;
    } else {
      b = b / 12.92;
    }

    r *= 100;
    g *= 100;
    b *= 100;

    // Observer. = 2°, Illuminant = D65
    double x = r * 0.4124 + g * 0.3576 + b * 0.1805;
    double y = r * 0.2126 + g * 0.7152 + b * 0.0722;
    double z = r * 0.0193 + g * 0.1192 + b * 0.9505;

    // 2. XYZ to Lab
    // Reference white D65
    x /= 95.047;
    y /= 100.000;
    z /= 108.883;

    if (x > 0.008856) {
      x = pow(x, 1 / 3) as double;
    } else {
      x = (7.787 * x) + (16 / 116);
    }
    if (y > 0.008856) {
      y = pow(y, 1 / 3) as double;
    } else {
      y = (7.787 * y) + (16 / 116);
    }
    if (z > 0.008856) {
      z = pow(z, 1 / 3) as double;
    } else {
      z = (7.787 * z) + (16 / 116);
    }

    final l = (116 * y) - 16;
    final a = 500 * (x - y);
    final bMetric = 200 * (y - z); // 'b' is a valid variable name here

    return _LabColor(l, a, bMetric);
  }

  // Standard Web Colors (CSS Level 3/4) (~140 colors)
  static const Map<String, Color> _namedColors = {
    'Alice Blue': Color(0xFFF0F8FF),
    'Antique White': Color(0xFFFAEBD7),
    'Aqua': Color(0xFF00FFFF),
    'Aquamarine': Color(0xFF7FFFD4),
    'Azure': Color(0xFFF0FFFF),
    'Beige': Color(0xFFF5F5DC),
    'Bisque': Color(0xFFFFE4C4),
    'Black': Color(0xFF000000),
    'Blanched Almond': Color(0xFFFFEBCD),
    'Blue': Color(0xFF0000FF),
    'Blue Violet': Color(0xFF8A2BE2),
    'Brown': Color(0xFFA52A2A),
    'Burlywood': Color(0xFFDEB887),
    'Cadet Blue': Color(0xFF5F9EA0),
    'Chartreuse': Color(0xFF7FFF00),
    'Chocolate': Color(0xFFD2691E),
    'Coral': Color(0xFFFF7F50),
    'Cornflower Blue': Color(0xFF6495ED),
    'Cornsilk': Color(0xFFFFF8DC),
    'Crimson': Color(0xFFDC143C),
    'Cyan': Color(0xFF00FFFF),
    'Dark Blue': Color(0xFF00008B),
    'Dark Cyan': Color(0xFF008B8B),
    'Dark Goldenrod': Color(0xFFB8860B),
    'Dark Gray': Color(0xFFA9A9A9),
    'Dark Green': Color(0xFF006400),
    'Dark Khaki': Color(0xFFBDB76B),
    'Dark Magenta': Color(0xFF8B008B),
    'Dark Olive Green': Color(0xFF556B2F),
    'Dark Orange': Color(0xFFFF8C00),
    'Dark Orchid': Color(0xFF9932CC),
    'Dark Red': Color(0xFF8B0000),
    'Dark Salmon': Color(0xFFE9967A),
    'Dark Sea Green': Color(0xFF8FBC8F),
    'Dark Slate Blue': Color(0xFF483D8B),
    'Dark Slate Gray': Color(0xFF2F4F4F),
    'Dark Turquoise': Color(0xFF00CED1),
    'Dark Violet': Color(0xFF9400D3),
    'Deep Pink': Color(0xFFFF1493),
    'Deep Sky Blue': Color(0xFF00BFFF),
    'Dim Gray': Color(0xFF696969),
    'Dodger Blue': Color(0xFF1E90FF),
    'Firebrick': Color(0xFFB22222),
    'Floral White': Color(0xFFFFFAF0),
    'Forest Green': Color(0xFF228B22),
    'Fuchsia': Color(0xFFFF00FF),
    'Gainsboro': Color(0xFFDCDCDC),
    'Ghost White': Color(0xFFF8F8FF),
    'Gold': Color(0xFFFFD700),
    'Goldenrod': Color(0xFFDAA520),
    'Gray': Color(0xFF808080),
    'Green': Color(0xFF008000),
    'Green Yellow': Color(0xFFADFF2F),
    'Honeydew': Color(0xFFF0FFF0),
    'Hot Pink': Color(0xFFFF69B4),
    'Indian Red': Color(0xFFCD5C5C),
    'Indigo': Color(0xFF4B0082),
    'Ivory': Color(0xFFFFFFF0),
    'Khaki': Color(0xFFF0E68C),
    'Lavender': Color(0xFFE6E6FA),
    'Lavender Blush': Color(0xFFFFF0F5),
    'Lawn Green': Color(0xFF7CFC00),
    'Lemon Chiffon': Color(0xFFFFFACD),
    'Light Blue': Color(0xFFADD8E6),
    'Light Coral': Color(0xFFF08080),
    'Light Cyan': Color(0xFFE0FFFF),
    'Light Goldenrod Yellow': Color(0xFFFAFAD2),
    'Light Gray': Color(0xFFD3D3D3),
    'Light Green': Color(0xFF90EE90),
    'Light Pink': Color(0xFFFFB6C1),
    'Light Salmon': Color(0xFFFFA07A),
    'Light Sea Green': Color(0xFF20B2AA),
    'Light Sky Blue': Color(0xFF87CEFA),
    'Light Slate Gray': Color(0xFF778899),
    'Light Steel Blue': Color(0xFFB0C4DE),
    'Light Yellow': Color(0xFFFFFFE0),
    'Lime': Color(0xFF00FF00),
    'Lime Green': Color(0xFF32CD32),
    'Linen': Color(0xFFFAF0E6),
    'Magenta': Color(0xFFFF00FF),
    'Maroon': Color(0xFF800000),
    'Medium Aquamarine': Color(0xFF66CDAA),
    'Medium Blue': Color(0xFF0000CD),
    'Medium Orchid': Color(0xFFBA55D3),
    'Medium Purple': Color(0xFF9370DB),
    'Medium Sea Green': Color(0xFF3CB371),
    'Medium Slate Blue': Color(0xFF7B68EE),
    'Medium Spring Green': Color(0xFF00FA9A),
    'Medium Turquoise': Color(0xFF48D1CC),
    'Medium Violet Red': Color(0xFFC71585),
    'Midnight Blue': Color(0xFF191970),
    'Mint Cream': Color(0xFFF5FFFA),
    'Misty Rose': Color(0xFFFFE4E1),
    'Moccasin': Color(0xFFFFE4B5),
    'Navajo White': Color(0xFFFFDEAD),
    'Navy': Color(0xFF000080),
    'Old Lace': Color(0xFFFDF5E6),
    'Olive': Color(0xFF808000),
    'Olive Drab': Color(0xFF6B8E23),
    'Orange': Color(0xFFFFA500),
    'Orange Red': Color(0xFFFF4500),
    'Orchid': Color(0xFFDA70D6),
    'Pale Goldenrod': Color(0xFFEEE8AA),
    'Pale Green': Color(0xFF98FB98),
    'Pale Turquoise': Color(0xFFAFEEEE),
    'Pale Violet Red': Color(0xFFDB7093),
    'Papaya Whip': Color(0xFFFFEFD5),
    'Peach Puff': Color(0xFFFFDAB9),
    'Peru': Color(0xFFCD853F),
    'Pink': Color(0xFFFFC0CB),
    'Plum': Color(0xFFDDA0DD),
    'Powder Blue': Color(0xFFB0E0E6),
    'Purple': Color(0xFF800080),
    'Rebecca Purple': Color(0xFF663399),
    'Red': Color(0xFFFF0000),
    'Rosy Brown': Color(0xFFBC8F8F),
    'Royal Blue': Color(0xFF4169E1),
    'Saddle Brown': Color(0xFF8B4513),
    'Salmon': Color(0xFFFA8072),
    'Sandy Brown': Color(0xFFF4A460),
    'Sea Green': Color(0xFF2E8B57),
    'Seashell': Color(0xFFFFF5EE),
    'Sienna': Color(0xFFA0522D),
    'Silver': Color(0xFFC0C0C0),
    'Sky Blue': Color(0xFF87CEEB),
    'Slate Blue': Color(0xFF6A5ACD),
    'Slate Gray': Color(0xFF708090),
    'Snow': Color(0xFFFFFAFA),
    'Spring Green': Color(0xFF00FF7F),
    'Steel Blue': Color(0xFF4682B4),
    'Tan': Color(0xFFD2B48C),
    'Teal': Color(0xFF008080),
    'Thistle': Color(0xFFD8BFD8),
    'Tomato': Color(0xFFFF6347),
    'Turquoise': Color(0xFF40E0D0),
    'Violet': Color(0xFFEE82EE),
    'Wheat': Color(0xFFF5DEB3),
    'White': Color(0xFFFFFFFF),
    'White Smoke': Color(0xFFF5F5F5),
    'Yellow': Color(0xFFFFFF00),
    'Yellow Green': Color(0xFF9ACD32),
  };
}

class _LabColor {
  final double l;
  final double a;
  final double b;

  const _LabColor(this.l, this.a, this.b);
}
