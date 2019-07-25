import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:session_list_view_controller/session_list_view_controller.dart';

void main() {
  const MethodChannel channel = MethodChannel('session_list_view_controller');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await SessionListViewController.platformVersion, '42');
  });
}
