import 'local_notification_close_reason.dart';
import 'local_notification.dart';

abstract class LocalNotificationListener {
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
