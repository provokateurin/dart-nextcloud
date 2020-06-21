import 'dart:convert';

import '../../nextcloud.dart';
import '../network.dart';

/// All the talk functions for conversation management
class ConversationManagement {
  // ignore: public_member_api_docs
  ConversationManagement(Network network, String url) {
    _network = network;
    _baseUrl = url;
  }

  String _baseUrl;
  Network _network;

  String _getUrl(String path) => '$_baseUrl/$path';

  /// Returns all conversations of the current user
  Future<List<Conversation>> getUserConversations() async {
    final result = await _network.send('GET', _getUrl('room'), [200]);
    return Room.fromJson(json.decode(result.body)['ocs']['data']).conversations;
  }

  /// Creates a new conversation of the given [type] and returns the created conversation token
  ///
  /// For a [ConversationType.oneToOne] conversation is a user id as [invite] parameter required,
  /// otherwise the [invite] parameter can be a group id (for [ConversationType.group]) or
  /// if `circles-support` is enabled a circle id
  ///
  /// The [source] for the invite,
  /// only supported on [ConversationType.group] for groups and circles
  /// (only available with circles-support capability)
  ///
  /// The [name] is the conversation name (Not available for [ConversationType.oneToOne])
  Future<String> createConversation(
    ConversationType type, {
    String invite,
    ParticipantSource source = ParticipantSource.users,
    String name,
  }) async {
    assert(
      type != ConversationType.changelog || name == null,
      'Name must be set when creating a changelog!',
    );
    assert(
      type != ConversationType.oneToOne || name == null,
      'Name cannot be set in a user-to-user chat!',
    );
    assert(
      type != ConversationType.oneToOne || invite != null,
      'A user-to-user conversation always needs a user to invite!',
    );

    final result = await _network.send(
      'POST',
      _getUrl('room'),
      [200, 201],
      data: utf8.encode(json.encode({
        'roomType': type.index + 1,
        'invite': invite,
        'source': source.value,
        'roomName': name,
      })),
    );
    return json.decode(result.body)['ocs']['data']['token'];
  }

  /// Returns a single [Conversation] with the given [token]
  ///
  /// This is also possible for guest users
  Future<Conversation> getConversation(String token) async {
    final result = await _network.send('GET', _getUrl('room/$token'), [200]);
    return Conversation.fromJson(json.decode(result.body)['ocs']['data']);
  }

  /// Renames the [Conversation] with the given [token] to the given [name]
  ///
  /// The function will have an 400 status code if the name is too long, empty or
  /// the conversation is of the type [ConversationType.oneToOne]
  /// and an 403 status code if the user is not allowed to rename the conversation
  Future renameConversation(String token, String name) async {
    await _network.send(
      'PUT',
      _getUrl('room/$token'),
      [200],
      data: utf8.encode(json.encode({
        'roomName': name,
      })),
    );
  }

  /// Deletes the [Conversation] with the given [token]
  ///
  /// This cannot be used to delete [ConversationType.oneToOne] conversations,
  /// because them must be left and not deleted (This will throw and 400 error)
  ///
  /// If the user has not the permissions to delete the conversation a 403 error
  /// will be thrown
  Future deleteConversation(String token) async {
    await _network.send(
      'DELETE',
      _getUrl('room/$token'),
      [200],
    );
  }

  /// Add the [Conversation] with the given [token] to the favorites
  ///
  /// Only non guests can do this (401 error)
  Future setConversationAsFavorite(String token) async {
    await _network.send(
      'POST',
      _getUrl('room/$token/favorite'),
      [200],
    );
  }

  /// Delete the [Conversation] with the given [token] from the favorites
  ///
  /// Only non guests can do this (401 error)
  Future deleteConversationAsFavorite(String token) async {
    await _network.send(
      'DELETE',
      _getUrl('room/$token/favorite'),
      [200],
    );
  }

  /// Allow guests to join the conversation
  ///
  /// Only for non one-to-one conversations (400 error)
  ///
  /// The user have to be the moderator/owner otherwise a 403 error will be thrown
  Future allowGuests(String token) async {
    await _network.send(
      'POST',
      _getUrl('room/$token/public'),
      [200],
    );
  }

  /// Disallow guests to join the conversation
  ///
  /// Only for public conversations (400 error)
  ///
  /// The user have to be the moderator/owner otherwise a 403 error will be thrown
  Future disallowGuests(String token) async {
    await _network.send(
      'DELETE',
      _getUrl('room/$token/public'),
      [200],
    );
  }

  /// Allow guests to join the conversation
  ///
  /// The conversation must be a group or public (400 error)
  ///
  /// The user have to be the moderator/owner and the conversation must be public
  /// otherwise a 403 error will be thrown
  Future setReadOnly(String token, ReadOnlyState state) async {
    await _network.send(
      'PUT',
      _getUrl('room/$token/read-only'),
      [200],
      data: utf8.encode(json.encode({
        'state': state.index,
      })),
    );
  }

  /// Allow guests to join the conversation
  ///
  /// The user have to be the moderator/owner and the conversation must be public
  /// otherwise a 403 error will be thrown
  Future setPassword(String token, String password) async {
    await _network.send(
      'PUT',
      _getUrl('room/$token/password'),
      [200],
      data: utf8.encode(json.encode({
        'password': password,
      })),
    );
  }

  /// Set the notification level for a conversation
  ///
  /// This can only do non-guests (401 error)
  Future setNotificationLevel(String token, NotificationLevel level) async {
    await _network.send(
      'POST',
      _getUrl('room/$token/notify'),
      [200],
      data: utf8.encode(json.encode({
        'level': level.index,
      })),
    );
  }

