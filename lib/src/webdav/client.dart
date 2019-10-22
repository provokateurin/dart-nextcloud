import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:nextcloud/nextcloud.dart';
import 'package:nextcloud/src/network.dart';
import 'package:nextcloud/src/webdav/file.dart';

/// WebDavClient class
class WebDavClient {
  // ignore: public_member_api_docs
  WebDavClient(
    String host,
    String username,
    String password, {
    int port,
  }) {
    if (port == null) {
      _baseUrl = 'https://$host';
    } else {
      _baseUrl = 'https://$host:$port';
    }
    _baseUrl = '$_baseUrl/remote.php/webdav/';
    final client = NextCloudHttpClient(username, password);
    _network = Network(client);
  }

  String _baseUrl;

  Network _network;

  /// get url from given [path]
  String getUrl(String path) {
    path = path.trim();

    if (path.startsWith('/')) {
      // Since the base url ends with '/' by default trim of one char at the
      // beginning of the path
      return _baseUrl + path.substring(1, path.length);
    }

    // If the path does not start with '/' append it after the baseUrl
    return [_baseUrl, path].join('');
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
    return _network.send('MKCOL', getUrl(path), expectedCodes);
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
  Future delete(String path) => _network.send('DELETE', getUrl(path), [204]);

  /// upload a new file with [localData] as content to [remotePath]
  Future upload(Uint8List localData, String remotePath) => _network
      .send('PUT', getUrl(remotePath), [200, 201, 204], data: localData);

  /// download [remotePath] and store the response file contents to String
  Future<Uint8List> download(String remotePath) async =>
      (await _network.send('GET', getUrl(remotePath), [200])).bodyBytes;

  /// list the directories and files under given [remotePath]
  Future<List<WebDavFile>> ls(String remotePath) async {
    final data = utf8.encode('''
      <d:propfind xmlns:d="DAV:">
        <d:prop>
          <d:getlastmodified/>
          <d:getcontentlength/>
          <d:getcontenttype/>
        </d:prop>
      </d:propfind>
    ''');
    final response = await _network
        .send('PROPFIND', getUrl(remotePath), [207, 301], data: data);
    if (response.statusCode == 301) {
      return ls(response.headers['location']);
    }
    return treeFromWebDavXml(response.body);
  }

  /// Move a file from [sourcePath] to [destinationPath]
  Future move(String sourcePath, String destinationPath) async {
    await _network.send(
      'MOVE',
      getUrl(sourcePath),
      [200, 201],
      headers: {
        'Destination': getUrl(destinationPath),
      },
    );
  }

  /// Copy a file from [sourcePath] to [destinationPath]
  Future copy(String sourcePath, String destinationPath) async {
    await _network.send(
      'COPY',
      getUrl(sourcePath),
      [200, 201],
      headers: {
        'Destination': getUrl(destinationPath),
      },
    );
  }
}
