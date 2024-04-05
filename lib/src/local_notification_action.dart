class LocalNotificationAction {
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

  /// The type of action, can be button.
  String type;

  /// The label for the given action.
  String? text;

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'text': text,
    }..removeWhere((key, value) => value == null);
  }
}
