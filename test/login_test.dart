import 'package:browser_launcher/browser_launcher.dart';
import 'package:nextcloud/nextcloud.dart';
import 'package:test/test.dart';

import 'config.dart';

void main() {
  group('Login', () {
    test('Login flow works', () async {
      var client = NextCloudClient.withoutLogin(Config.host);
      final init = await client.login.initLoginFlow();
      // Linux users might need to create a link: https://github.com/dart-lang/browser_launcher/issues/16
      await Chrome.start([init.login]);
      LoginFlowResult _result;
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
          await Future.delayed(Duration(milliseconds: 500));
        }
      }
    });
  });
}
