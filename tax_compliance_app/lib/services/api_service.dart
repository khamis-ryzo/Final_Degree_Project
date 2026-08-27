import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'storage_service.dart';

class AppConstants {
  static String get baseUrl {
    if (kIsWeb) return 'http://127.0.0.1:8080/api';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8080/api';
    }
    return 'http://127.0.0.1:8080/api';
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException(this.statusCode, this.message);

  @override
  String toString() => message;
}

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final StorageService _storageService = StorageService();
  final http.Client _httpClient = http.Client();

  Future<void> init() async {
    debugPrint('ApiService initialized with baseUrl: ${AppConstants.baseUrl}');
  }

  Future<dynamic> post(String endpoint, dynamic data) async {
    try {
      final hasConnection = await checkConnectivity();
      if (!hasConnection) {
        throw Exception('No internet connection');
      }

      final token = await _storageService.getToken();
      final headers = {'Content-Type': 'application/json'};
      // Debug: print the stored token value to help trace missing Authorization
      debugPrint('Stored token: ${token ?? "<null>"}');
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      debugPrint('Request: POST ${AppConstants.baseUrl}$endpoint');
      debugPrint('Headers: $headers');
      try {
        debugPrint('Body: ${jsonEncode(data)}');
      } catch (e) {
        debugPrint('Body (non-encodable): ${data.toString()}');
      }

      final response = await _httpClient
          .post(Uri.parse('${AppConstants.baseUrl}$endpoint'),
              headers: headers, body: jsonEncode(data))
          .timeout(const Duration(seconds: 30));

      debugPrint('Response: ${response.statusCode} - ${response.body}');
      _throwForErrorStatus(response);
      return jsonDecode(response.body);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw _handleError(e);
    }
  }

  Future<dynamic> get(String endpoint) async {
    try {
      final hasConnection = await checkConnectivity();
      if (!hasConnection) {
        throw Exception('No internet connection');
      }

      final token = await _storageService.getToken();
      final headers = {'Content-Type': 'application/json'};
      // Debug: print the stored token value to help trace missing Authorization
      debugPrint('Stored token: ${token ?? "<null>"}');
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      debugPrint('Request: GET ${AppConstants.baseUrl}$endpoint');
      debugPrint('Headers: $headers');

      final response = await _httpClient
          .get(Uri.parse('${AppConstants.baseUrl}$endpoint'), headers: headers)
          .timeout(const Duration(seconds: 30));

      debugPrint('Response: ${response.statusCode} - ${response.body}');
      _throwForErrorStatus(response);
      return jsonDecode(response.body);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw _handleError(e);
    }
  }

  Future<dynamic> put(String endpoint, dynamic data) async {
    try {
      final hasConnection = await checkConnectivity();
      if (!hasConnection) {
        throw Exception('No internet connection');
      }

      final token = await _storageService.getToken();
      final headers = {'Content-Type': 'application/json'};
      // Debug: print the stored token value to help trace missing Authorization
      debugPrint('Stored token: ${token ?? "<null>"}');
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      debugPrint('Request: PUT ${AppConstants.baseUrl}$endpoint');
      debugPrint('Headers: $headers');
      try {
        debugPrint('Body: ${jsonEncode(data)}');
      } catch (e) {
        debugPrint('Body (non-encodable): ${data.toString()}');
      }

      final response = await _httpClient
          .put(Uri.parse('${AppConstants.baseUrl}$endpoint'),
              headers: headers, body: jsonEncode(data))
          .timeout(const Duration(seconds: 30));

      debugPrint('Response: ${response.statusCode} - ${response.body}');
      _throwForErrorStatus(response);
      return jsonDecode(response.body);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw _handleError(e);
    }
  }

  Future<dynamic> delete(String endpoint) async {
    try {
      final hasConnection = await checkConnectivity();
      if (!hasConnection) {
        throw Exception('No internet connection');
      }

      final token = await _storageService.getToken();
      final headers = {'Content-Type': 'application/json'};
      // Debug: print the stored token value to help trace missing Authorization
      debugPrint('Stored token: ${token ?? "<null>"}');
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      debugPrint('Request: DELETE ${AppConstants.baseUrl}$endpoint');
      debugPrint('Headers: $headers');

      final response = await _httpClient
          .delete(Uri.parse('${AppConstants.baseUrl}$endpoint'),
              headers: headers)
          .timeout(const Duration(seconds: 30));

      debugPrint('Response: ${response.statusCode} - ${response.body}');
      _throwForErrorStatus(response);
      return jsonDecode(response.body);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw _handleError(e);
    }
  }

  Future<Uint8List> downloadBinary(String endpoint) async {
    try {
      final hasConnection = await checkConnectivity();
      if (!hasConnection) {
        throw Exception('No internet connection');
      }

      final token = await _storageService.getToken();
      final headers = <String, String>{};
      if (token != null) headers['Authorization'] = 'Bearer $token';

      debugPrint('Request: GET ${AppConstants.baseUrl}$endpoint (binary)');

      final response = await _httpClient
          .get(Uri.parse('${AppConstants.baseUrl}$endpoint'), headers: headers)
          .timeout(const Duration(seconds: 60));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Request failed (${response.statusCode})');
      }

      return response.bodyBytes;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw _handleError(e);
    }
  }

  void _throwForErrorStatus(http.Response response) {
    if (response.statusCode == 401) {
      final body = response.body.trim();
      if (body.isNotEmpty) {
        _storageService.clearAll();
      }
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      String message = response.statusCode == 403
          ? 'Access denied. Your account does not have permission for this action.'
          : 'Request failed (${response.statusCode})';
      try {
        final body = jsonDecode(response.body);
        if (body is Map<String, dynamic>) {
          message =
              (body['message'] ?? body['error'] ?? body['detail'] ?? message)
                  .toString();
        }
      } on FormatException {
        // Keep the status-based message when the backend returns a non-JSON error.
      }
      throw ApiException(response.statusCode, message);
    }
  }

  Future<bool> checkConnectivity() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      return connectivityResult != ConnectivityResult.none;
    } catch (error) {
      debugPrint('Connectivity check failed, assuming online status: $error');
      return true;
    }
  }

  String _handleError(dynamic error) {
    debugPrint('Error: $error');
    if (error is http.ClientException) {
      return 'No internet connection. Please check your network and ensure the server is running.';
    }
    if (error is TimeoutException) {
      return 'Connection timed out. The server may be unreachable.';
    }
    if (error is FormatException) {
      return 'Invalid response from server.';
    }
    if (error is Exception) {
      final msg = error.toString();
      if (msg.toLowerCase().contains('connection') ||
          msg.toLowerCase().contains('socket') ||
          msg.toLowerCase().contains('network')) {
        return 'No internet connection. Please check your network and ensure the server is running.';
      }
      return msg.replaceFirst(RegExp(r'^Exception:\\s*'), '');
    }
    return 'An unexpected error occurred: $error';
  }
}
