import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/event_model.dart';
import '../models/ticket_model.dart';

/// Local storage service for persisting data
class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  SharedPreferences? _prefs;
  final _secureStorage = const FlutterSecureStorage();

  /// Initialize storage
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Get SharedPreferences instance
  SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception('StorageService not initialized. Call init() first.');
    }
    return _prefs!;
  }

  // ===== String Operations =====
  
  Future<bool> setString(String key, String value) async {
    return await prefs.setString(key, value);
  }

  String? getString(String key) {
    return prefs.getString(key);
  }

  // ===== Int Operations =====
  
  Future<bool> setInt(String key, int value) async {
    return await prefs.setInt(key, value);
  }

  int? getInt(String key) {
    return prefs.getInt(key);
  }

  // ===== Bool Operations =====
  
  Future<bool> setBool(String key, bool value) async {
    return await prefs.setBool(key, value);
  }

  bool? getBool(String key) {
    return prefs.getBool(key);
  }

  // ===== Double Operations =====
  
  Future<bool> setDouble(String key, double value) async {
    return await prefs.setDouble(key, value);
  }

  double? getDouble(String key) {
    return prefs.getDouble(key);
  }

  // ===== List Operations =====
  
  Future<bool> setStringList(String key, List<String> value) async {
    return await prefs.setStringList(key, value);
  }

  List<String>? getStringList(String key) {
    return prefs.getStringList(key);
  }

  // ===== Secure Storage Operations (for sensitive data like tokens) =====
  
  Future<void> setSecureString(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
  }

  Future<String?> getSecureString(String key) async {
    return await _secureStorage.read(key: key);
  }

  Future<void> deleteSecureString(String key) async {
    await _secureStorage.delete(key: key);
  }

  Future<void> deleteAllSecure() async {
    await _secureStorage.deleteAll();
  }

  // ===== Remove Operations =====
  
  Future<bool> remove(String key) async {
    return await prefs.remove(key);
  }

  Future<bool> clear() async {
    return await prefs.clear();
  }

  /// Check if key exists
  bool containsKey(String key) {
    return prefs.containsKey(key);
  }

  /// Get all keys
  Set<String> getKeys() {
    return prefs.getKeys();
  }

  // ===== Convenience Methods for Auth =====
  
  Future<void> saveAuthToken(String token) async {
    await setSecureString('auth_token', token);
  }

  Future<String?> getAuthToken() async {
    return await getSecureString('auth_token');
  }

  Future<void> saveRefreshToken(String token) async {
    await setSecureString('refresh_token', token);
  }

  Future<String?> getRefreshToken() async {
    return await getSecureString('refresh_token');
  }

  Future<void> clearAuthTokens() async {
    await deleteSecureString('auth_token');
    await deleteSecureString('refresh_token');
  }

  /// Save user data
  Future<void> saveUserData({
    required String userId,
    required String email,
    required String name,
    required String role,
  }) async {
    await setString('user_id', userId);
    await setString('user_email', email);
    await setString('user_name', name);
    await setString('user_role', role);
    await setBool('is_logged_in', true);
  }

  /// Get user ID
  String? getUserId() {
    return getString('user_id');
  }

  /// Get user email
  String? getUserEmail() {
    return getString('user_email');
  }

  /// Get user name
  String? getUserName() {
    return getString('user_name');
  }

  /// Get user role
  String? getUserRole() {
    return getString('user_role');
  }

  /// Check if user is logged in
  bool isLoggedIn() {
    return getBool('is_logged_in') ?? false;
  }

  /// Clear all user data
  Future<void> clearUserData() async {
    await remove('user_id');
    await remove('user_email');
    await remove('user_name');
    await remove('user_role');
    await setBool('is_logged_in', false);
    await clearAuthTokens();
  }

  // ===== Caching Methods =====

  /// Save list of events
  Future<void> saveEvents(List<EventModel> events) async {
    try {
      final String jsonString = jsonEncode(events.map((e) => e.toJson()).toList());
      await setString('cached_events', jsonString);
    } catch (e) {
      print('Error saving events to cache: $e');
    }
  }

  /// Get cached events
  List<EventModel>? getCachedEvents() {
    final String? jsonString = getString('cached_events');
    if (jsonString == null) return null;
    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((e) => EventModel.fromJson(e)).toList();
    } catch (e) {
      print('Error parsing cached events: $e');
      return null;
    }
  }

  /// Save list of tickets
  Future<void> saveMyTickets(List<TicketModel> tickets) async {
    try {
      final String jsonString = jsonEncode(tickets.map((t) => t.toJson()).toList());
      await setString('cached_tickets', jsonString);
    } catch (e) {
      print('Error saving tickets to cache: $e');
    }
  }

  /// Get cached tickets
  List<TicketModel>? getCachedTickets() {
    final String? jsonString = getString('cached_tickets');
    if (jsonString == null) return null;
    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      // Assuming TicketModel has fromJson
      return jsonList.map((e) => TicketModel.fromJson(e)).toList();
    } catch (e) {
      print('Error parsing cached tickets: $e');
      return null;
    }
  }
}
