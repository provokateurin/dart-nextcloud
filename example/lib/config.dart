import 'package:nextcloud/nextcloud.dart';

// ignore: avoid_classes_with_only_static_members
class Config {
  static Uri host = Uri.parse('https:files.prayercircle.co.uk');
  static String username = 'admin';
  static String password = 'sipmaf-fyzfAw-3morfi';
  static String email = 'admin@prayercircle.co.uk';
}

NextCloudClient getClient() => NextCloudClient.withCredentials(
      Config.host,
      Config.username,
      Config.password,
    );

void main() {
  // Stub
}
