// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sync_status.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SyncStatus {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is SyncStatus);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'SyncStatus()';
}


}

/// @nodoc
class $SyncStatusCopyWith<$Res>  {
$SyncStatusCopyWith(SyncStatus _, $Res Function(SyncStatus) __);
}


/// Adds pattern-matching-related methods to [SyncStatus].
extension SyncStatusPatterns on SyncStatus {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( SyncIdle value)?  idle,TResult Function( SyncSyncing value)?  syncing,TResult Function( SyncError value)?  error,TResult Function( SyncOffline value)?  offline,required TResult orElse(),}){
final _that = this;
switch (_that) {
case SyncIdle() when idle != null:
return idle(_that);case SyncSyncing() when syncing != null:
return syncing(_that);case SyncError() when error != null:
return error(_that);case SyncOffline() when offline != null:
return offline(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( SyncIdle value)  idle,required TResult Function( SyncSyncing value)  syncing,required TResult Function( SyncError value)  error,required TResult Function( SyncOffline value)  offline,}){
final _that = this;
switch (_that) {
case SyncIdle():
return idle(_that);case SyncSyncing():
return syncing(_that);case SyncError():
return error(_that);case SyncOffline():
return offline(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( SyncIdle value)?  idle,TResult? Function( SyncSyncing value)?  syncing,TResult? Function( SyncError value)?  error,TResult? Function( SyncOffline value)?  offline,}){
final _that = this;
switch (_that) {
case SyncIdle() when idle != null:
return idle(_that);case SyncSyncing() when syncing != null:
return syncing(_that);case SyncError() when error != null:
return error(_that);case SyncOffline() when offline != null:
return offline(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  idle,TResult Function( int pending,  int total)?  syncing,TResult Function( String message)?  error,TResult Function()?  offline,required TResult orElse(),}) {final _that = this;
switch (_that) {
case SyncIdle() when idle != null:
return idle();case SyncSyncing() when syncing != null:
return syncing(_that.pending,_that.total);case SyncError() when error != null:
return error(_that.message);case SyncOffline() when offline != null:
return offline();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  idle,required TResult Function( int pending,  int total)  syncing,required TResult Function( String message)  error,required TResult Function()  offline,}) {final _that = this;
switch (_that) {
case SyncIdle():
return idle();case SyncSyncing():
return syncing(_that.pending,_that.total);case SyncError():
return error(_that.message);case SyncOffline():
return offline();}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  idle,TResult? Function( int pending,  int total)?  syncing,TResult? Function( String message)?  error,TResult? Function()?  offline,}) {final _that = this;
switch (_that) {
case SyncIdle() when idle != null:
return idle();case SyncSyncing() when syncing != null:
return syncing(_that.pending,_that.total);case SyncError() when error != null:
return error(_that.message);case SyncOffline() when offline != null:
return offline();case _:
  return null;

}
}

}

/// @nodoc


class SyncIdle implements SyncStatus {
  const SyncIdle();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is SyncIdle);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'SyncStatus.idle()';
}


}




/// @nodoc


class SyncSyncing implements SyncStatus {
  const SyncSyncing({required this.pending, required this.total});
  

 final  int pending;
 final  int total;

/// Create a copy of SyncStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SyncSyncingCopyWith<SyncSyncing> get copyWith => _$SyncSyncingCopyWithImpl<SyncSyncing>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is SyncSyncing&&(identical(other.pending, pending) || other.pending == pending)&&(identical(other.total, total) || other.total == total));
}


@override
int get hashCode {
    return Object.hash(runtimeType,pending,total);
}

@override
String toString() {
    return 'SyncStatus.syncing(pending: $pending, total: $total)';
}


}

/// @nodoc
abstract mixin class $SyncSyncingCopyWith<$Res> implements $SyncStatusCopyWith<$Res> {
  factory $SyncSyncingCopyWith(SyncSyncing value, $Res Function(SyncSyncing) _then) = _$SyncSyncingCopyWithImpl;
@useResult
$Res call({
 int pending, int total
});




}
/// @nodoc
class _$SyncSyncingCopyWithImpl<$Res>
    implements $SyncSyncingCopyWith<$Res> {
  _$SyncSyncingCopyWithImpl(this._self, this._then);

  final SyncSyncing _self;
  final $Res Function(SyncSyncing) _then;

/// Create a copy of SyncStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? pending = null,Object? total = null,}) {
  return _then(SyncSyncing(
pending: null == pending ? _self.pending : pending // ignore: cast_nullable_to_non_nullable
as int,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class SyncError implements SyncStatus {
  const SyncError({required this.message});
  

 final  String message;

/// Create a copy of SyncStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SyncErrorCopyWith<SyncError> get copyWith => _$SyncErrorCopyWithImpl<SyncError>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is SyncError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode {
    return Object.hash(runtimeType,message);
}

@override
String toString() {
    return 'SyncStatus.error(message: $message)';
}


}

/// @nodoc
abstract mixin class $SyncErrorCopyWith<$Res> implements $SyncStatusCopyWith<$Res> {
  factory $SyncErrorCopyWith(SyncError value, $Res Function(SyncError) _then) = _$SyncErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$SyncErrorCopyWithImpl<$Res>
    implements $SyncErrorCopyWith<$Res> {
  _$SyncErrorCopyWithImpl(this._self, this._then);

  final SyncError _self;
  final $Res Function(SyncError) _then;

/// Create a copy of SyncStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(SyncError(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class SyncOffline implements SyncStatus {
  const SyncOffline();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is SyncOffline);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'SyncStatus.offline()';
}


}




// dart format on
