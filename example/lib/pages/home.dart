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
    title: "local_notifier_example",
    subtitle: "example",
    body: "hello flutter!",
    actions: [
      LocalNotificationAction(
        text: 'OK',
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
    _exampleNotification?.onClose = () {
      print('onClose ${_exampleNotification?.identifier}');
    };
    _exampleNotification?.onClick = () {
      print('onClick ${_exampleNotification?.identifier}');
    };
  }

  _handleNewLocalNotification() async {
    LocalNotification notification = LocalNotification(
      title: "local_notifier_example",
      subtitle: "example - ${_notificationList.length}",
      body: "hello flutter!",
    );
    notification.onShow = () {
      print('onShow ${notification.identifier}');
    };
    notification.onClose = () {
      print('onClose ${notification.identifier}');
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
