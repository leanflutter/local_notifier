import 'package:uuid/uuid.dart';

class LocalNotification {
  String identifier = Uuid().v4();

  /// Representing the title of the notification.
  String title;

  /// Representing the subtitle of the notification.
  String? subtitle;

  /// Representing the body of the notification.
  String? body;

  /// Representing whether the notification is silent.
  bool silent;

  LocalNotification({
    String? identifier,
    required this.title,
    this.subtitle,
    this.body,
    this.silent = false,
  }) {
    if (identifier != null) {
      this.identifier = identifier;
    }
  }

  factory LocalNotification.fromJson(Map<String, dynamic> json) {
    return LocalNotification(
      identifier: json['identifier'],
      title: json['title'],
      subtitle: json['subtitle'],
      body: json['body'],
      silent: json['silent'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'identifier': identifier,
      'title': title,
      'subtitle': subtitle ?? '',
      'body': body ?? '',
      'silent': silent,
    }..removeWhere((key, value) => value == null);
  }
}
