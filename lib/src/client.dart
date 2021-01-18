import '../nextcloud.dart';
import 'network.dart';

/// NextCloudClient class
class NextCloudClient {
  // ignore: public_member_api_docs
  NextCloudClient(
    Uri host,
    NextCloudHttpClient httpClient,
  ) {
    // Default to HTTPS scheme
    if (host.scheme.isEmpty) {
      host = Uri.https(host.authority, Uri.decodeComponent(host.path));
    }

    baseUrl = host.toString();

    // Normalize URI
    if (baseUrl.endsWith('/')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 1);
    }

    final network = Network(
      httpClient,
    );

    _webDavClient = WebDavClient(baseUrl, network);
    _userClient = UserClient(baseUrl, network);
    _usersClient = UsersClient(baseUrl, network);
    _sharesClient = SharesClient(baseUrl, network);
    _shareesClient = ShareesClient(baseUrl, network);
    _talkClient = TalkClient(baseUrl, network);
    _avatarClient = AvatarClient(baseUrl, network);
    _autocompleteClient = AutocompleteClient(baseUrl, network);
    _previewClient = PreviewClient(baseUrl, network);
    _login = LoginClient(baseUrl, network);
  }

  /// Constructs a new [NextCloudClient] which will use the provided [username]
  /// and [password] for all subsequent requests.
  factory NextCloudClient.withCredentials(
    Uri host,
    String username,
    String password, {
    String language,
    Map<String, String> defaultHeaders,
  }) =>
      NextCloudClient(
        host,
        NextCloudHttpClient.withCredentials(
          username,
          password,
          language,
          defaultHeaders: defaultHeaders,
        ),
      );

  /// Constructs a new [NextCloudClient] which will use the provided
  /// [appPassword] for all subsequent requests.
  factory NextCloudClient.withAppPassword(
    Uri host,
    String appPassword, {
    String language,
    Map<String, String> defaultHeaders,
  }) =>
      NextCloudClient(
        host,
        NextCloudHttpClient.withAppPassword(
          appPassword,
          language,
          defaultHeaders: defaultHeaders,
        ),
      );

  /// Constructs a new [NextCloudClient] without login data.
  /// May only be useful for app password login setup
  factory NextCloudClient.withoutLogin(
    Uri host, {
    String language,
    Map<String, String> defaultHeaders,
  }) =>
      NextCloudClient(
        host,
        NextCloudHttpClient.withoutLogin(
          language,
          defaultHeaders: defaultHeaders,
        ),
      );

  /// The host of the cloud
  ///
  /// For example: `cloud.example.com`
  String baseUrl;

  WebDavClient _webDavClient;
  UserClient _userClient;
  UsersClient _usersClient;
  SharesClient _sharesClient;
  ShareesClient _shareesClient;
  TalkClient _talkClient;
  AvatarClient _avatarClient;
  AutocompleteClient _autocompleteClient;
  PreviewClient _previewClient;
  LoginClient _login;

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

  // ignore: public_member_api_docs
  LoginClient get login => _login;
}
