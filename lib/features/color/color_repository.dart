import 'dart:convert';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:point_hue/features/color/color_model.dart';

part 'color_repository.g.dart';

@riverpod
class ColorLibraryNotifier extends _$ColorLibraryNotifier {
  static const _key = 'color_library';

  @override
  Future<List<ColorModel>> build() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_key) ?? [];
    return data.map((e) => ColorModel.fromJson(jsonDecode(e))).toList();
  }

  Future<void> saveColor(ColorModel color) async {
    final colors = await future;
    if (colors.any((c) => c.hex == color.hex)) return; // Avoid duplicates

    final newList = [color.copyWith(timestamp: DateTime.now()), ...colors];
    state = AsyncData(newList);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _key,
      newList.map((e) => jsonEncode(e.toJson())).toList(),
    );
  }

  Future<void> removeColor(String hex) async {
    final colors = await future;
    final newList = colors.where((c) => c.hex != hex).toList();
    state = AsyncData(newList);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _key,
      newList.map((e) => jsonEncode(e.toJson())).toList(),
    );
  }
}

@riverpod
class ColorHistoryNotifier extends _$ColorHistoryNotifier {
  static const _key = 'color_history';
  static const _maxItems = 20;

  @override
  Future<List<ColorModel>> build() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_key) ?? [];
    return data.map((e) => ColorModel.fromJson(jsonDecode(e))).toList();
  }

  Future<void> addRecord(ColorModel color) async {
    final history = await future;
    // Don't add if it's the same as the last one
    if (history.isNotEmpty && history.first.hex == color.hex) return;

    final newList = [color.copyWith(timestamp: DateTime.now()), ...history];
    if (newList.length > _maxItems) newList.removeLast();

    state = AsyncData(newList);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _key,
      newList.map((e) => jsonEncode(e.toJson())).toList(),
    );
  }
}
