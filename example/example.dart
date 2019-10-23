import 'dart:convert';

import 'package:nextcloud/nextcloud.dart';
import 'package:nextcloud/src/shares/share.dart';

Future main() async {
  final client = NextCloudClient('cloud.example.com', 'myuser', 'mypassword');
  await client.webDav.upload(utf8.encode('Test file'), '/test.txt');
  await listFiles(client);
  await client.webDav.move('/test.txt', '/abc.txt');
  await listFiles(client);
  await client.webDav.copy('/abc.txt', '/test.txt');
  await listFiles(client);

  final userData = await client.metaData.getMetaData();
  print(userData.fullName);
  print(userData.groups);
  
  // Sharing example
  print('Share file:');
  final share = await client.shares.shareWithUser(
    '/test.txt', 
    'USER',
    permissions: Permissions([Permission.read, Permission.update]));
  print(share);
  print('List shared files');
  final shares = await client.shares.getShares(path: '/test.txt', reshares: false);
  print(shares.join('\n'));
  await client.shares.updateShareNote(share.id, 'Test Notiz');
  print('New note:');
  await client.shares.getShare(share.id);
  print('Delete share');
  await client.shares.deleteShare(share.id);
  
}

Future listFiles(NextCloudClient client) async {
  final files = await client.webDav.ls('/');
  for (final file in files) {
    print(file.path);
  }
}
