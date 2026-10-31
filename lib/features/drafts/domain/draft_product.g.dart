// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'draft_product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DraftProduct _$DraftProductFromJson(Map<String, dynamic> json) =>
    _DraftProduct(
      barcode: json['barcode'] as String,
      stripBarcode: json['stripBarcode'] as String?,
      nameAr: json['nameAr'] as String,
      nameEn: json['nameEn'] as String?,
      scientificName: json['scientificName'] as String?,
      category: json['category'] as String? ?? 'أدوية',
      dosageForm: json['dosageForm'] as String?,
      manufacturer: json['manufacturer'] as String?,
      costPriceBox: (json['costPriceBox'] as num?)?.toDouble() ?? 0.0,
      sellPriceBox: (json['sellPriceBox'] as num?)?.toDouble() ?? 0.0,
      stripsPerBox: (json['stripsPerBox'] as num?)?.toInt() ?? 1,
      costPriceUnit: (json['costPriceUnit'] as num?)?.toDouble() ?? 0.0,
      sellPriceUnit: (json['sellPriceUnit'] as num?)?.toDouble() ?? 0.0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      bonus: (json['bonus'] as num?)?.toInt() ?? 0,
      purchaseUnit: json['purchaseUnit'] as String? ?? 'box',
      quantityUnit: json['quantityUnit'] as String? ?? 'box',
      batchNumber: json['batchNumber'] as String?,
      expiryDate: json['expiryDate'] as String?,
      shelfLocation: json['shelfLocation'] as String?,
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$DraftProductToJson(_DraftProduct instance) =>
    <String, dynamic>{
      'barcode': instance.barcode,
      'stripBarcode': instance.stripBarcode,
      'nameAr': instance.nameAr,
      'nameEn': instance.nameEn,
      'scientificName': instance.scientificName,
      'category': instance.category,
      'dosageForm': instance.dosageForm,
      'manufacturer': instance.manufacturer,
      'costPriceBox': instance.costPriceBox,
      'sellPriceBox': instance.sellPriceBox,
      'stripsPerBox': instance.stripsPerBox,
      'costPriceUnit': instance.costPriceUnit,
      'sellPriceUnit': instance.sellPriceUnit,
      'quantity': instance.quantity,
      'bonus': instance.bonus,
      'purchaseUnit': instance.purchaseUnit,
      'quantityUnit': instance.quantityUnit,
      'batchNumber': instance.batchNumber,
      'expiryDate': instance.expiryDate,
      'shelfLocation': instance.shelfLocation,
      'notes': instance.notes,
    };
