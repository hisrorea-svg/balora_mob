// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'scanner_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ScannerState {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ScannerState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ScannerState()';
}


}

/// @nodoc
class $ScannerStateCopyWith<$Res>  {
$ScannerStateCopyWith(ScannerState _, $Res Function(ScannerState) __);
}


/// Adds pattern-matching-related methods to [ScannerState].
extension ScannerStatePatterns on ScannerState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Idle value)?  idle,TResult Function( _Processing value)?  processing,TResult Function( _ProductFound value)?  productFound,TResult Function( _ProductNotFound value)?  productNotFound,TResult Function( _ActionQueued value)?  actionQueued,TResult Function( _Error value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Idle() when idle != null:
return idle(_that);case _Processing() when processing != null:
return processing(_that);case _ProductFound() when productFound != null:
return productFound(_that);case _ProductNotFound() when productNotFound != null:
return productNotFound(_that);case _ActionQueued() when actionQueued != null:
return actionQueued(_that);case _Error() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Idle value)  idle,required TResult Function( _Processing value)  processing,required TResult Function( _ProductFound value)  productFound,required TResult Function( _ProductNotFound value)  productNotFound,required TResult Function( _ActionQueued value)  actionQueued,required TResult Function( _Error value)  error,}){
final _that = this;
switch (_that) {
case _Idle():
return idle(_that);case _Processing():
return processing(_that);case _ProductFound():
return productFound(_that);case _ProductNotFound():
return productNotFound(_that);case _ActionQueued():
return actionQueued(_that);case _Error():
return error(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Idle value)?  idle,TResult? Function( _Processing value)?  processing,TResult? Function( _ProductFound value)?  productFound,TResult? Function( _ProductNotFound value)?  productNotFound,TResult? Function( _ActionQueued value)?  actionQueued,TResult? Function( _Error value)?  error,}){
final _that = this;
switch (_that) {
case _Idle() when idle != null:
return idle(_that);case _Processing() when processing != null:
return processing(_that);case _ProductFound() when productFound != null:
return productFound(_that);case _ProductNotFound() when productNotFound != null:
return productNotFound(_that);case _ActionQueued() when actionQueued != null:
return actionQueued(_that);case _Error() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  idle,TResult Function( String barcode)?  processing,TResult Function( Product product)?  productFound,TResult Function( String barcode)?  productNotFound,TResult Function( String message)?  actionQueued,TResult Function( AppException exception)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Idle() when idle != null:
return idle();case _Processing() when processing != null:
return processing(_that.barcode);case _ProductFound() when productFound != null:
return productFound(_that.product);case _ProductNotFound() when productNotFound != null:
return productNotFound(_that.barcode);case _ActionQueued() when actionQueued != null:
return actionQueued(_that.message);case _Error() when error != null:
return error(_that.exception);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  idle,required TResult Function( String barcode)  processing,required TResult Function( Product product)  productFound,required TResult Function( String barcode)  productNotFound,required TResult Function( String message)  actionQueued,required TResult Function( AppException exception)  error,}) {final _that = this;
switch (_that) {
case _Idle():
return idle();case _Processing():
return processing(_that.barcode);case _ProductFound():
return productFound(_that.product);case _ProductNotFound():
return productNotFound(_that.barcode);case _ActionQueued():
return actionQueued(_that.message);case _Error():
return error(_that.exception);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  idle,TResult? Function( String barcode)?  processing,TResult? Function( Product product)?  productFound,TResult? Function( String barcode)?  productNotFound,TResult? Function( String message)?  actionQueued,TResult? Function( AppException exception)?  error,}) {final _that = this;
switch (_that) {
case _Idle() when idle != null:
return idle();case _Processing() when processing != null:
return processing(_that.barcode);case _ProductFound() when productFound != null:
return productFound(_that.product);case _ProductNotFound() when productNotFound != null:
return productNotFound(_that.barcode);case _ActionQueued() when actionQueued != null:
return actionQueued(_that.message);case _Error() when error != null:
return error(_that.exception);case _:
  return null;

}
}

}

/// @nodoc


class _Idle implements ScannerState {
  const _Idle();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Idle);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ScannerState.idle()';
}


}




/// @nodoc


class _Processing implements ScannerState {
  const _Processing(this.barcode);
  

 final  String barcode;

/// Create a copy of ScannerState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProcessingCopyWith<_Processing> get copyWith => __$ProcessingCopyWithImpl<_Processing>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Processing&&(identical(other.barcode, barcode) || other.barcode == barcode));
}


@override
int get hashCode {
    return Object.hash(runtimeType,barcode);
}

@override
String toString() {
    return 'ScannerState.processing(barcode: $barcode)';
}


}

