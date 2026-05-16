import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:point_hue/features/color/color_detail_screen.dart';
import 'package:point_hue/features/color/color_model.dart';
import 'package:point_hue/features/color/color_repository.dart';
import 'package:point_hue/core/theme.dart';

void main() {
  testWidgets('ColorDetailScreen displays correct color info', (tester) async {
    const testColor = ColorModel(
      hex: '#00FF00',
      r: 0,
      g: 255,
      b: 0,
      name: 'Test Green',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          colorLibraryProvider.overrideWith(
            () => FakeLibraryNotifier([testColor]),
          ),
          colorHistoryProvider.overrideWith(() => FakeHistoryNotifier()),
        ],
        child: MaterialApp(
          theme: PointHueTheme.light,
          home: const ColorDetailScreen(hex: '00FF00'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Test Green'), findsOneWidget);
    expect(find.text('#00FF00'), findsWidgets);

    // Color values section
    expect(find.text('Values'), findsOneWidget);
    expect(find.text('HEX'), findsWidgets);
    expect(find.text('RGB'), findsWidgets);
    expect(find.text('HSL'), findsWidgets);
    expect(find.text('HSV'), findsOneWidget);

    // Accessibility section
    expect(find.text('Accessibility (WCAG 2.1)'), findsOneWidget);
    expect(find.text('White Text'), findsOneWidget);
    expect(find.text('Black Text'), findsOneWidget);

    // Export section
    expect(find.text('Export'), findsOneWidget);
    expect(find.text('Copy CSS'), findsOneWidget);
    expect(find.text('Copy Swift'), findsOneWidget);
    expect(find.text('Copy Flutter'), findsOneWidget);
  });

  testWidgets('contrast badges show correct pass/fail', (tester) async {
    // Pure white has very high contrast with black and
    // 1:1 with white.
    const testColor = ColorModel(
      hex: '#FFFFFF',
      r: 255,
      g: 255,
      b: 255,
      name: 'White',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          colorLibraryProvider.overrideWith(
            () => FakeLibraryNotifier([testColor]),
          ),
          colorHistoryProvider.overrideWith(() => FakeHistoryNotifier()),
        ],
        child: MaterialApp(
          theme: PointHueTheme.light,
          home: const ColorDetailScreen(hex: 'FFFFFF'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // One should be AAA (on black), one should be FAIL (on white)
    expect(find.text('FAIL'), findsOneWidget);
    expect(find.text('AAA'), findsOneWidget);
    expect(find.text('AA'), findsNothing);
  });
}

class FakeLibraryNotifier extends ColorLibraryNotifier {
  final List<ColorModel> _colors;
  FakeLibraryNotifier(this._colors);

  @override
  Future<List<ColorModel>> build() async {
    return _colors;
  }
}

class FakeHistoryNotifier extends ColorHistoryNotifier {
  @override
  Future<List<ColorModel>> build() async {
    return [];
  }
}
