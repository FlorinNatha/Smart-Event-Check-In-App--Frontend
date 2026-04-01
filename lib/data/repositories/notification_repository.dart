import '../models/notification_model.dart';
import '../services/api_service.dart';
import '../../../core/constants/api_constants.dart';

/// Repository for notification-related API calls
class NotificationRepository {
  final _apiService = ApiService();

  /// Fetch notifications for current user
  Future<List<NotificationModel>> fetchNotifications() async {
    try {
      final response = await _apiService.get('/notifications');
      if (response is List) {
        return response.map((json) => NotificationModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  /// Mark notification as read
  Future<NotificationModel> markAsRead(String id) async {
    try {
      final response = await _apiService.patch('/notifications/$id/read');
      return NotificationModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  /// Clear all notifications
  Future<void> clearAll() async {
    try {
      await _apiService.delete('/notifications');
    } catch (e) {
      rethrow;
    }
  }
}
