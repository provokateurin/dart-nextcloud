import 'package:intl/intl.dart';
import 'package:xml/xml.dart' as xml;

/// WebDavFile class
class WebDavFile {
  /// Creates a new WebDavFile object with the given path
  WebDavFile(this.path);

  // ignore: public_member_api_docs
  final String path;

  /// The fileid namespaced by the instance id, globally unique
  String id;

  /// The unique id for the file within the instance
  String fileId;

  /// Whether this is a collection resource type
  bool isCollection = false;

  // ignore: public_member_api_docs
  String mimeType;

  /// File content length or folder size
  int size;

  /// The user id of the owner of a shared file
  String ownerId;

  /// The display name of the owner of a shared file
  String ownerDisplay;

  /// Share note
  String note;

  // ignore: public_member_api_docs
  DateTime lastModified;

  /// Upload date of the file.
  DateTime uploadedDate;

  /// Creation date of the file as provided by uploader.
  DateTime createdDate;

  // ignore: public_member_api_docs
  List<int> shareTypes = [];

  /// User IDs of sharees.
  List<String> sharees = [];

  /// Whether this file is marked as favorite.
  bool favorite = false;

  /// Other properties, mapped by their prefixed name name
  final Map<String, String> _otherProps = {};

  /// Additional namespace-prefix mappings for custom properties
  final Map<String, String> _otherNamespaces = {};

  /// Add an additional property by [name] and [value]
  void addOtherProp(xml.XmlName name, String value) {
    _otherNamespaces[name.namespaceUri] = name.prefix;
    _otherProps[name.qualified] = value;
  }

  /// Lookup an additional property by [name] and [namespaceUri]
  String getOtherProp(String name, String namespaceUri) {
    final localName = xml.XmlName.fromString(name).local;
    // find correct prefix
    final prefix = _otherNamespaces[namespaceUri];
    return _otherProps['$prefix:$localName'];
  }

  /// Returns the decoded name of the file / folder without the whole path
  String get name {
    // normalised path (remove trailing slash)
    final end = path.endsWith('/') ? path.length - 1 : path.length;
    return Uri.parse(path, 0, end).pathSegments.last;
  }

  /// Returns if the file is a directory
  bool get isDirectory => path.endsWith('/') || isCollection;

  @override
  String toString() =>
      // ignore: lines_longer_than_80_chars
      'WebDavFile{name: $name, id: $id, isDirectory: $isDirectory, path: $path, mimeType: $mimeType, size: $size, modificationTime: $lastModified, shareTypes: $shareTypes}';
}

void _handleProp(xml.XmlElement prop, WebDavFile file) {
  if (prop.children.isEmpty && prop.text.isEmpty) {
    // Ignore empty properties
    return;
  }

  switch (prop.name.qualified) {
    case 'd:getcontenttype':
      file.mimeType = prop.text;
      break;
    case 'd:getcontentlength':
      file.size = int.parse(prop.text);
      break;
    case 'd:getlastmodified':
      file.lastModified =
          DateFormat('E, d MMM yyyy HH:mm:ss', 'en_US').parseUtc(prop.text);
      break;
    case 'd:resourcetype':
      file.isCollection = prop.getElement('d:collection') != null;
      break;
    case 'oc:id':
      file.id = prop.text;
      break;
    case 'oc:fileid':
      file.fileId = prop.text;
      break;
    case 'oc:favorite':
      file.favorite = prop.text == '1';
      break;
    case 'oc:owner-id':
      file.ownerId = prop.text;
      break;
    case 'oc:owner-display-name':
      file.ownerDisplay = prop.text;
      break;
    case 'oc:share-types':
      file.shareTypes = prop
          .findElements('oc:share-type')
          .map((element) => int.parse(element.text))
          .toList();
      break;
    case 'nc:sharees':
      file.sharees = prop.findAllElements('nc:id').map((e) => e.text).toList();
      break;
    case 'oc:note':
      file.note = prop.text;
      break;
    case 'oc:size':
      file.size = int.parse(prop.text);
      break;
    case 'nc:creation_time':
      file.createdDate =
          DateTime.fromMillisecondsSinceEpoch(int.parse(prop.text) * 1000);
      break;
    case 'nc:upload_time':
      file.uploadedDate =
          DateTime.fromMillisecondsSinceEpoch(int.parse(prop.text) * 1000);
      break;
    default:
      // store with fully qualified name
      file.addOtherProp(prop.name, prop.text);
  }
}

/// Converts a single d:response to a [WebDavFile]
WebDavFile _fromWebDavXml(xml.XmlElement response) {
  final davItemName = response.findElements('d:href').single.text;
  final path = davItemName.replaceAll(RegExp('remote.php/(web)?dav/'), '');
  final file = WebDavFile(path);

  final propStatElements = response.findElements('d:propstat');
  for (final propStat in propStatElements) {
    final status = propStat.getElement('d:status').text;
    final props = propStat.getElement('d:prop');

    if (!status.contains('200')) {
      // Skip any props that are not returned correctly (e.g. not found)
      continue;
    }
    for (final prop in props.nodes.whereType<xml.XmlElement>()) {
      _handleProp(prop, file);
    }
  }

  return file;
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
  return tree.cast<WebDavFile>();
}

/// Returns false if some updates have failed.
bool checkUpdateFromWebDavXml(String xmlStr) {
  final xmlDocument = xml.XmlDocument.parse(xmlStr);
  final response = xmlDocument.findAllElements('d:response').single;
  final propStatElements = response.findElements('d:propstat');
  for (final propStat in propStatElements) {
    final status = propStat.getElement('d:status').text;
    if (!status.contains('200')) {
      return false;
    }
  }
  return true;
}
