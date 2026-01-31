import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/ticket_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class TicketRepository {
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();

  /// Get current user's tickets with Offline support
  Future<List<TicketModel>> getMyTickets() async {
    // Check connectivity
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      final cachedTickets = _storageService.getCachedTickets();
      if (cachedTickets != null && cachedTickets.isNotEmpty) {
        return cachedTickets;
      }
      throw Exception('No internet connection. Please check your network.');
    }

    try {
      final response = await _apiService.get('/tickets');
      if (response != null && response is List) {
        final tickets = response.map((json) => TicketModel.fromJson(json)).toList();
        // Cache tickets
        await _storageService.saveMyTickets(tickets);
        return tickets;
      }
      return [];
    } catch (e) {
      // Fallback to cache on API error
      final cachedTickets = _storageService.getCachedTickets();
      if (cachedTickets != null && cachedTickets.isNotEmpty) {
        return cachedTickets;
      }
      rethrow;
    }
  }

  /// Get ticket by ID
  Future<TicketModel> getTicketById(String id) async {
    try {
      final response = await _apiService.get('/tickets/$id');
      return TicketModel.fromJson(response);
    } catch (e) {
      // Search in cache
      final cachedTickets = _storageService.getCachedTickets();
      if (cachedTickets != null) {
        try {
          return cachedTickets.firstWhere((t) => t.id == id);
        } catch (_) {}
      }
      rethrow;
    }
  }
}
