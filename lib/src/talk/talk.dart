T _toEnumValue<T>(List<T> values, int index, {int first = 1}) {
  if (index != null) {
    index -= first;
    return values[index];
  }
  return null;
}

List<String> _actors = ['guests', 'users', 'bots'];

ActorType _toActorType(String type) => ActorType.values[_actors.indexOf(type)];

/// All possible message types
enum MessageType {
  /// A user comment (A normal message)
  comment,

  /// A system message like creating conversation, etc.
  system,

  /// A command message (beginning with /command)
  command,
}

/// The to string function
extension MessageTypeExtension on MessageType {
  /// The string value
  String get value => toString().split('.')[1];
}

List<String> get _messageTypes =>
    MessageType.values.map((t) => t.value).toList();

/// The different sources for participants
enum ParticipantSource {
  /// The source is a single user id
  users,

  /// The source is a group id
  groups,

  /// The source is a email
  emails,

  /// The source is a circle id
  /// (Only with `circles-support`)
  circles,
}

/// The different sources for participants
extension ParticipantSourceExtension on ParticipantSource {
  /// The string value
  String get value => toString().split('.')[1];
}

/// The type of conversation
enum ConversationType {
  /// A simple one to one conversation
  oneToOne,

  /// A group conversation
  group,

  /// A conversation for all cloud users
  public,

  /// A conversation for updates of one moderator
  changelog,
}

/// The state of the user permission in a conversation
enum ReadOnlyState {
  /// A user can read and write in a conversation
  readWrite,

  /// A user only can read a conversation
  readOnly,
}

/// The type of the participant in a conversation
enum ParticipantType {
  /// The owner is the one who created the conversation
  owner,

  /// A moderator can be promoted or demoted from and to a user
  ///
  /// The moderator can organize the conversation
  moderator,

  /// The user can only write and read in the conversation
  user,

  /// The guest is a user without a user on the cloud, so he
  /// does not have a username and must be identified with the session id
  ///
  /// He can set his own display name and
  /// needs extra permissions to join conversations
  guest,

  /// Somebody who joined via a public link
  publicLink,

  /// Same as moderator, but as a guest
  guestAsModerator,
}

/// The notification level for a conversation
enum NotificationLevel {
  /// Get all notifications (One-to-one conversation default)
  always,

  /// Only when a user is mentioned (Except one-to-one default)
  mention,

  /// Do not get any notifications
  never
}

/// The different actor types of chat messages
enum ActorType {
  /// Non-cloud users
  guests,

  /// Cloud users
  users,

  /// Programmatically messages
  bots,
}

/// All possible user mention suggestion types
enum SuggestionType {
  // ignore: public_member_api_docs
  users,
  // ignore: public_member_api_docs
  guests,
  // ignore: public_member_api_docs
  calls,
}

/// The to string function
extension SuggestionTypeExtension on SuggestionType {
  /// The string value
  String get value => toString().split('.')[1];
}

List<String> get _suggestionTypes =>
    SuggestionType.values.map((t) => t.value).toList();

/// The different lobby states
enum LobbyState {
  /// There is no lobby
  noLobby,

  /// The lobby is only for moderators
  forModerators,
}

/// A cloud message
class Message {
  // ignore: public_member_api_docs
  Message({
    this.messageType,
    this.isReplyable,
    this.id,
    this.token,
    this.actorType,
    this.actorId,
    this.actorDisplayName,
    this.timestamp,
    this.message,
    this.messageParameters,
    this.systemMessage,
  });

  // ignore: public_member_api_docs
  factory Message.fromJson(Map<String, dynamic> json) => Message(
        id: json['id'],
        token: json['token'],
        actorType: _toActorType(json['actorType']),
        actorId: json['actorId'],
        actorDisplayName: json['actorDisplayName'],
        timestamp: DateTime.fromMillisecondsSinceEpoch(
          json['timestamp'] * 1000,
          isUtc: true,
        ),
        message: json['message'],
        messageParameters: json['messageParameters'],
        systemMessage: json['systemMessage'],
        messageType: json['messageType'] != null
            ? MessageType.values[_messageTypes.indexOf(json['messageType'])]
            : null,
        isReplyable: json['isReplyable'],
      );

