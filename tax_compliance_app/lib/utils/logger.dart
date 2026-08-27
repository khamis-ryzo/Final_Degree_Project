import 'package:flutter/foundation.dart';

class AppLogger {
  static void debug(dynamic message) {
    if (kDebugMode) {
      print('🐞 DEBUG: $message');
    }
  }

  static void info(dynamic message) {
    if (kDebugMode) {
      print('ℹ️ INFO: $message');
    }
  }

  static void warning(dynamic message) {
    if (kDebugMode) {
      print('⚠️ WARNING: $message');
    }
  }

  static void error(dynamic message, [dynamic error]) {
    if (kDebugMode) {
      print('❌ ERROR: $message');
      if (error != null) {
        print('Error details: $error');
      }
    }
  }
}
