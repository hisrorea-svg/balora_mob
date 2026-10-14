// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'command.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Command {

/// Unique identifier for this command (UUID v4).
 String get commandId;/// The type of command.
 CommandType get type;/// The scanned barcode value (nullable for non-scan commands).
 String? get barcode;/// When this command was created on the device.
 DateTime get timestamp;/// The unique identifier of the sending device.
 String get deviceId;/// Optional payload for commands that need additional data
/// (e.g., product updates, inventory submissions).
 Map<String, dynamic>? get payload;
/// Create a copy of Command
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CommandCopyWith<Command> get copyWith => _$CommandCopyWithImpl<Command>(this as Command, _$identity);

  /// Serializes this Command to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Command;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Command&&(identical(other.commandId, _this.commandId) || other.commandId == _this.commandId)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.barcode, _this.barcode) || other.barcode == _this.barcode)&&(identical(other.timestamp, _this.timestamp) || other.timestamp == _this.timestamp)&&(identical(other.deviceId, _this.deviceId) || other.deviceId == _this.deviceId)&&const DeepCollectionEquality().equals(other.payload, _this.payload));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Command;
  return Object.hash(runtimeType,_this.commandId,_this.type,_this.barcode,_this.timestamp,_this.deviceId,const DeepCollectionEquality().hash(_this.payload));
}

@override
String toString() {
  final _this = this as Command;
  return 'Command(commandId: ${_this.commandId}, type: ${_this.type}, barcode: ${_this.barcode}, timestamp: ${_this.timestamp}, deviceId: ${_this.deviceId}, payload: ${_this.payload})';
}


}

/// @nodoc
abstract mixin class $CommandCopyWith<$Res>  {
  factory $CommandCopyWith(Command value, $Res Function(Command) _then) = _$CommandCopyWithImpl;
@useResult
$Res call({
 String commandId, CommandType type, String? barcode, DateTime timestamp, String deviceId, Map<String, dynamic>? payload
});




}
/// @nodoc
class _$CommandCopyWithImpl<$Res>
    implements $CommandCopyWith<$Res> {
  _$CommandCopyWithImpl(this._self, this._then);

  final Command _self;
  final $Res Function(Command) _then;

/// Create a copy of Command
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? commandId = null,Object? type = null,Object? barcode = freezed,Object? timestamp = null,Object? deviceId = null,Object? payload = freezed,}) {
  return _then(Command(
commandId: null == commandId ? _self.commandId : commandId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as CommandType,barcode: freezed == barcode ? _self.barcode : barcode // ignore: cast_nullable_to_non_nullable
as String?,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,deviceId: null == deviceId ? _self.deviceId : deviceId // ignore: cast_nullable_to_non_nullable
as String,payload: freezed == payload ? _self.payload : payload // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}


/// Adds pattern-matching-related methods to [Command].
extension CommandPatterns on Command {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Command value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Command() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Command value)  $default,){
final _that = this;
switch (_that) {
case _Command():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Command value)?  $default,){
final _that = this;
switch (_that) {
case _Command() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String commandId,  CommandType type,  String? barcode,  DateTime timestamp,  String deviceId,  Map<String, dynamic>? payload)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Command() when $default != null:
return $default(_that.commandId,_that.type,_that.barcode,_that.timestamp,_that.deviceId,_that.payload);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String commandId,  CommandType type,  String? barcode,  DateTime timestamp,  String deviceId,  Map<String, dynamic>? payload)  $default,) {final _that = this;
switch (_that) {
case _Command():
return $default(_that.commandId,_that.type,_that.barcode,_that.timestamp,_that.deviceId,_that.payload);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String commandId,  CommandType type,  String? barcode,  DateTime timestamp,  String deviceId,  Map<String, dynamic>? payload)?  $default,) {final _that = this;
switch (_that) {
case _Command() when $default != null:
return $default(_that.commandId,_that.type,_that.barcode,_that.timestamp,_that.deviceId,_that.payload);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Command implements Command {
  const _Command({required this.commandId, required this.type, this.barcode, required this.timestamp, required this.deviceId,  Map<String, dynamic>? payload}): _payload = payload;
  factory _Command.fromJson(Map<String, dynamic> json) => _$CommandFromJson(json);

/// Unique identifier for this command (UUID v4).
@override final  String commandId;
/// The type of command.
@override final  CommandType type;
/// The scanned barcode value (nullable for non-scan commands).
@override final  String? barcode;
/// When this command was created on the device.
@override final  DateTime timestamp;
/// The unique identifier of the sending device.
@override final  String deviceId;
/// Optional payload for commands that need additional data
/// (e.g., product updates, inventory submissions).
 final  Map<String, dynamic>? _payload;
/// Optional payload for commands that need additional data
/// (e.g., product updates, inventory submissions).
@override Map<String, dynamic>? get payload {
  final value = _payload;
  if (value == null) return null;
  if (_payload is EqualUnmodifiableMapView) return _payload;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of Command
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CommandCopyWith<_Command> get copyWith => __$CommandCopyWithImpl<_Command>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CommandToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Command&&(identical(other.commandId, commandId) || other.commandId == commandId)&&(identical(other.type, type) || other.type == type)&&(identical(other.barcode, barcode) || other.barcode == barcode)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.deviceId, deviceId) || other.deviceId == deviceId)&&const DeepCollectionEquality().equals(other.payload, _payload));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,commandId,type,barcode,timestamp,deviceId,const DeepCollectionEquality().hash(_payload));
}

@override
String toString() {
    return 'Command(commandId: $commandId, type: $type, barcode: $barcode, timestamp: $timestamp, deviceId: $deviceId, payload: $payload)';
}


}

/// @nodoc
abstract mixin class _$CommandCopyWith<$Res> implements $CommandCopyWith<$Res> {
  factory _$CommandCopyWith(_Command value, $Res Function(_Command) _then) = __$CommandCopyWithImpl;
@override @useResult
$Res call({
 String commandId, CommandType type, String? barcode, DateTime timestamp, String deviceId, Map<String, dynamic>? payload
});




}
/// @nodoc
class __$CommandCopyWithImpl<$Res>
    implements _$CommandCopyWith<$Res> {
  __$CommandCopyWithImpl(this._self, this._then);

  final _Command _self;
  final $Res Function(_Command) _then;

/// Create a copy of Command
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? commandId = null,Object? type = null,Object? barcode = freezed,Object? timestamp = null,Object? deviceId = null,Object? payload = freezed,}) {
  return _then(_Command(
commandId: null == commandId ? _self.commandId : commandId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as CommandType,barcode: freezed == barcode ? _self.barcode : barcode // ignore: cast_nullable_to_non_nullable
as String?,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,deviceId: null == deviceId ? _self.deviceId : deviceId // ignore: cast_nullable_to_non_nullable
as String,payload: freezed == payload ? _self._payload : payload // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}

// dart format on
