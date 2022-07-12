import 'package:json_annotation/json_annotation.dart';
import 'package:vcr/src/recorded_request.dart';
import 'package:vcr/src/recorded_response.dart';

part 'cassette.g.dart';

@JsonSerializable()
class Cassette {
  final RecordedRequest request;
  final RecordedResponse response;
  final DateTime createdAt;

  Cassette({
    required this.request,
    required this.response,
    required this.createdAt,
  });

  factory Cassette.fromJson(Map<String, dynamic> json) =>
      _$CassetteFromJson(json);

  Map<String, dynamic> toJson() => _$CassetteToJson(this);
}
