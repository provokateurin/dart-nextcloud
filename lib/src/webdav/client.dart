import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

import '../../nextcloud.dart';
import '../network.dart';

/// WebDavClient class
class WebDavClient {
  // ignore: public_member_api_docs
  WebDavClient(
    this._baseUrl,
    String username,
    String password,
  ) {
    final client = NextCloudHttpClient(username, password);
    _network = Network(client);
  }

  final String _baseUrl;

  Network _network;

  /// XML namespaces supported by Nextcloud:
  /// see [WebDav/Requesting properties](https://docs.nextcloud.com/server/latest/developer_manual/client_apis/WebDAV/basic.html#requesting-properties)
  static const Map<String, String> namespaces = {
    'DAV:': 'd',
    'http://owncloud.org/ns': 'oc',
    'http://nextcloud.org/ns': 'nc',
  };

  /// All WebDAV props supported by Nextcloud, in prefix form
  static const Set<String> allProps = {
    'd:getlastmodified',
    'd:getetag',
    'd:getcontenttype',
    'd:resourcetype',
    'd:getcontentlength',
    'oc:id',
    'oc:fileid',
    'oc:tags', // editable
    'oc:favorite', // editable, reportable
    'oc:systemtag', // reportable
    'oc:circle', // reportable
    'oc:comments-href',
    'oc:comments-count',
    'oc:comments-unread',
    'oc:downloadURL',
    'oc:owner-id',
    'oc:owner-display-name',
    'oc:share-types',
    'nc:sharees',
    'nc:note',
    'oc:checksums',
    'oc:size',
    'oc:permissions',
    'nc:data-fingerprint',
    'nc:has-preview',
    'nc:mount-type',
    'nc:is-encrypted',
    'nc:metadata_etag', // editable
    'nc:upload_time', // editable
    'nc:creation_time', // editable
  };

  /// get url from given [path]
  String _getUrl(String path) {
    path = path.trim();

    // Remove the trailing slash if needed
    if (path.startsWith('/')) {
      path = path.substring(1, path.length);
    }

    return '$_baseUrl/remote.php/dav/$path';
  }

  /// returns the WebDAV capabilities of the server
  Future<WebDavStatus> status() async {
    final response = await _network.send('OPTIONS', _getUrl('/'), [200]);
    final davCapabilities = response.headers['dav'] ?? '';
    final davSearchCapabilities = response.headers['dasl'] ?? '';
    return WebDavStatus(davCapabilities.split(',').map((e) => e.trim()).toSet(),
        davSearchCapabilities.split(',').map((e) => e.trim()).toSet());
  }

  /// make a dir with [path] under current dir
  Future<http.Response> mkdir(String path, [bool safe = true]) {
    final expectedCodes = [
      201,
      if (safe) ...[
        301,
        405,
      ],
    ];
    return _network.send('MKCOL', _getUrl(path), expectedCodes);
  }

  /// just like mkdir -p
  Future mkdirs(String path) async {
    path = path.trim();
    final dirs = path.split('/')
      ..removeWhere((value) => value == null || value == '');
    if (dirs.isEmpty) {
      return;
    }
    if (path.startsWith('/')) {
      dirs[0] = '/${dirs[0]}';
    }
    for (final dir in dirs) {
      await mkdir(dir, true);
    }
  }

  /// remove dir with given [path]
  Future delete(String path) => _network.send('DELETE', _getUrl(path), [204]);

  /// upload a new file with [localData] as content to [remotePath]
  Future upload(Uint8List localData, String remotePath) => _network
      .send('PUT', _getUrl(remotePath), [200, 201, 204], data: localData);

  /// download [remotePath] and store the response file contents to String
  Future<Uint8List> download(String remotePath) async =>
      (await _network.send('GET', _getUrl(remotePath), [200])).bodyBytes;

  /// download [remotePath] and store the response file contents to ByteStream
  Future<http.ByteStream> downloadStream(String remotePath) async =>
      (await _network.download('GET', _getUrl(remotePath), [200])).stream;

  /// download [remotePath] and returns the received bytes
  Future<Uint8List> downloadDirectoryAsZip(String remotePath) async {
    final url =
        '$_baseUrl/index.php/apps/files/ajax/download.php?dir=$remotePath';
    final result = await _network.send('GET', url, [200]);
    return result.bodyBytes;
  }

  /// download [remotePath] and returns a stream with the received bytes
  Future<http.ByteStream> downloadStreamDirectoryAsZip(
      String remotePath) async {
    final url =
        '$_baseUrl/index.php/apps/files/ajax/download.php?dir=$remotePath';
    return (await _network.download('GET', url, [200])).stream;
  }

  /// list the directories and files under given [remotePath].
  ///
  /// Optionally populates the given [props] on the returned files.
  Future<List<WebDavFile>> ls(String remotePath,
      {Set<String> props = const {
        'd:getlastmodified',
        'd:getcontentlength',
        'd:getcontenttype',
        'oc:id',
        'oc:share-types',
      }}) async {
    final builder = XmlBuilder();
    builder
      ..processing('xml', 'version="1.0"')
      ..element('d:propfind', nest: () {
        namespaces.forEach(builder.namespace);
        builder.element('d:prop', nest: () {
          props.forEach(builder.element);
        });
      });
    final data = utf8.encode(builder.buildDocument().toString());
    final response = await _network
        .send('PROPFIND', _getUrl(remotePath), [207, 301], data: data);
    if (response.statusCode == 301) {
      return ls(response.headers['location']);
    }
    return treeFromWebDavXml(response.body);
  }

  /// Retrieves properties for the given [remotePath].
  ///
  /// Populates all available properties by default, but a reduced set can be
  /// specified via [props].
  Future<WebDavFile> getProps(String remotePath,
      {Set<String> props = WebDavClient.allProps}) async {
    final builder = XmlBuilder();
    builder
      ..processing('xml', 'version="1.0"')
      ..element('d:propfind', nest: () {
        namespaces.forEach(builder.namespace);
        builder.element('d:prop', nest: () {
          props.forEach(builder.element);
        });
      });
    final data = utf8.encode(builder.buildDocument().toString());
    final response = await _network.send(
        'PROPFIND', _getUrl(remotePath), [200, 207],
        data: data, headers: {'Depth': '0'});
    return fileFromWebDavXml(response.body);
  }

  /// Move a file from [sourcePath] to [destinationPath]
  Future move(String sourcePath, String destinationPath) async {
    await _network.send(
      'MOVE',
      _getUrl(sourcePath),
      [200, 201],
      headers: {
        'Destination': _getUrl(destinationPath),
      },
    );
  }

  /// Copy a file from [sourcePath] to [destinationPath]
  Future copy(String sourcePath, String destinationPath) async {
    await _network.send(
      'COPY',
      _getUrl(sourcePath),
      [200, 201],
      headers: {
        'Destination': _getUrl(destinationPath),
      },
    );
  }
}

/// WebDAV server status.
class WebDavStatus {
  /// Creates a new WebDavStatus.
  WebDavStatus(
    this.capabilities,
    this.searchCapabilities,
  );

  /// DAV capabilities as advertised by the server in the 'dav' header.
  Set<String> capabilities;

  /// DAV search and locating capabilities as advertised by the server in the
  /// 'dasl' header.
  Set<String> searchCapabilities;
}
