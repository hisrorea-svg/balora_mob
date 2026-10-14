// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Product _$ProductFromJson(Map<String, dynamic> json) => _Product(
  barcode: json['barcode'] as String,
  name: json['name'] as String,
  scientificName: json['scientificName'] as String?,
  category: json['category'] as String,
  manufacturer: json['manufacturer'] as String?,
  price: (json['price'] as num).toDouble(),
  costPrice: (json['costPrice'] as num).toDouble(),
  countInBox: (json['countInBox'] as num).toInt(),
  unitPrice: (json['unitPrice'] as num).toDouble(),
  quantity: (json['quantity'] as num).toInt(),
  expiryDate: json['expiryDate'] == null
      ? null
      : DateTime.parse(json['expiryDate'] as String),
  storageLocation: json['storageLocation'] as String?,
  description: json['description'] as String?,
);

Map<String, dynamic> _$ProductToJson(_Product instance) => <String, dynamic>{
  'barcode': instance.barcode,
  'name': instance.name,
  'scientificName': instance.scientificName,
  'category': instance.category,
  'manufacturer': instance.manufacturer,
  'price': instance.price,
  'costPrice': instance.costPrice,
  'countInBox': instance.countInBox,
  'unitPrice': instance.unitPrice,
  'quantity': instance.quantity,
  'expiryDate': instance.expiryDate?.toIso8601String(),
  'storageLocation': instance.storageLocation,
  'description': instance.description,
};
