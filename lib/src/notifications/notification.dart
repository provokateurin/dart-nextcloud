/// A notification
class Notification {
  // ignore: public_member_api_docs
  Notification({
    this.id,
    this.app,
    this.user,
    this.datetime,
    this.objectType,
    this.objectId,
    this.subject,
    this.subjectRich,
    this.subjectRichParameters,
    this.message,
    this.messageRich,
    this.messageRichParameters,
    this.link,
    this.icon,
    this.actions,
  });

  // ignore: public_member_api_docs
  factory Notification.fromJson(Map<String, dynamic> json) => Notification(
        id: json['notification_id'],
        app: json['app'],
        user: json['user'],
        datetime: DateTime.parse(json['datetime']).toLocal(),
        objectType: json['object_type'],
        objectId: json['object_id'],
        subject: json['subject'],
        subjectRich: json['subjectRich'],
        subjectRichParameters:
            json['subjectRichParameters'].cast<String, Map<String, dynamic>>(),
        message: json['message'],
        messageRich: json['messageRich'],
        messageRichParameters: json['messageRichParameters'].cast<dynamic>(),
        link: json['link'],
        icon: json['icon'],
        actions: json['actions']
            .map<NotificationAction>((a) => NotificationAction.fromJson(a))
            .toList(),
      );

  /// ID if the notification
  final int id;

  /// Name of the app
  final String app;

  /// ID of the user this notifications is for
  final String user;

  /// Date time of when the notification was published
  final DateTime datetime;

  /// Type of the object the notification is about
  final String objectType;

  /// ID of the object the notification is about
  final String objectId;

  /// Short subject that should be presented to the user
  final String subject;

  /// Subject with placeholders
  final String subjectRich;

  /// Subject parameters for [subjectRich]
  final Map<String, Map<String, dynamic>> subjectRichParameters;

  /// Long message that should be presented to the user
  final String message;

  /// Message with placeholders
  final String messageRich;

  /// Message parameters for [subjectRich]
  final List<dynamic> messageRichParameters;

  /// Link that should be followed when clicking on the notification
  final String link;

  /// Icon to display next to the notification
  final String icon;

  /// List of possible actions
  final List<NotificationAction> actions;
}

/// Actions to display as response to the notification
class NotificationAction {
  // ignore: public_member_api_docs
  NotificationAction({
    this.label,
    this.link,
    this.type,
    this.primary,
  });

  // ignore: public_member_api_docs
  factory NotificationAction.fromJson(Map<String, dynamic> json) =>
      NotificationAction(
        label: json['label'],
        link: json['link'],
        type: json['type'],
        primary: json['primary'],
      );

  /// Label of the button that should be presented
  final String label;

  /// Link that should be followed when clicking on the button
  final String link;

  /// HTTP method to request against the link
  final String type;

  /// Whether the action is the primary action for the notification
  final bool primary;
}
