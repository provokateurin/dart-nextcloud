import '../../nextcloud.dart';
import '../network.dart';

/// SharesClient class
class SharesClient {
  // ignore: public_member_api_docs
  SharesClient(
    String baseUrl,
    this._network,
  ) : _baseUrl = '$baseUrl/ocs/v2.php/apps/files_sharing/api/v1/';

  final String _baseUrl;

  final Network _network;

  /// get url from given [path]
  String _getUrl(String path) {
    path = path.trim();

    if (path.startsWith('/')) {
      // Since the base url ends with '/' by default trim of one char at the
      // beginning of the path
      return _baseUrl +
          path.substring(
            1,
            path.length,
          );
    }

    // If the path does not start with '/' append it after the baseUrl
    return [
      _baseUrl,
      path,
    ].join('');
  }

  /// Get a list of shares.
  ///
  /// By default it is a list of all shares of the current user
  Future<List<Share>> getShares({
    String path,
    bool reshares = false,
    bool subfiles = false,
  }) async {
    var url = _getUrl('/shares?reshares=$reshares&subfiles=$subfiles');
    if (path != null) {
      url += '&path=$path';
    }
    final response = await _network.send(
      'GET',
      url,
      [200],
    );
    return sharesFromSharesXml(response.body);
  }

  /// Get a share by [id]
  Future<Share> getShare(int id) async {
    final url = _getUrl('/shares/$id');
    final response = await _network.send(
      'GET',
      url,
      [200],
    );
    return sharesFromSharesXml(response.body).single;
  }

  /// Get a share by [id]
  Future deleteShare(int id) async {
    final url = _getUrl('/shares/$id');
    await _network.send(
      'DELETE',
      url,
      [200],
    );
  }

  /// Updates the permissions of a share
  Future<Share> updateSharePermissions(
    int id,
    Permissions permissions,
  ) async {
    final url = _getUrl('/shares/$id?permissions=${permissions.toInt()}');
    final response = await _network.send(
      'PUT',
      url,
      [200],
    );
    return shareFromRequestResponseXml(response.body);
  }

  /// Updates the password of a share
  Future<Share> updateSharePassword(
    int id,
    String password,
  ) async {
    final url = _getUrl('/shares/$id?password=$password');
    final response = await _network.send(
      'PUT',
      url,
      [200],
    );
    return shareFromRequestResponseXml(response.body);
  }

  /// Updates the public upload option of a share
  Future<Share> updateSharePublicUpload(
    int id,
    bool publicUpload,
  ) async {
    final url = _getUrl('/shares/$id?publicUpload=$publicUpload');
    final response = await _network.send(
      'PUT',
      url,
      [200],
    );
    return shareFromRequestResponseXml(response.body);
  }

  /// Updates the expire date of a share
  Future<Share> updateShareExpireDate(
    int id,
    DateTime expireDate,
  ) async {
    final url = _getUrl(
        '/shares/$id?expireDate=${expireDate.year}-${expireDate.month}-${expireDate.day}');
    final response = await _network.send(
      'PUT',
      url,
      [200],
    );
    return shareFromRequestResponseXml(response.body);
  }

  /// Updates the note of a share
  Future<Share> updateShareNote(
    int id,
    String note,
  ) async {
    final url = _getUrl('/shares/$id?note=$note');
    final response = await _network.send(
      'PUT',
      url,
      [200],
    );
    return shareFromRequestResponseXml(response.body);
  }

  /// share a folder of file
  ///
  /// The [path] can be a directory of a file
  ///
  /// To set the [shareType] use the [ShareTypes] class
  ///
  /// If [shareType] is [ShareTypes.user] or [ShareTypes.group] the [shareWith] attribute is required
  ///
  /// [shareWith] must be a username or group id
  ///
  /// To set the [permissions] user the [Permissions] class
  ///
  /// The [password] is optional to protect a public link Share
  ///
  /// It returns the share id of the created share
  Future<Share> _createShare(
    String path,
    int shareType, {
    String shareWith,
    bool publicUpload = false,
    String password,
    Permissions permissions,
  }) async {
    // For sharing with user or group the user or group must be defined
    if ((shareType == ShareTypes.user || shareType == ShareTypes.group) &&
        shareWith == null) {
      throw RequestException(
        "When the share type is 'user' or 'group' then the share with attribute must not be null",
        -1,
      );
    }
    // For public shares the default permission is one
    if (shareType == ShareTypes.publicLink && permissions == null) {
      permissions = Permissions([Permission.read]);
    }
    permissions ??= Permissions([Permission.all]);
    var url = _getUrl(
        '/shares?path=$path&shareType=$shareType&publicUpload=$publicUpload&permissions=${permissions.toInt()}');
    if (shareType == ShareTypes.user || shareType == ShareTypes.group) {
      url += '&shareWith=$shareWith';
    } else if (shareType == ShareTypes.publicLink && password != null) {
      url += '&password=$password';
    }
    final response = await _network.send(
      'POST',
      url,
      [200],
    );
    return shareFromRequestResponseXml(response.body);
  }

  /// Shares a [path] (dir/file) with a [user]
  Future<Share> shareWithUser(
    String path,
    String user, {
    Permissions permissions,
    bool publicUpload,
  }) =>
      _createShare(
        path,
        ShareTypes.user,
        shareWith: user,
        permissions: permissions,
        publicUpload: publicUpload,
      );

  /// Shares a [path] (dir/file) with a [group]
  Future<Share> shareWithGroup(
    String path,
    String group, {
    Permissions permissions,
    bool publicUpload,
  }) =>
      _createShare(
        path,
        ShareTypes.group,
        shareWith: group,
        permissions: permissions,
        publicUpload: publicUpload,
      );

  /// Shares a [path] (dir/file) with a url.
  /// This url can be found in the returned [Share.url]
  Future<Share> shareWithPublicLink(
    String path, {
    Permissions permissions,
    String password,
    bool publicUpload,
  }) =>
      _createShare(
        path,
        ShareTypes.publicLink,
        password: password,
        permissions: permissions,
        publicUpload: publicUpload,
      );
}
