import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../../nextcloud.dart';
import '../network.dart';

/// WebDavClient class
class WebDavClient {
  // ignore: public_member_api_docs
  WebDavClient(
    String baseUrl,
    String username,
    String password,
  ) {
    _baseUrl = '$baseUrl/remote.php/dav/';
    final client = NextCloudHttpClient(username, password);
    _network = Network(client);
  }

  String _baseUrl;

  Network _network;

  /// get url from given [path]
  String _getUrl(String path) {
    path = path.trim();

    if (path.startsWith('/')) {
      // Since the base url ends with '/' by default trim of one char at the
      // beginning of the path
      return '$_baseUrl/remote.php/webdav/${path.substring(1, path.length)}';
    }

    // If the path does not start with '/' append it after the baseUrl
    return '$_baseUrl/$path';
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

  /// list the directories and files under given [remotePath]
  Future<List<WebDavFile>> ls(String remotePath) async {
    final data = utf8.encode('''
      <d:propfind xmlns:d="DAV:" xmlns:oc="http://owncloud.org/ns">
        <d:prop>
          <d:getlastmodified/>
          <d:getcontentlength/>
          <d:getcontenttype/>
          <oc:share-types/>
        </d:prop>
      </d:propfind>
    ''');
    final response = await _network
        .send('PROPFIND', _getUrl(remotePath), [207, 301], data: data);
    if (response.statusCode == 301) {
      return ls(response.headers['location']);
    }
    return treeFromWebDavXml(response.body);
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
