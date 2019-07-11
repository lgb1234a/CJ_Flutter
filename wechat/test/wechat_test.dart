import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wechat/wechat.dart';

void main() {
  const MethodChannel channel = MethodChannel('wechat');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await Wechat.platformVersion, '42');
  });
}
