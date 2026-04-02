import 'package:flutter/foundation.dart';
import '../../../data/models/notification_model.dart';
import '../../../data/repositories/notification_repository.dart';

/// Notification state management
class NotificationProvider with ChangeNotifier {
  final _repository = NotificationRepository();

  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _error;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Unread notifications count
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  /// Fetch user notifications
  Future<void> fetchNotifications() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _notifications = await _repository.fetchNotifications();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Mark as read
  Future<void> markAsRead(String id) async {
    try {
      final updated = await _repository.markAsRead(id);
      final index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        _notifications[index] = updated;
        notifyListeners();
      }
    } catch (e) {
      // debugPrint('Failed to mark as read: $e');
    }
  }

  /// Clear all notifications
  Future<bool> clearAll() async {
    try {
      await _repository.clearAll();
      _notifications.clear();
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Reset state on logout
  void reset() {
    _notifications = [];
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}
