// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pairing_payload.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PairingPayload {

/// The base URL of the Balora Desktop server.
 String get server;/// One-time pairing token for authentication.
 String get pairToken;/// Human-readable name of the desktop device.
 String get deviceName;/// When this pairing token expires.
 DateTime get expiresAt;/// Protocol version for compatibility checks.
 int get version;
/// Create a copy of PairingPayload
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PairingPayloadCopyWith<PairingPayload> get copyWith => _$PairingPayloadCopyWithImpl<PairingPayload>(this as PairingPayload, _$identity);

  /// Serializes this PairingPayload to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PairingPayload;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PairingPayload&&(identical(other.server, _this.server) || other.server == _this.server)&&(identical(other.pairToken, _this.pairToken) || other.pairToken == _this.pairToken)&&(identical(other.deviceName, _this.deviceName) || other.deviceName == _this.deviceName)&&(identical(other.expiresAt, _this.expiresAt) || other.expiresAt == _this.expiresAt)&&(identical(other.version, _this.version) || other.version == _this.version));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PairingPayload;
  return Object.hash(runtimeType,_this.server,_this.pairToken,_this.deviceName,_this.expiresAt,_this.version);
}

@override
String toString() {
  final _this = this as PairingPayload;
  return 'PairingPayload(server: ${_this.server}, pairToken: ${_this.pairToken}, deviceName: ${_this.deviceName}, expiresAt: ${_this.expiresAt}, version: ${_this.version})';
}


}

/// @nodoc
abstract mixin class $PairingPayloadCopyWith<$Res>  {
  factory $PairingPayloadCopyWith(PairingPayload value, $Res Function(PairingPayload) _then) = _$PairingPayloadCopyWithImpl;
@useResult
$Res call({
 String server, String pairToken, String deviceName, DateTime expiresAt, int version
});




}
/// @nodoc
class _$PairingPayloadCopyWithImpl<$Res>
    implements $PairingPayloadCopyWith<$Res> {
  _$PairingPayloadCopyWithImpl(this._self, this._then);

  final PairingPayload _self;
  final $Res Function(PairingPayload) _then;

/// Create a copy of PairingPayload
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? server = null,Object? pairToken = null,Object? deviceName = null,Object? expiresAt = null,Object? version = null,}) {
  return _then(PairingPayload(
server: null == server ? _self.server : server // ignore: cast_nullable_to_non_nullable
as String,pairToken: null == pairToken ? _self.pairToken : pairToken // ignore: cast_nullable_to_non_nullable
as String,deviceName: null == deviceName ? _self.deviceName : deviceName // ignore: cast_nullable_to_non_nullable
as String,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PairingPayload].
extension PairingPayloadPatterns on PairingPayload {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PairingPayload value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PairingPayload() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PairingPayload value)  $default,){
final _that = this;
switch (_that) {
case _PairingPayload():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PairingPayload value)?  $default,){
final _that = this;
switch (_that) {
case _PairingPayload() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String server,  String pairToken,  String deviceName,  DateTime expiresAt,  int version)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PairingPayload() when $default != null:
return $default(_that.server,_that.pairToken,_that.deviceName,_that.expiresAt,_that.version);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String server,  String pairToken,  String deviceName,  DateTime expiresAt,  int version)  $default,) {final _that = this;
switch (_that) {
case _PairingPayload():
return $default(_that.server,_that.pairToken,_that.deviceName,_that.expiresAt,_that.version);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String server,  String pairToken,  String deviceName,  DateTime expiresAt,  int version)?  $default,) {final _that = this;
switch (_that) {
case _PairingPayload() when $default != null:
return $default(_that.server,_that.pairToken,_that.deviceName,_that.expiresAt,_that.version);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PairingPayload implements PairingPayload {
  const _PairingPayload({required this.server, required this.pairToken, required this.deviceName, required this.expiresAt, this.version = 1});
  factory _PairingPayload.fromJson(Map<String, dynamic> json) => _$PairingPayloadFromJson(json);

/// The base URL of the Balora Desktop server.
@override final  String server;
/// One-time pairing token for authentication.
@override final  String pairToken;
/// Human-readable name of the desktop device.
@override final  String deviceName;
/// When this pairing token expires.
@override final  DateTime expiresAt;
/// Protocol version for compatibility checks.
@override@JsonKey() final  int version;

/// Create a copy of PairingPayload
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PairingPayloadCopyWith<_PairingPayload> get copyWith => __$PairingPayloadCopyWithImpl<_PairingPayload>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PairingPayloadToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PairingPayload&&(identical(other.server, server) || other.server == server)&&(identical(other.pairToken, pairToken) || other.pairToken == pairToken)&&(identical(other.deviceName, deviceName) || other.deviceName == deviceName)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.version, version) || other.version == version));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,server,pairToken,deviceName,expiresAt,version);
}

