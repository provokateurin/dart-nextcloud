


import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:nextcloud/nextcloud.dart';
import 'package:path_provider/path_provider.dart';

import 'config.dart';

Future mainCll() async {
  final client = getClient();
  Future<File> getImageFileFromAssets(String path) async {
  final byteData = await rootBundle.load('assets/$path');

  final file = File('${(await getTemporaryDirectory()).path}/$path');
  await file.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

  return file;
}
  try {
    final client = NextCloudClient.withCredentials(
      Uri(host: 'files.prayercircle.co.uk'),
      'admin',
      'sipmaf-fyzfAw-3morfi',
    );
    // final ff = await getImageFileFromAssets('images/1024.png');
    await client.webDav.status();
    const f = 'Documents/e/r';
    await client.webDav.mkdirs(f);
    // await client.webDav.mkdir(f);
    // await client.webDav
    //     .upload(ff.readAsBytesSync(), f);
    // File('example/bla.png')
    //     .writeAsBytesSync(await client.webDav.download('/test.png'));
    // await client.webDav
    //     .upload(Uint8List.fromList(utf8.encode('Test file')), '/test.txt');
    // await listFiles(client);
    // await client.webDav.move('/test.txt', '/abc.txt');
    // await listFiles(client);
    // await client.webDav.copy('/abc.txt', '/test.txt');
    // await listFiles(client);

    // final userData = await client.users.getMetaData('otheruser');
    // print(userData.fullName);
    // print(userData.groups);

    // // Sharing example
    // print('Share file:');
    // final share = await client.shares.shareWithUser(
    //   '/test.txt',
    //   'USER',
    //   permissions: Permissions([Permission.read, Permission.update]),
    // );
    // print(share);
    // print('List shared files');
    // print((await client.shares.getShares(path: '/test.txt')).join('\n'));
    // await client.shares.updateShareNote(share.id, 'Test notice');
    // print('New note:');
    // print(await client.shares.getShare(share.id));
    // print('Delete share');
    // await client.shares.deleteShare(share.id);
    // print(
    //   'List shared files: ${(await client.shares.getShares(path: '/test.txt')).length}',
    // );

    // print('Download /test.txt ...');
    // final downloadedData = await client.webDav.downloadStream('/test.txt');

    // final file = File('example/test.txt');
    // if (file.existsSync()) {
    //   file.deleteSync();
    // }
    // final inputStream = file.openWrite();
    // await inputStream.addStream(downloadedData);
    // await inputStream.close();

    // print('... done!');

    // await client.webDav.delete('/test.txt');
    // await client.webDav.delete('/abc.txt');

    // print('List all sharees:');
    // print(await client.sharees.getSharees('', 1000, 'file'));
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
