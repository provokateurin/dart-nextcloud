import 'dart:typed_data';

import 'package:http/http.dart';

import '../network.dart';

/// PreviewClient abstracts preview and thumbnail API
class PreviewClient {
  // ignore: public_member_api_docs
  PreviewClient(
    this._baseUrl,
    this._network,
  );

  final String _baseUrl;
  final Network _network;

  /// fetch preview for [filePath] with provided [width] and [height]
  Future<Uint8List> getPreviewByPath(
    String filePath,
    int width,
    int height, {
    bool a = true,
    String mode = 'cover',
    bool forceIcon = false,
  }) async =>
      _getPreview(
        _createPreviewUrl(
          width,
          height,
          filePath: filePath,
          a: a,
          mode: mode,
          forceIcon: forceIcon,
        ),
      );

  /// fetch preview for [filePath] with provided [width] and [height] as ByteStream
  Future<ByteStream> getPreviewStreamByPath(
    String filePath,
    int width,
    int height, {
    bool a = true,
    String mode = 'cover',
    bool forceIcon = false,
  }) async =>
      _getPreviewStream(
        _createPreviewUrl(
          width,
          height,
          filePath: filePath,
          a: a,
          mode: mode,
          forceIcon: forceIcon,
        ),
      );

  /// fetch preview for [fileId] with provided [width] and [height]
  Future<Uint8List> getPreviewById(
    String fileId,
    int width,
    int height, {
    bool a = true,
    String mode = 'cover',
    bool forceIcon = false,
  }) async =>
      _getPreview(
        _createPreviewUrl(
          width,
          height,
          fileId: fileId,
          a: a,
          mode: mode,
          forceIcon: forceIcon,
        ),
      );

  /// fetch preview for [fileId] with provided [width] and [height] as ByteStream
  Future<ByteStream> getPreviewStreamById(
    String fileId,
    int width,
    int height, {
    bool a = true,
    String mode = 'cover',
    bool forceIcon = false,
  }) async =>
      _getPreviewStream(
        _createPreviewUrl(
          width,
          height,
          fileId: fileId,
          a: a,
          mode: mode,
          forceIcon: forceIcon,
        ),
      );

  Future<Uint8List> _getPreview(String url) async {
    final response = await _network.send(
      'GET',
      url,
      [200],
    );
    return response.bodyBytes;
  }

  Future<ByteStream> _getPreviewStream(String url) async {
    final response = await _network.download(
      'GET',
      url,
      [200],
    );
    return response.stream;
  }

  String _createPreviewUrl(
    int width,
    int height, {
    String? filePath,
    String? fileId,
    bool a = true,
    String mode = 'cover',
    bool forceIcon = false,
  }) {
    assert(
      filePath != null || fileId != null,
      'FilePath or FileId has to be specified!',
    );

    final query = 'x=$width&y=$height&a=$a&mode=$mode&forceIcon=$forceIcon';

    if (fileId != null) {
      return '$_baseUrl/index.php/core/preview?fileId=$fileId&$query';
    }

    if (filePath != null) {
      return '$_baseUrl/index.php/core/preview.png?file=${Uri.encodeQueryComponent(filePath)}&$query';
    }
    // Never going to happen
    return '';
  }

  /// fetch thumbnail for [remotePath] with provided [width] and [height]
  /// thumbnail will crop your image if you want resized images use preview
  Future<Uint8List> getThumbnail(
    String remotePath,
    int width,
    int height,
  ) async {
    final response = await _network.send(
      'GET',
      _getThumbnailUrl(remotePath, width, height),
      [200],
    );
    return response.bodyBytes;
  }

  /// fetch thumbnail for [remotePath] with provided [width] and [height] as ByteStream
  /// thumbnail will crop your image if you want resized images use preview
  Future<ByteStream> getThumbnailStream(
    String remotePath,
    int width,
    int height,
  ) async {
    final response = await _network.download(
      'GET',
      _getThumbnailUrl(remotePath, width, height),
      [200],
    );
    return response.stream;
  }

  String _getThumbnailUrl(String remotePath, int width, int height) {
    if (!remotePath.startsWith('/')) {
      remotePath = '/$remotePath';
    }
    return '$_baseUrl/index.php/apps/files/api/v1/thumbnail/$width/$height${Uri.encodeFull(remotePath)}';
  }
}
