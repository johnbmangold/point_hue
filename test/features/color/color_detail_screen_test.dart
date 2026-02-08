import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:point_hue/features/color/color_detail_screen.dart';
import 'package:point_hue/features/color/color_model.dart';
import 'package:point_hue/features/color/color_repository.dart';

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
        child: const MaterialApp(home: ColorDetailScreen(hex: '00FF00')),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Test Green'), findsOneWidget);
    expect(find.text('#00FF00'), findsOneWidget);

    // Check contrast section
    expect(find.text('Accessibility (WCAG)'), findsOneWidget);

    // Check export
    expect(find.text('CSS'), findsOneWidget);
    expect(find.text('JSON'), findsOneWidget);
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
