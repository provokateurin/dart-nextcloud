import 'dart:io';

import 'package:nextcloud/nextcloud.dart';
import 'package:test/test.dart';

import 'config.dart';

void main() {
  final client = getClient();

  group('Preview', () {
    final fullImagePath = '${Config.testDir}/preview.png';
    final rootWithoutUser =
        Config.testDir.split('/files/${Config.username}')[1];
    final imageRootPath = '$rootWithoutUser/preview.png';
    WebDavFile previewFile;

    setUpAll(() async {
      await client.webDav
          .upload(File('test/files/test.png').readAsBytesSync(), fullImagePath);
      previewFile = await client.webDav.getProps(fullImagePath);
    });

    test('Get preview by path', () async {
      expect(await client.preview.getPreviewByPath(imageRootPath, 64, 64),
          isNotNull);
    });
    test('Get preview by id', () async {
      expect(await client.preview.getPreviewById(previewFile.id, 64, 64),
          isNotNull);
    });
    test('Get preview stream by path', () async {
      expect(await client.preview.getPreviewStreamByPath(imageRootPath, 64, 64),
          isNotNull);
    });
    test('Get preview stream by id', () async {
      expect(await client.preview.getPreviewStreamById(previewFile.id, 64, 64),
          isNotNull);
    });
    test('Get thumbnail', () async {
      expect(
          await client.preview.getThumbnail(imageRootPath, 64, 64), isNotNull);
    });
    test('Get thumbnail stream', () async {
      expect(await client.preview.getThumbnailStream(imageRootPath, 64, 64),
          isNotNull);
    });
  });
}
