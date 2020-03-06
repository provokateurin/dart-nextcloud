import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

/// RequestException class
class RequestException implements Exception {
  // ignore: public_member_api_docs
  RequestException(this.cause, this.response);

  // ignore: public_member_api_docs
  String cause;

  // ignore: public_member_api_docs
  String response;
}

/// Organizes the requests
class Network {
  /// Create a network with the given username and password
  Network(String username, String password)
      : _client = Dio()
          ..options = BaseOptions(
            headers: {
              'authorization':
                  'Basic ${base64.encode(utf8.encode('$username:$password'))}',
              'OCS-APIRequest': 'true',
              'Content-Type': 'application/xml',
            },
            responseType: ResponseType.plain,
            followRedirects: false,
          );

  final Dio _client;

  /// send the request with given [method] and [url]
  Future<Response> send(
    String method,
    String url,
    List<int> expectedCodes, {
    Uint8List data,
    Map<String, String> headers,
  }) async {
    try {
      final response = await _client.request(
        url,
        data: data ?? Uint8List(0),
        options: Options(
          headers: headers ?? {},
          method: method,
        ),
      );

      if (!expectedCodes.contains(response.statusCode)) {
        throw RequestException(
            'operation failed method: $method statusCode: ${response.statusCode}',
            response.toString());
      }
      return response;
    } on DioError catch (e) {
      throw RequestException(
          'operation failed method: $method statusCode: ${e.response.statusCode}',
          e.response.toString());
    }
  }

  /// send the request with given [method] and [url]
  Future<Response<ResponseBody>> download(
    String method,
    String url,
    List<int> expectedCodes, {
    Uint8List data,
    Map<String, String> headers,
  }) async {
    try {
      final response = await _client.request<ResponseBody>(
        url,
        data: data ?? Uint8List(0),
        options: Options(
          headers: headers ?? {},
          method: method,
          responseType: ResponseType.stream
        ),
      );

      if (!expectedCodes.contains(response.statusCode)) {
        throw RequestException(
            'operation failed method: $method statusCode: ${response.statusCode}',
            response.toString());
      }
      return response;
    } on DioError catch (e) {
      throw RequestException(
          'operation failed method: $method statusCode: ${e.response.statusCode}',
          e.response.toString());
    }
  }
}
