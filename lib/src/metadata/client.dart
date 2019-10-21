import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http_auth/http_auth.dart' as http_auth;
import 'package:nextcloud/src/metadata/metadata.dart';
import 'package:retry/retry.dart';

/// MetaDataException class
class MetaDataException implements Exception {
  // ignore: public_member_api_docs
  MetaDataException(this.cause);

  // ignore: public_member_api_docs
  String cause;
}

/// MetaDataClient class
class MetaDataClient {
  // ignore: public_member_api_docs
  MetaDataClient(
    String host,
    String username,
    String password, {
    int port,
  }) {
    if (port == null) {
      _baseUrl = 'https://$host';
    } else {
      _baseUrl = 'https://$host:$port';
    }
    _baseUrl = '$_baseUrl/ocs/v1.php/cloud/users/$username';
    _httpClient = _NextCloudHttpClient(username, password);
  }

  String _baseUrl;

  http.Client _httpClient;

  /// send the request with given [method] and [path]
  ///
  Future<http.Response> _send(
          String method, String path, List<int> expectedCodes,
          {Uint8List data}) =>
      retry(
        () => __send(
          method,
          path,
          expectedCodes,
          data: data,
        ),
        retryIf: (e) => e is MetaDataException,
        maxAttempts: 5,
      );

  /// send the request with given [method] and [path]
  Future<http.Response> __send(
    String method,
    String path,
    List<int> expectedCodes, {
    Uint8List data,
  }) async {
    final response =
        await _httpClient.send(http.Request(method, Uri.parse(_baseUrl))
          ..followRedirects = false
          ..persistentConnection = true
          ..body = data != null ? utf8.decode(data) : '');
    if (!expectedCodes.contains(response.statusCode)) {
      throw MetaDataException('operation failed method:$method '
          'path:$path exceptionCodes:$expectedCodes '
          'statusCode:${response.statusCode}');
    }
    return http.Response.fromStream(response);
  }

  /// Get the meta data of the user
  Future<MetaData> getMetaData() async {
    final response = await _send('GET', '/', [200]);
    return metaDataFromMetaDataXml(response.body);
  }
}

class _NextCloudHttpClient extends http.BaseClient {
  _NextCloudHttpClient(String username, String password, {inner})
      : _inner = inner ?? http_auth.BasicAuthClient(username, password),
        super();

  final http_auth.BasicAuthClient _inner;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    request.headers['OCS-APIRequest'] = 'true';
    return _inner.send(request);
  }
}
