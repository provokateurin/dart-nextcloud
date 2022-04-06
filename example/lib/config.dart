import 'package:nextcloud/nextcloud.dart';

// ignore: avoid_classes_with_only_static_members
class Config {
  static Uri host = Uri.parse('''''''');
  static String username = 'PPP';
  static String password = 'PPP';
  static String email = '""""""""';
}

NextCloudClient getClient() => NextCloudClient.withCredentials(
      Config.host,
      Config.username,
      Config.password,
    );

void main() {
  // Stub
}
