import 'dart:convert';

import '../../nextcloud.dart';
import '../network.dart';

// ignore: public_member_api_docs
class AutocompleteClient {
  // ignore: public_member_api_docs
  AutocompleteClient(
    String baseUrl,
    String username,
    String password,
  ) {
    _baseUrl = '$baseUrl/ocs/v2.php/core/autocomplete/get';
    final client = NextCloudHttpClient(username, password, useJson: true);
    _network = Network(client);
  }

  String _baseUrl;

  Network _network;

  /// Search a user
  Future<List<User>> searchUser(
    String query, {
    int limit = 10,
  }) async {
    final url = '$_baseUrl?search=$query&itemType=users&itemId= &limit=$limit';
    final response = await _network.send('GET', url, [200]);
    return json
        .decode(response.body)['ocs']['data']
        .map((user) => User.fromJson(user))
        .toList()
        .cast<User>()
        .toList();
  }
}
