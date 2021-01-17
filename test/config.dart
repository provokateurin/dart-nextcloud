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
    this.email,
    this.storageLocation,
  });

  factory Config.fromJson(Map<String, dynamic> json) => Config(
        host: Uri.parse(json['host']),
        username: json['username'],
        password: json['password'],
        shareUser: json['shareUser'],
        // normalised path (remove trailing slash)
        testDir: json['testDir'].endsWith('/')
            ? json['testDir'].substring(0, json['testDir'].length - 1)
            : json['testDir'],
        email: json['email'],
        storageLocation: json['storageLocation'],
      );

  final Uri host;
  final String username;
  final String password;
  final String shareUser;
  final String testDir;
  final String email;
  final String storageLocation;
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
