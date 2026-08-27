import '../models/user.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  Future<LoginResponse> login(LoginRequest request) async {
    final response = await _apiService.post('/auth/login', request.toJson());
    return LoginResponse.fromJson(response);
  }

  Future<User> register(RegisterRequest request) async {
    await _apiService.post('/auth/register', request.toJson());
    return User(
      username: request.username,
      email: request.email,
      tinNumber: request.tinNumber,
      fullName: request.fullName,
      mobileNumber: request.mobileNumber,
    );
  }

  Future<void> verifyEmail({required String email, required String otp}) async {
    final query = Uri(queryParameters: {'email': email, 'otp': otp}).query;
    await _apiService.post('/auth/verify-email?$query', {});
  }

  Future<void> resendVerificationOtp(String email) async {
    final query = Uri(queryParameters: {'email': email}).query;
    await _apiService.post('/auth/resend-verification-otp?$query', {});
  }

  Future<void> logout() async {
    await _apiService.post('/auth/logout', {});
  }

  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    final query = Uri(queryParameters: {
      'email': email,
      'otp': otp,
      'newPassword': newPassword,
    }).query;
    await _apiService.post('/auth/reset-password?$query', {});
  }
}

bool isValidTanzanianMobile(String phone) {
  String cleaned = phone.replaceAll(RegExp(r'\D'), '');
  if (cleaned.length == 12 && cleaned.startsWith('255')) return true;
  if (cleaned.length == 10 && cleaned.startsWith('0')) return true;
  if (cleaned.length == 9 && cleaned.startsWith('7')) return true;
  return false;
}

String formatMobileNumber(String phone) {
  String cleaned = phone.replaceAll(RegExp(r'\D'), '');
  if (cleaned.startsWith('255') && cleaned.length == 12) {
    return '+${cleaned.substring(0, 3)} ${cleaned.substring(3, 6)} ${cleaned.substring(6, 9)} ${cleaned.substring(9, 12)}';
  } else if (cleaned.startsWith('0') && cleaned.length == 10) {
    return '+255 ${cleaned.substring(1, 4)} ${cleaned.substring(4, 7)} ${cleaned.substring(7, 10)}';
  } else if (cleaned.length == 9 && cleaned.startsWith('7')) {
    return '+255 ${cleaned.substring(0, 3)} ${cleaned.substring(3, 6)} ${cleaned.substring(6, 9)}';
  } else {
    return phone;
  }
}
