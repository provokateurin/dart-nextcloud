import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import 'http_client/http_client.dart';

/// Http client with the correct authentication and header
class NextCloudHttpClient extends HttpClient {
  // ignore: public_member_api_docs
  NextCloudHttpClient(this._authString, this._appType, this._language)
      : _inner = HttpClient();

  /// Constructs a new [NextCloudHttpClient] which will use the provided [username]
  /// and [password] for all subsequent requests.
  factory NextCloudHttpClient.withCredentials(
    String username,
    String password,
    AppType appType,
    String language,
  ) =>
      NextCloudHttpClient(
        'Basic ${base64.encode(utf8.encode('$username:$password')).trim()}',
        appType,
        language,
      );

  /// Constructs a new [NextCloudHttpClient] which will use the provided
  /// [appPassword] for all subsequent requests.
  factory NextCloudHttpClient.withAppPassword(
    String appPassword,
    AppType appType,
    String language,
  ) =>
      NextCloudHttpClient(
        'Bearer $appPassword',
        appType,
        language,
      );

  /// Constructs a new [NextCloudHttpClient] without login data.
  /// May only be useful for app password login setup
  factory NextCloudHttpClient.withoutLogin(
    AppType appType,
    String language,
  ) =>
      NextCloudHttpClient(
        '',
        appType,
        language,
      );

  final http.Client _inner;
  final String _authString;
  final AppType _appType;
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

    if (_appType.userAgent != null) {
      request.headers['User-Agent'] = _appType.userAgent;
    }

    return _inner.send(request);
  }
}

/// Different app types to register for
enum AppType {
  /// Will only receive Talk notifications
  talk,

  /// Will receive all notifications except Talk notifications if another Talk
  /// app is already registered for the user
  nextcloud,

  /// Default. Same problem with notifications as the [nextcloud] type
  unknown,
}

const _appTypeUserAgents = [
  // Normally the version would be appended, but we can also leave it like it is
  'Mozilla/5.0 (Android) Nextcloud-Talk v1',
  'Mozilla/5.0 (Android) Nextcloud-android',
  null,
];

// ignore: public_member_api_docs
extension AppTypeUserAgent on AppType {
  // ignore: public_member_api_docs
  String get userAgent =>
      this != null ? _appTypeUserAgents[index] : _appTypeUserAgents.last;
}

/// RequestException class
class RequestException implements Exception {
  // ignore: public_member_api_docs
  RequestException(this.body, this.statusCode);

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
    final response = await _client.send(http.Request(method, Uri.parse(url))
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
