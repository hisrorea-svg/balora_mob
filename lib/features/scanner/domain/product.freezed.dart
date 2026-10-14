// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Product {

 String get barcode; String get name; String? get scientificName; String get category; String? get manufacturer;/// Pricing
 double get price; double get costPrice; int get countInBox; double get unitPrice;/// Stock
 int get quantity; DateTime? get expiryDate;/// Optional
 String? get storageLocation; String? get description;
/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductCopyWith<Product> get copyWith => _$ProductCopyWithImpl<Product>(this as Product, _$identity);

  /// Serializes this Product to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Product;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Product&&(identical(other.barcode, _this.barcode) || other.barcode == _this.barcode)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.scientificName, _this.scientificName) || other.scientificName == _this.scientificName)&&(identical(other.category, _this.category) || other.category == _this.category)&&(identical(other.manufacturer, _this.manufacturer) || other.manufacturer == _this.manufacturer)&&(identical(other.price, _this.price) || other.price == _this.price)&&(identical(other.costPrice, _this.costPrice) || other.costPrice == _this.costPrice)&&(identical(other.countInBox, _this.countInBox) || other.countInBox == _this.countInBox)&&(identical(other.unitPrice, _this.unitPrice) || other.unitPrice == _this.unitPrice)&&(identical(other.quantity, _this.quantity) || other.quantity == _this.quantity)&&(identical(other.expiryDate, _this.expiryDate) || other.expiryDate == _this.expiryDate)&&(identical(other.storageLocation, _this.storageLocation) || other.storageLocation == _this.storageLocation)&&(identical(other.description, _this.description) || other.description == _this.description));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Product;
  return Object.hash(runtimeType,_this.barcode,_this.name,_this.scientificName,_this.category,_this.manufacturer,_this.price,_this.costPrice,_this.countInBox,_this.unitPrice,_this.quantity,_this.expiryDate,_this.storageLocation,_this.description);
}

@override
String toString() {
  final _this = this as Product;
  return 'Product(barcode: ${_this.barcode}, name: ${_this.name}, scientificName: ${_this.scientificName}, category: ${_this.category}, manufacturer: ${_this.manufacturer}, price: ${_this.price}, costPrice: ${_this.costPrice}, countInBox: ${_this.countInBox}, unitPrice: ${_this.unitPrice}, quantity: ${_this.quantity}, expiryDate: ${_this.expiryDate}, storageLocation: ${_this.storageLocation}, description: ${_this.description})';
}


}

