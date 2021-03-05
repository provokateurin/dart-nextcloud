import 'dart:convert';

import '../../nextcloud.dart';
import '../network.dart';

// ignore: public_member_api_docs
class UsersClient {
  // ignore: public_member_api_docs
  UsersClient(
    String baseUrl,
    this._network,
  ) : _baseUrl = '$baseUrl/ocs/v1.php/cloud/users';

  final String _baseUrl;

  final Network _network;

  /// Get the meta data of a user
  Future<MetaData> getMetaData(String username) async {
    final url = '$_baseUrl/$username';
    final response = await _network.send('GET', url, [200]);
    return MetaData.fromJson(
      json.decode(response.body) as Map<String, dynamic>,
    );
  }
}
