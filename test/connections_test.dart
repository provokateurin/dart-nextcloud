import 'package:nextcloud/nextcloud.dart';
import 'package:test/test.dart';

import 'config.dart';

@Timeout(Duration(seconds: 60))
void main() {
  final config = getConfig();
  group('Nextcloud connection', () {
    test('Different host urls', () {
      final urls = [
        ['http://cloud.test.com/index.php/123', 'http://cloud.test.com'],
        [
          'https://cloud.test.com:80/index.php/123',
          'https://cloud.test.com:80'
        ],
        ['cloud.test.com', 'https://cloud.test.com'],
        ['cloud.test.com:90', 'https://cloud.test.com:90'],
        ['test.com/cloud', 'https://test.com/cloud'],
        ['test.com/cloud/index.php/any/path', 'https://test.com/cloud'],
        ['http://localhost:8081/nextcloud', 'http://localhost:8081/nextcloud'],
      ];

      for (final url in urls) {
        final client = NextCloudClient.withCredentials(
          url[0],
          config.username,
          config.password,
        );
        expect(client.baseUrl, equals(url[1]));
      }
    });
  });
}
