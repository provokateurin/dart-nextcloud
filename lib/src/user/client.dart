import 'dart:convert';

import '../../nextcloud.dart';
import '../network.dart';

// ignore: public_member_api_docs
class UserClient {
  // ignore: public_member_api_docs
  UserClient(
    String baseUrl,
    this._network,
  ) : _baseUrl = '$baseUrl/ocs/v1.php/cloud/user';

  final String _baseUrl;

  final Network _network;

  /// Get the meta data of a user
  Future<UserData> getUser() async {
    final response = await _network.send(
      'GET',
      _baseUrl,
      [200],
    );
    return UserData.fromJson(
      json.decode(response.body) as Map<String, dynamic>,
    );
  }
}