  /// Returns all participants in a conversation
  ///
  /// This can only do non-guests (403 error)
  Future<List<Participant>> getParticipants(String token) async {
    final result = await _network.send(
      'GET',
      _getUrl('room/$token/participants'),
      [200],
    );
    return json
        .decode(result.body)['ocs']['data']
        .map<Participant>((json) => Participant.fromJson(json))
        .toList();
  }

  /// Add a participant to a conversation
  ///
  /// The [participant] can be the user id, a email address or circle id
  ///
  /// The [source] of the participant as returned by the autocomplete
  /// suggestion endpoint (default is users) (All: users, groups, emails, circles)
  ///
  /// This can only do moderators/owners (403 error)
  ///
  /// In case that the participant or the conversation is not found a 404 error
  /// will be thrown
  Future addParticipant(
    String token,
    String participant, {
    ParticipantSource source = ParticipantSource.users,
  }) async {
    await _network.send(
      'POST',
      _getUrl('room/$token/participants'),
      [200],
      data: utf8.encode(json.encode({
        'newParticipant': participant,
        'source': source.value,
      })),
    );
  }

  /// Delete a participant from a conversation
  ///
  /// Only non moderator or owner can be deleted from a conversation
  /// and there must be at least one owner or moderator left (400/403 error)
  ///
  /// The [participant] must be a user
  Future deleteParticipant(String token, String participant) async {
    await _network.send(
      'DELETE',
      _getUrl('room/$token/participants'),
      [200],
      data: utf8.encode(json.encode({
        'participant': participant,
      })),
    );
  }

  /// Leave a conversation
  ///
  /// There must be at least one owner or moderator left (400 error)
  Future leaveConversation(String token) async {
    await _network.send(
      'DELETE',
      _getUrl('room/$token/participants/self'),
      [200],
    );
  }

  /// Join a conversation (For chats and calls)
  ///
  /// The [password] must only be set when the user is [ParticipantType.guest]
  /// or [ParticipantType.publicLink] and the conversation has a password
  /// (403 error)
  ///
  /// The function returns the session id after joining a conversation
  Future<String> joinConversation(String token, {String password}) async {
    final result = await _network.send(
      'POST',
      _getUrl('room/$token/participants/active'),
      [200],
      data: utf8.encode(json.encode({
        'password': password,
      })),
    );
    return json.decode(result.body)['ocs']['data']['sessionId'];
  }

  /// Removes a guest from a conversation
  ///
  /// The [sessionId] of the guest, because guests are no cloud users and do not
  /// have a username to identify
  ///
  /// The function returns the session id after joining a conversation
  Future removeGuest(String token, String sessionId) async {
    await _network.send(
      'DELETE',
      _getUrl('room/$token/participants/guests'),
      [200],
      data: utf8.encode(json.encode({
        'participant': sessionId,
      })),
    );
  }

  /// Promote a user to moderator
  ///
  /// The [participant] have to be of the type [ParticipantType.user] (400 error)
  ///
  /// This can only do owners/moderators (403 error)
  Future promoteUserToModerator(String token, String participant) async {
    await _network.send(
      'POST',
      _getUrl('room/$token/moderators'),
      [200],
      data: utf8.encode(json.encode({
        'participant': participant,
      })),
    );
  }

  /// Promote a user to moderator
  ///
  /// The user with the [sessionId] have to be of the type [ParticipantType.guest] (400 error)
  ///
  /// This can only do owners/moderators (403 error)
  Future promoteGuestToModerator(String token, String sessionId) async {
    await _network.send(
      'POST',
      _getUrl('room/$token/moderators'),
      [200],
      data: utf8.encode(json.encode({
        'sessionId': sessionId,
      })),
    );
  }

  /// Demote a user from moderator
  ///
  /// The [participant] have to be of the type [ParticipantType.moderator] (400 error)
  ///
  /// This can only do owners/moderators (403 error)
  Future demoteUserFromModerator(String token, String participant) async {
    await _network.send(
      'DELETE',
      _getUrl('room/$token/moderators'),
      [200],
      data: utf8.encode(json.encode({
        'participant': participant,
      })),
    );
  }

  /// Demote a user from moderator
  ///
  /// The user with the [sessionId] have to be of the type [ParticipantType.guestAsModerator]
  /// (400 error)
  ///
  /// This can only do owners/moderators (403 error)
  Future demoteGuestFromModerator(String token, String sessionId) async {
    await _network.send(
      'DELETE',
      _getUrl('room/$token/moderators'),
      [200],
      data: utf8.encode(json.encode({
        'sessionId': sessionId,
      })),
    );
  }

  /// Returns a conversation token for a given [fileId]
  ///
  /// The file must be visible for more than one person (error 404)
  Future<String> getFileConversation(String fileId) async {
    final result = await _network.send(
      'GET',
      _getUrl('file/$fileId'),
      [200],
      data: utf8.encode(json.encode({
        'fileId': fileId,
      })),
    );
    return json.decode(result.body)['ocs']['data']['token'];
  }

  /// Returns a conversation token for a given [shareToken]
  ///
  /// The file must be visible for more than one person (error 404)
  Future<String> getPublicShareConversation(String shareToken) async {
    final result = await _network.send(
      'GET',
      _getUrl('publicshare/$shareToken'),
      [200],
      data: utf8.encode(json.encode({
        'shareToken': shareToken,
      })),
    );
    return json.decode(result.body)['ocs']['data']['token'];
  }
}
