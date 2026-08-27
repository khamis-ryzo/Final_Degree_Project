import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../utils/logger.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _errorMessage;
  String? _token;

  // Getters
  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get errorMessage => _errorMessage;
  String? get token => _token;
  bool get isAuthenticated =>
      _user != null && _token != null && _token!.trim().isNotEmpty;

  final AuthService _authService;
  final StorageService _storageService;

  AuthProvider({AuthService? authService, StorageService? storageService})
      : _authService = authService ?? AuthService(),
        _storageService = storageService ?? StorageService() {
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    try {
      final savedToken = await _storageService.getToken();
      _token = savedToken != null && savedToken.trim().isNotEmpty
          ? savedToken.trim()
          : null;
      _user = await _storageService.getUser();
      if (_token == null || _user == null) {
        _token = null;
        _user = null;
      }
    } catch (error) {
      AppLogger.error('Unable to restore the saved session: $error');
      _token = null;
      _user = null;
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.login(
        LoginRequest(username: username, password: password),
      );
      _token = response.token;
      _user = response.user;
      await _storageService.saveToken(response.token);
      await _storageService.saveUser(response.user);
      return true;
    } catch (error) {
      _errorMessage = error.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(RegisterRequest request) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.register(request);
      return true;
    } catch (error) {
      _errorMessage = error.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> verifyEmail({required String email, required String otp}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.verifyEmail(email: email, otp: otp);
    } catch (error) {
      final message = error.toString();
      if (message.toLowerCase().contains('no verification code') ||
          message.toLowerCase().contains('no otp has been requested')) {
        try {
          await _authService.resendVerificationOtp(email);
          throw Exception(
              'A new verification code was sent to your email. Please try again.');
        } catch (_) {
          _errorMessage =
              'A new verification code was sent to your email. Please try again.';
          rethrow;
        }
      }
      _errorMessage = message;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resendVerificationOtp(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.resendVerificationOtp(email);
    } catch (error) {
      _errorMessage = error.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    try {
      if (_token != null) await _authService.logout();
    } catch (error) {
      AppLogger.warning('Remote logout failed: $error');
    } finally {
      await _storageService.clearAll();
      _token = null;
      _user = null;
      _isLoading = false;
      notifyListeners();
    }
  }

  // Existing methods...

  // Forgot Password
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      AppLogger.info('Processing forgot password for email: $email');

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // For demo, generate a token
      final resetToken = 'reset_token_${DateTime.now().millisecondsSinceEpoch}';

      _isLoading = false;
      notifyListeners();

      return {
        'success': true,
        'resetToken': resetToken,
        'errorMessage': null,
      };
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();

      return {
        'success': false,
        'resetToken': null,
        'errorMessage': _errorMessage,
      };
    }
  }

  // Resend Reset Email
  Future<Map<String, dynamic>> resendResetEmail(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      AppLogger.info('Resending reset email for: $email');

      await Future.delayed(const Duration(seconds: 1));

      _isLoading = false;
      notifyListeners();

      return {
        'success': true,
        'errorMessage': null,
      };
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();

      return {
        'success': false,
        'errorMessage': _errorMessage,
      };
    }
  }

  // Verify Reset Token
  Future<bool> verifyResetToken(String token) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      AppLogger.info('Verifying reset token: $token');

      await Future.delayed(const Duration(seconds: 1));

      // For demo, accept any token that starts with 'reset_token_'
      final isValid = token.startsWith('reset_token_');

      _isLoading = false;
      notifyListeners();

      return isValid;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Reset Password
  Future<Map<String, dynamic>> resetPassword(
    String token,
    String newPassword,
    String confirmPassword,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      AppLogger.info('Resetting password with token: $token');

      // Validate passwords match
      if (newPassword != confirmPassword) {
        throw Exception('Passwords do not match');
      }

      await Future.delayed(const Duration(seconds: 1));

      _isLoading = false;
      notifyListeners();

      return {
        'success': true,
        'errorMessage': null,
      };
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();

      return {
        'success': false,
        'errorMessage': _errorMessage,
      };
    }
  }
}
