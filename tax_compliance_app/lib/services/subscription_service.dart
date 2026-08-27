import '../models/subscription.dart';
import 'api_service.dart';

class SubscriptionService {
  final ApiService _apiService = ApiService();

  Future<Subscription> getMySubscription() async {
    final response = await _apiService.get('/subscriptions/me');
    return Subscription.fromJson(response);
  }

  Future<Subscription> subscribe(SubscriptionRequest request) async {
    final response = await _apiService.post('/subscriptions/subscribe', request.toJson());
    return Subscription.fromJson(response);
  }

  Future<Subscription> cancel() async {
    final response = await _apiService.post('/subscriptions/cancel', {});
    return Subscription.fromJson(response);
  }
}
