// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ack_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AckResponse {

/// The commandId this ACK corresponds to.
 String get commandId;/// The result status.
 AckStatus get status;/// Optional message (e.g., error description on failure).
 String? get message;/// Optional response data from the server.
 Map<String, dynamic>? get data;
/// Create a copy of AckResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AckResponseCopyWith<AckResponse> get copyWith => _$AckResponseCopyWithImpl<AckResponse>(this as AckResponse, _$identity);

  /// Serializes this AckResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AckResponse;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AckResponse&&(identical(other.commandId, _this.commandId) || other.commandId == _this.commandId)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.message, _this.message) || other.message == _this.message)&&const DeepCollectionEquality().equals(other.data, _this.data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AckResponse;
  return Object.hash(runtimeType,_this.commandId,_this.status,_this.message,const DeepCollectionEquality().hash(_this.data));
}

@override
String toString() {
  final _this = this as AckResponse;
  return 'AckResponse(commandId: ${_this.commandId}, status: ${_this.status}, message: ${_this.message}, data: ${_this.data})';
}


}

/// @nodoc
abstract mixin class $AckResponseCopyWith<$Res>  {
  factory $AckResponseCopyWith(AckResponse value, $Res Function(AckResponse) _then) = _$AckResponseCopyWithImpl;
@useResult
$Res call({
 String commandId, AckStatus status, String? message, Map<String, dynamic>? data
});




}
/// @nodoc
class _$AckResponseCopyWithImpl<$Res>
    implements $AckResponseCopyWith<$Res> {
  _$AckResponseCopyWithImpl(this._self, this._then);

  final AckResponse _self;
  final $Res Function(AckResponse) _then;

/// Create a copy of AckResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? commandId = null,Object? status = null,Object? message = freezed,Object? data = freezed,}) {
  return _then(AckResponse(
commandId: null == commandId ? _self.commandId : commandId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AckStatus,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,data: freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}


/// Adds pattern-matching-related methods to [AckResponse].
extension AckResponsePatterns on AckResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AckResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AckResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AckResponse value)  $default,){
final _that = this;
switch (_that) {
case _AckResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AckResponse value)?  $default,){
final _that = this;
switch (_that) {
case _AckResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String commandId,  AckStatus status,  String? message,  Map<String, dynamic>? data)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AckResponse() when $default != null:
return $default(_that.commandId,_that.status,_that.message,_that.data);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String commandId,  AckStatus status,  String? message,  Map<String, dynamic>? data)  $default,) {final _that = this;
switch (_that) {
case _AckResponse():
return $default(_that.commandId,_that.status,_that.message,_that.data);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String commandId,  AckStatus status,  String? message,  Map<String, dynamic>? data)?  $default,) {final _that = this;
switch (_that) {
case _AckResponse() when $default != null:
return $default(_that.commandId,_that.status,_that.message,_that.data);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AckResponse implements AckResponse {
  const _AckResponse({required this.commandId, required this.status, this.message,  Map<String, dynamic>? data}): _data = data;
  factory _AckResponse.fromJson(Map<String, dynamic> json) => _$AckResponseFromJson(json);

/// The commandId this ACK corresponds to.
@override final  String commandId;
/// The result status.
@override final  AckStatus status;
/// Optional message (e.g., error description on failure).
@override final  String? message;
/// Optional response data from the server.
 final  Map<String, dynamic>? _data;
/// Optional response data from the server.
@override Map<String, dynamic>? get data {
  final value = _data;
  if (value == null) return null;
  if (_data is EqualUnmodifiableMapView) return _data;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of AckResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AckResponseCopyWith<_AckResponse> get copyWith => __$AckResponseCopyWithImpl<_AckResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AckResponseToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AckResponse&&(identical(other.commandId, commandId) || other.commandId == commandId)&&(identical(other.status, status) || other.status == status)&&(identical(other.message, message) || other.message == message)&&const DeepCollectionEquality().equals(other.data, _data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,commandId,status,message,const DeepCollectionEquality().hash(_data));
}

@override
String toString() {
    return 'AckResponse(commandId: $commandId, status: $status, message: $message, data: $data)';
}


}

/// @nodoc
abstract mixin class _$AckResponseCopyWith<$Res> implements $AckResponseCopyWith<$Res> {
  factory _$AckResponseCopyWith(_AckResponse value, $Res Function(_AckResponse) _then) = __$AckResponseCopyWithImpl;
@override @useResult
$Res call({
 String commandId, AckStatus status, String? message, Map<String, dynamic>? data
});




}
/// @nodoc
class __$AckResponseCopyWithImpl<$Res>
    implements _$AckResponseCopyWith<$Res> {
  __$AckResponseCopyWithImpl(this._self, this._then);

  final _AckResponse _self;
  final $Res Function(_AckResponse) _then;

/// Create a copy of AckResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? commandId = null,Object? status = null,Object? message = freezed,Object? data = freezed,}) {
  return _then(_AckResponse(
commandId: null == commandId ? _self.commandId : commandId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AckStatus,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,data: freezed == data ? _self._data : data // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}

// dart format on
