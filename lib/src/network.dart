import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import 'http_client/http_client.dart';

/// Http client with the correct authentication and header
class NextCloudHttpClient extends HttpClient {
  // ignore: public_member_api_docs
  NextCloudHttpClient(
    this._authString,
    this._language,
  ) : _inner = HttpClient();

  /// Constructs a new [NextCloudHttpClient] which will use the provided [username]
  /// and [password] for all subsequent requests.
  factory NextCloudHttpClient.withCredentials(
    String username,
    String password,
    String language,
  ) =>
      NextCloudHttpClient(
        'Basic ${base64.encode(utf8.encode('$username:$password')).trim()}',
        language,
      );

  /// Constructs a new [NextCloudHttpClient] which will use the provided
  /// [appPassword] for all subsequent requests.
  factory NextCloudHttpClient.withAppPassword(
    String appPassword,
    String language,
  ) =>
      NextCloudHttpClient(
        'Bearer $appPassword',
        language,
      );

  /// Constructs a new [NextCloudHttpClient] without login data.
  /// May only be useful for app password login setup
  factory NextCloudHttpClient.withoutLogin(
    String language,
  ) =>
      NextCloudHttpClient(
        '',
        language,
      );

  final http.Client _inner;
  final String _authString;
  final String _language;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    request.headers['Authorization'] = _authString;
    request.headers['OCS-APIRequest'] = 'true';

    if (request.headers['Content-Type'] == null) {
      request.headers['Content-Type'] = 'application/json';
    }
    request.headers['Accept'] = 'application/json';

    if (_language != null) {
      request.headers['Accept-Language'] = _language;
    }

    return _inner.send(request);
  }
}

/// RequestException class
class RequestException implements Exception {
  // ignore: public_member_api_docs
  RequestException(
    this.body,
    this.statusCode,
  );

  // ignore: public_member_api_docs
  String body;

  // ignore: public_member_api_docs
  int statusCode;
}

/// Organizes the requests
class Network {
  /// Create a network with the given client and base url
  Network(this._client);

  /// The http client
  final http.Client _client;

  /// send the request with given [method] and [url]
  Future<http.Response> send(
    String method,
    String url,
    List<int> expectedCodes, {
    Uint8List data,
    Map<String, String> headers,
  }) async =>
      http.Response.fromStream(await download(
        method,
        url,
        expectedCodes,
        data: data,
        headers: headers,
      ));

  /// send the request with given [method] and [url]
  Future<http.StreamedResponse> download(
    String method,
    String url,
    List<int> expectedCodes, {
    Uint8List data,
    Map<String, String> headers,
  }) async {
    final response = await _client.send(http.Request(
      method,
      Uri.parse(url),
    )
      ..followRedirects = false
      ..persistentConnection = true
      ..bodyBytes = data ?? Uint8List(0)
      ..headers.addAll(headers ?? {}));

    if (!expectedCodes.contains(response.statusCode)) {
      final r = await http.Response.fromStream(response);

      throw RequestException(
        r.body,
        r.statusCode,
      );
    }
    return response;
  }
}
