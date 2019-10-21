import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http_auth/http_auth.dart' as http_auth;
import 'package:nextcloud/nextcloud.dart';
import 'package:nextcloud/src/webdav/file.dart';
import 'package:retry/retry.dart';

/// WebDavException class
class WebDavException implements Exception {
  // ignore: public_member_api_docs
  WebDavException(this.cause);

  // ignore: public_member_api_docs
  String cause;
}

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
    _httpClient = http_auth.BasicAuthClient(username, password);
  }

  String _baseUrl;

  http.Client _httpClient;

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

  /// send the request with given [method] and [path]
  ///
  Future<http.Response> _send(
          String method, String path, List<int> expectedCodes,
          {Uint8List data}) =>
      retry(
        () => __send(
          method,
          path,
          expectedCodes,
          data: data,
        ),
        retryIf: (e) => e is WebDavException,
        maxAttempts: 5,
      );

  /// send the request with given [method] and [path]
  Future<http.Response> __send(
    String method,
    String path,
    List<int> expectedCodes, {
    Uint8List data,
  }) async {
    final url = getUrl(path);

    final response = await _httpClient.send(http.Request(method, Uri.parse(url))
      ..followRedirects = false
      ..persistentConnection = true
      ..body = data != null ? utf8.decode(data) : '');
    if (!expectedCodes.contains(response.statusCode)) {
      throw WebDavException('operation failed method:$method '
          'path:$path exceptionCodes:$expectedCodes '
          'statusCode:${response.statusCode}');
    }
    return http.Response.fromStream(response);
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
    return _send('MKCOL', path, expectedCodes);
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
  Future rmdir(String path, [bool safe = true]) async {
    path = path.trim();
    final expectedCodes = [
      204,
      if (safe) ...[
        204,
        404,
      ]
    ];
    await _send('DELETE', path, expectedCodes);
  }

  /// remove dir with given [path]
  Future delete(String path) => _send('DELETE', path, [204]);

  /// upload a new file with [localData] as content to [remotePath]
  Future upload(Uint8List localData, String remotePath) =>
      _send('PUT', remotePath, [200, 201, 204], data: localData);

  /// download [remotePath] and store the response file contents to String
  Future<String> download(String remotePath) async =>
      (await _send('GET', remotePath, [200])).body;

  /// list the directories and files under given [remotePath]
  Future<List<WebDavFile>> ls(String remotePath) async {
    final data = utf8.encode('''
      <d:propfind xmlns:d="DAV:">
        <d:prop>
          <d:getlastmodified/>
          <d:getcontentlength/>
        </d:prop>
      </d:propfind>
    ''');
    final response =
        await _send('PROPFIND', remotePath, [207, 301], data: data);
    if (response.statusCode == 301) {
      return ls(response.headers['location']);
    }
    return treeFromWebDavXml(response.body);
  }
}
