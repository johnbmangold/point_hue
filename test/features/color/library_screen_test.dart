import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:point_hue/features/color/color_model.dart';
import 'package:point_hue/features/color/color_repository.dart';
import 'package:point_hue/features/color/library_screen.dart';

void main() {
  testWidgets('LibraryScreen displays saved colors', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          colorLibraryProvider.overrideWith(() => FakeLibraryNotifier()),
          colorHistoryProvider.overrideWith(() => FakeHistoryNotifier()),
        ],
        child: const MaterialApp(home: LibraryScreen()),
      ),
    );

    // Initial pump
    await tester.pumpAndSettle();

    // Verification
    expect(find.text('Color Library'), findsOneWidget);
    expect(find.text('Saved'), findsOneWidget);
    expect(find.text('History'), findsOneWidget);

    // Find our fake colors
    expect(find.text('Test Red'), findsOneWidget);
    expect(find.text('#FF0000'), findsOneWidget);
  });
}

class FakeLibraryNotifier extends ColorLibraryNotifier {
  @override
  Future<List<ColorModel>> build() async {
    return [
      const ColorModel(hex: '#FF0000', r: 255, g: 0, b: 0, name: 'Test Red'),
    ];
  }
}

class FakeHistoryNotifier extends ColorHistoryNotifier {
  @override
  Future<List<ColorModel>> build() async {
    return [];
  }
}
