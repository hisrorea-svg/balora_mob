// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'draft_product.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DraftProduct {

/// Barcode of the box/package
 String get barcode;/// Barcode of an individual strip or unit (optional)
 String? get stripBarcode;/// Commercial/Arabic name
 String get nameAr;/// English name (for label printers)
 String? get nameEn;/// Active ingredient / scientific formula
 String? get scientificName;/// Drug category (e.g. Antibiotic, Analgesic)
 String get category;/// Pharmaceutical form (e.g. Capsule, Syrup, Tablet, Ampoule)
 String? get dosageForm;/// Manufacturing company
 String? get manufacturer;/// Box cost price (IQD)
 double get costPriceBox;/// Box selling price (IQD)
 double get sellPriceBox;/// Number of strips/units per box
 int get stripsPerBox;/// Unit cost price (IQD)
 double get costPriceUnit;/// Unit selling price (IQD)
 double get sellPriceUnit;/// Opening stock quantity
 int get quantity;/// Bonus quantity received free from supplier
 int get bonus;/// Purchase unit: 'box' or 'unit'
 String get purchaseUnit;/// Unit of opening stock ('box' or 'unit')
 String get quantityUnit;/// Batch or lot number
 String? get batchNumber;/// Expiration date (formatted as YYYY-MM or YYYY-MM-DD)
 String? get expiryDate;/// Shelf/storage location (e.g. A-12, Ref-3)
 String? get shelfLocation;/// Any additional notes
 String? get notes;
/// Create a copy of DraftProduct
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DraftProductCopyWith<DraftProduct> get copyWith => _$DraftProductCopyWithImpl<DraftProduct>(this as DraftProduct, _$identity);

  /// Serializes this DraftProduct to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DraftProduct;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DraftProduct&&(identical(other.barcode, _this.barcode) || other.barcode == _this.barcode)&&(identical(other.stripBarcode, _this.stripBarcode) || other.stripBarcode == _this.stripBarcode)&&(identical(other.nameAr, _this.nameAr) || other.nameAr == _this.nameAr)&&(identical(other.nameEn, _this.nameEn) || other.nameEn == _this.nameEn)&&(identical(other.scientificName, _this.scientificName) || other.scientificName == _this.scientificName)&&(identical(other.category, _this.category) || other.category == _this.category)&&(identical(other.dosageForm, _this.dosageForm) || other.dosageForm == _this.dosageForm)&&(identical(other.manufacturer, _this.manufacturer) || other.manufacturer == _this.manufacturer)&&(identical(other.costPriceBox, _this.costPriceBox) || other.costPriceBox == _this.costPriceBox)&&(identical(other.sellPriceBox, _this.sellPriceBox) || other.sellPriceBox == _this.sellPriceBox)&&(identical(other.stripsPerBox, _this.stripsPerBox) || other.stripsPerBox == _this.stripsPerBox)&&(identical(other.costPriceUnit, _this.costPriceUnit) || other.costPriceUnit == _this.costPriceUnit)&&(identical(other.sellPriceUnit, _this.sellPriceUnit) || other.sellPriceUnit == _this.sellPriceUnit)&&(identical(other.quantity, _this.quantity) || other.quantity == _this.quantity)&&(identical(other.bonus, _this.bonus) || other.bonus == _this.bonus)&&(identical(other.purchaseUnit, _this.purchaseUnit) || other.purchaseUnit == _this.purchaseUnit)&&(identical(other.quantityUnit, _this.quantityUnit) || other.quantityUnit == _this.quantityUnit)&&(identical(other.batchNumber, _this.batchNumber) || other.batchNumber == _this.batchNumber)&&(identical(other.expiryDate, _this.expiryDate) || other.expiryDate == _this.expiryDate)&&(identical(other.shelfLocation, _this.shelfLocation) || other.shelfLocation == _this.shelfLocation)&&(identical(other.notes, _this.notes) || other.notes == _this.notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DraftProduct;
  return Object.hashAll([runtimeType,_this.barcode,_this.stripBarcode,_this.nameAr,_this.nameEn,_this.scientificName,_this.category,_this.dosageForm,_this.manufacturer,_this.costPriceBox,_this.sellPriceBox,_this.stripsPerBox,_this.costPriceUnit,_this.sellPriceUnit,_this.quantity,_this.bonus,_this.purchaseUnit,_this.quantityUnit,_this.batchNumber,_this.expiryDate,_this.shelfLocation,_this.notes]);
}

