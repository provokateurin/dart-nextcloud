import 'dart:convert';
import 'dart:typed_data';

import 'package:http_auth/http_auth.dart' as http_auth;
import 'package:http/http.dart' as http;
import 'package:retry/retry.dart';

/// Http client with the correct authentication and header
class NextCloudHttpClient extends http.BaseClient {
  NextCloudHttpClient(String username, String password, {inner})
      : _inner = inner ?? http_auth.BasicAuthClient(username, password),
        super();

  final http_auth.BasicAuthClient _inner;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    request.headers['OCS-APIRequest'] = 'true';
    return _inner.send(request);
  }
}

/// WebDavException class
class RequestException implements Exception {
  // ignore: public_member_api_docs
  RequestException(this.cause);

  // ignore: public_member_api_docs
  String cause;
}

/// Organizes the requests 
class Network {

  /// Create a network with the given client and base url
  Network(this.client, this.baseUrl);

  /// The http client
  final http.Client client;

  /// The base url for all requests
  final String baseUrl;

  /// send the request with given [method] and [path]
  Future<http.Response> send(
          String method, String path, List<int> expectedCodes,
          {Uint8List data}) =>
      retry(
        () => _send(
          method,
          path,
          expectedCodes,
          data: data,
        ),
        retryIf: (e) => e is RequestException,
        maxAttempts: 5,
      );

  /// send the request with given [method] and [path]
  Future<http.Response> _send(
    String method,
    String path,
    List<int> expectedCodes, {
    Uint8List data,
  }) async {
    final response =
        await client.send(http.Request(method, Uri.parse(baseUrl))
          ..followRedirects = false
          ..persistentConnection = true
          ..body = data != null ? utf8.decode(data) : '');
    if (!expectedCodes.contains(response.statusCode)) {
      throw RequestException('operation failed method:$method '
          'path:$path exceptionCodes:$expectedCodes '
          'statusCode:${response.statusCode}');
    }
    return http.Response.fromStream(response);
  }
}