// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recorded_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecordedResponse _$RecordedResponseFromJson(Map<String, dynamic> json) =>
    RecordedResponse(
      statusCode: json['statusCode'] as int?,
      body: json['body'],
      headers: (json['headers'] as Map<String, dynamic>?)?.map(
        (k, e) =>
            MapEntry(k, (e as List<dynamic>).map((e) => e as String).toList()),
      ),
    );

Map<String, dynamic> _$RecordedResponseToJson(RecordedResponse instance) =>
    <String, dynamic>{
      'statusCode': instance.statusCode,
      'body': instance.body,
      'headers': instance.headers,
    };