@override
String toString() {
  final _this = this as DraftProduct;
  return 'DraftProduct(barcode: ${_this.barcode}, stripBarcode: ${_this.stripBarcode}, nameAr: ${_this.nameAr}, nameEn: ${_this.nameEn}, scientificName: ${_this.scientificName}, category: ${_this.category}, dosageForm: ${_this.dosageForm}, manufacturer: ${_this.manufacturer}, costPriceBox: ${_this.costPriceBox}, sellPriceBox: ${_this.sellPriceBox}, stripsPerBox: ${_this.stripsPerBox}, costPriceUnit: ${_this.costPriceUnit}, sellPriceUnit: ${_this.sellPriceUnit}, quantity: ${_this.quantity}, bonus: ${_this.bonus}, purchaseUnit: ${_this.purchaseUnit}, quantityUnit: ${_this.quantityUnit}, batchNumber: ${_this.batchNumber}, expiryDate: ${_this.expiryDate}, shelfLocation: ${_this.shelfLocation}, notes: ${_this.notes})';
}


}

/// @nodoc
abstract mixin class $DraftProductCopyWith<$Res>  {
  factory $DraftProductCopyWith(DraftProduct value, $Res Function(DraftProduct) _then) = _$DraftProductCopyWithImpl;
@useResult
$Res call({
 String barcode, String? stripBarcode, String nameAr, String? nameEn, String? scientificName, String category, String? dosageForm, String? manufacturer, double costPriceBox, double sellPriceBox, int stripsPerBox, double costPriceUnit, double sellPriceUnit, int quantity, int bonus, String purchaseUnit, String quantityUnit, String? batchNumber, String? expiryDate, String? shelfLocation, String? notes
});




}
/// @nodoc
class _$DraftProductCopyWithImpl<$Res>
    implements $DraftProductCopyWith<$Res> {
  _$DraftProductCopyWithImpl(this._self, this._then);

  final DraftProduct _self;
  final $Res Function(DraftProduct) _then;

/// Create a copy of DraftProduct
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? barcode = null,Object? stripBarcode = freezed,Object? nameAr = null,Object? nameEn = freezed,Object? scientificName = freezed,Object? category = null,Object? dosageForm = freezed,Object? manufacturer = freezed,Object? costPriceBox = null,Object? sellPriceBox = null,Object? stripsPerBox = null,Object? costPriceUnit = null,Object? sellPriceUnit = null,Object? quantity = null,Object? bonus = null,Object? purchaseUnit = null,Object? quantityUnit = null,Object? batchNumber = freezed,Object? expiryDate = freezed,Object? shelfLocation = freezed,Object? notes = freezed,}) {
  return _then(DraftProduct(
barcode: null == barcode ? _self.barcode : barcode // ignore: cast_nullable_to_non_nullable
as String,stripBarcode: freezed == stripBarcode ? _self.stripBarcode : stripBarcode // ignore: cast_nullable_to_non_nullable
as String?,nameAr: null == nameAr ? _self.nameAr : nameAr // ignore: cast_nullable_to_non_nullable
as String,nameEn: freezed == nameEn ? _self.nameEn : nameEn // ignore: cast_nullable_to_non_nullable
as String?,scientificName: freezed == scientificName ? _self.scientificName : scientificName // ignore: cast_nullable_to_non_nullable
as String?,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,dosageForm: freezed == dosageForm ? _self.dosageForm : dosageForm // ignore: cast_nullable_to_non_nullable
as String?,manufacturer: freezed == manufacturer ? _self.manufacturer : manufacturer // ignore: cast_nullable_to_non_nullable
as String?,costPriceBox: null == costPriceBox ? _self.costPriceBox : costPriceBox // ignore: cast_nullable_to_non_nullable
as double,sellPriceBox: null == sellPriceBox ? _self.sellPriceBox : sellPriceBox // ignore: cast_nullable_to_non_nullable
as double,stripsPerBox: null == stripsPerBox ? _self.stripsPerBox : stripsPerBox // ignore: cast_nullable_to_non_nullable
as int,costPriceUnit: null == costPriceUnit ? _self.costPriceUnit : costPriceUnit // ignore: cast_nullable_to_non_nullable
as double,sellPriceUnit: null == sellPriceUnit ? _self.sellPriceUnit : sellPriceUnit // ignore: cast_nullable_to_non_nullable
as double,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,bonus: null == bonus ? _self.bonus : bonus // ignore: cast_nullable_to_non_nullable
as int,purchaseUnit: null == purchaseUnit ? _self.purchaseUnit : purchaseUnit // ignore: cast_nullable_to_non_nullable
as String,quantityUnit: null == quantityUnit ? _self.quantityUnit : quantityUnit // ignore: cast_nullable_to_non_nullable
as String,batchNumber: freezed == batchNumber ? _self.batchNumber : batchNumber // ignore: cast_nullable_to_non_nullable
as String?,expiryDate: freezed == expiryDate ? _self.expiryDate : expiryDate // ignore: cast_nullable_to_non_nullable
as String?,shelfLocation: freezed == shelfLocation ? _self.shelfLocation : shelfLocation // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [DraftProduct].
extension DraftProductPatterns on DraftProduct {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DraftProduct value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DraftProduct() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DraftProduct value)  $default,){
final _that = this;
switch (_that) {
case _DraftProduct():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DraftProduct value)?  $default,){
final _that = this;
switch (_that) {
case _DraftProduct() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String barcode,  String? stripBarcode,  String nameAr,  String? nameEn,  String? scientificName,  String category,  String? dosageForm,  String? manufacturer,  double costPriceBox,  double sellPriceBox,  int stripsPerBox,  double costPriceUnit,  double sellPriceUnit,  int quantity,  int bonus,  String purchaseUnit,  String quantityUnit,  String? batchNumber,  String? expiryDate,  String? shelfLocation,  String? notes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DraftProduct() when $default != null:
return $default(_that.barcode,_that.stripBarcode,_that.nameAr,_that.nameEn,_that.scientificName,_that.category,_that.dosageForm,_that.manufacturer,_that.costPriceBox,_that.sellPriceBox,_that.stripsPerBox,_that.costPriceUnit,_that.sellPriceUnit,_that.quantity,_that.bonus,_that.purchaseUnit,_that.quantityUnit,_that.batchNumber,_that.expiryDate,_that.shelfLocation,_that.notes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String barcode,  String? stripBarcode,  String nameAr,  String? nameEn,  String? scientificName,  String category,  String? dosageForm,  String? manufacturer,  double costPriceBox,  double sellPriceBox,  int stripsPerBox,  double costPriceUnit,  double sellPriceUnit,  int quantity,  int bonus,  String purchaseUnit,  String quantityUnit,  String? batchNumber,  String? expiryDate,  String? shelfLocation,  String? notes)  $default,) {final _that = this;
switch (_that) {
case _DraftProduct():
return $default(_that.barcode,_that.stripBarcode,_that.nameAr,_that.nameEn,_that.scientificName,_that.category,_that.dosageForm,_that.manufacturer,_that.costPriceBox,_that.sellPriceBox,_that.stripsPerBox,_that.costPriceUnit,_that.sellPriceUnit,_that.quantity,_that.bonus,_that.purchaseUnit,_that.quantityUnit,_that.batchNumber,_that.expiryDate,_that.shelfLocation,_that.notes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String barcode,  String? stripBarcode,  String nameAr,  String? nameEn,  String? scientificName,  String category,  String? dosageForm,  String? manufacturer,  double costPriceBox,  double sellPriceBox,  int stripsPerBox,  double costPriceUnit,  double sellPriceUnit,  int quantity,  int bonus,  String purchaseUnit,  String quantityUnit,  String? batchNumber,  String? expiryDate,  String? shelfLocation,  String? notes)?  $default,) {final _that = this;
switch (_that) {
case _DraftProduct() when $default != null:
return $default(_that.barcode,_that.stripBarcode,_that.nameAr,_that.nameEn,_that.scientificName,_that.category,_that.dosageForm,_that.manufacturer,_that.costPriceBox,_that.sellPriceBox,_that.stripsPerBox,_that.costPriceUnit,_that.sellPriceUnit,_that.quantity,_that.bonus,_that.purchaseUnit,_that.quantityUnit,_that.batchNumber,_that.expiryDate,_that.shelfLocation,_that.notes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DraftProduct implements DraftProduct {
  const _DraftProduct({required this.barcode, this.stripBarcode, required this.nameAr, this.nameEn, this.scientificName, this.category = 'أدوية', this.dosageForm, this.manufacturer, this.costPriceBox = 0.0, this.sellPriceBox = 0.0, this.stripsPerBox = 1, this.costPriceUnit = 0.0, this.sellPriceUnit = 0.0, this.quantity = 0, this.bonus = 0, this.purchaseUnit = 'box', this.quantityUnit = 'box', this.batchNumber, this.expiryDate, this.shelfLocation, this.notes});
  factory _DraftProduct.fromJson(Map<String, dynamic> json) => _$DraftProductFromJson(json);

/// Barcode of the box/package
@override final  String barcode;
/// Barcode of an individual strip or unit (optional)
@override final  String? stripBarcode;
/// Commercial/Arabic name
@override final  String nameAr;
/// English name (for label printers)
@override final  String? nameEn;
/// Active ingredient / scientific formula
@override final  String? scientificName;
/// Drug category (e.g. Antibiotic, Analgesic)
@override@JsonKey() final  String category;
/// Pharmaceutical form (e.g. Capsule, Syrup, Tablet, Ampoule)
@override final  String? dosageForm;
/// Manufacturing company
@override final  String? manufacturer;
/// Box cost price (IQD)
@override@JsonKey() final  double costPriceBox;
/// Box selling price (IQD)
@override@JsonKey() final  double sellPriceBox;
/// Number of strips/units per box
@override@JsonKey() final  int stripsPerBox;
/// Unit cost price (IQD)
@override@JsonKey() final  double costPriceUnit;
/// Unit selling price (IQD)
@override@JsonKey() final  double sellPriceUnit;
/// Opening stock quantity
@override@JsonKey() final  int quantity;
/// Bonus quantity received free from supplier
@override@JsonKey() final  int bonus;
/// Purchase unit: 'box' or 'unit'
@override@JsonKey() final  String purchaseUnit;
/// Unit of opening stock ('box' or 'unit')
@override@JsonKey() final  String quantityUnit;
/// Batch or lot number
@override final  String? batchNumber;
/// Expiration date (formatted as YYYY-MM or YYYY-MM-DD)
@override final  String? expiryDate;
/// Shelf/storage location (e.g. A-12, Ref-3)
@override final  String? shelfLocation;
/// Any additional notes
@override final  String? notes;

/// Create a copy of DraftProduct
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DraftProductCopyWith<_DraftProduct> get copyWith => __$DraftProductCopyWithImpl<_DraftProduct>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DraftProductToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DraftProduct&&(identical(other.barcode, barcode) || other.barcode == barcode)&&(identical(other.stripBarcode, stripBarcode) || other.stripBarcode == stripBarcode)&&(identical(other.nameAr, nameAr) || other.nameAr == nameAr)&&(identical(other.nameEn, nameEn) || other.nameEn == nameEn)&&(identical(other.scientificName, scientificName) || other.scientificName == scientificName)&&(identical(other.category, category) || other.category == category)&&(identical(other.dosageForm, dosageForm) || other.dosageForm == dosageForm)&&(identical(other.manufacturer, manufacturer) || other.manufacturer == manufacturer)&&(identical(other.costPriceBox, costPriceBox) || other.costPriceBox == costPriceBox)&&(identical(other.sellPriceBox, sellPriceBox) || other.sellPriceBox == sellPriceBox)&&(identical(other.stripsPerBox, stripsPerBox) || other.stripsPerBox == stripsPerBox)&&(identical(other.costPriceUnit, costPriceUnit) || other.costPriceUnit == costPriceUnit)&&(identical(other.sellPriceUnit, sellPriceUnit) || other.sellPriceUnit == sellPriceUnit)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.bonus, bonus) || other.bonus == bonus)&&(identical(other.purchaseUnit, purchaseUnit) || other.purchaseUnit == purchaseUnit)&&(identical(other.quantityUnit, quantityUnit) || other.quantityUnit == quantityUnit)&&(identical(other.batchNumber, batchNumber) || other.batchNumber == batchNumber)&&(identical(other.expiryDate, expiryDate) || other.expiryDate == expiryDate)&&(identical(other.shelfLocation, shelfLocation) || other.shelfLocation == shelfLocation)&&(identical(other.notes, notes) || other.notes == notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hashAll([runtimeType,barcode,stripBarcode,nameAr,nameEn,scientificName,category,dosageForm,manufacturer,costPriceBox,sellPriceBox,stripsPerBox,costPriceUnit,sellPriceUnit,quantity,bonus,purchaseUnit,quantityUnit,batchNumber,expiryDate,shelfLocation,notes]);
}

@override
String toString() {
    return 'DraftProduct(barcode: $barcode, stripBarcode: $stripBarcode, nameAr: $nameAr, nameEn: $nameEn, scientificName: $scientificName, category: $category, dosageForm: $dosageForm, manufacturer: $manufacturer, costPriceBox: $costPriceBox, sellPriceBox: $sellPriceBox, stripsPerBox: $stripsPerBox, costPriceUnit: $costPriceUnit, sellPriceUnit: $sellPriceUnit, quantity: $quantity, bonus: $bonus, purchaseUnit: $purchaseUnit, quantityUnit: $quantityUnit, batchNumber: $batchNumber, expiryDate: $expiryDate, shelfLocation: $shelfLocation, notes: $notes)';
}


}

/// @nodoc
abstract mixin class _$DraftProductCopyWith<$Res> implements $DraftProductCopyWith<$Res> {
  factory _$DraftProductCopyWith(_DraftProduct value, $Res Function(_DraftProduct) _then) = __$DraftProductCopyWithImpl;
@override @useResult
$Res call({
 String barcode, String? stripBarcode, String nameAr, String? nameEn, String? scientificName, String category, String? dosageForm, String? manufacturer, double costPriceBox, double sellPriceBox, int stripsPerBox, double costPriceUnit, double sellPriceUnit, int quantity, int bonus, String purchaseUnit, String quantityUnit, String? batchNumber, String? expiryDate, String? shelfLocation, String? notes
});




}
/// @nodoc
class __$DraftProductCopyWithImpl<$Res>
    implements _$DraftProductCopyWith<$Res> {
  __$DraftProductCopyWithImpl(this._self, this._then);

  final _DraftProduct _self;
  final $Res Function(_DraftProduct) _then;

/// Create a copy of DraftProduct
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? barcode = null,Object? stripBarcode = freezed,Object? nameAr = null,Object? nameEn = freezed,Object? scientificName = freezed,Object? category = null,Object? dosageForm = freezed,Object? manufacturer = freezed,Object? costPriceBox = null,Object? sellPriceBox = null,Object? stripsPerBox = null,Object? costPriceUnit = null,Object? sellPriceUnit = null,Object? quantity = null,Object? bonus = null,Object? purchaseUnit = null,Object? quantityUnit = null,Object? batchNumber = freezed,Object? expiryDate = freezed,Object? shelfLocation = freezed,Object? notes = freezed,}) {
  return _then(_DraftProduct(
barcode: null == barcode ? _self.barcode : barcode // ignore: cast_nullable_to_non_nullable
as String,stripBarcode: freezed == stripBarcode ? _self.stripBarcode : stripBarcode // ignore: cast_nullable_to_non_nullable
as String?,nameAr: null == nameAr ? _self.nameAr : nameAr // ignore: cast_nullable_to_non_nullable
as String,nameEn: freezed == nameEn ? _self.nameEn : nameEn // ignore: cast_nullable_to_non_nullable
as String?,scientificName: freezed == scientificName ? _self.scientificName : scientificName // ignore: cast_nullable_to_non_nullable
as String?,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,dosageForm: freezed == dosageForm ? _self.dosageForm : dosageForm // ignore: cast_nullable_to_non_nullable
as String?,manufacturer: freezed == manufacturer ? _self.manufacturer : manufacturer // ignore: cast_nullable_to_non_nullable
as String?,costPriceBox: null == costPriceBox ? _self.costPriceBox : costPriceBox // ignore: cast_nullable_to_non_nullable
as double,sellPriceBox: null == sellPriceBox ? _self.sellPriceBox : sellPriceBox // ignore: cast_nullable_to_non_nullable
as double,stripsPerBox: null == stripsPerBox ? _self.stripsPerBox : stripsPerBox // ignore: cast_nullable_to_non_nullable
as int,costPriceUnit: null == costPriceUnit ? _self.costPriceUnit : costPriceUnit // ignore: cast_nullable_to_non_nullable
as double,sellPriceUnit: null == sellPriceUnit ? _self.sellPriceUnit : sellPriceUnit // ignore: cast_nullable_to_non_nullable
as double,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,bonus: null == bonus ? _self.bonus : bonus // ignore: cast_nullable_to_non_nullable
as int,purchaseUnit: null == purchaseUnit ? _self.purchaseUnit : purchaseUnit // ignore: cast_nullable_to_non_nullable
as String,quantityUnit: null == quantityUnit ? _self.quantityUnit : quantityUnit // ignore: cast_nullable_to_non_nullable
as String,batchNumber: freezed == batchNumber ? _self.batchNumber : batchNumber // ignore: cast_nullable_to_non_nullable
as String?,expiryDate: freezed == expiryDate ? _self.expiryDate : expiryDate // ignore: cast_nullable_to_non_nullable
as String?,shelfLocation: freezed == shelfLocation ? _self.shelfLocation : shelfLocation // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
