import 'package:shared_preferences/shared_preferences.dart';

abstract class TokenStorage {
  Future<void> saveAccessToken(String token);
  Future<String?> getAccessToken();
  Future<void> clearAccessToken();

  Future<void> saveRefreshToken(String token);
  Future<String?> getRefreshToken();
  Future<void> clearRefreshToken();

  Future<void> saveBackgroundedAt(String value);
  Future<String?> getBackgroundedAt();
  Future<void> clearBackgroundedAt();

  Future<void> clearAll();
}

class SharedPrefsTokenStorage implements TokenStorage {
  static const _accessKey = 'fixi_access_token';
  static const _refreshKey = 'fixi_refresh_token';
  static const _backgroundedAtKey = 'fixi_backgrounded_at';

  @override
  Future<void> saveAccessToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessKey, token);
  }

  @override
  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_accessKey);
    if (value == null) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  @override
  Future<void> clearAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessKey);
  }

  @override
  Future<void> saveRefreshToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_refreshKey, token);
  }

  @override
  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_refreshKey);
    if (value == null) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  @override
  Future<void> clearRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_refreshKey);
  }

  @override
  Future<void> saveBackgroundedAt(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_backgroundedAtKey, value);
  }

  @override
  Future<String?> getBackgroundedAt() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_backgroundedAtKey);
    if (value == null) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  @override
  Future<void> clearBackgroundedAt() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_backgroundedAtKey);
  }

  @override
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessKey);
    await prefs.remove(_refreshKey);
    await prefs.remove(_backgroundedAtKey);
  }
}
