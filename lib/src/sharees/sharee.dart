import 'package:xml/xml.dart' as xml;

/// Sharee class
class Sharee {
  // ignore: public_member_api_docs
  Sharee(
    this.label,
    this.uuid,
    this.name,
    this.shareType,
  );

  // ignore: public_member_api_docs
  final String label;

  // ignore: public_member_api_docs
  final String uuid;

  // ignore: public_member_api_docs
  final String name;

  // ignore: public_member_api_docs
  final int shareType;

  @override
  String toString() =>
      'Sharee{label: $label, uuid: $uuid, name: $name, shareType: $shareType}';
}

/// Extract the sharees from the sharees xml
List<Sharee> shareesFromShareesXml(String xmlStr) {
  // parse the xml using the xml.XmlDocument.parse method
  final xmlDocument = xml.XmlDocument.parse(xmlStr);
  final usersElements = xmlDocument.findAllElements('element');
  return usersElements.map(shareeFromShareeXml).toList();
}

/// Extract a sharee from the sharee xml
Sharee shareeFromShareeXml(xml.XmlElement element) => Sharee(
      element.findAllElements('label').single.text,
      element.findAllElements('shareWith').single.text,
      (element.findAllElements('name').isNotEmpty
              ? element.findAllElements('name')
              : element.findAllElements('label'))
          .single
          .text,
      int.parse(element.findAllElements('shareType').single.text),
    );
