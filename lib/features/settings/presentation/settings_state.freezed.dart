// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'settings_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SettingsState {

 bool get isLoading; SessionEntry? get session; int get pendingQueueCount; bool get isConnected;
/// Create a copy of SettingsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SettingsStateCopyWith<SettingsState> get copyWith => _$SettingsStateCopyWithImpl<SettingsState>(this as SettingsState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as SettingsState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SettingsState&&(identical(other.isLoading, _this.isLoading) || other.isLoading == _this.isLoading)&&const DeepCollectionEquality().equals(other.session, _this.session)&&(identical(other.pendingQueueCount, _this.pendingQueueCount) || other.pendingQueueCount == _this.pendingQueueCount)&&(identical(other.isConnected, _this.isConnected) || other.isConnected == _this.isConnected));
}


@override
int get hashCode {
  final _this = this as SettingsState;
  return Object.hash(runtimeType,_this.isLoading,const DeepCollectionEquality().hash(_this.session),_this.pendingQueueCount,_this.isConnected);
}

@override
String toString() {
  final _this = this as SettingsState;
  return 'SettingsState(isLoading: ${_this.isLoading}, session: ${_this.session}, pendingQueueCount: ${_this.pendingQueueCount}, isConnected: ${_this.isConnected})';
}


}

/// @nodoc
abstract mixin class $SettingsStateCopyWith<$Res>  {
  factory $SettingsStateCopyWith(SettingsState value, $Res Function(SettingsState) _then) = _$SettingsStateCopyWithImpl;
@useResult
$Res call({
 bool isLoading, SessionEntry? session, int pendingQueueCount, bool isConnected
});




}
/// @nodoc
class _$SettingsStateCopyWithImpl<$Res>
    implements $SettingsStateCopyWith<$Res> {
  _$SettingsStateCopyWithImpl(this._self, this._then);

  final SettingsState _self;
  final $Res Function(SettingsState) _then;

/// Create a copy of SettingsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isLoading = null,Object? session = freezed,Object? pendingQueueCount = null,Object? isConnected = null,}) {
  return _then(SettingsState(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,session: freezed == session ? _self.session : session // ignore: cast_nullable_to_non_nullable
as SessionEntry?,pendingQueueCount: null == pendingQueueCount ? _self.pendingQueueCount : pendingQueueCount // ignore: cast_nullable_to_non_nullable
as int,isConnected: null == isConnected ? _self.isConnected : isConnected // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [SettingsState].
extension SettingsStatePatterns on SettingsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SettingsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SettingsState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SettingsState value)  $default,){
final _that = this;
switch (_that) {
case _SettingsState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SettingsState value)?  $default,){
final _that = this;
switch (_that) {
case _SettingsState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isLoading,  SessionEntry? session,  int pendingQueueCount,  bool isConnected)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SettingsState() when $default != null:
return $default(_that.isLoading,_that.session,_that.pendingQueueCount,_that.isConnected);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isLoading,  SessionEntry? session,  int pendingQueueCount,  bool isConnected)  $default,) {final _that = this;
switch (_that) {
case _SettingsState():
return $default(_that.isLoading,_that.session,_that.pendingQueueCount,_that.isConnected);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isLoading,  SessionEntry? session,  int pendingQueueCount,  bool isConnected)?  $default,) {final _that = this;
switch (_that) {
case _SettingsState() when $default != null:
return $default(_that.isLoading,_that.session,_that.pendingQueueCount,_that.isConnected);case _:
  return null;

}
}

}

/// @nodoc


class _SettingsState implements SettingsState {
  const _SettingsState({this.isLoading = false, this.session, this.pendingQueueCount = 0, this.isConnected = false});
  

@override@JsonKey() final  bool isLoading;
@override final  SessionEntry? session;
@override@JsonKey() final  int pendingQueueCount;
@override@JsonKey() final  bool isConnected;

/// Create a copy of SettingsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SettingsStateCopyWith<_SettingsState> get copyWith => __$SettingsStateCopyWithImpl<_SettingsState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SettingsState&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&const DeepCollectionEquality().equals(other.session, session)&&(identical(other.pendingQueueCount, pendingQueueCount) || other.pendingQueueCount == pendingQueueCount)&&(identical(other.isConnected, isConnected) || other.isConnected == isConnected));
}


@override
int get hashCode {
    return Object.hash(runtimeType,isLoading,const DeepCollectionEquality().hash(session),pendingQueueCount,isConnected);
}

@override
String toString() {
    return 'SettingsState(isLoading: $isLoading, session: $session, pendingQueueCount: $pendingQueueCount, isConnected: $isConnected)';
}


}

/// @nodoc
abstract mixin class _$SettingsStateCopyWith<$Res> implements $SettingsStateCopyWith<$Res> {
  factory _$SettingsStateCopyWith(_SettingsState value, $Res Function(_SettingsState) _then) = __$SettingsStateCopyWithImpl;
@override @useResult
$Res call({
 bool isLoading, SessionEntry? session, int pendingQueueCount, bool isConnected
});




}
/// @nodoc
class __$SettingsStateCopyWithImpl<$Res>
    implements _$SettingsStateCopyWith<$Res> {
  __$SettingsStateCopyWithImpl(this._self, this._then);

  final _SettingsState _self;
  final $Res Function(_SettingsState) _then;

/// Create a copy of SettingsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isLoading = null,Object? session = freezed,Object? pendingQueueCount = null,Object? isConnected = null,}) {
  return _then(_SettingsState(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,session: freezed == session ? _self.session : session // ignore: cast_nullable_to_non_nullable
as SessionEntry?,pendingQueueCount: null == pendingQueueCount ? _self.pendingQueueCount : pendingQueueCount // ignore: cast_nullable_to_non_nullable
as int,isConnected: null == isConnected ? _self.isConnected : isConnected // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
