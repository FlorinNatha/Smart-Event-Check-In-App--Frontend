import 'package:flutter/foundation.dart';
import '../../../data/models/event_model.dart';
import '../../../data/repositories/event_repository.dart';

class EventProvider with ChangeNotifier {
  final EventRepository _repository = EventRepository();
  
  List<EventModel> _events = [];
  EventModel? _selectedEvent;
  bool _isLoading = false;
  String? _error;

  List<EventModel> get events => _events;
  EventModel? get selectedEvent => _selectedEvent;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Fetch all events
  Future<void> fetchEvents({bool refresh = false}) async {
    if (_events.isNotEmpty && !refresh) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _events = await _repository.getEvents();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get event details
  Future<void> fetchEventDetails(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedEvent = await _repository.getEventById(id);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Register for event
  Future<bool> registerForEvent(String eventId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.registerForEvent(eventId);
      // Refresh event details to update counts if needed
      if (_selectedEvent?.id == eventId) {
        await fetchEventDetails(eventId);
      }
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear errors
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
