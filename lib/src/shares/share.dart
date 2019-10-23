import 'package:xml/xml.dart' as xml;

/// Share class
class Share {
  // ignore: public_member_api_docs
  Share(
      {this.id,
      this.shareType,
      this.uidOwner,
      this.displaynameOwner,
      this.permissions,
      this.stime,
      this.parent,
      this.expiration,
      this.token,
      this.uidFileOwner,
      this.note,
      this.label,
      this.displaynameFileOwner,
      this.path,
      this.itemType,
      this.mimeType,
      this.storageId,
      this.storage,
      this.itemSource,
      this.fileSource,
      this.fileParent,
      this.fileTarget,
      this.shareWith,
      this.shareWithDisplayName,
      this.mailSend,
      this.hideDownload,
      this.password,
      this.url});

  /// The share id
  final int id;

  /// Integer defined in [ShareTypes]
  final int shareType;

  // ignore: public_member_api_docs
  final String uidOwner;

  // ignore: public_member_api_docs
  final String displaynameOwner;

  // ignore: public_member_api_docs
  final Permissions permissions;

  // ignore: public_member_api_docs
  final int stime;

  // ignore: public_member_api_docs
  final String parent;

  // ignore: public_member_api_docs
  final DateTime expiration;

  // ignore: public_member_api_docs
  final String token;

  // ignore: public_member_api_docs
  final String uidFileOwner;

  // ignore: public_member_api_docs
  final String note;

  // ignore: public_member_api_docs
  final String label;

  // ignore: public_member_api_docs
  final String displaynameFileOwner;

  // ignore: public_member_api_docs
  final String path;

  // ignore: public_member_api_docs
  final String itemType;

  // ignore: public_member_api_docs
  final String mimeType;

  // ignore: public_member_api_docs
  final String storageId;

  // ignore: public_member_api_docs
  final int storage;

  // ignore: public_member_api_docs
  final int itemSource;

  // ignore: public_member_api_docs
  final int fileSource;

  // ignore: public_member_api_docs
  final int fileParent;

  // ignore: public_member_api_docs
  final String fileTarget;

  // ignore: public_member_api_docs
  final String shareWith;

  // ignore: public_member_api_docs
  final String shareWithDisplayName;

  // ignore: public_member_api_docs
  final int mailSend;

  // ignore: public_member_api_docs
  final int hideDownload;

  /// Password for public link share
  final String password;

  /// Url for public link share
  final String url;

  /// Returns if the file is a directory
  bool get isDirectory => itemType == 'folder';

  @override
  String toString() =>
      'Share{path: $path, id: $id owner: $displaynameOwner, shareWith: $shareWith, permissions: $permissions, url: $url, ...}';
}

/// Defines all possible share types
class ShareTypes {
  /// Share with user
  static const user = 0;

  /// Share with group
  static const group = 1;

  /// Create a public link share
  static const publicLink = 3;

  /// All possible share types
  static const values = [user, group, publicLink];
}

/// Defines the permission
class Permission {
  /// Read only
  static const read = 1;

  /// Update only
  static const update = 2;

  /// Create only
  static const create = 4;

  /// Update only
  static const delete = 8;

  /// Share only
  static const share = 16;

  /// All permissions
  static const all = 31;

  /// All possible permission values
  static const values = [read, update, create, delete, share, all];
}

/// Defines the combination of permissions
class Permissions {
  /// Create permissions by the integer lists of [Permission].VALUE objects
  Permissions(List<int> permissions) {
    _permissions = permissions;
    _value = permissions.reduce((i1, i2) => i1 + i2);
  }

  /// Create permissions the the combined permission integer
  factory Permissions.fromInt(int number) {
    // ignore: omit_local_variable_types
    final List<int> permissions = [];
    // ignore: avoid_function_literals_in_foreach_calls
    Permission.values.forEach((value) {
      if (value <= number) {
        number -= value;
        permissions.add(value);
      }
    });
    return Permissions(permissions);
  }

  int _value;
  List<int> _permissions;

  /// Returns the permission as value
  int get value => _value;

  /// Returns the separated permissions as list
  List<int> get permissions => _permissions;

  @override
  String toString() {
    return '$_value: $_permissions';
  }
}

