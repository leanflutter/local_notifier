import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart' hide MenuItem;
import 'package:preference_list/preference_list.dart';
import 'package:local_notifier/local_notifier.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TrayListener {
  LocalNotification? _exampleNotification = LocalNotification(
    identifier: '_exampleNotification',
    title: "example",
    body: "hello flutter!",
    actions: [
      LocalNotificationAction(
        text: 'Yes',
      ),
      LocalNotificationAction(
        text: 'No',
      ),
    ],
  );

  List<LocalNotification> _notificationList = [];

  @override
  void initState() {
    trayManager.addListener(this);
    super.initState();

    _initTray();

    _exampleNotification?.onShow = () {
      print('onShow ${_exampleNotification?.identifier}');
    };
    _exampleNotification?.onClose = (closeReason) {
      switch (closeReason) {
        case LocalNotificationCloseReason.userCanceled:
          // do something
          break;
        case LocalNotificationCloseReason.timedOut:
          // do something
          break;
        default:
      }
      String log = 'onClose ${_exampleNotification?.identifier} - $closeReason';
      print(log);
      BotToast.showText(text: log);
    };
    _exampleNotification?.onClick = () {
      String log = 'onClick ${_exampleNotification?.identifier}';
      print(log);
      BotToast.showText(text: log);
    };
    _exampleNotification?.onClickAction = (actionIndex) {
      String log =
          'onClickAction ${_exampleNotification?.identifier} - $actionIndex';
      print(log);
      BotToast.showText(text: log);
    };
  }

  void _initTray() async {
    await trayManager.setIcon(
      Platform.isWindows
          ? 'images/tray_icon_original.ico'
          : 'images/tray_icon_original.png',
    );
    Menu menu = Menu(
      items: [
        MenuItem(
          label: 'Show Window',
          onClick: (_) async {
            await windowManager.show();
            await windowManager.setSkipTaskbar(false);
          },
        ),
        MenuItem(
          label: 'Hide Window',
          onClick: (_) async {
            await windowManager.hide();
            await windowManager.setSkipTaskbar(true);
          },
        ),
        MenuItem.separator(),
        MenuItem(
          label: 'show exampleNotification',
          onClick: (_) {
            _exampleNotification?.show();
          },
        ),
        MenuItem(
          label: 'close exampleNotification',
          onClick: (_) {
            _exampleNotification?.close();
          },
        ),
        MenuItem.separator(),
        MenuItem(
          label: 'Exit App',
          onClick: (_) async {
            await windowManager.destroy();
          },
        ),
      ],
    );
    await trayManager.setContextMenu(menu);
    setState(() {});
  }

  _handleNewLocalNotification() async {
    LocalNotification notification = LocalNotification(
      title: "example - ${_notificationList.length}",
      subtitle: "local_notifier_example",
      body: "hello flutter!",
    );
    notification.onShow = () {
      print('onShow ${notification.identifier}');
    };
    notification.onClose = (closeReason) {
      print('onClose ${notification.identifier} - $closeReason');
    };
    notification.onClick = () {
      print('onClick ${notification.identifier}');
    };

    _notificationList.add(notification);

    setState(() {});
  }

  Widget _buildBody(BuildContext context) {
    return PreferenceList(
      children: <Widget>[
        PreferenceListSection(
          children: [
            PreferenceListItem(
              title: Text('New a notification'),
              onTap: _handleNewLocalNotification,
            ),
          ],
        ),
        PreferenceListSection(
          title: Text('${_exampleNotification?.identifier}'),
          children: [
            PreferenceListItem(
              title: Text('show'),
              onTap: () => _exampleNotification?.show(),
            ),
            PreferenceListItem(
              title: Text('close'),
              onTap: () => _exampleNotification?.close(),
            ),
            PreferenceListItem(
              title: Text('destroy'),
              onTap: () async {
                await _exampleNotification?.destroy();
                _exampleNotification = null;
                setState(() {});
              },
            ),
          ],
        ),
        for (var notification in _notificationList)
          PreferenceListSection(
            title: Text('${notification.identifier}'),
            children: [
              PreferenceListItem(
                title: Text('show'),
                onTap: () => notification.show(),
              ),
              PreferenceListItem(
                title: Text('close'),
                onTap: () => notification.close(),
              ),
            ],
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: _buildBody(context),
    );
  }

  @override
  void onTrayIconMouseDown() {
    trayManager.popUpContextMenu();
  }
}
