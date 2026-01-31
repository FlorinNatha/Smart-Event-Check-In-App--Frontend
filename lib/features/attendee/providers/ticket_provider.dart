import 'package:flutter/foundation.dart';
import '../../../data/models/ticket_model.dart';
import '../../../data/repositories/ticket_repository.dart';

class TicketProvider with ChangeNotifier {
  final TicketRepository _repository = TicketRepository();
  
  List<TicketModel> _tickets = [];
  TicketModel? _selectedTicket;
  bool _isLoading = false;
  String? _error;

  List<TicketModel> get tickets => _tickets;
  TicketModel? get selectedTicket => _selectedTicket;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Fetch user tickets
  Future<void> fetchMyTickets({bool refresh = false}) async {
    if (_tickets.isNotEmpty && !refresh) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _tickets = await _repository.getMyTickets();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get ticket details
  Future<void> fetchTicketDetails(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedTicket = await _repository.getTicketById(id);
    } catch (e) {
      _error = e.toString();
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
