import 'package:flutter/foundation.dart';
import '../../../data/repositories/staff_repository.dart';

enum ScanStatus { idle, scanning, processing, success, error }

class ScanProvider with ChangeNotifier {
  final StaffRepository _repository = StaffRepository();
  
  ScanStatus _status = ScanStatus.idle;
  String? _message;
  Map<String, dynamic>? _lastResult;
  List<Map<String, dynamic>> _scanHistory = [];

  ScanStatus get status => _status;
  String? get message => _message;
  Map<String, dynamic>? get lastResult => _lastResult;
  List<Map<String, dynamic>> get scanHistory => _scanHistory;

  /// Process scanned code
  Future<void> processCode(String code) async {
    if (_status == ScanStatus.processing || _status == ScanStatus.success || _status == ScanStatus.error) {
      return;
    }

    _status = ScanStatus.processing;
    notifyListeners();

    try {
      final result = await _repository.validateTicket(code);
      _status = ScanStatus.success;
      _lastResult = result;
      _message = result['message'] ?? 'Ticket Validated';
      
      // Add to local history temporarily if not fetched from server
      _scanHistory.insert(0, {
        'timestamp': DateTime.now().toIso8601String(),
        'status': 'valid',
        'details': result,
      });
      
    } catch (e) {
      _status = ScanStatus.error;
      _message = e.toString().replaceAll('Exception: ', '');
      _lastResult = null;
    } finally {
      notifyListeners();
    }
  }

  /// Reset scanner state
  void resetScanner() {
    _status = ScanStatus.idle;
    _message = null;
    _lastResult = null;
    notifyListeners();
  }

  /// Fetch history
  Future<void> fetchHistory() async {
    try {
      _scanHistory = await _repository.getScanHistory();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching history: $e');
    }
  }
}
