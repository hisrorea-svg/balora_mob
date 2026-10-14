// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ack_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AckResponse _$AckResponseFromJson(Map<String, dynamic> json) => _AckResponse(
  commandId: json['commandId'] as String,
  status: $enumDecode(_$AckStatusEnumMap, json['status']),
  message: json['message'] as String?,
  data: json['data'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$AckResponseToJson(_AckResponse instance) =>
    <String, dynamic>{
      'commandId': instance.commandId,
      'status': _$AckStatusEnumMap[instance.status]!,
      'message': instance.message,
      'data': instance.data,
    };

const _$AckStatusEnumMap = {
  AckStatus.success: 'success',
  AckStatus.failure: 'failure',
  AckStatus.pending: 'pending',
};
