import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:nextcloud/src/http_client/http_client.dart';

/// Http client with the correct authentication and header
class NextCloudHttpClient extends http.BaseClient {
  /// Creates a client wrapping [inner] that uses Basic HTTP auth.
  ///
  /// Constructs a new [NextCloudHttpClient] which will use the provided [username]
  /// and [password] for all subsequent requests.
  NextCloudHttpClient(this.username, this.password, {inner})
      : _authString =
            'Basic ${base64.encode(utf8.encode('$username:$password')).trim()}',
        _inner = inner ?? HttpClient();

  /// The username to be used for all requests
  final String username;

  /// The password to be used for all requests
  final String password;

  final http.Client _inner;
  final String _authString;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    request.headers['Authorization'] = _authString;
    request.headers['OCS-APIRequest'] = 'true';

    return _inner.send(request);
  }
}

/// RequestException class
class RequestException implements Exception {
  // ignore: public_member_api_docs
  RequestException(this.cause);

  // ignore: public_member_api_docs
  String cause;
}

/// Organizes the requests
class Network {
  /// Create a network with the given client and base url
  Network(this.client);

  /// The http client
  final http.Client client;

  /// send the request with given [method] and [url]
  Future<http.Response> send(
    String method,
    String url,
    List<int> expectedCodes, {
    Uint8List data,
    Map<String, String> headers,
  }) async {
    final response = await client.send(http.Request(method, Uri.parse(url))
      ..followRedirects = false
      ..persistentConnection = true
      ..body = data != null ? utf8.decode(data) : ''
      ..headers.addAll(headers ?? {}));
    if (!expectedCodes.contains(response.statusCode)) {
      final r = await http.Response.fromStream(response);
      print(r.statusCode);
      print(r.body);
      throw RequestException(
          'operation failed method:$method exceptionCodes:$expectedCodes statusCode:${response.statusCode}');
    }
    return http.Response.fromStream(response);
  }
}
