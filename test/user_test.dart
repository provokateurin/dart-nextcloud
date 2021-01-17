import 'package:test/test.dart';

import 'config.dart';

void main() {
  final config = getConfig();
  final client = getClient(config);

  group('User', () {
    test('Get user data', () async {
      final userdata = await client.user.getUser();
      expect(userdata.id, equals(config.username));
      expect(userdata.displayName, equals(config.username));
      expect(userdata.email, equals(config.email));
      expect(userdata.storageLocation, equals(config.storageLocation));
    });
  });
}
