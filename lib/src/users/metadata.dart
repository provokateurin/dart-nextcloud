/// MetaData class
class MetaData {
  // ignore: public_member_api_docs
  MetaData(
    this.fullName,
    this.groups,
  );

  // ignore: public_member_api_docs
  factory MetaData.fromJson(Map<String, dynamic> json) => MetaData(
        json['ocs']['data']['displayname'] as String,
        json['ocs']['data']['groups'] as List<String>,
      );

  // ignore: public_member_api_docs
  final String fullName;

  // ignore: public_member_api_docs
  final List<String> groups;

  @override
  String toString() => 'MetaData{fullName: $fullName ,groups: $groups}}';
}
