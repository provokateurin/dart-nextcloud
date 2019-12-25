import 'package:nextcloud/nextcloud.dart';
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
    _network = Network(username, password);
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
    return shareesFromShareesXml(response.toString());
  }

  /// Get a list of group sharees
  Future<List<Sharee>> getGroupSharees(
    String search,
    int perPage,
    String itemType, {
    bool lookup = false,
  }) async =>
      (await getSharees(search, perPage, itemType))
          .where((sharee) => sharee.shareType == ShareTypes.group)
          .toList();

  /// Get a list of user sharees
  Future<List<Sharee>> getUserSharees(
    String search,
    int perPage,
    String itemType, {
    bool lookup = false,
  }) async =>
      (await getSharees(search, perPage, itemType))
          .where((sharee) => sharee.shareType == ShareTypes.user)
          .toList();
}
