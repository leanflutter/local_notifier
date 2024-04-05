import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'local_notification.dart';
import 'local_notification_close_reason.dart';
import 'local_notification_listener.dart';
import 'shortcut_policy.dart';

class LocalNotifier {
  LocalNotifier._() {
    _channel.setMethodCallHandler(_methodCallHandler);
  }

  /// The shared instance of [LocalNotifier].
  static final LocalNotifier instance = LocalNotifier._();

  final MethodChannel _channel = const MethodChannel('local_notifier');

  final ObserverList<LocalNotificationListener> _listeners =
      ObserverList<LocalNotificationListener>();

  bool _isInitialized = false;
  String? _appName;
  Map<String, LocalNotification> _notifications = {};

  Future<void> _methodCallHandler(MethodCall call) async {
    String notificationId = call.arguments['notificationId'] as String;
    LocalNotification? localNotification = _notifications[notificationId];

    for (final LocalNotificationListener listener in listeners) {
      if (!_listeners.contains(listener)) {
        return;
      }

      if (call.method == 'onLocalNotificationShow') {
        listener.onLocalNotificationShow(localNotification!);
      } else if (call.method == 'onLocalNotificationClose') {
        LocalNotificationCloseReason closeReason =
            LocalNotificationCloseReason.values.firstWhere(
          (e) => e.name == call.arguments['closeReason'],
          orElse: () => LocalNotificationCloseReason.unknown,
        );
        listener.onLocalNotificationClose(
          localNotification!,
          closeReason,
        );
      } else if (call.method == 'onLocalNotificationClick') {
        listener.onLocalNotificationClick(localNotification!);
      } else if (call.method == 'onLocalNotificationClickAction') {
        int actionIndex = call.arguments['actionIndex'] as int;
        listener.onLocalNotificationClickAction(
          localNotification!,
          actionIndex,
        );
      } else {
        throw UnimplementedError();
      }
    }
  }

  List<LocalNotificationListener> get listeners {
    final List<LocalNotificationListener> localListeners =
        List<LocalNotificationListener>.from(_listeners);
    return localListeners;
  }

  bool get hasListeners {
    return _listeners.isNotEmpty;
  }

  void addListener(LocalNotificationListener listener) {
    _listeners.add(listener);
  }

  void removeListener(LocalNotificationListener listener) {
    _listeners.remove(listener);
  }

  Future<void> setup({
    required String appName,
    ShortcutPolicy shortcutPolicy = ShortcutPolicy.requireCreate,
  }) async {
    final Map<String, dynamic> arguments = {
      'appName': appName,
      'shortcutPolicy': shortcutPolicy.name,
    };
    if (Platform.isWindows) {
      _isInitialized = await _channel.invokeMethod('setup', arguments) as bool;
    } else {
      _isInitialized = true;
    }
    _appName = appName;
  }

  /// Immediately shows the notification to the user.
  Future<void> notify(LocalNotification notification) async {
    if ((Platform.isLinux || Platform.isWindows) && !_isInitialized) {
      throw Exception(
        'Not initialized, please call `localNotifier.setup` first to initialize',
      );
    }

    _notifications[notification.identifier] = notification;

    final Map<String, dynamic> arguments = notification.toJson();
    arguments['appName'] = _appName;
    await _channel.invokeMethod('notify', arguments);
  }

  /// Closes the notification immediately.
  Future<void> close(LocalNotification notification) async {
    final Map<String, dynamic> arguments = notification.toJson();
    await _channel.invokeMethod('close', arguments);
  }

  /// Destroys the notification immediately.
  Future<void> destroy(LocalNotification notification) async {
    await close(notification);
    removeListener(notification);
    _notifications.remove(notification.identifier);
  }
}

final localNotifier = LocalNotifier.instance;
