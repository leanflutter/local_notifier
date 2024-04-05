# local_notifier

[![pub version][pub-image]][pub-url] [![][discord-image]][discord-url] ![][visits-count-image] 

[pub-image]: https://img.shields.io/pub/v/local_notifier.svg
[pub-url]: https://pub.dev/packages/local_notifier

[discord-image]: https://img.shields.io/discord/884679008049037342.svg
[discord-url]: https://discord.gg/zPa6EZ2jqb

[visits-count-image]: https://img.shields.io/badge/dynamic/json?label=Visits%20Count&query=value&url=https://api.countapi.xyz/hit/leanflutter.local_notifier/visits

This plugin allows Flutter desktop apps to displaying local notifications.

---

English | [简体中文](./README-ZH.md)

---

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [local_notifier](#local_notifier)
  - [Platform Support](#platform-support)
  - [Screenshots](#screenshots)
  - [Quick Start](#quick-start)
    - [Installation](#installation)
      - [Linux requirements](#linux-requirements)
    - [Usage](#usage)
  - [Who's using it?](#whos-using-it)
  - [Related Links](#related-links)
  - [License](#license)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Platform Support

| Linux | macOS | Windows |
| :---: | :---: | :-----: |
|   ✔️   |   ✔️   |    ✔️    |

## Screenshots

| macOS                                                                                       | Linux                                                                                       | Windows                                                                                            |
| ------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------- |
| ![](https://github.com/leanflutter/local_notifier/blob/main/screenshots/macos.png?raw=true) | ![](https://github.com/leanflutter/local_notifier/blob/main/screenshots/linux.png?raw=true) | ![image](https://github.com/leanflutter/local_notifier/blob/main/screenshots/windows.png?raw=true) |

## Quick Start

### Installation

Add this to your package's pubspec.yaml file:

```yaml
dependencies:
  local_notifier: ^0.1.6
```

Or

```yaml
dependencies:
  local_notifier:
    git:
      url: https://github.com/leanflutter/local_notifier.git
      ref: main
```

#### Linux requirements

- `libnotify`

Run the following command

```
sudo apt-get install libnotify-dev
```

### Usage

```dart
// Add in main method.
await localNotifier.setup(
  appName: 'local_notifier_example',
  // The parameter shortcutPolicy only works on Windows
  shortcutPolicy: ShortcutPolicy.requireCreate,
);

LocalNotification notification = LocalNotification(
  title: "local_notifier_example",
  body: "hello flutter!",
);
notification.onShow = () {
  print('onShow ${notification.identifier}');
};
notification.onClose = (closeReason) {
  // Only supported on windows, other platforms closeReason is always unknown.
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
notification.onClick = () {
  print('onClick ${notification.identifier}');
};
notification?.onClickAction = (actionIndex) {
  print('onClickAction ${notification?.identifier} - $actionIndex');
};

notification.show();
```

> Please see the example app of this plugin for a full example.

## Who's using it?

- [Biyi (比译)](https://biyidev.com/) - A convenient translation and dictionary app.

## Related Links

- https://github.com/mohabouje/WinToast

## License

[MIT](./LICENSE)
