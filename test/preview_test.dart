import 'dart:io';

import 'package:nextcloud/nextcloud.dart';
import 'package:test/test.dart';

import 'config.dart';

void main() {
  final client = getClient();

  group('Preview', () {
    const imageName = 'preview.png';
    late WebDavFile previewFile;

    setUpAll(() async {
      await client.webDav.status();
      await client.webDav
          .upload(File('test/files/test.png').readAsBytesSync(), imageName);
      previewFile = await client.webDav.getProps(imageName);
    });

    test('Get preview by path', () async {
      expect(
          await client.preview.getPreviewByPath(imageName, 64, 64), isNotNull);
    });
    test('Get preview by id', () async {
      expect(await client.preview.getPreviewById(previewFile.id, 64, 64),
          isNotNull);
    });
    test('Get preview stream by path', () async {
      expect(await client.preview.getPreviewStreamByPath(imageName, 64, 64),
          isNotNull);
    });
    test('Get preview stream by id', () async {
      expect(await client.preview.getPreviewStreamById(previewFile.id, 64, 64),
          isNotNull);
    });
    test('Get thumbnail', () async {
      expect(await client.preview.getThumbnail(imageName, 64, 64), isNotNull);
    });
    test('Get thumbnail stream', () async {
      expect(await client.preview.getThumbnailStream(imageName, 64, 64),
          isNotNull);
    });
  });
}
