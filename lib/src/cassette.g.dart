// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cassette.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Cassette _$CassetteFromJson(Map<String, dynamic> json) => Cassette(
      request:
          RecordedRequest.fromJson(json['request'] as Map<String, dynamic>),
      response:
          RecordedResponse.fromJson(json['response'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$CassetteToJson(Cassette instance) => <String, dynamic>{
      'request': instance.request,
      'response': instance.response,
      'createdAt': instance.createdAt.toIso8601String(),
    };
