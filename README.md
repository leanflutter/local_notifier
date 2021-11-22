# local_notifier

[![pub version][pub-image]][pub-url]

[pub-image]: https://img.shields.io/pub/v/local_notifier.svg
[pub-url]: https://pub.dev/packages/local_notifier

This plugin allows Flutter **desktop** apps to notify local notifications.

[![Discord](https://img.shields.io/badge/discord-%237289DA.svg?style=for-the-badge&logo=discord&logoColor=white)](https://discord.gg/zPa6EZ2jqb)

---

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [local_notifier](#local_notifier)
  - [Platform Support](#platform-support)
  - [Quick Start](#quick-start)
    - [Installation](#installation)
      - [⚠️ Linux requirements](#️-linux-requirements)
    - [Usage](#usage)
  - [Who's using it?](#whos-using-it)
  - [Discussion](#discussion)
  - [API](#api)
    - [LocalNotifier](#localnotifier)
  - [License](#license)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Platform Support

| Linux | macOS | Windows |
| :---: | :---: | :-----: |
|   ✔️   |   ✔️   |    ➖    |

## Quick Start

### Installation

Add this to your package's pubspec.yaml file:

```yaml
dependencies:
  local_notifier: ^0.0.1
```

Or

```yaml
dependencies:
  local_notifier:
    git:
      url: https://github.com/leanflutter/local_notifier.git
      ref: main
```

#### ⚠️ Linux requirements

- `libnotify`

Run the following command

```
sudo apt-get install libnotify-dev
```

### Usage

```dart
LocalNotification notification = LocalNotification(
  title: "local_notifier_example",
  subtitle: "subtitle",
  body: "hello flutter!",
);
await localNotifier.notify(notification);
```

> Please see the example app of this plugin for a full example.

## Who's using it?

- [Biyi (比译)](https://biyidev.com/) - A convenient translation and dictionary app written in dart / Flutter.

## Discussion

> Welcome to join the discussion group to share your suggestions and ideas with me.

- WeChat Group 请添加我的微信 `lijy91`，并备注 `LeanFlutter`
- [QQ Group](https://jq.qq.com/?_wv=1027&k=e3kwRnnw)
- [Telegram Group](https://t.me/leanflutter)

## API

### LocalNotifier

| Method   | Description | Linux | macOS | Windows |
| -------- | ----------- | ----- | ----- | ------- |
| `notify` | -           | ✔️     | ✔️     | ➖       |

## License

```text
MIT License

Copyright (c) 2021 LiJianying <lijy91@foxmail.com>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
