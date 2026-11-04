import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Secure token & session storage helper
/// Uses FlutterSecureStorage with SharedPreferences fallback for maximum platform compatibility
class TokenStorage {
  static const String _keyToken = 'auth_jwt_token';
  static const String _keyRefreshToken = 'auth_refresh_token';
  static const String _keyUserData = 'auth_user_data';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  /// Save JWT access token
  Future<void> saveToken(String token) async {
    try {
      await _secureStorage.write(key: _keyToken, value: token);
    } catch (_) {
      // Fallback to shared preferences if secure storage is unavailable
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyToken, token);
    }
  }

  /// Retrieve JWT access token
  Future<String?> getToken() async {
    try {
      final token = await _secureStorage.read(key: _keyToken);
      if (token != null && token.isNotEmpty) return token;
    } catch (_) {}

    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  /// Save refresh token if provided
  Future<void> saveRefreshToken(String refreshToken) async {
    try {
      await _secureStorage.write(key: _keyRefreshToken, value: refreshToken);
    } catch (_) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyRefreshToken, refreshToken);
    }
  }

  /// Retrieve refresh token
  Future<String?> getRefreshToken() async {
    try {
      final token = await _secureStorage.read(key: _keyRefreshToken);
      if (token != null && token.isNotEmpty) return token;
    } catch (_) {}

    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyRefreshToken);
  }

  /// Save user profile data
  Future<void> saveUser(Map<String, dynamic> user) async {
    final userJson = jsonEncode(user);
    try {
      await _secureStorage.write(key: _keyUserData, value: userJson);
    } catch (_) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyUserData, userJson);
    }
  }

  /// Retrieve stored user profile data
  Future<Map<String, dynamic>?> getUser() async {
    String? raw;
    try {
      raw = await _secureStorage.read(key: _keyUserData);
    } catch (_) {}

    if (raw == null || raw.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      raw = prefs.getString(_keyUserData);
    }

    if (raw != null && raw.isNotEmpty) {
      try {
        return jsonDecode(raw) as Map<String, dynamic>;
      } catch (_) {}
    }
    return null;
  }

  /// Check if an active token exists
  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Clear all stored authentication data (logout)
  Future<void> clear() async {
    try {
      await _secureStorage.deleteAll();
    } catch (_) {}

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyRefreshToken);
    await prefs.remove(_keyUserData);
  }
}

