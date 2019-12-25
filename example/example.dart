import 'dart:convert';

import 'package:nextcloud/nextcloud.dart';
import 'package:nextcloud/src/shares/share.dart';

Future main() async {
  try {
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
    final share = await client.shares.shareWithUser('/test.txt', 'USER',
        permissions: Permissions([Permission.read, Permission.update]));
    print(share);
    print('List shared files');
    print((await client.shares.getShares(path: '/test.txt', reshares: false))
        .join('\n'));
    await client.shares.updateShareNote(share.id, 'Test notice');
    print('New note:');
    print(await client.shares.getShare(share.id));
    print('Delete share');
    await client.shares.deleteShare(share.id);
    print(
        'List shared files: ${(await client.shares.getShares(path: '/test.txt', reshares: false)).length}');

    await client.webDav.delete('/test.txt');
    await client.webDav.delete('/abc.txt');

    print('List all sharees:');
    print(await client.sharees.getSharees('', 1000, 'file'));
  } on RequestException catch (e, stacktrace) {
    print(e.cause);
    print(e.response);
    print(stacktrace);
  }
}

Future listFiles(NextCloudClient client) async {
  final files = await client.webDav.ls('/');
  for (final file in files) {
    print(file.path);
  }
}
