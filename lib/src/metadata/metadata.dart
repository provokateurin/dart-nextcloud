import 'package:xml/xml.dart' as xml;

/// MetaData class
class MetaData {
  // ignore: public_member_api_docs
  MetaData(
    this.fullName,
    this.groups,
  );

  // ignore: public_member_api_docs
  final String fullName;

  // ignore: public_member_api_docs
  final List<String> groups;

  @override
  String toString() => 'MetaData{fullName: $fullName ,groups: $groups}}';
}

/// Extract the meta data from the meta data xml
MetaData metaDataFromMetaDataXml(String xmlStr) {
  // parse the xml using the xml.parse method
  final xmlDocument = xml.parse(xmlStr);

  final fullName = xmlDocument.findAllElements('displayname').single.text;
  final groups = xmlDocument
      .findAllElements('groups')
      .single
      .findAllElements('element')
      .map((element) => element.text)
      .toList()
      .cast<String>();

  return MetaData(fullName, groups);
}
