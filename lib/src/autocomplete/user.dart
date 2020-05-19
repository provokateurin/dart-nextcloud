// ignore: public_member_api_docs
class User {
  // ignore: public_member_api_docs
  User(this.id, this.label);

  // ignore: public_member_api_docs
  factory User.fromJson(Map<String, dynamic> json) => User(
        json['id'],
        json['label'],
      );

  // ignore: public_member_api_docs
  final String id;

  // ignore: public_member_api_docs
  final String label;
}
