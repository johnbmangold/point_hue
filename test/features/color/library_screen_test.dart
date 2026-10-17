import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:point_hue/features/color/color_model.dart';
import 'package:point_hue/features/color/color_repository.dart';
import 'package:point_hue/features/color/library_screen.dart';
import 'package:point_hue/core/theme.dart';

void main() {
  testWidgets('LibraryScreen displays saved colors', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          colorLibraryProvider.overrideWith(() => FakeLibraryNotifier()),
          colorHistoryProvider.overrideWith(() => FakeHistoryNotifier()),
        ],
        child: MaterialApp(
          theme: PointHueTheme.light,
          home: const LibraryScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify structure
    expect(find.text('Color Library'), findsOneWidget);
    expect(find.text('Saved'), findsOneWidget);
    expect(find.text('History'), findsOneWidget);

    // Verify saved colors
    expect(find.text('Test Red'), findsOneWidget);
    expect(find.text('#FF0000'), findsOneWidget);
  });

  testWidgets('LibraryScreen toggles between list and grid views', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          colorLibraryProvider.overrideWith(() => FakeLibraryNotifier()),
          colorHistoryProvider.overrideWith(() => FakeHistoryNotifier()),
        ],
        child: MaterialApp(
          theme: PointHueTheme.light,
          home: const LibraryScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Default is list view, so grid icon is shown
    expect(find.byIcon(Icons.grid_view), findsOneWidget);

    // Tap to switch to grid view
    await tester.tap(find.byIcon(Icons.grid_view));
    await tester.pumpAndSettle();

    // Now in grid view, list icon is shown
    expect(find.byIcon(Icons.view_list), findsOneWidget);
    expect(find.text('Test Red'), findsOneWidget);
  });

  testWidgets('LibraryScreen shows empty state', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          colorLibraryProvider.overrideWith(() => FakeEmptyLibraryNotifier()),
          colorHistoryProvider.overrideWith(() => FakeHistoryNotifier()),
        ],
        child: MaterialApp(
          theme: PointHueTheme.light,
          home: const LibraryScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify empty state message
    expect(find.text('No colors yet'), findsOneWidget);
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

class FakeEmptyLibraryNotifier extends ColorLibraryNotifier {
  @override
  Future<List<ColorModel>> build() async {
    return [];
  }
}

class FakeHistoryNotifier extends ColorHistoryNotifier {
  @override
  Future<List<ColorModel>> build() async {
    return [];
  }
}
