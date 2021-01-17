import 'dart:convert';

import '../network.dart';

// ignore: public_member_api_docs
class AvatarClient {
  // ignore: public_member_api_docs
  AvatarClient(
    String baseUrl,
    this._network,
  ) : _baseUrl = '$baseUrl/index.php/avatar/';

  final String _baseUrl;

  final Network _network;

  /// Get the avatar of a user with a specific as a base64 encoded string
  Future<String> getAvatar(
    String name,
    int size,
  ) async {
    final url = '$_baseUrl$name/$size';
    final response = await _network.send(
      'GET',
      url,
      [
        200,
        201,
      ],
    );
    return base64.encode(response.bodyBytes);
  }
}
