import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wx_sdk/wx_sdk.dart';

void main() {
  const MethodChannel channel = MethodChannel('wx_sdk');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await WxSdk.platformVersion, '42');
  });
}
