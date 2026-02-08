import 'package:flutter_test/flutter_test.dart';
import 'package:point_hue/features/color/color_model.dart';
import 'package:point_hue/features/color/color_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('ColorLibraryNotifier', () {
    late ProviderContainer container;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state is empty', () async {
      final colors = await container.read(colorLibraryProvider.future);
      expect(colors, isEmpty);
    });

    test('saveColor adds a color', () async {
      final notifier = container.read(colorLibraryProvider.notifier);
      const color = ColorModel(hex: '#FF0000', r: 255, g: 0, b: 0, name: 'Red');

      await notifier.saveColor(color);

      final colors = await container.read(colorLibraryProvider.future);
      expect(colors.length, 1);
      expect(colors.first.hex, color.hex);
    });

    test('removeColor removes a color', () async {
      final notifier = container.read(colorLibraryProvider.notifier);
      const color = ColorModel(hex: '#FF0000', r: 255, g: 0, b: 0, name: 'Red');
      await notifier.saveColor(color);

      await notifier.removeColor(color.hex);

      final colors = await container.read(colorLibraryProvider.future);
      expect(colors, isEmpty);
    });
  });

  group('ColorHistoryNotifier', () {
    late ProviderContainer container;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('addRecord adds a color to history', () async {
      final notifier = container.read(colorHistoryProvider.notifier);
      const color = ColorModel(
        hex: '#00FF00',
        r: 0,
        g: 255,
        b: 0,
        name: 'Green',
      );

      await notifier.addRecord(color);

      final history = await container.read(colorHistoryProvider.future);
      expect(history.length, 1);
      expect(history.first.hex, color.hex);
    });

    test('addRecord does not duplicate consecutive colors', () async {
      final notifier = container.read(colorHistoryProvider.notifier);
      const color = ColorModel(
        hex: '#00FF00',
        r: 0,
        g: 255,
        b: 0,
        name: 'Green',
      );

      await notifier.addRecord(color);
      await notifier.addRecord(color);

      final history = await container.read(colorHistoryProvider.future);
      expect(history.length, 1);
    });
  });
}
