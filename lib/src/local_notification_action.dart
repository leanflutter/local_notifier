class LocalNotificationAction {
  /// The type of action, can be button.
  String type;

  /// The label for the given action.
  String? text;

  LocalNotificationAction({
    this.type = 'button',
    this.text,
  });

  factory LocalNotificationAction.fromJson(Map<String, dynamic> json) {
    return LocalNotificationAction(
      type: json['type'] as String,
      text: json['text'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'text': text,
    }..removeWhere((key, value) => value == null);
  }
}
