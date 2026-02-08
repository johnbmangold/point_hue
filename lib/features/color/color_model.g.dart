// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'color_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ColorModel _$ColorModelFromJson(Map<String, dynamic> json) => _ColorModel(
  hex: json['hex'] as String,
  r: (json['r'] as num).toInt(),
  g: (json['g'] as num).toInt(),
  b: (json['b'] as num).toInt(),
  name: json['name'] as String,
  isLocked: json['isLocked'] as bool? ?? false,
  timestamp: json['timestamp'] == null
      ? null
      : DateTime.parse(json['timestamp'] as String),
);

Map<String, dynamic> _$ColorModelToJson(_ColorModel instance) =>
    <String, dynamic>{
      'hex': instance.hex,
      'r': instance.r,
      'g': instance.g,
      'b': instance.b,
      'name': instance.name,
      'isLocked': instance.isLocked,
      'timestamp': instance.timestamp?.toIso8601String(),
    };
