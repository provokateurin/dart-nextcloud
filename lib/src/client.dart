import 'package:nextcloud/src/preview/client.dart';

import '../nextcloud.dart';

/// NextCloudClient class
class NextCloudClient {
  // ignore: public_member_api_docs
  NextCloudClient(
    String host,
    this.username,
    this.password,
  ) {
    // Default to HTTPS scheme
    host = host.contains('://') ? host : 'https://$host';
    // Find end of base URI
    final end =
        host.contains('/index.php') ? host.indexOf('/index.php') : host.length;
    baseUrl = Uri.parse(host, 0, end).toString();

    _webDavClient = WebDavClient(
      baseUrl,
      username,
      password,
    );
    _userClient = UserClient(
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
  final String username;

  // ignore: public_member_api_docs
  final String password;

  WebDavClient _webDavClient;
  UserClient _userClient;
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
  UserClient get user => _userClient;

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
