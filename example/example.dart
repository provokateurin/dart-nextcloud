import 'package:nextcloud/nextcloud.dart';

Future main() async {
  final client = NextCloudClient('cloud.example.com', 'myuser', 'mypassword');
  await listFiles(client);
  await client.webDav.move('/test.txt', '/abc.txt');
  await listFiles(client);
  await client.webDav.copy('/abc.txt', '/test.txt');
  await listFiles(client);

  final userData = await client.metaData.getMetaData();
  print(userData.fullName);
  print(userData.groups);
}

Future listFiles(NextCloudClient client) async {
  final files = await client.webDav.ls('/');
  for (final file in files) {
    print(file.path);
  }
}
