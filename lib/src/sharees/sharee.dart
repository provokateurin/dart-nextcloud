import 'package:xml/xml.dart' as xml;

/// Sharee class
class Sharee {
  // ignore: public_member_api_docs
  Sharee(
    this.label,
    this.uuid,
    this.name,
  );

  // ignore: public_member_api_docs
  final String label;

  // ignore: public_member_api_docs
  final String uuid;

  // ignore: public_member_api_docs
  final String name;

  @override
  String toString() => 'Sharee{label: $label, uuid: $uuid, name: $name}';
}

/// Extract the sharees from the sharees xml
List<Sharee> shareesFromShareesXml(String xmlStr) {
  // parse the xml using the xml.parse method
  final xmlDocument = xml.parse(xmlStr);
  final usersElements = xmlDocument.findAllElements('element');
  return usersElements.map(shareeFromShareeXml).toList().cast<Sharee>();
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
    );
