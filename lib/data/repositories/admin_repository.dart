import '../models/event_model.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class AdminRepository {
  final ApiService _apiService = ApiService();

  /// Create a new event
  Future<EventModel> createEvent(Map<String, dynamic> eventData) async {
    try {
      final response = await _apiService.post('/admin/events', body: eventData);
      return EventModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  /// Update an existing event
  Future<EventModel> updateEvent(String id, Map<String, dynamic> eventData) async {
    try {
      final response = await _apiService.put('/admin/events/$id', body: eventData);
      return EventModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  /// Delete an event
  Future<void> deleteEvent(String id) async {
    try {
      await _apiService.delete('/admin/events/$id');
    } catch (e) {
      rethrow;
    }
  }

  /// Get dashboard statistics
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final response = await _apiService.get('/admin/stats');
      return Map<String, dynamic>.from(response);
    } catch (e) {
      rethrow;
    }
  }

  /// Get event specific statistics
  Future<Map<String, dynamic>> getEventStats(String eventId) async {
    try {
      final response = await _apiService.get('/admin/events/$eventId/stats');
      return Map<String, dynamic>.from(response);
    } catch (e) {
      rethrow;
    }
  }

  /// Get registrations for an event
  Future<List<Map<String, dynamic>>> getEventRegistrations(String eventId) async {
    try {
      final response = await _apiService.get('/admin/events/$eventId/registrations');
      if (response != null && response is List) {
        return List<Map<String, dynamic>>.from(response);
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }
}
