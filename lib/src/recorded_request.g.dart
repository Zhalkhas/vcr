// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recorded_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecordedRequest _$RecordedRequestFromJson(Map<String, dynamic> json) =>
    RecordedRequest(
      url: Uri.parse(json['url'] as String),
      payload: json['payload'],
      headers: json['headers'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$RecordedRequestToJson(RecordedRequest instance) =>
    <String, dynamic>{
      'url': instance.url.toString(),
      'payload': instance.payload,
      'headers': instance.headers,
    };
