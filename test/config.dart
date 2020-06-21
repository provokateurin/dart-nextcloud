import 'dart:convert';
import 'dart:io';

import 'package:nextcloud/nextcloud.dart';

class Config {
  const Config({
    this.host,
    this.username,
    this.password,
    this.shareUser,
    this.testDir,
    this.pushToken,
  });

  factory Config.fromJson(Map<String, dynamic> json) => Config(
        host: json['host'],
        username: json['username'],
        password: json['password'],
        shareUser: json['shareUser'],
        // normalised path (remove trailing slash)
        testDir: json['testDir'].endsWith('/')
            ? json['testDir'].substring(0, json['testDir'].length - 1)
            : json['testDir'],
        pushToken: json['pushToken'],
      );

  final String host;
  final String username;
  final String password;
  final String shareUser;
  final String testDir;
  final String pushToken;
}

Config getConfig() =>
    Config.fromJson(json.decode(File('config.json').readAsStringSync()));

NextCloudClient getClient(Config config) => NextCloudClient.withCredentials(
      config.host,
      config.username,
      config.password,
    );

void main() {
  // Stub
}
