import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:mockito/mockito.dart';
import 'package:vcr/src/cassette.dart';
import 'package:vcr/src/recorded_request.dart';
import 'package:vcr/src/recorded_response.dart';

const dioHttpHeadersForResponseBody = {
  Headers.contentTypeHeader: [Headers.jsonContentType],
};

class VcrAdapter extends Mock implements HttpClientAdapter {
  String basePath = 'test/cassettes';

  void useCassette(String path) {
    File file = _loadFile(path);

    if (!file.existsSync()) {
      makeNormalRequestWithAdapter(file);
      return;
    }
    makeMockRequestWithAdapter(file);
    return;
  }

  File _loadFile(String path) {
    if (!path.contains('.json')) {
      path = "$path.json";
    }
    Directory current = Directory.current;
    String finalPath =
        current.path.endsWith('/test') ? current.path : current.path + '/test';

    finalPath = "$finalPath/cassettes/$path";

    return File(finalPath);
  }

  void makeMockRequestWithAdapter(File file) {
    when(fetch(any as RequestOptions, any, any)).thenAnswer((invocation) async {
      List<dynamic> arguments = invocation.positionalArguments;
      return makeMockRequest(file, arguments[0] as RequestOptions,
          arguments[1] as Stream<List<int>>, arguments[2] as Future);
    });
  }

  void makeNormalRequestWithAdapter(File file) {
    when(fetch(any as RequestOptions, any, any)).thenAnswer((invocation) async {
      List<dynamic> arguments = invocation.positionalArguments;
      if (file.existsSync()) {
        return makeMockRequest(file, arguments[0] as RequestOptions,
            arguments[1] as Stream<List<int>>, arguments[2] as Future);
      }

      return makeNormalRequest(file, arguments[0] as RequestOptions,
          arguments[1] as Stream<List<int>>, arguments[2] as Future);
    });
  }

  Future<ResponseBody> makeNormalRequest(
    File file,
    RequestOptions options,
    Stream<List<int>> requestStream,
    Future<void> cancelFuture,
  ) async {
    final adapter = DefaultHttpClientAdapter();

    ResponseBody responseBody = await adapter.fetch(
        options, requestStream.map(Uint8List.fromList), cancelFuture);

    final status = responseBody.statusCode;

    DefaultTransformer transformer = DefaultTransformer();

    var data = await transformer.transformResponse(options, responseBody);

    _storeRequest(file, options, data, responseBody);

    return ResponseBody.fromString(
      json.encode(data),
      status,
      headers: dioHttpHeadersForResponseBody,
    );
  }

  Future<ResponseBody> makeMockRequest(
    File file,
    RequestOptions options,
    Stream<List<int>> requestStream,
    Future<void> cancelFuture,
  ) async {
    Cassette data = await _matchRequest(options.uri, file, orElse: () async {
      await makeNormalRequest(file, options, requestStream, cancelFuture);
      return _matchRequest(options.uri, file);
    });

    RecordedResponse response = data.response;
    final responsePayload = json.encode(response.body);

    return ResponseBody.fromString(
      responsePayload,
      response.statusCode,
      headers: dioHttpHeadersForResponseBody,
    );
  }

  void _storeRequest(File file, RequestOptions requestOptions, dynamic data,
      ResponseBody responseBody) {
    List<Cassette> mock = [_buildCassette(data, responseBody, requestOptions)];

    if (!file.existsSync()) {
      file.createSync(recursive: true);
    } else {
      List<Cassette> requests = _readFile(file);
      requests.addAll(mock);
      mock = requests;
    }

    file.writeAsStringSync(json.encode(mock));
  }

  List<Cassette> _readFile(File file) {
    String jsonString = file.readAsStringSync();
    return (json.decode(jsonString) as List<Map<String, dynamic>>)
        .map(Cassette.fromJson)
        .toList();
  }

  Cassette _buildCassette(dynamic data, ResponseBody responseBody,
          RequestOptions requestOptions) =>
      Cassette(
          request: RecordedRequest(
              url: requestOptions.uri,
              payload: requestOptions.data,
              headers: requestOptions.headers),
          response: RecordedResponse(
            statusCode: responseBody.statusCode,
            body: data,
            headers: responseBody.headers,
          ),
          createdAt: DateTime.now());

  Future<Cassette> _matchRequest(Uri uri, File file,
      {FutureOr<Cassette> Function()? orElse}) async {
    String host = uri.host;
    String path = uri.path;
    List<Cassette> cassettes = _readFile(file);
    try {
      return cassettes.firstWhere(
        (cassette) {
          Uri uri2 = cassette.request.url;
          return uri2.host == host && uri2.path == path;
        },
      );
    } on StateError {
      return orElse != null ? orElse() : throw Exception('Cassette not found');
    }
  }
}
