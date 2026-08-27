import 'package:flutter/material.dart';
import '../utils/logger.dart';

class AppNotification {
  final String id;
  final String? title;
  final String? body;
  bool isRead;

  AppNotification({
    required this.id,
    this.title,
    this.body,
    this.isRead = false,
  });
}

// Local placeholder service implementation.
// Replace this stub with the real notification service when the file exists.
class NotificationService {
  void Function(AppNotification notification)? onNotificationReceived;
  void Function(AppNotification notification)? onNotificationOpened;

  Future<List<AppNotification>> getNotifications() async {
    return [];
  }

  Future<void> markAsRead(String notificationId) async {}
  Future<void> markAllAsRead() async {}
  Future<void> deleteNotification(String notificationId) async {}
  Future<void> deleteAllNotifications() async {}

  Future<void> sendLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {}
}

class NotificationProvider extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();
  
  List<AppNotification> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<AppNotification> get notifications => _notifications;
  List<AppNotification> get unreadNotifications => 
      _notifications.where((n) => !n.isRead).toList();
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasNotifications => _notifications.isNotEmpty;

  NotificationProvider() {
    loadNotifications();
    _setupNotificationListeners();
  }

  void _setupNotificationListeners() {
    _notificationService.onNotificationReceived = (notification) {
      _addNotification(notification);
    };
    
    _notificationService.onNotificationOpened = (notification) {
      // Handle notification tap
      _markAsRead(notification.id);
    };
  }

  // Load notifications
  Future<void> loadNotifications() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      AppLogger.info('Loading notifications');
      _notifications = await _notificationService.getNotifications();
      _updateUnreadCount();
      _isLoading = false;
      notifyListeners();
      AppLogger.info('Loaded ${_notifications.length} notifications');
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      AppLogger.error('Error loading notifications', e);
    }
  }

  // Add new notification
  void _addNotification(AppNotification notification) {
    _notifications.insert(0, notification);
    _updateUnreadCount();
    notifyListeners();
  }

  // Mark notification as read
  Future<void> _markAsRead(String notificationId) async {
    try {
      await _notificationService.markAsRead(notificationId);
      
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index].isRead = true;
        _updateUnreadCount();
        notifyListeners();
      }
    } catch (e) {
      AppLogger.error('Error marking notification as read', e);
    }
  }

  // Mark all as read
  Future<void> markAllAsRead() async {
    try {
      await _notificationService.markAllAsRead();
      
      for (var notification in _notifications) {
        notification.isRead = true;
      }
      _updateUnreadCount();
      notifyListeners();
      
      AppLogger.info('All notifications marked as read');
    } catch (e) {
      AppLogger.error('Error marking all as read', e);
    }
  }

  // Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _notificationService.deleteNotification(notificationId);
      
      _notifications.removeWhere((n) => n.id == notificationId);
      _updateUnreadCount();
      notifyListeners();
      
      AppLogger.info('Notification deleted');
    } catch (e) {
      AppLogger.error('Error deleting notification', e);
    }
  }

  // Delete all notifications
  Future<void> deleteAllNotifications() async {
    try {
      await _notificationService.deleteAllNotifications();
      
      _notifications.clear();
      _updateUnreadCount();
      notifyListeners();
      
      AppLogger.info('All notifications deleted');
    } catch (e) {
      AppLogger.error('Error deleting all notifications', e);
    }
  }

  // Update unread count
  void _updateUnreadCount() {
    _unreadCount = _notifications.where((n) => !n.isRead).length;
  }

  // Send test notification (for development)
  Future<void> sendTestNotification() async {
    try {
      await _notificationService.sendLocalNotification(
        title: 'Test Notification',
        body: 'This is a test notification from Tax Compliance System',
        payload: 'test_payload',
      );
    } catch (e) {
      AppLogger.error('Error sending test notification', e);
    }
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}