/// Parse a nullable value with given parser
result parse<result>(String text, result Function(String) parser) {
  if (text == null || text.isEmpty) {
    // ignore: avoid_returning_null
    return null;
  }
  return parser(text);
}

/// Returns the first element when it exists
String getElement(Iterable<xml.XmlElement> elements) {
  if (elements.isNotEmpty) {
    return elements.toList()[0].text;
  }
  return null;
}

/// Converts the shares xml to a list of share objects
List<Share> sharesFromSharesXml(String xmlStr) {
  // Initialize a list to store the FileInfo Objects
  final tree = [];

  // parse the xml using the xml.parse method
  final xmlDocument = xml.parse(xmlStr);

  // Iterate over the response to find all share elements and parse the information
  for (final response in xmlDocument.findAllElements('element')) {
    tree.add(shareFromShareXml(response));
  }
  return tree.cast<Share>();
}

/// Converts the shares xml to a list of share objects
Share shareFromRequestResponseXml(String xmlStr) {
  // parse the xml using the xml.parse method
  final xmlDocument = xml.parse(xmlStr);

  // Get the created share
  final response = xmlDocument.findAllElements('data').single;
  return shareFromShareXml(response);
}

/// Converts a share xml a a share object
Share shareFromShareXml(xml.XmlElement element) {
  final id = parse<int>(element.findAllElements('id').single.text, int.parse);
  final shareType =
      parse<int>(element.findAllElements('share_type').single.text, int.parse);
  final stime =
      parse<int>(element.findAllElements('stime').single.text, int.parse);
  final uidOwner = element.findAllElements('uid_owner').single.text;
  final displaynameOwner =
      element.findAllElements('displayname_owner').single.text;
  final parent = element.findAllElements('parent').single.text;
  final expiration = parse<DateTime>(
      element.findAllElements('expiration').single.text, DateTime.parse);
  final token = element.findAllElements('token').single.text;
  final uidFileOwner = element.findAllElements('uid_file_owner').single.text;
  final note = element.findAllElements('note').single.text;
  final label = element.findAllElements('label').single.text;
  final displaynameFileOwner =
      element.findAllElements('displayname_file_owner').single.text;
  final path = element.findAllElements('path').single.text;
  final itemType = element.findAllElements('item_type').single.text;
  final mimeType = element.findAllElements('mimetype').single.text;
  final storageId = element.findAllElements('storage_id').single.text;
  final storage =
      parse<int>(element.findAllElements('storage').single.text, int.parse);
  final itemSource =
      parse<int>(element.findAllElements('item_source').single.text, int.parse);
  final fileSource =
      parse<int>(element.findAllElements('file_source').single.text, int.parse);
  final fileParent =
      parse<int>(element.findAllElements('file_parent').single.text, int.parse);
  final fileTarget = element.findAllElements('file_target').single.text;
  final shareWith = element.findAllElements('share_with').single.text;
  final shareWithDisplayName =
      element.findAllElements('share_with_displayname').single.text;
  final mailSend =
      parse<int>(element.findAllElements('mail_send').single.text, int.parse);
  final hideDownload = parse<int>(
      element.findAllElements('hide_download').single.text, int.parse);
  final password = getElement(element.findAllElements('password'));
  final url = getElement(element.findAllElements('url'));

  final permissionsNumber =
      parse<int>(element.findAllElements('permissions').single.text, int.parse);
  final permissions = Permissions.fromInt(permissionsNumber);

  return Share(
      id: id,
      shareType: shareType,
      uidOwner: uidOwner,
      displaynameOwner: displaynameOwner,
      permissions: permissions,
      stime: stime,
      parent: parent,
      expiration: expiration,
      token: token,
      uidFileOwner: uidFileOwner,
      note: note,
      label: label,
      displaynameFileOwner: displaynameFileOwner,
      path: path,
      itemType: itemType,
      mimeType: mimeType,
      storageId: storageId,
      storage: storage,
      itemSource: itemSource,
      fileSource: fileSource,
      fileParent: fileParent,
      fileTarget: fileTarget,
      shareWith: shareWith,
      shareWithDisplayName: shareWithDisplayName,
      mailSend: mailSend,
      hideDownload: hideDownload,
      password: password,
      url: url);
}
