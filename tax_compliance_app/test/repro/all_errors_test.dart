import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tax_compliance_app/main.dart';

void main() {
  testWidgets('all errors at 320 pre-fix', (tester) async {
    final userJson = {'id': 1, 'username': 'testuser', 'email': 'test@example.com', 'tinNumber': '123456789', 'fullName': 'Test User', 'mobileNumber': '0712345678', 'role': 'USER'};
    SharedPreferences.setMockInitialValues({'auth_token': 'mock-token', 'user_data': jsonEncode(userJson)});
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(const MethodChannel('dev.fluttercommunity.plus/connectivity'), (call) async => ['wifi']);
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final errors = <String>[];
    final old = FlutterError.onError;
    FlutterError.onError = (d) { errors.add(d.exceptionAsString()); };
    await tester.pumpWidget(const MyApp());
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));
    FlutterError.onError = old;
    for (final e in errors) {
      final head = e.split('\n').first;
      debugPrint('ERROR: $head');
    }
    debugPrint('TOTAL: ${errors.length}');
  });
}
