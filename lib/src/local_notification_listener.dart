import 'package:local_notifier/src/local_notification.dart';
import 'package:local_notifier/src/local_notification_close_reason.dart';

abstract mixin class LocalNotificationListener {
  void onLocalNotificationShow(LocalNotification notification) {}
  void onLocalNotificationClose(
    LocalNotification notification,
    LocalNotificationCloseReason closeReason,
  ) {}
  void onLocalNotificationClick(LocalNotification notification) {}
  void onLocalNotificationClickAction(
    LocalNotification notification,
    int actionIndex,
  ) {}
}
