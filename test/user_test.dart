import 'package:test/test.dart';

import 'config.dart';

void main() {
  final client = getClient();

  group('User', () {
    test('Get user data', () async {
      final userdata = await client.user.getUser();
      expect(userdata.id, equals(Config.username));
      expect(userdata.displayName, equals(Config.username));
      expect(userdata.email, equals(Config.email));
      expect(userdata.storageLocation, equals('/usr/src/nextcloud/data/admin'));
    });
  });
}
