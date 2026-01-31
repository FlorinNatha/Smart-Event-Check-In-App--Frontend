/// Application constants
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Smart Event Check-in';
  static const String appVersion = '1.0.0';
  
  // Storage Keys
  static const String keyAuthToken = 'auth_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUserId = 'user_id';
  static const String keyUserRole = 'user_role';
  static const String keyUserEmail = 'user_email';
  static const String keyUserName = 'user_name';
  static const String keyIsLoggedIn = 'is_logged_in';
  static const String keyThemeMode = 'theme_mode';
  
  // User Roles
  static const String roleAttendee = 'attendee';
  static const String roleStaff = 'staff';
  static const String roleAdmin = 'admin';
  
  // Event Status
  static const String eventStatusUpcoming = 'upcoming';
  static const String eventStatusOngoing = 'ongoing';
  static const String eventStatusCompleted = 'completed';
  static const String eventStatusCancelled = 'cancelled';
  
  // Ticket Status
  static const String ticketStatusActive = 'active';
  static const String ticketStatusCheckedIn = 'checked_in';
  static const String ticketStatusExpired = 'expired';
  static const String ticketStatusCancelled = 'cancelled';
  
  // Validation Messages
  static const String msgEmailRequired = 'Email is required';
  static const String msgEmailInvalid = 'Please enter a valid email';
  static const String msgPasswordRequired = 'Password is required';
  static const String msgPasswordTooShort = 'Password must be at least 6 characters';
  static const String msgNameRequired = 'Name is required';
  static const String msgFieldRequired = 'This field is required';
  
  // Error Messages
  static const String msgNetworkError = 'Network error. Please check your connection.';
  static const String msgServerError = 'Server error. Please try again later.';
  static const String msgUnauthorized = 'Unauthorized. Please login again.';
  static const String msgNotFound = 'Resource not found.';
  static const String msgUnknownError = 'An unknown error occurred.';
  
  // Success Messages
  static const String msgLoginSuccess = 'Login successful!';
  static const String msgRegisterSuccess = 'Registration successful!';
  static const String msgEventCreated = 'Event created successfully!';
  static const String msgEventUpdated = 'Event updated successfully!';
  static const String msgEventDeleted = 'Event deleted successfully!';
  static const String msgRegistrationSuccess = 'Registered for event successfully!';
  static const String msgCheckInSuccess = 'Check-in successful!';
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // QR Code
  static const double qrCodeSize = 280.0;
  static const int qrCodeVersion = 5;
  static const int qrCodeErrorCorrectLevel = 0; // Low
  
  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);
  
  // Debounce
  static const Duration searchDebounce = Duration(milliseconds: 500);
  
  // Date Formats
  static const String dateFormat = 'MMM dd, yyyy';
  static const String timeFormat = 'hh:mm a';
  static const String dateTimeFormat = 'MMM dd, yyyy • hh:mm a';
  static const String fullDateTimeFormat = 'EEEE, MMMM dd, yyyy • hh:mm a';
}
