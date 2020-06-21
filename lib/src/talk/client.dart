import '../../nextcloud.dart';
import '../network.dart';

/// The Nextcloud talk client
class TalkClient {
  // ignore: public_member_api_docs
  TalkClient(
    String baseUrl,
    Network _network,
  ) {
    final _baseUrl = '$baseUrl/ocs/v2.php/apps/spreed/api/v1';
    _conversationManagement = ConversationManagement(_network, _baseUrl);
    _guestManagement = GuestManagement(_network, _baseUrl);
    _messageManagement = MessageManagement(_network, _baseUrl);
    _signalingManagement = SignalingManagement(_network, _baseUrl);
  }

  ConversationManagement _conversationManagement;
  GuestManagement _guestManagement;
  SignalingManagement _signalingManagement;
  MessageManagement _messageManagement;

  /// ALl management option for talk conversations
  ConversationManagement get conversationManagement => _conversationManagement;

  /// ALl management option for talk guests
  GuestManagement get guestManagement => _guestManagement;

  /// All management option to get updates about all types of changes
  SignalingManagement get signalingManagement => _signalingManagement;

  /// ALl management option for talk messages
  MessageManagement get messageManagement => _messageManagement;
}
