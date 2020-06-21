import '../nextcloud.dart';
import 'network.dart';

/// NextCloudClient class
class NextCloudClient {
  // ignore: public_member_api_docs
  NextCloudClient(
    String host,
    NextCloudHttpClient httpClient, {
    this.port,
  }) {
    // Default to HTTPS scheme
    host = host.contains('://') ? host : 'https://$host';
    // Find end of base URI
    final end =
        host.contains('/index.php') ? host.indexOf('/index.php') : host.length;
    baseUrl = Uri.parse(host, 0, end).toString();
    final network = Network(
      httpClient,
    );

    _webDavClient = WebDavClient(baseUrl, network);
    _usersClient = UsersClient(baseUrl, network);
    _sharesClient = SharesClient(baseUrl, network);
    _shareesClient = ShareesClient(baseUrl, network);
    _talkClient = TalkClient(baseUrl, network);
    _avatarClient = AvatarClient(baseUrl, network);
    _autocompleteClient = AutocompleteClient(baseUrl, network);
    _notificationsClient = NotificationsClient(baseUrl, network);
    _loginClient = LoginClient(baseUrl, network);
    _previewClient = PreviewClient(baseUrl, network);
  }

  /// Constructs a new [NextCloudClient] which will use the provided [username]
  /// and [password] for all subsequent requests.
  factory NextCloudClient.withCredentials(
    String host,
    String username,
    String password, {
    int port,
    AppType appType,
    String language,
  }) =>
      NextCloudClient(
        host,
        NextCloudHttpClient.withCredentials(
          username,
          password,
          appType,
          language,
        ),
        port: port,
      );

  /// Constructs a new [NextCloudClient] which will use the provided
  /// [appPassword] for all subsequent requests.
  factory NextCloudClient.withAppPassword(
    String host,
    String appPassword, {
    int port,
    AppType appType,
    String language,
  }) =>
      NextCloudClient(
        host,
        NextCloudHttpClient.withAppPassword(
          appPassword,
          appType,
          language,
        ),
        port: port,
      );

  /// Constructs a new [NextCloudClient] without login data.
  /// May only be useful for app password login setup
  factory NextCloudClient.withoutLogin(
    String host, {
    int port,
    AppType appType,
    String language,
  }) =>
      NextCloudClient(
        host,
        NextCloudHttpClient.withoutLogin(
          appType,
          language,
        ),
        port: port,
      );

  /// The host of the cloud
  ///
  /// For example: `cloud.example.com`
  String baseUrl;

  // ignore: public_member_api_docs
  final int port;

  WebDavClient _webDavClient;
  UsersClient _usersClient;
  SharesClient _sharesClient;
  ShareesClient _shareesClient;
  TalkClient _talkClient;
  AvatarClient _avatarClient;
  AutocompleteClient _autocompleteClient;
  PreviewClient _previewClient;
  NotificationsClient _notificationsClient;
  LoginClient _loginClient;

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

  // ignore: public_member_api_docs
  NotificationsClient get notifications => _notificationsClient;

  // ignore: public_member_api_docs
  LoginClient get login => _loginClient;
}
