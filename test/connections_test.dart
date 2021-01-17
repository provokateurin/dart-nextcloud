import 'package:nextcloud/nextcloud.dart';
import 'package:test/test.dart';

import 'config.dart';

void main() {
  final config = getConfig();

  group('Nextcloud connection', () {
    test('Different host urls', () {
      final urls = [
        [
          Uri.parse('http://cloud.test.com/'),
          'http://cloud.test.com',
        ],
        [
          Uri.parse('https://cloud.test.com:80/'),
          'https://cloud.test.com:80',
        ],
        [
          Uri(host: 'cloud.test.com'),
          'https://cloud.test.com',
        ],
        [
          Uri(host: 'cloud.test.com', port: 90),
          'https://cloud.test.com:90',
        ],
        [
          Uri(host: 'test.com', path: 'cloud'),
          'https://test.com/cloud',
        ],
        [
          Uri.parse('http://localhost:8081/nextcloud'),
          'http://localhost:8081/nextcloud',
        ],
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
