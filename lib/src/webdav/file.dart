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

/// Converts a single d:response to a [WebDavFile]
WebDavFile _fromWebDavXml(xml.XmlElement response) {
  final davItemName = response.findAllElements('d:href').single.text;
  final contentTypeElements = response.findAllElements('d:getcontenttype');
  final contentType = contentTypeElements.single.text != ''
      ? contentTypeElements.single.text
      : null;
  final contentLengthElements = response.findAllElements('d:getcontentlength');
  final contentLength = contentLengthElements.single.text != ''
      ? int.parse(contentLengthElements.single.text)
      : 0;

  final lastModifiedElements = response.findAllElements('d:getlastmodified');
  final lastModified = lastModifiedElements.single.text != ''
      ? DateFormat('E, d MMM yyyy HH:mm:ss', 'en_US')
          .parseUtc(lastModifiedElements.single.text)
      : null;

  final shareTypes = response
      .findAllElements('oc:share-type')
      .map((element) => int.parse(element.text))
      .toList();

  return WebDavFile(davItemName.replaceAll(RegExp('remote.php/(web)?dav/'), ''),
      contentType, contentLength, lastModified,
      shareTypes: shareTypes);
}

/// Extract a file from the webav xml
WebDavFile fileFromWebDavXml(String xmlStr) {
  final xmlDocument = xml.XmlDocument.parse(xmlStr);
  return _fromWebDavXml(xmlDocument.findAllElements('d:response').single);
}

/// Extract the file tree from the webdav xml
List<WebDavFile> treeFromWebDavXml(String xmlStr) {
  // Initialize a list to store the FileInfo Objects
  final tree = [];

  // parse the xml using the xml.XmlDocument.parse method
  final xmlDocument = xml.XmlDocument.parse(xmlStr);

  // Iterate over the response to find all folders / files and parse the information
  for (final response in xmlDocument.findAllElements('d:response')) {
    tree.add(_fromWebDavXml(response));
  }
  return tree.cast<WebDavFile>()..removeAt(0);
}
