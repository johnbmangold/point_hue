// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'camera_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CameraState {

 CameraController get controller; int get currentCameraIndex; bool get isFlashOn;
/// Create a copy of CameraState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CameraStateCopyWith<CameraState> get copyWith => _$CameraStateCopyWithImpl<CameraState>(this as CameraState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CameraState&&(identical(other.controller, controller) || other.controller == controller)&&(identical(other.currentCameraIndex, currentCameraIndex) || other.currentCameraIndex == currentCameraIndex)&&(identical(other.isFlashOn, isFlashOn) || other.isFlashOn == isFlashOn));
}


@override
int get hashCode => Object.hash(runtimeType,controller,currentCameraIndex,isFlashOn);

@override
String toString() {
  return 'CameraState(controller: $controller, currentCameraIndex: $currentCameraIndex, isFlashOn: $isFlashOn)';
}


}

/// @nodoc
abstract mixin class $CameraStateCopyWith<$Res>  {
  factory $CameraStateCopyWith(CameraState value, $Res Function(CameraState) _then) = _$CameraStateCopyWithImpl;
@useResult
$Res call({
 CameraController controller, int currentCameraIndex, bool isFlashOn
});




}
/// @nodoc
class _$CameraStateCopyWithImpl<$Res>
    implements $CameraStateCopyWith<$Res> {
  _$CameraStateCopyWithImpl(this._self, this._then);

  final CameraState _self;
  final $Res Function(CameraState) _then;

/// Create a copy of CameraState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? controller = null,Object? currentCameraIndex = null,Object? isFlashOn = null,}) {
  return _then(_self.copyWith(
controller: null == controller ? _self.controller : controller // ignore: cast_nullable_to_non_nullable
as CameraController,currentCameraIndex: null == currentCameraIndex ? _self.currentCameraIndex : currentCameraIndex // ignore: cast_nullable_to_non_nullable
as int,isFlashOn: null == isFlashOn ? _self.isFlashOn : isFlashOn // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [CameraState].
extension CameraStatePatterns on CameraState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CameraState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CameraState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CameraState value)  $default,){
final _that = this;
switch (_that) {
case _CameraState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CameraState value)?  $default,){
final _that = this;
switch (_that) {
case _CameraState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( CameraController controller,  int currentCameraIndex,  bool isFlashOn)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CameraState() when $default != null:
return $default(_that.controller,_that.currentCameraIndex,_that.isFlashOn);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( CameraController controller,  int currentCameraIndex,  bool isFlashOn)  $default,) {final _that = this;
switch (_that) {
case _CameraState():
return $default(_that.controller,_that.currentCameraIndex,_that.isFlashOn);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( CameraController controller,  int currentCameraIndex,  bool isFlashOn)?  $default,) {final _that = this;
switch (_that) {
case _CameraState() when $default != null:
return $default(_that.controller,_that.currentCameraIndex,_that.isFlashOn);case _:
  return null;

}
}

}

/// @nodoc


class _CameraState implements CameraState {
  const _CameraState({required this.controller, this.currentCameraIndex = 0, this.isFlashOn = false});
  

@override final  CameraController controller;
@override@JsonKey() final  int currentCameraIndex;
@override@JsonKey() final  bool isFlashOn;

/// Create a copy of CameraState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CameraStateCopyWith<_CameraState> get copyWith => __$CameraStateCopyWithImpl<_CameraState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CameraState&&(identical(other.controller, controller) || other.controller == controller)&&(identical(other.currentCameraIndex, currentCameraIndex) || other.currentCameraIndex == currentCameraIndex)&&(identical(other.isFlashOn, isFlashOn) || other.isFlashOn == isFlashOn));
}


@override
int get hashCode => Object.hash(runtimeType,controller,currentCameraIndex,isFlashOn);

@override
String toString() {
  return 'CameraState(controller: $controller, currentCameraIndex: $currentCameraIndex, isFlashOn: $isFlashOn)';
}


}

/// @nodoc
abstract mixin class _$CameraStateCopyWith<$Res> implements $CameraStateCopyWith<$Res> {
  factory _$CameraStateCopyWith(_CameraState value, $Res Function(_CameraState) _then) = __$CameraStateCopyWithImpl;
@override @useResult
$Res call({
 CameraController controller, int currentCameraIndex, bool isFlashOn
});




}
/// @nodoc
class __$CameraStateCopyWithImpl<$Res>
    implements _$CameraStateCopyWith<$Res> {
  __$CameraStateCopyWithImpl(this._self, this._then);

  final _CameraState _self;
  final $Res Function(_CameraState) _then;

/// Create a copy of CameraState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? controller = null,Object? currentCameraIndex = null,Object? isFlashOn = null,}) {
  return _then(_CameraState(
controller: null == controller ? _self.controller : controller // ignore: cast_nullable_to_non_nullable
as CameraController,currentCameraIndex: null == currentCameraIndex ? _self.currentCameraIndex : currentCameraIndex // ignore: cast_nullable_to_non_nullable
as int,isFlashOn: null == isFlashOn ? _self.isFlashOn : isFlashOn // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
