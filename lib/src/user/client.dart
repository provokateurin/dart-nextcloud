import 'dart:convert';

import '../../nextcloud.dart';
import '../network.dart';

// ignore: public_member_api_docs
class UserClient {
  // ignore: public_member_api_docs
  UserClient(
    String baseUrl,
    String username,
    String password,
  ) {
    _baseUrl = '$baseUrl/ocs/v1.php/cloud/user';
    final client = NextCloudHttpClient(username, password, useJson: true);
    _network = Network(client);
  }

  String _baseUrl;

  Network _network;

  /// Get the meta data of a user
  Future<UserData> getUser() async {
    final response = await _network.send('GET', _baseUrl, [200]);
    return UserData.fromJson(json.decode(response.body));
  }
}
