import 'dart:convert';
import 'dart:io';

import 'package:browser_launcher/browser_launcher.dart';
import 'package:crypton/crypton.dart';
import 'package:nextcloud/nextcloud.dart';
import 'package:test/test.dart';

import 'config.dart';

@Timeout(Duration(seconds: 60))
Future main() async {
  group('Login', () {
    test('Login flow works', () async {
      final config =
          Config.fromJson(json.decode(File('config.json').readAsStringSync()));
      var client = NextCloudClient.withoutLogin(config.host);
      final init = await client.login.initLoginFlow();
      await Chrome.start([init.login]);
      LoginFlowResult _result;
      while (_result == null) {
        try {
          _result = await client.login.pollLogin(init);
          client = NextCloudClient.withAppPassword(
            config.host,
            _result.appPassword,
          );
          final keypair = RSAKeypair.fromRandom();
          try {
            await client.notifications
                .registerDeviceAtServer(config.pushToken, keypair);
            // ignore: avoid_catches_without_on_clauses
          } catch (e, stacktrace) {
            print(e);
            print(stacktrace);
            break;
          }
          // ignore: empty_catches, avoid_catches_without_on_clauses
        } catch (e) {
          await Future.delayed(Duration(milliseconds: 500));
        }
      }
    });
  });
}
