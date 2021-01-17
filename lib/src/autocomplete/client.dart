import 'dart:convert';

import '../../nextcloud.dart';
import '../network.dart';

// ignore: public_member_api_docs
class AutocompleteClient {
  // ignore: public_member_api_docs
  AutocompleteClient(
    String baseUrl,
    this._network,
  ) : _baseUrl = '$baseUrl/ocs/v2.php/core/autocomplete/get';

  final String _baseUrl;

  final Network _network;

  /// Search a user
  Future<List<User>> searchUser(
    String query, {
    int limit = 10,
  }) async {
    final url = '$_baseUrl?search=$query&itemType=users&itemId= &limit=$limit';
    final response = await _network.send(
      'GET',
      url,
      [200],
    );
    return (json.decode(response.body)['ocs']['data'] as List)
        .map((user) => User.fromJson(user as Map<String, dynamic>))
        .toList();
  }
}
