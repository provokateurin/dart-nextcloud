import 'dart:convert';

import '../../nextcloud.dart';
import '../network.dart';

/// All the talk functions for guest management
class SignalingManagement {
  // ignore: public_member_api_docs
  SignalingManagement(Network network, String url) {
    _network = network;
    _baseUrl = url;
  }

  String _baseUrl;
  Network _network;

  String _getUrl(String path) => '$_baseUrl/$path';

  /// Returns the signaling server settings
  Future<SignalingSettings> getSettings() async {
    final result = await _network.send(
      'GET',
      _getUrl('signaling/settings'),
      [200],
    );
    return SignalingSettings.fromJson(
        json.decode(result.body)['ocs']['data'] as Map<String, dynamic>);
  }
}
