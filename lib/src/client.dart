import 'package:nextcloud/src/preview/client.dart';

import '../nextcloud.dart';

/// NextCloudClient class
class NextCloudClient {
  // ignore: public_member_api_docs
  NextCloudClient(
    String host,
    this.username,
    this.password, {
    this.port,
  }) {
    final prefix = host.startsWith('http://') ? 'http' : 'https';
    final main =
        host.replaceAll(RegExp(r'https?:\/\/|\/index.php(.+)?|:.+'), '');
    final end = port != null ? ':$port' : '';
    baseUrl = '$prefix://$main$end';

    _webDavClient = WebDavClient(
      baseUrl,
      username,
      password,
    );
    _usersClient = UsersClient(
      baseUrl,
      username,
      password,
    );
    _sharesClient = SharesClient(
      baseUrl,
      username,
      password,
    );
    _shareesClient = ShareesClient(
      baseUrl,
      username,
      password,
    );
    _talkClient = TalkClient(
      baseUrl,
      username,
      password,
    );
    _avatarClient = AvatarClient(
      baseUrl,
      username,
      password,
    );
    _autocompleteClient = AutocompleteClient(
      baseUrl,
      username,
      password,
    );
    _previewClient = PreviewClient(
      baseUrl,
      username,
      password,
    );
  }

  /// The host of the cloud
  ///
  /// For example: `cloud.example.com`
  String baseUrl;

  // ignore: public_member_api_docs
  final int port;

  // ignore: public_member_api_docs
  final String username;

  // ignore: public_member_api_docs
  final String password;

  WebDavClient _webDavClient;
  UsersClient _usersClient;
  SharesClient _sharesClient;
  ShareesClient _shareesClient;
  TalkClient _talkClient;
  AvatarClient _avatarClient;
  AutocompleteClient _autocompleteClient;
  PreviewClient _previewClient;

  // ignore: public_member_api_docs
  WebDavClient get webDav => _webDavClient;

  // ignore: public_member_api_docs
  UsersClient get users => _usersClient;

  // ignore: public_member_api_docs
  SharesClient get shares => _sharesClient;

  // ignore: public_member_api_docs
  ShareesClient get sharees => _shareesClient;

  // ignore: public_member_api_docs
  TalkClient get talk => _talkClient;

  // ignore: public_member_api_docs
  AvatarClient get avatar => _avatarClient;

  // ignore: public_member_api_docs
  AutocompleteClient get autocomplete => _autocompleteClient;

  // ignore: public_member_api_docs
  PreviewClient get preview => _previewClient;
}
