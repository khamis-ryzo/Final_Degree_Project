import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tax_compliance_app/main.dart';

void main() {
  testWidgets('hovering over login screen does not corrupt mouse tracker',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    final List<String> errors = [];
    final oldHandler = FlutterError.onError;
    FlutterError.onError = (details) {
      errors.add(details.exceptionAsString());
    };

    final gesture =
        await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: Offset.zero);
    await tester.pump();

    for (final point in [
      const Offset(10, 10),
      const Offset(200, 300),
      const Offset(200, 400),
      const Offset(200, 500),
      const Offset(300, 600),
      const Offset(100, 100),
    ]) {
      await gesture.moveTo(point);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
    }

    FlutterError.onError = oldHandler;

    final mouseErrors =
        errors.where((e) => e.contains('mouse_tracker')).toList();
    expect(mouseErrors, isEmpty,
        reason: 'Mouse tracker assertions: $mouseErrors');
    expect(errors, isEmpty, reason: 'Errors: $errors');
  });

  testWidgets('hovering over dashboard does not corrupt mouse tracker',
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

    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MyApp());
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));

    final List<String> errors = [];
    final oldHandler = FlutterError.onError;
    FlutterError.onError = (details) {
      errors.add(details.exceptionAsString());
    };

    final gesture =
        await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: Offset.zero);
    await tester.pump();

    for (final point in [
      const Offset(10, 10),
      const Offset(200, 50),
      const Offset(600, 100),
      const Offset(600, 300),
      const Offset(600, 500),
      const Offset(1200, 700),
      const Offset(640, 400),
    ]) {
      await gesture.moveTo(point);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
    }

    FlutterError.onError = oldHandler;

    final mouseErrors =
        errors.where((e) => e.contains('mouse_tracker')).toList();
    expect(mouseErrors, isEmpty,
        reason: 'Mouse tracker assertions: $mouseErrors');
    expect(errors, isEmpty, reason: 'Errors: $errors');
  });
}
