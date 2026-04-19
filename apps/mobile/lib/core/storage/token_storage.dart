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

  Future<SharedPreferences> get _prefs async => SharedPreferences.getInstance();

  Future<String?> _readTrimmed(String key) async {
    final value = (await _prefs).getString(key);
    if (value == null) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  Future<void> _write(String key, String value) async {
    await (await _prefs).setString(key, value);
  }

  Future<void> _remove(String key) async {
    await (await _prefs).remove(key);
  }

  @override
  Future<void> saveAccessToken(String token) => _write(_accessKey, token);

  @override
  Future<String?> getAccessToken() => _readTrimmed(_accessKey);

  @override
  Future<void> clearAccessToken() => _remove(_accessKey);

  @override
  Future<void> saveRefreshToken(String token) => _write(_refreshKey, token);

  @override
  Future<String?> getRefreshToken() => _readTrimmed(_refreshKey);

  @override
  Future<void> clearRefreshToken() => _remove(_refreshKey);

  @override
  Future<void> saveBackgroundedAt(String value) => _write(_backgroundedAtKey, value);

  @override
  Future<String?> getBackgroundedAt() => _readTrimmed(_backgroundedAtKey);

  @override
  Future<void> clearBackgroundedAt() => _remove(_backgroundedAtKey);

  @override
  Future<void> clearAll() async {
    await _remove(_accessKey);
    await _remove(_refreshKey);
    await _remove(_backgroundedAtKey);
  }
}
