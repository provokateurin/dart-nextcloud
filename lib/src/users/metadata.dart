/// MetaData class
class MetaData {
  // ignore: public_member_api_docs
  MetaData(
    this.fullName,
    this.groups,
  );

  // ignore: public_member_api_docs
  factory MetaData.fromJson(Map<String, dynamic> json) => MetaData(
        json['ocs']['data']['displayname'],
        json['ocs']['data']['groups'].cast<String>(),
      );

  // ignore: public_member_api_docs
  final String fullName;

  // ignore: public_member_api_docs
  final List<String> groups;

  @override
  String toString() => 'MetaData{fullName: $fullName ,groups: $groups}}';
}
