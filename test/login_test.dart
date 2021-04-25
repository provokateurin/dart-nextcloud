import 'dart:io';

import 'package:nextcloud/nextcloud.dart';
import 'package:test/test.dart';

import 'config.dart';

void main() {
  group('Login', () {
    test('Login with email works', () async {
      final client = NextCloudClient.withCredentials(
        Config.host,
        Config.email,
        Config.password,
      );
      final userdata = await client.user.getUser();
      expect(userdata.id, equals(Config.username));
    });
    // We need to skip this test on CI, because it can't work
    if (Platform.environment['NONINTERACTIVE'] == null ||
        Platform.environment['NONINTERACTIVE']!.isEmpty) {
      test('Login flow works', () async {
        var client = NextCloudClient.withoutLogin(
          Config.host,
          defaultHeaders: {HttpHeaders.userAgentHeader: 'dart-nextcloud'},
        );
        final init = await client.login.initLoginFlow();
        print(
          "Please open ${init.login} and login as '${Config.username}' with '${Config.password}'",
        );
        LoginFlowResult? _result;
        while (_result == null) {
          try {
            _result = await client.login.pollLogin(init);
            client = NextCloudClient.withAppPassword(
              Config.host,
              _result.appPassword,
            );
            try {
              await client.user.getUser();
              // ignore: avoid_catches_without_on_clauses
            } catch (e, stacktrace) {
              print(e);
              print(stacktrace);
              fail('Could not read from server after connection!');
            }
            // ignore: empty_catches, avoid_catches_without_on_clauses
          } catch (e) {
            await Future.delayed(const Duration(milliseconds: 500));
          }
        }
      });
    }
  });
}
