import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'local_notification_action.dart';
import 'local_notification_close_reason.dart';
import 'local_notification_listener.dart';
import 'local_notifier.dart';

class LocalNotification with LocalNotificationListener {
  String identifier = Uuid().v4();

  /// Representing the title of the notification.
  String title;

  /// Representing the subtitle of the notification.
  String? subtitle;

  /// Representing the body of the notification.
  String? body;

  /// Representing whether the notification is silent.
  bool silent;

  /// Representing the actions of the notification.
  List<LocalNotificationAction>? actions;

  VoidCallback? onShow;
  ValueChanged<LocalNotificationCloseReason>? onClose;
  VoidCallback? onClick;
  ValueChanged<int>? onClickAction;

  LocalNotification({
    String? identifier,
    required this.title,
    this.subtitle,
    this.body,
    this.silent = false,
    this.actions,
  }) {
    if (identifier != null) {
      this.identifier = identifier;
    }
    localNotifier.addListener(this);
  }

  factory LocalNotification.fromJson(Map<String, dynamic> json) {
    List<LocalNotificationAction>? actions;

    if (json['actions'] != null) {
      Iterable l = json['actions'] as List;
      actions =
          l.map((item) => LocalNotificationAction.fromJson(item)).toList();
    }

    return LocalNotification(
      identifier: json['identifier'],
      title: json['title'],
      subtitle: json['subtitle'],
      body: json['body'],
      silent: json['silent'],
      actions: actions,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'identifier': identifier,
      'title': title,
      'subtitle': subtitle ?? '',
      'body': body ?? '',
      'silent': silent,
      'actions': (actions ?? []).map((e) => e.toJson()).toList(),
    }..removeWhere((key, value) => value == null);
  }

  /// Immediately shows the notification to the user
  Future<void> show() {
    return localNotifier.notify(this);
  }

  /// Closes the notification immediately.
  Future<void> close() {
    return localNotifier.close(this);
  }

  /// Destroys the notification immediately.
  Future<void> destroy() {
    return localNotifier.destroy(this);
  }

  @override
  void onLocalNotificationShow(LocalNotification notification) {
    if (identifier != notification.identifier || onShow == null) {
      return;
    }
    onShow!();
  }

  @override
  void onLocalNotificationClose(
    LocalNotification notification,
    LocalNotificationCloseReason closeReason,
  ) {
    if (identifier != notification.identifier || onClose == null) {
      return;
    }
    onClose!(closeReason);
  }

  @override
  void onLocalNotificationClick(LocalNotification notification) {
    if (identifier != notification.identifier || onClick == null) {
      return;
    }
    onClick!();
  }

  @override
  void onLocalNotificationClickAction(
    LocalNotification notification,
    int actionIndex,
  ) {
    if (identifier != notification.identifier || onClickAction == null) {
      return;
    }
    onClickAction!(actionIndex);
  }
}
