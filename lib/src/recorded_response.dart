import 'package:json_annotation/json_annotation.dart';

part 'recorded_response.g.dart';

@JsonSerializable()
class RecordedResponse {
  final int? statusCode;
  final dynamic body;
  final Map<String, List<String>> headers;

  RecordedResponse({
    this.statusCode,
    this.body,
    Map<String, List<String>>? headers,
  }) : headers = headers ?? {};

  factory RecordedResponse.fromJson(Map<String, dynamic> json) =>
      _$RecordedResponseFromJson(json);

  Map<String, dynamic> toJson() => _$RecordedResponseToJson(this);
}
