// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'color_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ColorModel {

 String get hex; int get r; int get g; int get b; String get name; bool get isLocked; DateTime? get timestamp;
/// Create a copy of ColorModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ColorModelCopyWith<ColorModel> get copyWith => _$ColorModelCopyWithImpl<ColorModel>(this as ColorModel, _$identity);

  /// Serializes this ColorModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ColorModel&&(identical(other.hex, hex) || other.hex == hex)&&(identical(other.r, r) || other.r == r)&&(identical(other.g, g) || other.g == g)&&(identical(other.b, b) || other.b == b)&&(identical(other.name, name) || other.name == name)&&(identical(other.isLocked, isLocked) || other.isLocked == isLocked)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,hex,r,g,b,name,isLocked,timestamp);

@override
String toString() {
  return 'ColorModel(hex: $hex, r: $r, g: $g, b: $b, name: $name, isLocked: $isLocked, timestamp: $timestamp)';
}


}

/// @nodoc
abstract mixin class $ColorModelCopyWith<$Res>  {
  factory $ColorModelCopyWith(ColorModel value, $Res Function(ColorModel) _then) = _$ColorModelCopyWithImpl;
@useResult
$Res call({
 String hex, int r, int g, int b, String name, bool isLocked, DateTime? timestamp
});




}
/// @nodoc
class _$ColorModelCopyWithImpl<$Res>
    implements $ColorModelCopyWith<$Res> {
  _$ColorModelCopyWithImpl(this._self, this._then);

  final ColorModel _self;
  final $Res Function(ColorModel) _then;

/// Create a copy of ColorModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? hex = null,Object? r = null,Object? g = null,Object? b = null,Object? name = null,Object? isLocked = null,Object? timestamp = freezed,}) {
  return _then(_self.copyWith(
hex: null == hex ? _self.hex : hex // ignore: cast_nullable_to_non_nullable
as String,r: null == r ? _self.r : r // ignore: cast_nullable_to_non_nullable
as int,g: null == g ? _self.g : g // ignore: cast_nullable_to_non_nullable
as int,b: null == b ? _self.b : b // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,isLocked: null == isLocked ? _self.isLocked : isLocked // ignore: cast_nullable_to_non_nullable
as bool,timestamp: freezed == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [ColorModel].
extension ColorModelPatterns on ColorModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ColorModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ColorModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ColorModel value)  $default,){
final _that = this;
switch (_that) {
case _ColorModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ColorModel value)?  $default,){
final _that = this;
switch (_that) {
case _ColorModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String hex,  int r,  int g,  int b,  String name,  bool isLocked,  DateTime? timestamp)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ColorModel() when $default != null:
return $default(_that.hex,_that.r,_that.g,_that.b,_that.name,_that.isLocked,_that.timestamp);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String hex,  int r,  int g,  int b,  String name,  bool isLocked,  DateTime? timestamp)  $default,) {final _that = this;
switch (_that) {
case _ColorModel():
return $default(_that.hex,_that.r,_that.g,_that.b,_that.name,_that.isLocked,_that.timestamp);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String hex,  int r,  int g,  int b,  String name,  bool isLocked,  DateTime? timestamp)?  $default,) {final _that = this;
switch (_that) {
case _ColorModel() when $default != null:
return $default(_that.hex,_that.r,_that.g,_that.b,_that.name,_that.isLocked,_that.timestamp);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ColorModel extends ColorModel {
  const _ColorModel({required this.hex, required this.r, required this.g, required this.b, required this.name, this.isLocked = false, this.timestamp}): super._();
  factory _ColorModel.fromJson(Map<String, dynamic> json) => _$ColorModelFromJson(json);

@override final  String hex;
@override final  int r;
@override final  int g;
@override final  int b;
@override final  String name;
@override@JsonKey() final  bool isLocked;
@override final  DateTime? timestamp;

/// Create a copy of ColorModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ColorModelCopyWith<_ColorModel> get copyWith => __$ColorModelCopyWithImpl<_ColorModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ColorModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ColorModel&&(identical(other.hex, hex) || other.hex == hex)&&(identical(other.r, r) || other.r == r)&&(identical(other.g, g) || other.g == g)&&(identical(other.b, b) || other.b == b)&&(identical(other.name, name) || other.name == name)&&(identical(other.isLocked, isLocked) || other.isLocked == isLocked)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,hex,r,g,b,name,isLocked,timestamp);

@override
String toString() {
  return 'ColorModel(hex: $hex, r: $r, g: $g, b: $b, name: $name, isLocked: $isLocked, timestamp: $timestamp)';
}


}

/// @nodoc
abstract mixin class _$ColorModelCopyWith<$Res> implements $ColorModelCopyWith<$Res> {
  factory _$ColorModelCopyWith(_ColorModel value, $Res Function(_ColorModel) _then) = __$ColorModelCopyWithImpl;
@override @useResult
$Res call({
 String hex, int r, int g, int b, String name, bool isLocked, DateTime? timestamp
});




}
/// @nodoc
class __$ColorModelCopyWithImpl<$Res>
    implements _$ColorModelCopyWith<$Res> {
  __$ColorModelCopyWithImpl(this._self, this._then);

  final _ColorModel _self;
  final $Res Function(_ColorModel) _then;

/// Create a copy of ColorModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? hex = null,Object? r = null,Object? g = null,Object? b = null,Object? name = null,Object? isLocked = null,Object? timestamp = freezed,}) {
  return _then(_ColorModel(
hex: null == hex ? _self.hex : hex // ignore: cast_nullable_to_non_nullable
as String,r: null == r ? _self.r : r // ignore: cast_nullable_to_non_nullable
as int,g: null == g ? _self.g : g // ignore: cast_nullable_to_non_nullable
as int,b: null == b ? _self.b : b // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,isLocked: null == isLocked ? _self.isLocked : isLocked // ignore: cast_nullable_to_non_nullable
as bool,timestamp: freezed == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
