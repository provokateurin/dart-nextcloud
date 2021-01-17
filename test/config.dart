import 'package:nextcloud/nextcloud.dart';

// ignore: avoid_classes_with_only_static_members
class Config {
  static Uri host = Uri.parse('http://localhost:8080');
  static String username = 'admin';
  static String password = 'password';
  static String shareUser = 'test';
  static String testDir = '/files/admin/dart-nextcloud-tests';
  static String email = 'admin@example.com';
  static String storageLocation = '/usr/src/nextcloud/data/admin';
}

NextCloudClient getClient() => NextCloudClient.withCredentials(
      Config.host,
      Config.username,
      Config.password,
    );

void main() {
  // Stub
}
