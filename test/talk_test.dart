import 'package:nextcloud/nextcloud.dart';
import 'package:test/test.dart';

import 'config.dart';

void main() {
  final config = getConfig();
  final client = getClient(config);

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
          'Test answer',
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
}
