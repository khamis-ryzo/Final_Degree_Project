import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tax_compliance_app/main.dart';

void main() {
  testWidgets('measure dashboard rects', (WidgetTester tester) async {
    final userJson = {
      'id': 1,
      'username': 'testuser',
      'email': 'test@example.com',
      'tinNumber': '123456789',
      'fullName': 'Test User',
      'mobileNumber': '0712345678',
      'role': 'USER',
    };
    SharedPreferences.setMockInitialValues({
      'auth_token': 'mock-token',
      'user_data': jsonEncode(userJson),
    });
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/connectivity'),
      (call) async => ['wifi'],
    );

    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final oldHandler = FlutterError.onError;
    FlutterError.onError = (details) {};
    await tester.pumpWidget(const MyApp());
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));
    FlutterError.onError = oldHandler;

    final tinText = find.textContaining('TIN:');
    debugPrint('TIN text: "${(tester.widget(tinText) as Text).data}" rect=${tester.getRect(tinText)}');

    final viewAll = find.widgetWithText(TextButton, 'View All');
    debugPrint('viewAll rect: ${tester.getRect(viewAll)}');
    final recent = find.text('Recent Returns');
    debugPrint('recent text rect: ${tester.getRect(recent)}');
  });
}
