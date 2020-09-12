import 'dart:convert';
import 'dart:io';

import 'package:nextcloud/nextcloud.dart';
import 'package:test/test.dart';

class Config {
  const Config({
    this.host,
    this.username,
    this.password,
    this.shareUser,
    this.testDir,
    this.image,
  });

  factory Config.fromJson(Map<String, dynamic> json) => Config(
      host: json['host'],
      username: json['username'],
      password: json['password'],
      shareUser: json['shareUser'],
      testDir: json['testDir'],
      image: json['image']);

  final String host;
  final String username;
  final String password;
  final String shareUser;
  final String testDir;
  final String image;
}

// TODO: add more tests
void main() {
  final config =
      Config.fromJson(json.decode(File('config.json').readAsStringSync()));
  final client = NextCloudClient(config.host, config.username, config.password);
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
        final client = NextCloudClient(
          url[0],
          config.username,
          config.password,
        );
        expect(client.baseUrl, equals(url[1]));
      }
    });
  });
  group('WebDav', () {
    test('Clean test environment', () async {
      expect(
          await (() async {
            try {
              await client.webDav.delete(config.testDir);
              // ignore: empty_catches
            } on RequestException catch (ex) {
              if (ex.statusCode != 404) {
                rethrow;
              }
            }
          })(),
          equals(null));
    });
    test('Create directory', () async {
      expect(
          (await client.webDav.mkdir(config.testDir)).statusCode, equals(201));
    });
    test('List directory', () async {
      expect((await client.webDav.ls(config.testDir)).length, equals(0));
    });
    test('Upload files', () async {
      expect(
          (await client.webDav.upload(
                  File('test/files/test.png').readAsBytesSync(),
                  '${config.testDir}/test.png'))
              .statusCode,
          equals(201));
      expect(
          (await client.webDav.upload(
                  File('test/files/test.txt').readAsBytesSync(),
                  '${config.testDir}/test.txt'))
              .statusCode,
          equals(201));
      final files = await client.webDav.ls(config.testDir);
      expect(files.length, equals(2));
      expect(files.singleWhere((f) => f.name == 'test.png', orElse: () => null),
          isNotNull);
      expect(files.singleWhere((f) => f.name == 'test.txt', orElse: () => null),
          isNotNull);
    });
    test('List directory with properties', () async {
      final startTime = DateTime.now()
          // lastmodified is second-precision only
          .subtract(Duration(seconds: 2));
      final path = '${config.testDir}/list-test.txt';
      final data = utf8.encode('WebDAV list-test');
      await client.webDav.upload(data, path);

      final files = await client.webDav.ls(config.testDir);
      final file = files.singleWhere((f) => f.name == 'list-test.txt');
      expect(file.isDirectory, false);
      expect(file.name, 'list-test.txt');
      expect(startTime.isBefore(file.lastModified), isTrue,
          reason: 'Expected $startTime < ${file.lastModified}');
      expect(file.mimeType, 'text/plain');
      expect(file.path, path);
      expect(file.shareTypes, []);
      expect(file.size, data.length);
    });
    test('Copy file', () async {
      expect(
          await client.webDav.copy(
            '${config.testDir}/test.txt',
            '${config.testDir}/test2.txt',
          ),
          null);
      final files = await client.webDav.ls(config.testDir);
      expect(files.where((f) => f.name == 'test.txt'), hasLength(1));
      expect(files.where((f) => f.name == 'test2.txt'), hasLength(1));
    });
    test('Move file', () async {
      expect(
          await client.webDav.move(
            '${config.testDir}/test2.txt',
            '${config.testDir}/test3.txt',
          ),
          null);
      final files = await client.webDav.ls(config.testDir);
      expect(files.where((f) => f.name == 'test2.txt'), isEmpty);
      expect(files.where((f) => f.name == 'test3.txt'), hasLength(1));
    });
  });
  group('Talk', () {
    test('Signaling', () async {
      expect(
        await client.talk.signalingManagement.getSettings(),
        isNotNull,
      );
    });
    test('Get conversations', () async {
      expect(await client.talk.conversationManagement.getUserConversations(),
          isNotEmpty);
    });
    String token;
    test('Create conversation', () async {
      token = await client.talk.conversationManagement
          .createConversation(ConversationType.group, name: 'Test-group');
      expect(
        token,
        isNotNull,
      );
    });
    test('Get conversation', () async {
      final conversation =
          await client.talk.conversationManagement.getConversation(token);
      expect(conversation, isNotNull);
      expect(conversation.displayName, isNotNull);
    });
    test('Rename conversation', () async {
      expect(
          await client.talk.conversationManagement.renameConversation(
            token,
            'Test-group-2',
          ),
          isNull);
    });
    test('Allow guests', () async {
      expect(
          await client.talk.conversationManagement.allowGuests(token), isNull);
    });
    test('Disallow guests', () async {
      expect(await client.talk.conversationManagement.disallowGuests(token),
          isNull);
    });
    test('Read-only', () async {
      expect(
        await client.talk.conversationManagement.setReadOnly(
          token,
          ReadOnlyState.readOnly,
        ),
        isNull,
      );
    });
    test('Read and write', () async {
      expect(
        await client.talk.conversationManagement.setReadOnly(
          token,
          ReadOnlyState.readWrite,
        ),
        isNull,
      );
    });
    test('Set favorite', () async {
      expect(
        await client.talk.conversationManagement
            .setConversationAsFavorite(token),
        isNull,
      );
    });
    test('Delete favorite', () async {
      expect(
        await client.talk.conversationManagement
            .deleteConversationAsFavorite(token),
        isNull,
      );
    });
    test('Set notifications', () async {
      expect(
        await client.talk.conversationManagement.setNotificationLevel(
          token,
          NotificationLevel.always,
        ),
        isNull,
      );
    });
    test('Get participants', () async {
      expect(
        (await client.talk.conversationManagement.getParticipants(token))
            .first
            .userId,
        equals(config.username),
      );
    });
    test('Add participant', () async {
      expect(
        await client.talk.conversationManagement
            .addParticipant(token, config.shareUser),
        isNull,
      );
    });
    test('Set moderator', () async {
      expect(
        await client.talk.conversationManagement
            .promoteUserToModerator(token, config.shareUser),
        isNull,
      );
      expect(
        await client.talk.conversationManagement
            .demoteUserFromModerator(token, config.shareUser),
        isNull,
      );
    });
    test('Get messages', () async {
      expect(
        await client.talk.messageManagement.getMessages(token),
        isNotNull,
      );
    });
    Message message;
    test('Send message', () async {
      message = await client.talk.messageManagement.sendMessage(
        token,
        'Test',
      );
      expect(
        message,
        isNotNull,
      );
    });
    test('Reply to message', () async {
      expect(
        await client.talk.messageManagement.sendMessage(
          token,
          'Test answere',
          replyTo: message.id,
        ),
        isNotNull,
      );
    });
    test('Mention user', () async {
      expect(
        await client.talk.messageManagement.getMentionSuggestions(
          message.token,
          config.shareUser.substring(0, 2),
        ),
        isNotEmpty,
      );
    });
    test('Delete participant', () async {
      expect(
        await client.talk.conversationManagement
            .deleteParticipant(token, config.shareUser),
        isNull,
      );
    });
    test('Delete conversation', () async {
      expect(await client.talk.conversationManagement.deleteConversation(token),
          isNull);
    });
  });
  group('Preview', () {
    test('Get preview', () async {
      expect(await client.preview.getPreview('/${config.image}', 64, 64),
          isNotNull);
    });
    test('Get preview stream', () async {
      expect(await client.preview.getPreviewStream('/${config.image}', 64, 64),
          isNotNull);
    });
    test('Get thumbnail', () async {
      expect(await client.preview.getThumbnail('/${config.image}', 64, 64),
          isNotNull);
    });
    test('Get thumbnail stream', () async {
      expect(
          await client.preview.getThumbnailStream('/${config.image}', 64, 64),
          isNotNull);
    });
  });
}
