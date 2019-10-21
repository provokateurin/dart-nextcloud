import 'package:nextcloud/nextcloud.dart';

Future main() async {
  final client = NextCloudClient('cloud.example.com', 'myuser', 'mypassword');
  final files = await client.webDav.ls('/');
  for (final file in files) {
    print(file.name);
    print(file.path);
    print(file.lastModified);
    print(file.size);
    print('');
  }
  final userData = await client.metaData.getMetaData();
  print(userData.fullName);
  print(userData.groups);
}
