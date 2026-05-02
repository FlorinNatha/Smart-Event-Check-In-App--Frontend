import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:device_info_plus/device_info_plus.dart';

/// API configuration constants
class ApiConstants {
  ApiConstants._();

  // Base URL - initialized in main.dart
  static String _baseUrl = 'http://localhost:3000/api';

  static String get baseUrl => _baseUrl;

  // Initialize base URL based on device type (call in main.dart)
  static Future<void> initializeBaseUrl() async {
    try {
      if (kIsWeb) {
        _baseUrl = 'http://localhost:3000/api';
        return;
      }

      if (Platform.isAndroid) {
        final deviceInfo = DeviceInfoPlugin();
        final androidInfo = await deviceInfo.androidInfo;

        // Check if running on emulator or physical device
        bool isEmulator = !androidInfo.isPhysicalDevice;

        if (isEmulator) {
          _baseUrl = 'http://10.0.2.2:3000/api'; // Android emulator
        } else {
          _baseUrl = 'http://192.168.143.34:3000/api'; // Physical Android phone
        }
      } else if (Platform.isIOS) {
        final deviceInfo = DeviceInfoPlugin();
        final iosInfo = await deviceInfo.iosInfo;

        // For iOS, use localhost for simulator, IP for physical
        if (iosInfo.isPhysicalDevice) {
          _baseUrl = 'http://192.168.143.34:3000/api';
        } else {
          _baseUrl = 'http://localhost:3000/api';
        }
      } else {
        _baseUrl = 'http://localhost:3000/api';
      }

      debugPrint('✅ API Base URL initialized: $_baseUrl');
    } catch (e) {
      debugPrint('❌ Error initializing API base URL: $e');
      _baseUrl = 'http://localhost:3000/api';
    }
  }

  // API Endpoints
  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';

  // Events
  static const String events = '/events';
  static String eventById(String id) => '/events/$id';
  static String registerForEvent(String id) => '/events/$id/register';
  static String eventRegistrations(String id) => '/events/$id/registrations';
  static String eventAttendance(String id) => '/events/$id/attendance';
  static String exportAttendance(String id) => '/events/$id/export';

  // Tickets
  static const String myTickets = '/registrations/my-tickets';
  static String ticketById(String id) => '/registrations/$id';
  static const String validateTicket = '/tickets/validate';

  // User
  static const String profile = '/user/profile';
  static const String updateProfile = '/user/profile';

  // Scan
  static const String scanHistory = '/scan/history';
  static const String scanTicket = '/scan/validate';

  // Admin
  // Admin - utilizing the main events endpoints as they are protected now
  static const String createEvent = '/events';
  static String updateEvent(String id) => '/events/$id';
  static String deleteEvent(String id) => '/events/$id';
  static const String analytics = '/events/admin/stats';
  static const String allRegistrations = '/events/admin/registrations';

  // Timeout
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
