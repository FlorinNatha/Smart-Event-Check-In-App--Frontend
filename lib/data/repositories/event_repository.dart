import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/event_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class EventRepository {
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();

  /// Fetch all events with Offline support
  Future<List<EventModel>> getEvents({Map<String, String>? queryParams}) async {
    // Check connectivity
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      final cachedEvents = _storageService.getCachedEvents();
      if (cachedEvents != null && cachedEvents.isNotEmpty) {
        return cachedEvents;
      }
      throw Exception('No internet connection. Please check your network.');
    }

    try {
      final response = await _apiService.get('/events', queryParams: queryParams);
      if (response != null && response is List) {
        final events = response.map((json) => EventModel.fromJson(json)).toList();
        // Cache the fresh data
        await _storageService.saveEvents(events);
        return events;
      }
      return [];
    } catch (e) {
      // If API fails (e.g. server down), try falling back to cache
      final cachedEvents = _storageService.getCachedEvents();
      if (cachedEvents != null && cachedEvents.isNotEmpty) {
        return cachedEvents;
      }
      rethrow;
    }
  }

  /// Get event by ID with Offline fallback
  Future<EventModel> getEventById(String id) async {
    try {
      final response = await _apiService.get('/events/$id');
      return EventModel.fromJson(response);
    } catch (e) {
      // Fallback: search in cached list
      final cachedEvents = _storageService.getCachedEvents();
      if (cachedEvents != null) {
        try {
          return cachedEvents.firstWhere((e) => e.id == id);
        } catch (_) {
          // Not found in cache
        }
      }
      rethrow;
    }
  }

  /// Register for an event
  Future<void> registerForEvent(String eventId) async {
    // Registration writes data, so we need internet usage.
    // In a sophisticated app, we'd queue this request. For now, strict check.
    
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
       throw Exception('Internet connection required to register.');
    }

    try {
      await _apiService.post('/events/$eventId/register');
    } catch (e) {
      rethrow;
    }
  }
}
