import 'package:flutter/material.dart';
import 'package:preference_list/preference_list.dart';
import 'package:local_notifier/local_notifier.dart';

final localNotifier = LocalNotifier.instance;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
    super.initState();

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
      print('onClose ${_exampleNotification?.identifier} - $closeReason');
    };
    _exampleNotification?.onClick = () {
      print('onClick ${_exampleNotification?.identifier}');
    };
    _exampleNotification?.onClickAction = (actionIndex) {
      print('onClickAction ${_exampleNotification?.identifier} - $actionIndex');
    };
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
              title: Text('destory'),
              onTap: () async {
                await _exampleNotification?.destory();
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
}
