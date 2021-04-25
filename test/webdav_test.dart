import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:nextcloud/nextcloud.dart';
import 'package:test/test.dart';

import 'config.dart';

void main() {
  const testDir = 'dart-nextcloud-tests';
  final client = getClient();

  group('WebDav', () {
    setUpAll(() async {
      try {
        await client.webDav.status();
        await client.webDav.delete(testDir);
        // ignore: empty_catches
      } on RequestException catch (ex) {
        if (ex.statusCode != 404) {
          rethrow;
        }
      }
    });

    test('Get status', () async {
      final status = await client.webDav.status();
      expect(status.capabilities, containsAll(['1', '3', 'access-control']));
      expect(status.searchCapabilities, contains('<DAV:basicsearch>'));
    });
    test('Create directory', () async {
      expect((await client.webDav.mkdir(testDir)).statusCode, equals(201));
    });
    test('List directory', () async {
      expect((await client.webDav.ls(testDir)).length, equals(0));
    });
    test('Upload files', () async {
      expect(
        (await client.webDav.upload(
          File('test/files/test.png').readAsBytesSync(),
          '$testDir/test.png',
        ))
            .statusCode,
        equals(201),
      );
      expect(
        (await client.webDav.upload(
          File('test/files/test.txt').readAsBytesSync(),
          '$testDir/test.txt',
        ))
            .statusCode,
        equals(201),
      );
      final files = await client.webDav.ls(testDir);
      expect(files.length, equals(2));
      expect(files.where((f) => f.name == 'test.png').length, 1);
      expect(files.where((f) => f.name == 'test.txt').length, 1);
    });
    test('List directory with properties', () async {
      final startTime = DateTime.now()
          // lastmodified is second-precision only
          .subtract(const Duration(seconds: 2));
      const path = '$testDir/list-test.txt';
      final data = utf8.encode('WebDAV list-test');
      await client.webDav.upload(Uint8List.fromList(data), path);

      final files = await client.webDav.ls(testDir);
      final file = files.singleWhere((f) => f.name == 'list-test.txt');
      expect(file.isDirectory, false);
      expect(file.name, 'list-test.txt');
      expect(
        startTime.isBefore(file.lastModified),
        isTrue,
        reason: 'Expected $startTime < ${file.lastModified}',
      );
      expect(file.mimeType, 'text/plain');
      expect(file.path, path);
      expect(file.shareTypes, []);
      expect(file.size, data.length);
    });
    test('Copy file', () async {
      final response = await client.webDav.copy(
        '$testDir/test.txt',
        '$testDir/test2.txt',
      );
      expect(response.statusCode, 201);
      final files = await client.webDav.ls(testDir);
      expect(files.where((f) => f.name == 'test.txt'), hasLength(1));
      expect(files.where((f) => f.name == 'test2.txt'), hasLength(1));
    });
    test('Copy file (no overwrite)', () async {
      const path = '$testDir/copy-test.txt';
      final data = utf8.encode('WebDAV copytest');
      await client.webDav.upload(Uint8List.fromList(data), path);

      expect(
        () => client.webDav.copy('$testDir/test.txt', '$testDir/copy-test.txt'),
        // ignore: avoid_types_on_closure_parameters
        throwsA(predicate((RequestException e) => e.statusCode == 412)),
      );
    });
    test('Copy file (overwrite)', () async {
      const path = '$testDir/copy-test.txt';
      final data = utf8.encode('WebDAV copytest');
      await client.webDav.upload(Uint8List.fromList(data), path);

      final response = await client.webDav
          .copy('$testDir/test.txt', '$testDir/copy-test.txt', overwrite: true);
      expect(response.statusCode, 204);
    });
    test('Move file', () async {
      final response = await client.webDav.move(
        '$testDir/test2.txt',
        '$testDir/test3.txt',
      );
      expect(response.statusCode, 201);
      final files = await client.webDav.ls(testDir);
      expect(files.where((f) => f.name == 'test2.txt'), isEmpty);
      expect(files.where((f) => f.name == 'test3.txt'), hasLength(1));
    });
    test('Move file (no overwrite)', () async {
      const path = '$testDir/move-test.txt';
      final data = utf8.encode('WebDAV movetest');
      await client.webDav.upload(Uint8List.fromList(data), path);

      expect(
        () => client.webDav.move('$testDir/test.txt', '$testDir/move-test.txt'),
        // ignore: avoid_types_on_closure_parameters
        throwsA(predicate((RequestException e) => e.statusCode == 412)),
      );
    });
    test('Move file (overwrite)', () async {
      const path = '$testDir/move-test.txt';
      final data = utf8.encode('WebDAV movetest');
      await client.webDav.upload(Uint8List.fromList(data), path);

      final response = await client.webDav
          .move('$testDir/test.txt', '$testDir/move-test.txt', overwrite: true);
      expect(response.statusCode, 204);
    });
    test('Get file properties', () async {
      final startTime = DateTime.now().subtract(const Duration(seconds: 2));
      const path = '$testDir/prop-test.txt';
      final data = utf8.encode('WebDAV proptest');
      await client.webDav.upload(Uint8List.fromList(data), path);

      final file = await client.webDav.getProps(path);
      expect(file.isDirectory, false);
      expect(file.name, 'prop-test.txt');
      expect(
        file.lastModified.isAfter(startTime),
        isTrue,
        reason: 'Expected lastModified: $startTime < ${file.lastModified}',
      );
      expect(
        file.uploadedDate.isAfter(startTime),
        isTrue,
        reason: 'Expected uploadedDate: $startTime < ${file.uploadedDate}',
      );
      expect(file.mimeType, 'text/plain');
      expect(file.path, path);
      expect(file.shareTypes, isEmpty);
      expect(file.size, data.length);
    });
    test('Get directory properties', () async {
      final path = Uri.parse(testDir);
      final file = await client.webDav.getProps(path.toString());
      expect(file.isDirectory, true);
      expect(file.isCollection, true);
      expect(file.name, path.pathSegments.last);
      expect(file.lastModified, isNotNull);
      expect(file.mimeType, isNull);
      expect(file.path, '$path/');
      expect(file.shareTypes, isEmpty);
      expect(file.size, greaterThan(0));
    });
    test('Get additional properties', () async {
      const path = '$testDir/prop-test.txt';
      final file = await client.webDav.getProps(path);

      expect(
        file.getOtherProp('oc:comments-count', 'http://owncloud.org/ns'),
        '0',
      );
      expect(
        file.getOtherProp('nc:has-preview', 'http://nextcloud.org/ns'),
        'true',
      );
    });
    test('Filter files', () async {
      const path = '$testDir/filter-test.txt';
      final data = utf8.encode('WebDAV filtertest');
      final response =
          await client.webDav.upload(Uint8List.fromList(data), path);
      final id = response.headers['oc-fileid'];

      // Favorite file
      await client.webDav.updateProps(path, {WebDavProps.ocFavorite: '1'});

      // Find favorites
      final files = await client.webDav.filter(
        testDir,
        {
          WebDavProps.ocFavorite: '1',
        },
        props: {
          WebDavProps.ocId,
          WebDavProps.ocFileId,
          WebDavProps.ocFavorite,
        },
      );
      final file = files.singleWhere((e) => e.name == 'filter-test.txt');
      expect(file.favorite, isTrue);
      expect(file.id, id);
    });
    test('Set properties', () async {
      final createdDate = DateTime.utc(1971, 2);
      final createdEpoch = createdDate.millisecondsSinceEpoch / 1000;
      const path = '$testDir/prop-test.txt';
      final updated = await client.webDav.updateProps(path, {
        WebDavProps.ocFavorite: '1',
        WebDavProps.ncCreationTime: '$createdEpoch'
      });
      expect(updated, isTrue);

      final file = await client.webDav.getProps(path);
      expect(file.favorite, isTrue);
      expect(
        file.createdDate.isAtSameMomentAs(createdDate),
        isTrue,
        reason: 'Expected same time: $createdDate = ${file.createdDate}',
      );
      expect(file.uploadedDate, isNotNull);
    });
    test('Set custom properties', () async {
      final customNamespaces = {
        'http://leonhardt.co.nz/ns': 'le',
        'http://test/ns': 'test'
      };
      const path = '$testDir/prop-test.txt';

      customNamespaces
          .forEach((ns, prefix) => client.webDav.registerNamespace(ns, prefix));

      final updated = await client.webDav.updateProps(path, {
        'le:custom': 'le-custom-prop-value',
        'le:custom2': 'le-custom-prop-value2',
        'test:custom': 'test-custom-prop-value',
      });
      expect(updated, isTrue);

      final file = await client.webDav.getProps(
        path,
        props: {
          'd:getlastmodified',
          'oc:fileid',
          'le:custom',
          'le:custom2',
          'test:custom',
        },
      );
      expect(file.name, 'prop-test.txt');
      expect(
        file.getOtherProp('custom', customNamespaces.keys.first),
        'le-custom-prop-value',
      );
      expect(
        file.getOtherProp('custom2', customNamespaces.keys.first),
        'le-custom-prop-value2',
      );
      expect(
        file.getOtherProp('custom', customNamespaces.keys.elementAt(1)),
        'test-custom-prop-value',
      );
    });
    test('Folders with URL like parts work', () async {
      await client.webDav.mkdir(':443');
      await client.webDav.upload(
        File('test/files/test.png').readAsBytesSync(),
        ':443/test.png',
      );
      expect((await client.webDav.ls(':443'))[0].name, 'test.png');
    });
  });

  group('WebDavFile', () {
    String _getXmlForFilePath(String xmlPath) =>
        '<?xml version="1.0"?><d:multistatus xmlns:d="DAV:" xmlns:s="http://sabredav.org/ns" xmlns:oc="http://owncloud.org/ns" xmlns:nc="http://nextcloud.org/ns"><d:response><d:href>$xmlPath</d:href><d:propstat><d:prop><d:getlastmodified>Fri, 22 Jan 2021 08:02:09 GMT</d:getlastmodified><oc:id>00000054oc8kuawfom6a</oc:id><oc:share-types/></d:prop><d:status>HTTP/1.1 200 OK</d:status></d:propstat><d:propstat><d:prop><d:getcontentlength/><d:getcontenttype/></d:prop><d:status>HTTP/1.1 404 Not Found</d:status></d:propstat></d:response></d:multistatus>';

    test('correct parsing of path with simple Nextcloud host', () async {
      // https://cloud.com this is the host address
      const expectedPath = '/files/admin/dart-nextcloud-tests/';
      const xmlPath = '/remote.php/dav$expectedPath';

      final files = treeFromWebDavXml(_getXmlForFilePath(xmlPath));

      expect(files.length, 1);
      expect(files[0].path, expectedPath);
    });

    test('correct parsing of path with Nextcloud host behind subpath',
        () async {
      // https://cloud.com/nc this is the host address
      const expectedPath = '/files/admin/dart-nextcloud-tests/';
      const xmlPath = '/nc/remote.php/dav$expectedPath';

      final files = treeFromWebDavXml(_getXmlForFilePath(xmlPath));

      expect(files.length, 1);
      expect(files[0].path, expectedPath);
    });
  });
}
