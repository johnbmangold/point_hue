import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:point_hue/features/color/color_model.dart';
import 'package:point_hue/features/color/color_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ColorLibraryNotifier', () {
    late ProviderContainer container;
    const testColor = ColorModel(
      hex: '#FF0000',
      r: 255,
      g: 0,
      b: 0,
      name: 'Red',
    );

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state should be empty', () async {
      final List<ColorModel> colors = await container.read(
        colorLibraryProvider.future,
      );
      expect(colors, isEmpty);
    });

    test('saveColor should add color to library', () async {
      final notifier = container.read(colorLibraryProvider.notifier);
      await notifier.saveColor(testColor);

      final List<ColorModel> colors = await container.read(
        colorLibraryProvider.future,
      );
      expect(colors.length, 1);
      expect(colors.first.hex, testColor.hex);
    });

    test('removeColor should remove color from library', () async {
      final notifier = container.read(colorLibraryProvider.notifier);
      await notifier.saveColor(testColor);

      List<ColorModel> colors = await container.read(
        colorLibraryProvider.future,
      );
      expect(colors.length, 1);

      await notifier.removeColor(testColor.hex);
      colors = await container.read(colorLibraryProvider.future);
      expect(colors, isEmpty);
    });

    test('saveColor should avoid duplicates', () async {
      final notifier = container.read(colorLibraryProvider.notifier);
      await notifier.saveColor(testColor);
      await notifier.saveColor(testColor);

      final List<ColorModel> colors = await container.read(
        colorLibraryProvider.future,
      );
      expect(colors.length, 1);
    });
  });

  group('ColorHistoryNotifier', () {
    late ProviderContainer container;
    const testColor1 = ColorModel(
      hex: '#FF0000',
      r: 255,
      g: 0,
      b: 0,
      name: 'Red',
    );
    const testColor2 = ColorModel(
      hex: '#00FF00',
      r: 0,
      g: 255,
      b: 0,
      name: 'Green',
    );

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('addRecord should add color to history', () async {
      final notifier = container.read(colorHistoryProvider.notifier);
      await notifier.addRecord(testColor1);

      final List<ColorModel> history = await container.read(
        colorHistoryProvider.future,
      );
      expect(history.length, 1);
      expect(history.first.hex, testColor1.hex);
    });

    test('addRecord should not add consecutive duplicate colors', () async {
      final notifier = container.read(colorHistoryProvider.notifier);
      await notifier.addRecord(testColor1);
      await notifier.addRecord(testColor1);

      final List<ColorModel> history = await container.read(
        colorHistoryProvider.future,
      );
      expect(history.length, 1);
    });

    test('history should respect max limit of 20', () async {
      final notifier = container.read(colorHistoryProvider.notifier);

      for (var i = 0; i < 25; i++) {
        await notifier.addRecord(
          ColorModel(hex: '#$i', r: i, g: i, b: i, name: 'Color $i'),
        );
      }

      final List<ColorModel> history = await container.read(
        colorHistoryProvider.future,
      );
      expect(history.length, 20);
    });
  });
}