@override
String toString() {
    return 'PairingPayload(server: $server, pairToken: $pairToken, deviceName: $deviceName, expiresAt: $expiresAt, version: $version)';
}


}

/// @nodoc
abstract mixin class _$PairingPayloadCopyWith<$Res> implements $PairingPayloadCopyWith<$Res> {
  factory _$PairingPayloadCopyWith(_PairingPayload value, $Res Function(_PairingPayload) _then) = __$PairingPayloadCopyWithImpl;
@override @useResult
$Res call({
 String server, String pairToken, String deviceName, DateTime expiresAt, int version
});




}
/// @nodoc
class __$PairingPayloadCopyWithImpl<$Res>
    implements _$PairingPayloadCopyWith<$Res> {
  __$PairingPayloadCopyWithImpl(this._self, this._then);

  final _PairingPayload _self;
  final $Res Function(_PairingPayload) _then;

/// Create a copy of PairingPayload
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? server = null,Object? pairToken = null,Object? deviceName = null,Object? expiresAt = null,Object? version = null,}) {
  return _then(_PairingPayload(
server: null == server ? _self.server : server // ignore: cast_nullable_to_non_nullable
as String,pairToken: null == pairToken ? _self.pairToken : pairToken // ignore: cast_nullable_to_non_nullable
as String,deviceName: null == deviceName ? _self.deviceName : deviceName // ignore: cast_nullable_to_non_nullable
as String,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$PairingResponse {

/// Session token for subsequent API calls.
 String get sessionToken;/// Unique identifier assigned to this device.
 String get deviceId;/// When this session expires.
 DateTime get expiresAt;/// Permissions granted to this device.
 List<String> get permissions;
/// Create a copy of PairingResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PairingResponseCopyWith<PairingResponse> get copyWith => _$PairingResponseCopyWithImpl<PairingResponse>(this as PairingResponse, _$identity);

  /// Serializes this PairingResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PairingResponse;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PairingResponse&&(identical(other.sessionToken, _this.sessionToken) || other.sessionToken == _this.sessionToken)&&(identical(other.deviceId, _this.deviceId) || other.deviceId == _this.deviceId)&&(identical(other.expiresAt, _this.expiresAt) || other.expiresAt == _this.expiresAt)&&const DeepCollectionEquality().equals(other.permissions, _this.permissions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PairingResponse;
  return Object.hash(runtimeType,_this.sessionToken,_this.deviceId,_this.expiresAt,const DeepCollectionEquality().hash(_this.permissions));
}

@override
String toString() {
  final _this = this as PairingResponse;
  return 'PairingResponse(sessionToken: ${_this.sessionToken}, deviceId: ${_this.deviceId}, expiresAt: ${_this.expiresAt}, permissions: ${_this.permissions})';
}


}

/// @nodoc
abstract mixin class $PairingResponseCopyWith<$Res>  {
  factory $PairingResponseCopyWith(PairingResponse value, $Res Function(PairingResponse) _then) = _$PairingResponseCopyWithImpl;
@useResult
$Res call({
 String sessionToken, String deviceId, DateTime expiresAt, List<String> permissions
});




}
/// @nodoc
class _$PairingResponseCopyWithImpl<$Res>
    implements $PairingResponseCopyWith<$Res> {
  _$PairingResponseCopyWithImpl(this._self, this._then);

  final PairingResponse _self;
  final $Res Function(PairingResponse) _then;

/// Create a copy of PairingResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sessionToken = null,Object? deviceId = null,Object? expiresAt = null,Object? permissions = null,}) {
  return _then(PairingResponse(
sessionToken: null == sessionToken ? _self.sessionToken : sessionToken // ignore: cast_nullable_to_non_nullable
as String,deviceId: null == deviceId ? _self.deviceId : deviceId // ignore: cast_nullable_to_non_nullable
as String,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,permissions: null == permissions ? _self.permissions : permissions // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [PairingResponse].
extension PairingResponsePatterns on PairingResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PairingResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PairingResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PairingResponse value)  $default,){
final _that = this;
switch (_that) {
case _PairingResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PairingResponse value)?  $default,){
final _that = this;
switch (_that) {
case _PairingResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String sessionToken,  String deviceId,  DateTime expiresAt,  List<String> permissions)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PairingResponse() when $default != null:
return $default(_that.sessionToken,_that.deviceId,_that.expiresAt,_that.permissions);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String sessionToken,  String deviceId,  DateTime expiresAt,  List<String> permissions)  $default,) {final _that = this;
switch (_that) {
case _PairingResponse():
return $default(_that.sessionToken,_that.deviceId,_that.expiresAt,_that.permissions);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String sessionToken,  String deviceId,  DateTime expiresAt,  List<String> permissions)?  $default,) {final _that = this;
switch (_that) {
case _PairingResponse() when $default != null:
return $default(_that.sessionToken,_that.deviceId,_that.expiresAt,_that.permissions);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PairingResponse implements PairingResponse {
  const _PairingResponse({required this.sessionToken, required this.deviceId, required this.expiresAt,  List<String> permissions = const []}): _permissions = permissions;
  factory _PairingResponse.fromJson(Map<String, dynamic> json) => _$PairingResponseFromJson(json);

/// Session token for subsequent API calls.
@override final  String sessionToken;
/// Unique identifier assigned to this device.
@override final  String deviceId;
/// When this session expires.
@override final  DateTime expiresAt;
/// Permissions granted to this device.
 final  List<String> _permissions;
/// Permissions granted to this device.
@override@JsonKey() List<String> get permissions {
  if (_permissions is EqualUnmodifiableListView) return _permissions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_permissions);
}


/// Create a copy of PairingResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PairingResponseCopyWith<_PairingResponse> get copyWith => __$PairingResponseCopyWithImpl<_PairingResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PairingResponseToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PairingResponse&&(identical(other.sessionToken, sessionToken) || other.sessionToken == sessionToken)&&(identical(other.deviceId, deviceId) || other.deviceId == deviceId)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&const DeepCollectionEquality().equals(other.permissions, _permissions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,sessionToken,deviceId,expiresAt,const DeepCollectionEquality().hash(_permissions));
}

@override
String toString() {
    return 'PairingResponse(sessionToken: $sessionToken, deviceId: $deviceId, expiresAt: $expiresAt, permissions: $permissions)';
}


}

/// @nodoc
abstract mixin class _$PairingResponseCopyWith<$Res> implements $PairingResponseCopyWith<$Res> {
  factory _$PairingResponseCopyWith(_PairingResponse value, $Res Function(_PairingResponse) _then) = __$PairingResponseCopyWithImpl;
@override @useResult
$Res call({
 String sessionToken, String deviceId, DateTime expiresAt, List<String> permissions
});




}
/// @nodoc
class __$PairingResponseCopyWithImpl<$Res>
    implements _$PairingResponseCopyWith<$Res> {
  __$PairingResponseCopyWithImpl(this._self, this._then);

  final _PairingResponse _self;
  final $Res Function(_PairingResponse) _then;

/// Create a copy of PairingResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sessionToken = null,Object? deviceId = null,Object? expiresAt = null,Object? permissions = null,}) {
  return _then(_PairingResponse(
sessionToken: null == sessionToken ? _self.sessionToken : sessionToken // ignore: cast_nullable_to_non_nullable
as String,deviceId: null == deviceId ? _self.deviceId : deviceId // ignore: cast_nullable_to_non_nullable
as String,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,permissions: null == permissions ? _self._permissions : permissions // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
