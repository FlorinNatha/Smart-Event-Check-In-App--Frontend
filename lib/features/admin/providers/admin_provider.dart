import 'package:flutter/foundation.dart';
import '../../../data/models/event_model.dart';
import '../../../data/repositories/admin_repository.dart';

class AdminProvider with ChangeNotifier {
  final AdminRepository _repository = AdminRepository();
  
  bool _isLoading = false;
  String? _error;
  
  Map<String, dynamic>? _dashboardStats;
  Map<String, dynamic>? _eventStats;
  List<Map<String, dynamic>> _registrations = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get dashboardStats => _dashboardStats;
  Map<String, dynamic>? get eventStats => _eventStats;
  List<Map<String, dynamic>> get registrations => _registrations;

  /// Load Dashboard Stats
  Future<void> loadDashboardStats() async {
    _setLoading(true);
    try {
      _dashboardStats = await _repository.getDashboardStats();
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  /// Create Event
  Future<bool> createEvent(Map<String, dynamic> data) async {
    _setLoading(true);
    try {
      await _repository.createEvent(data);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Update Event
  Future<bool> updateEvent(String id, Map<String, dynamic> data) async {
    _setLoading(true);
    try {
      await _repository.updateEvent(id, data);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Delete Event
  Future<bool> deleteEvent(String id) async {
    _setLoading(true);
    try {
      await _repository.deleteEvent(id);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Load Event Analytics
  Future<void> loadEventAnalytics(String eventId) async {
    _setLoading(true);
    try {
      _eventStats = await _repository.getEventStats(eventId);
      _registrations = await _repository.getEventRegistrations(eventId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    if (value) _error = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
