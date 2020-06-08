import 'dart:typed_data';

import 'package:http/http.dart';

import '../network.dart';

/// PreviewClient abstracts preview and thumbnail API
class PreviewClient {
  // ignore: public_member_api_docs
  PreviewClient(
    this._baseUrl,
    String username,
    String password
  ) {
    final client = NextCloudHttpClient(username, password);
    _network = Network(client);
  }

  final String _baseUrl;
  Network _network;

  String _getPreviewUrl(String remotePath, int width, int height) {
    return '$_baseUrl/index.php/core/preview.png?file=${Uri.encodeQueryComponent(remotePath)}&x=$width&y=$height&a=1&mode=cover&forceIcon=0';
  }

  String _getThumbnailUrl(String remotePath, int width, int height) {
    if(!remotePath.startsWith('/')) {
      remotePath = '/$remotePath';
    }
    return '$_baseUrl/index.php/apps/files/api/v1/thumbnail/$width/$height${Uri.encodeFull(remotePath)}';
  }

  /// fetch preview for [remotePath] with provided [width] and [height]
  Future<Uint8List> getPreview(String remotePath, int width, int height) async {
    final response = await _network.send('GET', _getPreviewUrl(remotePath, width, height), [200]);
    return response.bodyBytes;
  }

  /// fetch preview for [remotePath] with provided [width] and [height] as ByteStream
  Future<ByteStream> getPreviewStream(String remotePath, int width, int height) async {
    final response = await _network.download('GET', _getPreviewUrl(remotePath, width, height), [200]);
    return response.stream;
  }

  /// fetch thumbnail for [remotePath] with provided [width] and [height]
  /// thumbnail will crop your image if you want resized images use preview
  Future<Uint8List> getThumbnail(String remotePath, int width, int height) async {
    final response = await _network.send('GET', _getThumbnailUrl(remotePath, width, height), [200]);
    return response.bodyBytes;
  }

  /// fetch thumbnail for [remotePath] with provided [width] and [height] as ByteStream
  /// thumbnail will crop your image if you want resized images use preview
  Future<ByteStream> getThumbnailStream(String remotePath, int width, int height) async {
    final response = await _network.download('GET', _getThumbnailUrl(remotePath, width, height), [200]);
    return response.stream;
  }
}
