import 'dart:convert';

import '../../nextcloud.dart';
import '../network.dart';

/// All the talk functions for messages management
class MessageManagement {
  // ignore: public_member_api_docs
  MessageManagement(Network network, String url) {
    _network = network;
    _baseUrl = url;
  }

  String _baseUrl;
  Network _network;

  String _getUrl(String path) => '$_baseUrl/$path';

  /// Get last messages
  ///
  /// The [max] messages count is default 100 and max 200
  ///
  /// There must be messages (304 error)
  ///
  /// When the lobby is active and the user is not a moderator a 412 error
  /// will be thrown.
  ///
  /// The [lastKnownMessageID] must be set to define a offset to get older messages.
  /// And if you want to receive the [lastKnownMessageID], too, the [includeLastKnownMessageId]
  /// must be set to true.
  ///
  /// The [automaticMarkRead] property sets if the fetched messages should
  /// marked as read, or the client does it by itself
  Future<List<Message>> getMessages(
    String token, {
    int max = 100,
    int lastKnownMessageID,
    bool automaticMarkRead = true,
    bool includeLastKnownMessageId = false,
  }) async {
    assert(max <= 200, 'The max count must not be more than 200 hundred!');

    final url = _getUrl('chat/$token?${Uri(queryParameters: {
      'lookIntoFuture': '0',
      if (max != null) 'limit': max.toString(),
      if (lastKnownMessageID != null)
        'lastKnownMessageId': lastKnownMessageID.toString(),
      if (automaticMarkRead != null)
        'setReadMarker': automaticMarkRead ? '1' : '0',
      if (includeLastKnownMessageId != null)
        'includeLastKnown': includeLastKnownMessageId ? '1' : '0',
    }).query}');
    print(url);
    final result = await _network.send(
      'GET',
      url,
      [200],
    );
    return json
        .decode(result.body)['ocs']['data']
        .map<Message>((json) => Message.fromJson(json))
        .toList();
  }

  /// Mark a chat as read
  Future markAsRead(String token, int lastReadMessageId) => _network.send(
        'POST',
        _getUrl('chat/$token/read?${Uri(queryParameters: {
          'lastReadMessage': lastReadMessageId.toString(),
        }).query}'),
        [200],
      );

  /// Get future messages
  ///
  /// The [max] messages count is default 100 and max 200
  ///
  /// There must be messages (304 error)
  ///
  /// When the lobby is active and the user is not a moderator a 412 error
  /// will be thrown.
  ///
  /// The [lastKnownMessageID] must be set to define a offset to get older messages.
  /// And if you want to receive the [lastKnownMessageID], too, the [includeLastKnownMessageId]
  /// must be set to true.
  ///
  /// The [automaticMarkRead] property sets if the fetched messages should
  /// marked as read, or the client do this by itself
  ///
  /// The [timeout] is default 30 seconds and max 60
  /// TODO: Complete this function
  Future waitForMessage(
    String token, {
    int max = 100,
    Duration timeout,
    int lastKnownMessageID,
    bool automaticMarkRead = true,
    bool includeLastKnownMessageId = false,
  }) async {
    assert(max <= 200, 'The max count must not be more than 200 hundred!');
    assert(timeout.inSeconds <= 60, 'The max timeout is 60 seconds!');
    assert(false,
        'This function does not work yet, please implement it and create a PR');

    final result = await _network.download(
      'GET',
      _getUrl('chat/$token?${Uri(queryParameters: {
        'lookIntoFuture': '1',
        if (timeout != null) 'timeout': timeout.inSeconds.toString(),
        if (max != null) 'limit': max.toString(),
        if (lastKnownMessageID != null)
          'lastKnownMessageId': lastKnownMessageID.toString(),
        if (automaticMarkRead != null)
          'setReadMarker': automaticMarkRead ? '1' : '0',
        if (includeLastKnownMessageId != null)
          'includeLastKnown': includeLastKnownMessageId ? '1' : '0',
      }).query}'),
      [200],
    );

    // ignore: prefer_foreach
    await for (final contents in result.stream.transform(Utf8Decoder())) {
      print(contents);
    }
  }

  /// Send new message
  ///
  /// The [guestDisplayName] is only for guest, for normal user the display
  /// name will be ignored
  ///
  /// The [replyTo] can only reply to messages in the same conversation and
  /// of the type [MessageType.comment]
  ///
  /// The conversation must not be read-only (403 error)
  ///
  /// The message must not be longer than the max length (32000 or 1000 characters,
  /// depends on the nextcloud version and configuration) (413 error)
  Future<Message> sendMessage(
    String token,
    String message, {
    String guestDisplayName,
    int replyTo,
  }) async {
    final result = await _network.send(
      'POST',
      _getUrl('chat/$token?${Uri(queryParameters: {
        'message': message,
        if (replyTo != null) 'replyTo': replyTo,
        if (guestDisplayName != null) 'actorDisplayName': guestDisplayName,
      }).query}'),
      [201],
    );
    return Message.fromJson(json.decode(result.body)['ocs']['data']);
  }

  /// Returns all possible mentions for the given [search] string
  ///
  /// Only in non read-only conversations (403 error)
  ///
  /// When the lobby is active and the user is not a moderator a 412 error
  /// will be thrown
  Future<List<Suggestion>> getMentionSuggestions(
    String token,
    String search, {
    int max = 20,
  }) async {
    assert(search.isNotEmpty, 'The search string must not be empty!');

    final result = await _network.send(
      'GET',
      _getUrl('chat/$token/mentions?${Uri(queryParameters: {
        'search': search,
        if (max != null) 'limit': max.toString(),
      }).query}'),
      [200],
    );
    return json
        .decode(result.body)['ocs']['data']
        .map<Suggestion>((json) => Suggestion.fromJson(json))
        .toList();
  }
}
