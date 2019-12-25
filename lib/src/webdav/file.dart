import 'package:intl/intl.dart';
import 'package:xml/xml.dart' as xml;

/// WebDavFile class
class WebDavFile {
  // ignore: public_member_api_docs
  WebDavFile(
    this.path,
    this.mimeType,
    this.size,
    this.lastModified, {
    this.shareTypes = const [],
  });

  // ignore: public_member_api_docs
  final String path;

  // ignore: public_member_api_docs
  final String mimeType;

  // ignore: public_member_api_docs
  final int size;

  // ignore: public_member_api_docs
  final DateTime lastModified;

  // ignore: public_member_api_docs
  final List<int> shareTypes;

  /// Returns the decoded name of the file / folder without the whole path
  String get name {
    if (isDirectory) {
      return Uri.decodeFull(
          path.substring(0, path.lastIndexOf('/')).split('/').last);
    }
    return Uri.decodeFull(path.split('/').last);
  }

  /// Returns if the file is a directory
  bool get isDirectory => path.endsWith('/');

  @override
  String toString() =>
      // ignore: lines_longer_than_80_chars
      'WebDavFile{name: $name, isDirectory: $isDirectory, path: $path, mimeType: $mimeType, size: $size, modificationTime: $lastModified, shareTypes: $shareTypes}';
}

/// Extract the file tree from the webdav xml
List<WebDavFile> treeFromWebDavXml(String xmlStr) {
  // Initialize a list to store the FileInfo Objects
  final tree = [];

  // parse the xml using the xml.parse method
  final xmlDocument = xml.parse(xmlStr);

  // Iterate over the response to find all folders / files and parse the information
  for (final response in xmlDocument.findAllElements('d:response')) {
    final davItemName = response.findAllElements('d:href').single.text;
    final contentTypeElements = response.findAllElements('d:getcontenttype');
    final contentType =
        contentTypeElements.isNotEmpty && contentTypeElements.single.text != ''
            ? contentTypeElements.single.text
            : null;
    final contentLengthElements =
        response.findAllElements('d:getcontentlength');
    final contentLength = contentLengthElements.isNotEmpty &&
            contentLengthElements.single.text != ''
        ? int.parse(contentLengthElements.single.text)
        : 0;

    final lastModifiedElements = response.findAllElements('d:getlastmodified');
    final lastModified = lastModifiedElements.single.text != ''
        ? DateFormat('E, d MMM yyyy HH:mm:ss Z')
            .parse(lastModifiedElements.single.text)
        : null;

    final shareTypes = response
        .findAllElements('oc:share-type')
        .map((element) => int.parse(element.text))
        .toList();

    tree.add(WebDavFile(
      davItemName.replaceAll('remote.php/webdav/', ''),
      contentType,
      contentLength,
      lastModified,
      shareTypes: shareTypes,
    ));
  }
  return tree.cast<WebDavFile>()..removeAt(0);
}
