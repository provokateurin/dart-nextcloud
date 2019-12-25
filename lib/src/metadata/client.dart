import 'package:nextcloud/src/metadata/metadata.dart';
import 'package:nextcloud/src/network.dart';

/// MetaDataClient class
class MetaDataClient {
  // ignore: public_member_api_docs
  MetaDataClient(
    String host,
    String username,
    String password, {
    int port,
  }) {
    if (port == null) {
      _baseUrl = 'https://$host';
    } else {
      _baseUrl = 'https://$host:$port';
    }
    _baseUrl = '$_baseUrl/ocs/v1.php/cloud/users/$username';
    _network = Network(username, password);
  }

  String _baseUrl;

  Network _network;

  /// Get the meta data of the user
  Future<MetaData> getMetaData() async {
    final response = await _network.send('GET', _baseUrl, [200]);
    return metaDataFromMetaDataXml(response.toString());
  }
}
