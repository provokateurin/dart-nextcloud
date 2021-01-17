import 'dart:convert';
import 'dart:io';

import 'package:nextcloud/nextcloud.dart';

Future main() async {
  try {
    final client = NextCloudClient.withCredentials(
      Uri(host: 'cloud.example.com'),
      'myuser',
      'mypassword',
    );
    await client.webDav
        .upload(File('example/test.png').readAsBytesSync(), '/test.png');
    File('example/bla.png')
        .writeAsBytesSync(await client.webDav.download('/test.png'));
    await client.webDav.upload(utf8.encode('Test file'), '/test.txt');
    await listFiles(client);
    await client.webDav.move('/test.txt', '/abc.txt');
    await listFiles(client);
    await client.webDav.copy('/abc.txt', '/test.txt');
    await listFiles(client);

    final userData = await client.users.getMetaData('otheruser');
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

    print('Download /test.txt ...');
    final downloadedData = await client.webDav.downloadStream('/test.txt');

    final file = File('example/test.txt');
    if (file.existsSync()) {
      file.deleteSync();
    }
    final inputStream = file.openWrite();
    await inputStream.addStream(downloadedData);
    await inputStream.close();

    print('... done!');

    await client.webDav.delete('/test.txt');
    await client.webDav.delete('/abc.txt');

    print('List all sharees:');
    print(await client.sharees.getSharees('', 1000, 'file'));
  } on RequestException catch (e, stacktrace) {
    print(e.statusCode);
    print(e.body);
    print(stacktrace);
  }
}

Future listFiles(NextCloudClient client) async {
  final files = await client.webDav.ls('/');
  for (final file in files) {
    print(file.path);
  }
}
