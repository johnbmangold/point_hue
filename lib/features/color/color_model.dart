import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'color_model.freezed.dart';
part 'color_model.g.dart';

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

  Color toColor() => Color.fromARGB(255, r, g, b);

  String get rgbString => 'RGB($r, $g, $b)';
}