/// @nodoc
abstract mixin class _$ProcessingCopyWith<$Res> implements $ScannerStateCopyWith<$Res> {
  factory _$ProcessingCopyWith(_Processing value, $Res Function(_Processing) _then) = __$ProcessingCopyWithImpl;
@useResult
$Res call({
 String barcode
});




}
/// @nodoc
class __$ProcessingCopyWithImpl<$Res>
    implements _$ProcessingCopyWith<$Res> {
  __$ProcessingCopyWithImpl(this._self, this._then);

  final _Processing _self;
  final $Res Function(_Processing) _then;

/// Create a copy of ScannerState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? barcode = null,}) {
  return _then(_Processing(
null == barcode ? _self.barcode : barcode // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _ProductFound implements ScannerState {
  const _ProductFound(this.product);
  

 final  Product product;

/// Create a copy of ScannerState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductFoundCopyWith<_ProductFound> get copyWith => __$ProductFoundCopyWithImpl<_ProductFound>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProductFound&&(identical(other.product, product) || other.product == product));
}


@override
int get hashCode {
    return Object.hash(runtimeType,product);
}

@override
String toString() {
    return 'ScannerState.productFound(product: $product)';
}


}

/// @nodoc
abstract mixin class _$ProductFoundCopyWith<$Res> implements $ScannerStateCopyWith<$Res> {
  factory _$ProductFoundCopyWith(_ProductFound value, $Res Function(_ProductFound) _then) = __$ProductFoundCopyWithImpl;
@useResult
$Res call({
 Product product
});


$ProductCopyWith<$Res> get product;

}
/// @nodoc
class __$ProductFoundCopyWithImpl<$Res>
    implements _$ProductFoundCopyWith<$Res> {
  __$ProductFoundCopyWithImpl(this._self, this._then);

  final _ProductFound _self;
  final $Res Function(_ProductFound) _then;

/// Create a copy of ScannerState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? product = null,}) {
  return _then(_ProductFound(
null == product ? _self.product : product // ignore: cast_nullable_to_non_nullable
as Product,
  ));
}

/// Create a copy of ScannerState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProductCopyWith<$Res> get product {
  
  return $ProductCopyWith<$Res>(_self.product, (value) {
    return _then(_self.copyWith(product: value));
  });
}
}

/// @nodoc


class _ProductNotFound implements ScannerState {
  const _ProductNotFound(this.barcode);
  

 final  String barcode;

/// Create a copy of ScannerState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductNotFoundCopyWith<_ProductNotFound> get copyWith => __$ProductNotFoundCopyWithImpl<_ProductNotFound>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProductNotFound&&(identical(other.barcode, barcode) || other.barcode == barcode));
}


@override
int get hashCode {
    return Object.hash(runtimeType,barcode);
}

@override
String toString() {
    return 'ScannerState.productNotFound(barcode: $barcode)';
}


}

/// @nodoc
abstract mixin class _$ProductNotFoundCopyWith<$Res> implements $ScannerStateCopyWith<$Res> {
  factory _$ProductNotFoundCopyWith(_ProductNotFound value, $Res Function(_ProductNotFound) _then) = __$ProductNotFoundCopyWithImpl;
@useResult
$Res call({
 String barcode
});




}
/// @nodoc
class __$ProductNotFoundCopyWithImpl<$Res>
    implements _$ProductNotFoundCopyWith<$Res> {
  __$ProductNotFoundCopyWithImpl(this._self, this._then);

  final _ProductNotFound _self;
  final $Res Function(_ProductNotFound) _then;

/// Create a copy of ScannerState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? barcode = null,}) {
  return _then(_ProductNotFound(
null == barcode ? _self.barcode : barcode // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _ActionQueued implements ScannerState {
  const _ActionQueued(this.message);
  

 final  String message;

/// Create a copy of ScannerState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ActionQueuedCopyWith<_ActionQueued> get copyWith => __$ActionQueuedCopyWithImpl<_ActionQueued>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ActionQueued&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode {
    return Object.hash(runtimeType,message);
}

@override
String toString() {
    return 'ScannerState.actionQueued(message: $message)';
}


}

/// @nodoc
abstract mixin class _$ActionQueuedCopyWith<$Res> implements $ScannerStateCopyWith<$Res> {
  factory _$ActionQueuedCopyWith(_ActionQueued value, $Res Function(_ActionQueued) _then) = __$ActionQueuedCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class __$ActionQueuedCopyWithImpl<$Res>
    implements _$ActionQueuedCopyWith<$Res> {
  __$ActionQueuedCopyWithImpl(this._self, this._then);

  final _ActionQueued _self;
  final $Res Function(_ActionQueued) _then;

/// Create a copy of ScannerState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_ActionQueued(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _Error implements ScannerState {
  const _Error(this.exception);
  

 final  AppException exception;

/// Create a copy of ScannerState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ErrorCopyWith<_Error> get copyWith => __$ErrorCopyWithImpl<_Error>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Error&&(identical(other.exception, exception) || other.exception == exception));
}


@override
int get hashCode {
    return Object.hash(runtimeType,exception);
}

@override
String toString() {
    return 'ScannerState.error(exception: $exception)';
}


}

/// @nodoc
abstract mixin class _$ErrorCopyWith<$Res> implements $ScannerStateCopyWith<$Res> {
  factory _$ErrorCopyWith(_Error value, $Res Function(_Error) _then) = __$ErrorCopyWithImpl;
@useResult
$Res call({
 AppException exception
});




}
/// @nodoc
class __$ErrorCopyWithImpl<$Res>
    implements _$ErrorCopyWith<$Res> {
  __$ErrorCopyWithImpl(this._self, this._then);

  final _Error _self;
  final $Res Function(_Error) _then;

/// Create a copy of ScannerState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? exception = null,}) {
  return _then(_Error(
null == exception ? _self.exception : exception // ignore: cast_nullable_to_non_nullable
as AppException,
  ));
}


}

// dart format on
