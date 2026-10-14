// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pairing_payload.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PairingPayload _$PairingPayloadFromJson(Map<String, dynamic> json) =>
    _PairingPayload(
      server: json['server'] as String,
      pairToken: json['pairToken'] as String,
      deviceName: json['deviceName'] as String,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      version: (json['version'] as num?)?.toInt() ?? 1,
    );

Map<String, dynamic> _$PairingPayloadToJson(_PairingPayload instance) =>
    <String, dynamic>{
      'server': instance.server,
      'pairToken': instance.pairToken,
      'deviceName': instance.deviceName,
      'expiresAt': instance.expiresAt.toIso8601String(),
      'version': instance.version,
    };

_PairingResponse _$PairingResponseFromJson(Map<String, dynamic> json) =>
    _PairingResponse(
      sessionToken: json['sessionToken'] as String,
      deviceId: json['deviceId'] as String,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      permissions:
          (json['permissions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$PairingResponseToJson(_PairingResponse instance) =>
    <String, dynamic>{
      'sessionToken': instance.sessionToken,
      'deviceId': instance.deviceId,
      'expiresAt': instance.expiresAt.toIso8601String(),
      'permissions': instance.permissions,
    };
