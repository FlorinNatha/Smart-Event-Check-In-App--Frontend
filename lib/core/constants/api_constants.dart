/// API configuration constants
class ApiConstants {
  ApiConstants._();

  // Base URL - Update this with your actual backend URL
  static const String baseUrl = 'http://localhost:3000/api';
  
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
  static const String myTickets = '/tickets/my-tickets';
  static String ticketById(String id) => '/tickets/$id';
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
