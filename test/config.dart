import 'package:nextcloud/nextcloud.dart';

// ignore: avoid_classes_with_only_static_members
class Config {
  static Uri host = Uri.parse('http://localhost:8080');
  static String username = 'admin';
  static String password = 'password';
  static String email = 'admin@example.com';
}

NextCloudClient getClient() => NextCloudClient.withCredentials(
      Config.host,
      Config.username,
      Config.password,
    );

void main() {
  // Stub
}