/// @nodoc
abstract mixin class $ProductCopyWith<$Res>  {
  factory $ProductCopyWith(Product value, $Res Function(Product) _then) = _$ProductCopyWithImpl;
@useResult
$Res call({
 String barcode, String name, String? scientificName, String category, String? manufacturer, double price, double costPrice, int countInBox, double unitPrice, int quantity, DateTime? expiryDate, String? storageLocation, String? description
});




}
/// @nodoc
class _$ProductCopyWithImpl<$Res>
    implements $ProductCopyWith<$Res> {
  _$ProductCopyWithImpl(this._self, this._then);

  final Product _self;
  final $Res Function(Product) _then;

/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? barcode = null,Object? name = null,Object? scientificName = freezed,Object? category = null,Object? manufacturer = freezed,Object? price = null,Object? costPrice = null,Object? countInBox = null,Object? unitPrice = null,Object? quantity = null,Object? expiryDate = freezed,Object? storageLocation = freezed,Object? description = freezed,}) {
  return _then(Product(
barcode: null == barcode ? _self.barcode : barcode // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,scientificName: freezed == scientificName ? _self.scientificName : scientificName // ignore: cast_nullable_to_non_nullable
as String?,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,manufacturer: freezed == manufacturer ? _self.manufacturer : manufacturer // ignore: cast_nullable_to_non_nullable
as String?,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,costPrice: null == costPrice ? _self.costPrice : costPrice // ignore: cast_nullable_to_non_nullable
as double,countInBox: null == countInBox ? _self.countInBox : countInBox // ignore: cast_nullable_to_non_nullable
as int,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as double,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,expiryDate: freezed == expiryDate ? _self.expiryDate : expiryDate // ignore: cast_nullable_to_non_nullable
as DateTime?,storageLocation: freezed == storageLocation ? _self.storageLocation : storageLocation // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Product].
extension ProductPatterns on Product {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Product value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Product() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Product value)  $default,){
final _that = this;
switch (_that) {
case _Product():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Product value)?  $default,){
final _that = this;
switch (_that) {
case _Product() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String barcode,  String name,  String? scientificName,  String category,  String? manufacturer,  double price,  double costPrice,  int countInBox,  double unitPrice,  int quantity,  DateTime? expiryDate,  String? storageLocation,  String? description)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Product() when $default != null:
return $default(_that.barcode,_that.name,_that.scientificName,_that.category,_that.manufacturer,_that.price,_that.costPrice,_that.countInBox,_that.unitPrice,_that.quantity,_that.expiryDate,_that.storageLocation,_that.description);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String barcode,  String name,  String? scientificName,  String category,  String? manufacturer,  double price,  double costPrice,  int countInBox,  double unitPrice,  int quantity,  DateTime? expiryDate,  String? storageLocation,  String? description)  $default,) {final _that = this;
switch (_that) {
case _Product():
return $default(_that.barcode,_that.name,_that.scientificName,_that.category,_that.manufacturer,_that.price,_that.costPrice,_that.countInBox,_that.unitPrice,_that.quantity,_that.expiryDate,_that.storageLocation,_that.description);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String barcode,  String name,  String? scientificName,  String category,  String? manufacturer,  double price,  double costPrice,  int countInBox,  double unitPrice,  int quantity,  DateTime? expiryDate,  String? storageLocation,  String? description)?  $default,) {final _that = this;
switch (_that) {
case _Product() when $default != null:
return $default(_that.barcode,_that.name,_that.scientificName,_that.category,_that.manufacturer,_that.price,_that.costPrice,_that.countInBox,_that.unitPrice,_that.quantity,_that.expiryDate,_that.storageLocation,_that.description);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Product implements Product {
  const _Product({required this.barcode, required this.name, this.scientificName, required this.category, this.manufacturer, required this.price, required this.costPrice, required this.countInBox, required this.unitPrice, required this.quantity, this.expiryDate, this.storageLocation, this.description});
  factory _Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);

@override final  String barcode;
@override final  String name;
@override final  String? scientificName;
@override final  String category;
@override final  String? manufacturer;
/// Pricing
@override final  double price;
@override final  double costPrice;
@override final  int countInBox;
@override final  double unitPrice;
/// Stock
@override final  int quantity;
@override final  DateTime? expiryDate;
/// Optional
@override final  String? storageLocation;
@override final  String? description;

/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductCopyWith<_Product> get copyWith => __$ProductCopyWithImpl<_Product>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProductToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Product&&(identical(other.barcode, barcode) || other.barcode == barcode)&&(identical(other.name, name) || other.name == name)&&(identical(other.scientificName, scientificName) || other.scientificName == scientificName)&&(identical(other.category, category) || other.category == category)&&(identical(other.manufacturer, manufacturer) || other.manufacturer == manufacturer)&&(identical(other.price, price) || other.price == price)&&(identical(other.costPrice, costPrice) || other.costPrice == costPrice)&&(identical(other.countInBox, countInBox) || other.countInBox == countInBox)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.expiryDate, expiryDate) || other.expiryDate == expiryDate)&&(identical(other.storageLocation, storageLocation) || other.storageLocation == storageLocation)&&(identical(other.description, description) || other.description == description));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,barcode,name,scientificName,category,manufacturer,price,costPrice,countInBox,unitPrice,quantity,expiryDate,storageLocation,description);
}

@override
String toString() {
    return 'Product(barcode: $barcode, name: $name, scientificName: $scientificName, category: $category, manufacturer: $manufacturer, price: $price, costPrice: $costPrice, countInBox: $countInBox, unitPrice: $unitPrice, quantity: $quantity, expiryDate: $expiryDate, storageLocation: $storageLocation, description: $description)';
}


}

/// @nodoc
abstract mixin class _$ProductCopyWith<$Res> implements $ProductCopyWith<$Res> {
  factory _$ProductCopyWith(_Product value, $Res Function(_Product) _then) = __$ProductCopyWithImpl;
@override @useResult
$Res call({
 String barcode, String name, String? scientificName, String category, String? manufacturer, double price, double costPrice, int countInBox, double unitPrice, int quantity, DateTime? expiryDate, String? storageLocation, String? description
});




}
/// @nodoc
class __$ProductCopyWithImpl<$Res>
    implements _$ProductCopyWith<$Res> {
  __$ProductCopyWithImpl(this._self, this._then);

  final _Product _self;
  final $Res Function(_Product) _then;

/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? barcode = null,Object? name = null,Object? scientificName = freezed,Object? category = null,Object? manufacturer = freezed,Object? price = null,Object? costPrice = null,Object? countInBox = null,Object? unitPrice = null,Object? quantity = null,Object? expiryDate = freezed,Object? storageLocation = freezed,Object? description = freezed,}) {
  return _then(_Product(
barcode: null == barcode ? _self.barcode : barcode // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,scientificName: freezed == scientificName ? _self.scientificName : scientificName // ignore: cast_nullable_to_non_nullable
as String?,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,manufacturer: freezed == manufacturer ? _self.manufacturer : manufacturer // ignore: cast_nullable_to_non_nullable
as String?,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,costPrice: null == costPrice ? _self.costPrice : costPrice // ignore: cast_nullable_to_non_nullable
as double,countInBox: null == countInBox ? _self.countInBox : countInBox // ignore: cast_nullable_to_non_nullable
as int,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as double,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,expiryDate: freezed == expiryDate ? _self.expiryDate : expiryDate // ignore: cast_nullable_to_non_nullable
as DateTime?,storageLocation: freezed == storageLocation ? _self.storageLocation : storageLocation // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
