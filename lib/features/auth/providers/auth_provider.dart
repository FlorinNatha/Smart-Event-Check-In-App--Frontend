import 'package:flutter/foundation.dart';
import '../../../data/models/user_model.dart';
import '../../../data/services/api_service.dart';
import '../../../data/services/storage_service.dart';
import '../../../core/constants/api_constants.dart';

/// Authentication provider
class AuthProvider with ChangeNotifier {
  final _apiService = ApiService();
  final _storage = StorageService();

  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  /// Initialize auth state
  Future<void> init() async {
    try {
      final isLoggedIn = _storage.isLoggedIn();
      if (isLoggedIn) {
        final userId = _storage.getUserId();
        final email = _storage.getUserEmail();
        final name = _storage.getUserName();
        final role = _storage.getUserRole();

        if (userId != null && email != null && name != null && role != null) {
          _user = UserModel(
            id: userId,
            email: email,
            name: name,
            role: role,
            createdAt: DateTime.now(),
          );
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error initializing auth: $e');
    }
  }

  /// Login
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint('🔑 AuthProvider: Attempting login for $email');
      _setLoading(true);
      _error = null;

      final response = await _apiService.post(
        ApiConstants.login,
        body: {
          'email': email,
          'password': password,
        },
        includeAuth: false,
      );
      debugPrint('✅ AuthProvider: Login Response: $response');

      if (response != null) {
        final token = response['token'];
        final refreshToken = response['refreshToken'];
        final userData = response['user'];

        // Save tokens
        await _storage.saveAuthToken(token);
        if (refreshToken != null) {
          await _storage.saveRefreshToken(refreshToken);
        }

        // Save user data
        _user = UserModel.fromJson(userData);
        await _storage.saveUserData(
          userId: _user!.id,
          email: _user!.email,
          name: _user!.name,
          role: _user!.role,
        );

        _setLoading(false);
        return true;
      }

      _setLoading(false);
      return false;
    } on ApiException catch (e) {
      _error = e.message;
      _setLoading(false);
      return false;
    } catch (e) {
      _error = 'An error occurred during login';
      _setLoading(false);
      return false;
    }
  }

  /// Register
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      debugPrint('📝 AuthProvider: Attempting register for $email');
      _setLoading(true);
      _error = null;

      final response = await _apiService.post(
        ApiConstants.register,
        body: {
          'name': name,
          'email': email,
          'password': password,
          'role': role,
        },
        includeAuth: false,
      );
      debugPrint('✅ AuthProvider: Register Response: $response');

      if (response != null) {
        final token = response['token'];
        final refreshToken = response['refreshToken'];
        final userData = response['user'];

        // Save tokens
        await _storage.saveAuthToken(token);
        if (refreshToken != null) {
          await _storage.saveRefreshToken(refreshToken);
        }

        // Save user data
        _user = UserModel.fromJson(userData);
        await _storage.saveUserData(
          userId: _user!.id,
          email: _user!.email,
          name: _user!.name,
          role: _user!.role,
        );

        _setLoading(false);
        return true;
      }

      _setLoading(false);
      return false;
    } on ApiException catch (e) {
      _error = e.message;
      _setLoading(false);
      return false;
    } catch (e) {
      _error = 'An error occurred during registration';
      _setLoading(false);
      return false;
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      // Call logout API (optional)
      try {
        await _apiService.post(ApiConstants.logout);
      } catch (e) {
        // Ignore API errors during logout
        debugPrint('Logout API error: $e');
      }

      // Clear local data
      await _storage.clearUserData();
      _user = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Error during logout: $e');
    }
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Set loading state
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
