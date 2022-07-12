import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:test/test.dart';
import 'package:vcr/vcr.dart';

void main() {
  const userReposUrl = 'https://api.github.com/users/zhalkhas/repos';
  const userUrl = 'https://api.github.com/users/zhalkhas';
  late VcrAdapter adapter;
  late Dio client;

  File getFile() {
    String path = 'github/user_repos.json';
    Directory current = Directory.current;
    String finalPath =
        current.path.endsWith('/test') ? current.path : current.path + '/test';

    finalPath = "$finalPath/cassettes/$path";
    return File(finalPath);
  }

  List<dynamic> _readFile(File file) {
    String jsonString = file.readAsStringSync();
    return json.decode(jsonString) as List;
  }

  checkRequestSizeInFile(File file, int size) {
    List<dynamic> requests = _readFile(file);

    expect(requests.length, size);
  }

  setUp(() {
    adapter = VcrAdapter();
    client = Dio();
    client.httpClientAdapter = adapter;
  });

  tearDown(() {
    Directory current = Directory.current;
    String finalPath =
        current.path.endsWith('/test') ? current.path : current.path + '/test';
    var directory = Directory('$finalPath/cassettes');
    if (directory.existsSync()) directory.delete(recursive: true);
  });

  test('make request when there is no cassette', () async {
    File file = getFile();
    expect(file.existsSync(), isFalse);

    adapter.useCassette('github/user_repos');

    Response<dynamic> response = await client.get(userReposUrl);
    expect(response.statusCode, 200);

    expect(file.existsSync(), isTrue);

    checkRequestSizeInFile(file, 1);
  });

  test('must not store a new request in same file when it already exists',
      () async {
    File file = getFile();
    expect(file.existsSync(), isFalse);
    adapter.useCassette('github/user_repos');

    Response<dynamic> response = await client.get(userReposUrl);
    expect(response.statusCode, 200);
    expect(file.existsSync(), isTrue);
    checkRequestSizeInFile(file, 1);

    response = await client.get(userReposUrl);
    expect(response.statusCode, 200);
    checkRequestSizeInFile(file, 1);
  });

  test('must store a new request in same file when does not found', () async {
    File file = getFile();
    expect(file.existsSync(), isFalse);
    adapter.useCassette('github/user_repos');

    Response<dynamic> response = await client.get(userReposUrl);
    expect(response.statusCode, 200);
    expect(file.existsSync(), isTrue);
    checkRequestSizeInFile(file, 1);

    response = await client.get(userUrl);
    expect(response.statusCode, 200);
    checkRequestSizeInFile(file, 2);
  });
}
