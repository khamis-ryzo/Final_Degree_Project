import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tax_compliance_app/main.dart';

void main() {
  for (final width in [320.0, 360.0, 412.0, 480.0]) {
    testWidgets('dashboard renders without layout overflow at ${width}px',
        (WidgetTester tester) async {
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

      tester.view.physicalSize = Size(width, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final List<String> errors = [];
      final oldHandler = FlutterError.onError;
      FlutterError.onError = (details) {
        errors.add(details.toString());
      };

      await tester.pumpWidget(const MyApp());
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      FlutterError.onError = oldHandler;

      expect(find.byType(BottomNavigationBar), findsOneWidget,
          reason: 'Dashboard should be showing');

      final overflowErrors = errors
          .where((e) => e.contains('overflowed'))
          .toList();
      expect(overflowErrors, isEmpty,
          reason: 'Layout overflow errors at ${width}px: $overflowErrors');
    });
  }
}
