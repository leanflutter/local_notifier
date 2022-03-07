import 'dart:async';

import 'package:flutter/services.dart';

import 'local_notification.dart';

// typedef LocalNotificationHandler = void Function(
//     LocalNotification notification);

class LocalNotifier {
  LocalNotifier._() {
    _channel.setMethodCallHandler(_methodCallHandler);
  }

  /// The shared instance of [LocalNotifier].
  static final LocalNotifier instance = LocalNotifier._();

  final MethodChannel _channel = const MethodChannel('local_notifier');

  // List<LocalNotification> _notificationList = [];
  // Map<String, LocalNotificationHandler> _notificationHandlerMap = {};

  Future<void> _methodCallHandler(MethodCall call) async {
    print(call.method);
    print(call.arguments);
    if (call.method != 'onEvent') throw UnimplementedError();

    String eventName = call.arguments['eventName'];
    print(eventName);
  }

  /// Immediately shows the notification to the user.
  Future<void> notify(LocalNotification notification) async {
    final Map<String, dynamic> arguments = notification.toJson();
    await _channel.invokeMethod('notify', arguments);
  }
}
