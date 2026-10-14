// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'command.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Command _$CommandFromJson(Map<String, dynamic> json) => _Command(
  commandId: json['commandId'] as String,
  type: $enumDecode(_$CommandTypeEnumMap, json['type']),
  barcode: json['barcode'] as String?,
  timestamp: DateTime.parse(json['timestamp'] as String),
  deviceId: json['deviceId'] as String,
  payload: json['payload'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$CommandToJson(_Command instance) => <String, dynamic>{
  'commandId': instance.commandId,
  'type': _$CommandTypeEnumMap[instance.type]!,
  'barcode': instance.barcode,
  'timestamp': instance.timestamp.toIso8601String(),
  'deviceId': instance.deviceId,
  'payload': instance.payload,
};

const _$CommandTypeEnumMap = {
  CommandType.scan: 'scan',
  CommandType.addProduct: 'add_product',
  CommandType.updateProduct: 'update_product',
  CommandType.deleteProduct: 'delete_product',
  CommandType.inventoryScan: 'inventory_scan',
  CommandType.inventorySubmit: 'inventory_submit',
  CommandType.posScan: 'pos_scan',
};
