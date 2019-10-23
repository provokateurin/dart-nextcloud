import 'package:nextcloud/src/network.dart';
import 'package:nextcloud/src/sharees/sharee.dart';

/// ShareesClient class
class ShareesClient {
  // ignore: public_member_api_docs
  ShareesClient(
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
    _baseUrl = '$_baseUrl/ocs/v1.php/apps/files_sharing/api/v1/sharees';
    final _httpClient = NextCloudHttpClient(username, password);
    _network = Network(_httpClient);
  }

  String _baseUrl;

  Network _network;

  /// Get a list of sharees
  Future<List<Sharee>> getSharees(
    String search,
    int perPage,
    String itemType, {
    bool lookup = false,
  }) async {
    var url = '$_baseUrl?search=$search&perPage=$perPage&lookup=$lookup';
    if (itemType != null) {
      url += '&itemType=$itemType';
    }
    final response = await _network.send('GET', url, [200]);
    return shareesFromShareesXml(response.body);
  }
}
