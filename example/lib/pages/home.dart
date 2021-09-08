import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:preference_list/preference_list.dart';
import 'package:local_notifier/local_notifier.dart';

final localNotifier = LocalNotifier.instance;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  _handleNotify() async {
    LocalNotification notification = LocalNotification(
      identifier: 'identifier',
      title: "local_notifier_example",
      subtitle: "local_notifier_example",
      body: "hello flutter!",
    );
    await localNotifier.notify(notification);
  }

  Widget _buildBody(BuildContext context) {
    return PreferenceList(
      children: <Widget>[
        PreferenceListSection(
          title: Text('Methods'),
          children: [
            PreferenceListItem(
              title: Text('notify'),
              onTap: _handleNotify,
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
