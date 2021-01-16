// ignore: public_member_api_docs
class UserData {
  // ignore: public_member_api_docs
  UserData(
    this.id,
    this.displayName,
    this.email,
    this.storageLocation,
  );

  // ignore: public_member_api_docs
  factory UserData.fromJson(Map<String, dynamic> json) => UserData(
        json['ocs']['data']['id'],
        json['ocs']['data']['display-name'],
        json['ocs']['data']['email'],
        json['ocs']['data']['storageLocation'],
      );

  // ignore: public_member_api_docs
  final String id;
  // ignore: public_member_api_docs
  final String displayName;
  // ignore: public_member_api_docs
  final String storageLocation;
  // ignore: public_member_api_docs
  final String email;

  @override
  String toString() => 'UserData{id: $id, displayName: $displayName}}';
}
