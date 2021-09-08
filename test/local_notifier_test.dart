import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_notifier/local_notifier.dart';

void main() {
  const MethodChannel channel = MethodChannel('local_notifier');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });
}
