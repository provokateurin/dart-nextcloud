import 'dart:convert';

import '../../nextcloud.dart';
import '../network.dart';

// ignore: public_member_api_docs
class UsersClient {
  // ignore: public_member_api_docs
  UsersClient(
    String baseUrl,
    String username,
    String password,
  ) {
    _baseUrl = '$baseUrl/ocs/v1.php/cloud/users';
    final client = NextCloudHttpClient(username, password, useJson: true);
    _network = Network(client);
  }

  String _baseUrl;

  Network _network;

  /// Get the meta data of a user
  Future<MetaData> getMetaData(String username) async {
    final url = '$_baseUrl/$username';
    final response = await _network.send('GET', url, [200]);
    return MetaData.fromJson(json.decode(response.body));
  }
}
