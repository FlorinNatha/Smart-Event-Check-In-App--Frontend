import '../models/ticket_model.dart';
import '../services/api_service.dart';

class StaffRepository {
  final ApiService _apiService = ApiService();

  /// Validate a ticket by QR code
  Future<Map<String, dynamic>> validateTicket(String qrCode) async {
    try {
      final response = await _apiService.post(
        '/registrations/validate',
        body: {'ticketId': qrCode},
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Get scan history
  Future<List<Map<String, dynamic>>> getScanHistory() async {
    try {
      final response = await _apiService.get('/registrations/staff/history');
      if (response != null && response is List) {
        return List<Map<String, dynamic>>.from(response);
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  /// Get staff stats
  Future<Map<String, dynamic>> getStats() async {
    try {
      final response = await _apiService.get('/registrations/staff/stats');
      if (response != null && response is Map<String, dynamic>) {
        return response;
      }
      return {'todayScans': 0};
    } catch (e) {
      // debugPrint('Error fetching stats: $e');
      return {'todayScans': 0};
    }
  }
}