  /// The message id
  final int id;

  /// The conversation token
  final String token;

  /// The actor type of the writer of this message
  final ActorType actorType;

  /// The actor id (The username)
  final String actorId;

  /// String actor display name
  final String actorDisplayName;

  /// The send time
  final DateTime timestamp;

  /// The content of this message
  ///
  /// The message is in [rich object string](https://github.com/nextcloud/server/issues/1706)
  final String message;

  /// The parameter for [rich object string](https://github.com/nextcloud/server/issues/1706)
  final dynamic messageParameters;

  /// If it was a system message like participant removing [systemMessage] will be
  /// the type of the system message
  /// otherwise it will be empty
  ///
  /// A list of [all possible types](https://nextcloud-talk.readthedocs.io/en/latest/chat/#system-messages)
  final String systemMessage;

  /// The message type (normal/system/command)
  final MessageType messageType;

  /// If a user can post a reply to this message
  /// (only available with `chat-replies` capability)
  final bool isReplyable;
}

/// A mention suggestion
class Suggestion {
  // ignore: public_member_api_docs
  Suggestion({this.id, this.displayName, this.type});

  // ignore: public_member_api_docs
  factory Suggestion.fromJson(Map<String, dynamic> json) => Suggestion(
        id: json['id'],
        displayName: json['label'],
        type: json['source'] != null
            ? SuggestionType.values[_suggestionTypes.indexOf(json['source'])]
            : null,
      );

  ///  The user id which should be sent as @<id>in the message
  ///  (user ids that contain spaces as well as guest ids need
  ///  to be wrapped in double-quotes when sending in a message:
  ///  @"space user" and @"guest/random-string")
  final String id;

  /// The display name of the user
  final String displayName;

  /// The type of the user
  final SuggestionType type;
}

/// A participant (Talk user)
class Participant {
  // ignore: public_member_api_docs
  Participant({
    this.userId,
    this.displayName,
    this.participantType,
    this.lastPing,
    this.sessionId,
  });

  // ignore: public_member_api_docs
  factory Participant.fromJson(Map<String, dynamic> json) => Participant(
        userId: json['userId'],
        displayName: json['displayName'],
        participantType: _toEnumValue(
          ParticipantType.values,
          json['participantType'],
        ),
        lastPing: DateTime.fromMillisecondsSinceEpoch(
          json['lastPing'] * 1000,
          isUtc: true,
        ),
        sessionId: json['sessionId'],
      );

  /// The id to identify the user in requests (The username id)
  final String userId;

  /// The display name of the user
  final String displayName;

  /// The type of user (For permissions and roles)
  final ParticipantType participantType;

  /// Last ping of the user (Should be used for sorting)
  final DateTime lastPing;

  /// If a user is connected, the session id is a 512 character long string,
  /// otherwise it is '0'
  final String sessionId;

  /// If the user is currently connected or not
  bool get isConnected => sessionId.length > 1;
}

/// A user conversation
class Conversation {
  // ignore: public_member_api_docs
  Conversation({
    this.token,
    this.type,
    this.name,
    this.displayName,
    this.participantType,
    this.readOnlyState,
    this.userCount,
    this.guestCount,
    this.lastPing,
    this.sessionId,
    this.hasPassword,
    this.hasCall,
    this.canStartCall,
    this.lastActivity,
    this.isFavorite,
    this.notificationLevel,
    this.lobbyState,
    this.unreadMessages,
    this.unreadMention,
    this.lastReadMessage,
    this.lastMessage,
    this.objectType,
    this.objectId,
  });

