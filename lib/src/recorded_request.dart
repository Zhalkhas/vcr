import 'package:json_annotation/json_annotation.dart';

part 'recorded_request.g.dart';

@JsonSerializable()
class RecordedRequest {
  final Uri url;
  final dynamic payload;
  final Map<String, dynamic> headers;

  RecordedRequest({
    required this.url,
    this.payload,
    Map<String, dynamic>? headers,
  }) : headers = headers ?? {};

  factory RecordedRequest.fromJson(Map<String, dynamic> json) =>
      _$RecordedRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RecordedRequestToJson(this);
}
