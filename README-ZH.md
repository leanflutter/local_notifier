# local_notifier

[![pub version][pub-image]][pub-url] [![][discord-image]][discord-url]

[pub-image]: https://img.shields.io/pub/v/local_notifier.svg
[pub-url]: https://pub.dev/packages/local_notifier

[discord-image]: https://img.shields.io/discord/884679008049037342.svg
[discord-url]: https://discord.gg/zPa6EZ2jqb

这个插件允许 Flutter **桌面** 应用显示本地通知。

---

[English](./README.md) | 简体中文

---

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [local_notifier](#local_notifier)
  - [平台支持](#平台支持)
  - [快速开始](#快速开始)
    - [安装](#安装)
      - [Linux requirements](#linux-requirements)
    - [用法](#用法)
  - [谁在用使用它？](#谁在用使用它)
  - [相关链接](#相关链接)
  - [许可证](#许可证)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## 平台支持

| Linux | macOS | Windows |
| :---: | :---: | :-----: |
|   ✔️   |   ✔️   |    ✔️    |

## 快速开始

### 安装

将此添加到你的软件包的 pubspec.yaml 文件：

```yaml
dependencies:
  local_notifier: ^0.1.4
```

或

```yaml
dependencies:
  local_notifier:
    git:
      url: https://github.com/leanflutter/local_notifier.git
      ref: main
```

#### Linux requirements

- `libnotify`

运行以下命令

```
sudo apt-get install libnotify-dev
```

### 用法

```dart
// 在 main 方法中添加这行。
localNotifier.setAppName('example');

LocalNotification notification = LocalNotification(
  title: "local_notifier_example",
  body: "hello flutter!",
);
notification.onShow = () {
  print('onShow ${notification.identifier}');
};
notification.onClose = (closeReason) {
  // 只支持在windows，其他平台 closeReason 始终为 unknown。
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

> 请看这个插件的示例应用，以了解完整的例子。

## 谁在用使用它？

- [Biyi (比译)](https://biyidev.com/) - 一个便捷的翻译和词典应用。

## 相关链接

- https://github.com/mohabouje/WinToast

## 许可证

[MIT](./LICENSE)