  // ignore: public_member_api_docs
  factory Conversation.fromJson(Map<String, dynamic> json) => Conversation(
        token: json['token'],
        type: _toEnumValue(
          ConversationType.values,
          json['type'],
        ),
        name: json['name'],
        displayName: json['displayName'],
        participantType: _toEnumValue(
          ParticipantType.values,
          json['participantType'],
        ),
        readOnlyState:
            _toEnumValue(ReadOnlyState.values, json['readOnly'], first: 0),
        userCount: json['count'],
        guestCount: json['numGuests'],
        lastPing: DateTime.fromMillisecondsSinceEpoch(
          json['lastPing'] * 1000,
          isUtc: true,
        ),
        sessionId: json['sessionId'],
        hasPassword: json['hasPassword'],
        hasCall: json['hasCall'],
        canStartCall: json['canStartCall'],
        lastActivity: DateTime.fromMillisecondsSinceEpoch(
          json['lastActivity'] * 1000,
          isUtc: true,
        ).toLocal(),
        isFavorite: json['isFavorite'],
        notificationLevel: _toEnumValue(
          NotificationLevel.values,
          json['notificationLevel'],
          first: 0,
        ),
        lobbyState: _toEnumValue(
          LobbyState.values,
          json['lobbyState'],
          first: 0,
        ),
        unreadMessages: json['unreadMessages'],
        unreadMention: json['unreadMention'],
        lastReadMessage: json['lastReadMessage'],
        lastMessage: Message.fromJson(json['lastMessage']),
        objectType: json['objectType'],
        objectId: json['objectId'],
      );

  /// The conversation token
  ///
  /// The token is used to identify the conversation in the talk api
  final String token;

  /// If the conversation is user-to-user or other
  final ConversationType type;

  /// The internal conversation name (Must not be set)
  final String name;

  /// The human display name of the conversation
  final String displayName;

  /// The participant type of the current user
  final ParticipantType participantType;

  /// The current user permissions
  final ReadOnlyState readOnlyState;

  /// The count of active users
  final int userCount;

  /// The number of active guests
  final int guestCount;

  /// The timestamp of the last interaction with the conversation
  ///
  /// This attribute should be used for conversation sorting
  final DateTime lastPing;

  /// A 512 character long session id if connected, otherwise '0'
  final String sessionId;

  /// If the conversation has a password
  final bool hasPassword;

  /// If there is an active call
  final bool hasCall;

  /// If a user can start a new call in this conversation
  final bool canStartCall;

  /// The last user activity in this conversation
  final DateTime lastActivity;

  /// If the conversation is marked as favorite
  final bool isFavorite;

  /// The notification level of this conversation
  final NotificationLevel notificationLevel;

  /// If this conversation is a lobby or not
  ///
  /// Only available with `webinary-lobby` capability
  final LobbyState lobbyState;

  /// Number of unread chat messages in the conversation
  /// (only available with chat-v2 capability)
  final int unreadMessages;

  /// If a user was mentioned since the last visit
  final bool unreadMention;

  /// ID of the last read message in a room
  /// (only available with chat-read-marker capability)
  final int lastReadMessage;

  /// The last message in this conversation
  ///
  /// `null` if not available
  final Message lastMessage;

  /// The type of object that the conversation is associated with;
  /// "share:password" if the conversation is used to request a password for a share,
  /// otherwise empty
  final String objectType;

  /// Share token if "objectType" is "share:password", otherwise empty
  final String objectId;
}

/// The user talk room
class Room {
  // ignore: public_member_api_docs
  Room(this.conversations);

  // ignore: public_member_api_docs
  factory Room.fromJson(List<dynamic> json) => Room(
        json.map<Conversation>((e) => Conversation.fromJson(e)).toList(),
      );

  /// All user conversations
  List<Conversation> conversations;
}

/// All settings for the signaling server
class SignalingSettings {
  // ignore: public_member_api_docs
  SignalingSettings({
    this.ticket,
    this.externalSignalingServerAddress,
    this.stunServerAddresses,
    this.turnServers,
  });

  // ignore: public_member_api_docs
  factory SignalingSettings.fromJson(Map<String, dynamic> json) =>
      SignalingSettings(
        ticket: json['ticket'],
        externalSignalingServerAddress:
            json['server'].toString() == '[]' ? null : json['server'],
        stunServerAddresses: json['stunservers']
            .map<String>((i) => i['url'].toString())
            .toList(),
        turnServers: json['turnservers'],
      );

  /// The ticket for the external signaling server
  final String ticket;

  /// The url to an external signaling server
  final String externalSignalingServerAddress;

  /// The urls to the STUN servers
  final List<String> stunServerAddresses;

  /// All TURN servers
  ///
  /// Not implemented yet
  final List<dynamic> turnServers;
}
