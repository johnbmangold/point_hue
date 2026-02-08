import 'package:flutter/material.dart';

class ColorNames {
  static String getName(Color color) {
    // A simplified list of colors for naming.
    // In a production app, we could use a much larger dataset.
    final Map<String, Color> colorMap = {
      'Red': Colors.red,
      'Pink': Colors.pink,
      'Purple': Colors.purple,
      'Deep Purple': Colors.deepPurple,
      'Indigo': Colors.indigo,
      'Blue': Colors.blue,
      'Light Blue': Colors.lightBlue,
      'Cyan': Colors.cyan,
      'Teal': Colors.teal,
      'Green': Colors.green,
      'Light Green': Colors.lightGreen,
      'Lime': Colors.lime,
      'Yellow': Colors.yellow,
      'Amber': Colors.amber,
      'Orange': Colors.orange,
      'Deep Orange': Colors.deepOrange,
      'Brown': Colors.brown,
      'Grey': Colors.grey,
      'Blue Grey': Colors.blueGrey,
      'Black': Colors.black,
      'White': Colors.white,
    };

    String closestName = 'Unknown';
    double minDistance = double.infinity;

    for (var entry in colorMap.entries) {
      final distance = _colorDistance(color, entry.value);
      if (distance < minDistance) {
        minDistance = distance;
        closestName = entry.key;
      }
    }

    return closestName;
  }

  static double _colorDistance(Color c1, Color c2) {
    final dr = (c1.r * 255).toInt() - (c2.r * 255).toInt();
    final dg = (c1.g * 255).toInt() - (c2.g * 255).toInt();
    final db = (c1.b * 255).toInt() - (c2.b * 255).toInt();
    return dr * dr + dg * dg + db * db.toDouble();
  }
}
